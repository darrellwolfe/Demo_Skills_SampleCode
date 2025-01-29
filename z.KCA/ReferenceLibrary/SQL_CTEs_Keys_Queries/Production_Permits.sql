-- !preview conn=conn



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
  AND pm.ClassCD NOT LIKE '070%'
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

CTE_Permits AS (
Select
p.lrsn
, TRIM(p.permit_ref) AS REFERENCENum
, TRIM(p.permit_desc) AS DESCRIPTION
, TRIM(c.tbl_element_desc) AS PERMIT_TYPE
,p.status
, CASE
    WHEN f.field_person IS NOT NULL
      --AND f.need_to_visit = 'N'
      AND p.status = 'I'
      AND f.date_completed IS NOT NULL
      THEN 'Completed'
    WHEN f.field_person IS NULL
      --AND f.need_to_visit = 'N'
      AND p.status = 'I'
      AND f.date_completed IS NULL
      THEN 'Completed_MissingFV'
    ELSE 'Open'
  END AS 'PermitStatus'
, CAST(p.filing_date AS DATE) AS FILING_DATE
, CAST(f.field_out AS DATE) AS WORK_ASSIGNED_DATE

, CAST(f.date_completed AS DATE) AS COMPLETED_DATE
, TRIM(f.field_person) AS APPRAISER
, f.need_to_visit AS NEED_TO_VISIT

,YEAR(f.date_completed) AS Compl_Year
,MONTH(f.date_completed) AS Compl_Month
,DAY(f.date_completed) AS Compl_Day
,DATENAME(MONTH, f.date_completed) AS Compl_MonthName

From permits AS p

--Field Visits
LEFT JOIN field_visit AS f 
  ON p.field_number=f.field_number
  And f.status = 'A'

--Codes Table
LEFT JOIN codes_table AS c 
  ON c.tbl_element=p.permit_type 
  AND c.tbl_type_code= 'permits'
  AND c.code_status= 'A'
  
WHERE p.[status]='A'
  OR (p.[status]='I' 
    AND ((f.date_completed BETWEEN @FunctionalYearFROM AND @FunctionalYearTO
      OR f.date_completed IS NULL)
    AND (f.field_out BETWEEN @FunctionalYearFROM AND @FunctionalYearTO
      OR f.field_out IS NULL)))
--p.filing_date BETWEEN @FunctionalYearFROM AND @FunctionalYearTO

)


Select Distinct 
rymemo.District
,rymemo.GEO
,rymemo.GEO_Name
,rymemo.lrsn
,rymemo.PIN
,rymemo.AIN
,cp.FILING_DATE
,cp.WORK_ASSIGNED_DATE
,cp.COMPLETED_DATE
,UPPER(cp.APPRAISER) AS APPRAISER
,cp.NEED_TO_VISIT
,UPPER(cp.REFERENCENum) AS REFERENCENum
,cp.DESCRIPTION
,cp.PERMIT_TYPE
,cp.status
,cp.PermitStatus
,cp.Compl_Year
,cp.Compl_Month
,cp.Compl_Day
,cp.Compl_MonthName
,rymemo.CycleStartDate
,rymemo.CycleEndDate
,rymemo.RYYear
,rymemo.RY_Memos


From CTE_Memos_RY AS rymemo

Join CTE_Permits AS cp
  On cp.lrsn = rymemo.lrsn
--  And cp.WORK_ASSIGNED_DATE BETWEEN rymemo.CycleStartDate AND rymemo.CycleEndDate

Where cp.WORK_ASSIGNED_DATE IS NOT NULL

Order by District, GEO, PIN;






