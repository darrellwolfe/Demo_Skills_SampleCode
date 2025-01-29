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

--FIRST Year of Reval Cycle
DECLARE @TaxYear INT = 2023; 
-- Current Tax Year -- Change this to the current tax year
DECLARE @MemoIDYear1 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@TaxYear AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear2 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@TaxYear+1 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear3 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@TaxYear+2 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear4 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@TaxYear+3 AS VARCHAR(4)), 2) AS VARCHAR(4));
DECLARE @MemoIDYear5 VARCHAR(4) = CAST('RY' + RIGHT(CAST(@TaxYear+4 AS VARCHAR(4)), 2) AS VARCHAR(4));

DECLARE @YearFROM DATE = CAST(CAST(@TaxYear AS VARCHAR) + '-01-01' AS DATE);
DECLARE @YearTO DATE = CAST(CAST(@TaxYear+4 AS VARCHAR) + '-01-01' AS DATE);



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

)





---------------------------------------
-- END CTEs BEGIN QUERY
---------------------------------------

SELECT DISTINCT
rymemo.District
,rymemo.GEO
,rymemo.GEO_Name
,rymemo.lrsn
,rymemo.PIN
,rymemo.AIN

,rymemo.RYYear
,rymemo.RY_Memos
,TRIM(LEFT(rymemo.RY_Memos,4)) AS MemoApsrInitial

--,ap.Appraiser_Appraised
--,ap.AppraisedDate

--,fv.Appraiser_Fielded
--,fv.FieldedDate


/*
,pmd.LegalAcres
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod
,pmd.Improvement_Status 
*/

--FROM CTE_ParcelMaster AS pmd

From CTE_Memos_RY AS rymemo

--Left Join CTE_FieldVisits AS fv
  --On rymemo.lrsn = fv.lrsn

--Left Join CTE_AppraisedParcels AS ap
  --On rymemo.lrsn = ap.lrsn





Order By District,GEO,PIN;



/*

---------------------------------------
--CTE_AppraisedParcels
---------------------------------------
CTE_AppraisedParcels AS (
SELECT
    e.lrsn,
    -- e.extension,
    e.data_source_code,
    e.appraiser AS Appraiser_Appraised,
    e.appraisal_date AS AppraisedDate

FROM extensions AS e

WHERE e.extension = 'L00'
AND e.status = 'A'
--AND e.collection_date BETWEEN '2022-04-16' AND '2027-04-15'
AND e.appraisal_date BETWEEN @YearFROM AND @YearTO

)

---------------------------------------
--CTE_FieldVisits
---------------------------------------
CTE_FieldVisits AS (
SELECT
    e.lrsn,
    -- e.extension,
    e.data_source_code,
    e.data_collector AS Appraiser_Fielded,
    e.collection_date AS FieldedDate

FROM extensions AS e

WHERE e.extension = 'L00'
AND e.status = 'A'
--AND e.collection_date BETWEEN '2022-04-16' AND '2027-04-15'
AND e.collection_date BETWEEN @YearFROM AND @YearTO

)
*/
