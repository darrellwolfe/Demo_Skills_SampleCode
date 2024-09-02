-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

---------
--Select All
---------
Select Distinct *
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

*/

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @CurrentDate DATE = GETDATE();

--FIRST Year of Reval Cycle
DECLARE @FirstYearOfRevalCycle INT = 2023; 
--FIRST ACTUAL FUNCTIONAL Year of Reval Cycle
-- RY23 started 04/16/2022
-- 04/16/2022 -- 04/15/2027
DECLARE @FirstFunctionalYearOfRevalCycle INT = @FirstYearOfRevalCycle-1; 

-- Current Tax Year -- Change this to the current tax year
DECLARE @MemoIDYear1 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear2 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+1 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear3 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+2 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear4 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+3 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear5 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@FirstYearOfRevalCycle+4 AS VARCHAR(4)), 2) AS VARCHAR(4));

DECLARE @FunctionalYearFROM DATE = CAST(CAST(@FirstFunctionalYearOfRevalCycle AS VARCHAR) + '-04-16' AS DATE);
DECLARE @FunctionalYearTO DATE = CAST(CAST(@FirstFunctionalYearOfRevalCycle+5 AS VARCHAR) + '-04-15' AS DATE);

WITH
---------------------------------------
--CTE_Memos_RY
---------------------------------------

CTE_Memos_RY AS (
Select Distinct
CASE
  WHEN pm.neighborhood >= 9000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 6003 THEN 'District_6'
  WHEN pm.neighborhood = 6002 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood = 6001 THEN 'District_6'
  WHEN pm.neighborhood = 6000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 5003 THEN 'District_5'
  WHEN pm.neighborhood = 5002 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood = 5001 THEN 'District_5'
  WHEN pm.neighborhood = 5000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 4000 THEN 'District_4'
  WHEN pm.neighborhood >= 3000 THEN 'District_3'
  WHEN pm.neighborhood >= 2000 THEN 'District_2'
  WHEN pm.neighborhood >= 1021 THEN 'District_1'
  WHEN pm.neighborhood = 1020 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 1001 THEN 'District_1'
  WHEN pm.neighborhood = 1000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 451 THEN 'Commercial'
  WHEN pm.neighborhood = 450 THEN 'Specialized_Cell_Towers'
  WHEN pm.neighborhood >= 1 THEN 'Commercial'
  WHEN pm.neighborhood = 0 THEN 'Other (PP, OP, NA, Error)'
  ELSE NULL
END AS District

-- # District SubClass
,pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
--,m.lrsn AS mlrsn
,m.memo_id AS RYYear
--,m.memo_text AS RY_Memo
,STRING_AGG(CAST(mtext.memo_text AS VARCHAR(MAX)), ', ') AS RY_Memos

,DATEADD(YEAR, CAST(SUBSTRING(m.memo_id, 3, 2) AS INT) - CAST(SUBSTRING(@MemoIDYear1, 3, 2) AS INT), @FunctionalYearFROM) AS CycleStartDate
,DATEADD(YEAR, CAST(SUBSTRING(m.memo_id, 3, 2) AS INT) - CAST(SUBSTRING(@MemoIDYear1, 3, 2) AS INT), DATEADD(DAY, -1, DATEADD(YEAR, 1, @FunctionalYearFROM))) AS CycleEndDate


FROM TSBv_PARCELMASTER AS pm

LEFT JOIN memos AS m
  On m.lrsn=pm.lrsn
  And m.status = 'A'
  And m.memo_line_number = '1'
  And m.memo_id IN (@MemoIDYear1,@MemoIDYear2,@MemoIDYear3,@MemoIDYear4,@MemoIDYear5)

LEFT JOIN memos AS mtext
  On m.lrsn=mtext.lrsn
  And mtext.status = 'A'
  And mtext.memo_line_number <> '1'
  And mtext.memo_id IN (@MemoIDYear1,@MemoIDYear2,@MemoIDYear3,@MemoIDYear4,@MemoIDYear5)

WHERE pm.EffStatus = 'A'
  And (pm.PIN NOT LIKE 'E%'
  And pm.PIN NOT LIKE 'UP%'
  And pm.PIN NOT LIKE 'G00')

GROUP BY
--m.lrsn
pm.lrsn
,pm.pin
,pm.AIN
,m.memo_id
,pm.neighborhood
,pm.NeighborHoodName

),

CTE_FieldVisits AS (
SELECT
    e.lrsn,
    -- e.extension,
    e.data_source_code,
    TRIM(e.data_collector) AS Appraiser_Fielded,
    CAST(e.collection_date AS DATE) AS FieldedDate

FROM extensions AS e

WHERE e.extension = 'L00'
AND e.status = 'A'
--AND e.collection_date BETWEEN '2022-04-16' AND '2027-04-15'
AND e.collection_date BETWEEN @FunctionalYearFROM AND @FunctionalYearTO

),

CTE_AppraisedParcels AS (
SELECT
    e.lrsn,
    -- e.extension,
    e.data_source_code,
    TRIM(e.appraiser) AS Appraiser_Appraised,
    e.appraisal_date AS AppraisedDate

FROM extensions AS e

WHERE e.extension = 'L00'
AND e.status = 'A'
--AND e.collection_date BETWEEN '2022-04-16' AND '2027-04-15'
AND e.appraisal_date BETWEEN @FunctionalYearFROM AND @FunctionalYearTO

),




CTE_Final AS (
---------------------------------------
-- END CTEs BEGIN QUERY
---------------------------------------

SELECT DISTINCT
rymemo.District
,rymemo.GEO
,rymemo.GEO_Name
,rymemo.lrsn
,ROW_NUMBER() OVER (PARTITION BY rymemo.lrsn ORDER BY rymemo.CycleStartDate DESC) AS RowNumber
,rymemo.PIN
,rymemo.AIN

,rymemo.CycleStartDate
,rymemo.CycleEndDate

,CASE

  WHEN TRIM(rymemo.RYYear) IS NULL
    THEN 'NotAssignedRYMemoYet'

  WHEN TRIM(rymemo.RY_Memos) IS NOT NULL
    AND TRIM(rymemo.RYYear) IS NOT NULL
    AND ap.AppraisedDate IS NOT NULL
    AND ap.Appraiser_Appraised IS NOT NULL 
    AND fv.FieldedDate IS NOT NULL
    AND fv.Appraiser_Fielded IS NOT NULL
    THEN 'Complete'
  ELSE 'Check_All_Fields>>'

END AS Reval_Status_Check


,CASE
  WHEN TRIM(rymemo.RYYear) IS NULL
    THEN 'NotAssignedRYMemoYet'

  WHEN fv.FieldedDate IS NOT NULL
    AND fv.Appraiser_Fielded IS NOT NULL
    THEN 'Completed_IR_Fielded'
    
  ELSE 'Check_IR_Fielded>>'
END AS IR_Fielded_Check


,CASE
  WHEN TRIM(rymemo.RYYear) IS NULL
    THEN 'NotAssignedRYMemoYet'

  WHEN ap.AppraisedDate IS NOT NULL
    AND ap.Appraiser_Appraised IS NOT NULL 
    THEN 'Completed_IR_Appraised'
    
  ELSE 'Check_IR_Appraised>>'
END AS IR_Appraised_Check


,CASE
  WHEN TRIM(rymemo.RYYear) IS NULL
    THEN 'NotAssignedRYMemoYet'

  WHEN TRIM(rymemo.RY_Memos) IS NOT NULL
    AND TRIM(rymemo.RYYear) IS NOT NULL
    THEN 'Completed_RY_Memo'

  ELSE 'Check_RY_Memo>>'

END AS RY_Memo_Check


,'Details>>>' AS Details

,UPPER(TRIM(fv.Appraiser_Fielded)) AS Appraiser_Fielded
,fv.FieldedDate

,UPPER(TRIM(ap.Appraiser_Appraised)) AS Appraiser_Appraised
,ap.AppraisedDate

,rymemo.RYYear
,rymemo.RY_Memos
,TRIM(REPLACE(LEFT(rymemo.RY_Memos,4),'-','')) AS MemoApsrInitial


From CTE_Memos_RY AS rymemo

Left Join CTE_FieldVisits AS fv
  On rymemo.lrsn = fv.lrsn
  AND fv.FieldedDate BETWEEN rymemo.CycleStartDate AND rymemo.CycleEndDate

Left Join CTE_AppraisedParcels AS ap
  On rymemo.lrsn = ap.lrsn
  AND ap.AppraisedDate BETWEEN rymemo.CycleStartDate AND rymemo.CycleEndDate

Where GEO <> 0
--Where rymemo.PIN LIKE 'M%'
--Where GEO = 4036
--4030
--4036 is only geo complete in D4 as of 06/06/2024 use for testing query

)

Select 
--revalfinal.*
revalfinal.District
,revalfinal.GEO
,revalfinal.GEO_Name
--,revalfinal.lrsn
,revalfinal.PIN
,revalfinal.AIN

,revalfinal.Reval_Status_Check
,revalfinal.IR_Fielded_Check
,revalfinal.IR_Appraised_Check
,revalfinal.RY_Memo_Check
,revalfinal.Details
,revalfinal.Appraiser_Fielded
,revalfinal.FieldedDate
,revalfinal.Appraiser_Appraised
,revalfinal.AppraisedDate
,revalfinal.RYYear
,revalfinal.RY_Memos
,revalfinal.MemoApsrInitial

,CAST(@CurrentDate AS DATE) AS Today
,revalfinal.CycleStartDate
,revalfinal.CycleEndDate

From CTE_Final AS revalfinal
Where RowNumber = 1
--And Reval_Status_Check <> 'Complete'
And CycleStartDate < @CurrentDate
And CycleEndDate > @CurrentDate


Order By District,GEO,PIN;

