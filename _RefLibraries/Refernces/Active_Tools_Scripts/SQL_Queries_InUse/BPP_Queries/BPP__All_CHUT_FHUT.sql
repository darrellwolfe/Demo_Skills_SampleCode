-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/


DECLARE @Year INT = 2024;  -- Change this value to 2022 or 2024 as desired


WITH 

CTE_PARCELMASTER AS (
  --------------------------------
  --ParcelMaster pms
  --------------------------------
  Select Distinct
  pm.lrsn
,  LTRIM(RTRIM(pm.pin)) AS [PIN]
,  LTRIM(RTRIM(pm.AIN)) AS [AIN]
,  pm.neighborhood AS [GEO]
,  LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name]
,  LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD]
,  LTRIM(RTRIM(pm.TAG)) AS [TAG]
,  LTRIM(RTRIM(pm.DisplayName)) AS [Owner]
,  LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress]
,  LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity]
,  pm.Improvement_Status
,  pm.WorkValue_Impv
,  pm.WorkValue_Total
,  pm.CostingMethod
  
  From TSBv_PARCELMASTER AS pm
  
  Where pm.EffStatus = 'A'

    
  Group By
  pm.lrsn,
  pm.pin,
  pm.AIN,
  pm.PropClassDescr,
  pm.neighborhood,
  pm.NeighborHoodName,
  pm.TAG,
  pm.DisplayName,
  pm.SitusAddress,
  pm.SitusCity,
  pm.Improvement_Status,
  pm.WorkValue_Impv,
  pm.WorkValue_Total,
  pm.CostingMethod

),

CTE_Memos_CHUT AS (
----------------------------------------
-- Instead of Concat, use STRING_AGG to keep all memos on one row
----------------------------------------
SELECT DISTINCT
    m1.lrsn,
    STRING_AGG(CAST(m1.memo_text AS VARCHAR(MAX)), ', ') AS [MemoText_CHUT]
FROM memos AS m1

--WHERE m1.memo_id IN ('CELL') 
WHERE m1.memo_id IN ('CHI') 
--AND m1.memo_line_number <> 1

GROUP BY m1.lrsn

),

CTE_Memos_Imp_Land AS (
----------------------------------------
-- Instead of Concat, use STRING_AGG to keep all memos on one row
----------------------------------------
SELECT DISTINCT
    m1.lrsn,
    STRING_AGG(CAST(m1.memo_text AS VARCHAR(MAX)), ', ') AS [MemoText_Imp_Land]
FROM memos AS m1

--WHERE m1.memo_id IN ('CELL') 
WHERE m1.memo_id IN ('LAND','IMP') 

GROUP BY m1.lrsn

),

CTE_ImpBasic AS (
----------------------------------
-- View/Master Query: Always e > i > then finally mh, cb, dw
----------------------------------
Select Distinct
--Extensions Table
e.lrsn,
e.extension,
e.ext_description,
i.imp_type,
cu.use_code,
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade AS [GradeCode], -- is this a code that needs a key?
grades.tbl_element_desc AS [GradeType]

--Extensions always comes first
FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M','C','D')
    --need codes to get the grade name, vs just the grade code#
    LEFT JOIN codes_table AS grades 
    ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      And code_status = 'A'
      
--COMMERCIAL      
LEFT JOIN comm_bldg AS cb 
  ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='A'
    LEFT JOIN comm_uses AS cu 
    ON cb.lrsn=cu.lrsn
      AND cb.extension = cu.extension
      AND cu.status='A'

WHERE e.status = 'A'
AND (e.ext_description LIKE '%CHUT%'
  OR e.ext_description LIKE '%FHUT%')
)



SELECT 
pm1.lrsn,
pm1.PIN,
pm1.AIN,

imp.extension,
imp.ext_description,
imp.imp_type,
imp.use_code,
imp.year_built,
imp.eff_year_built,
imp.year_remodeled,
imp.condition,
imp.GradeCode,
imp.GradeType,

pm1.ClassCD,
pm1.GEO,
pm1.GEO_Name,
pm1.TAG,
pm1.Owner,
pm1.SitusAddress,
pm1.SitusCity,
--pm1.WorkValue_Total,
m1.MemoText_CHUT
--m2.MemoText_Imp_Land

FROM CTE_Memos_CHUT AS m1 
LEFT JOIN CTE_PARCELMASTER AS pm1 ON m1.lrsn=pm1.lrsn
LEFT JOIN CTE_Memos_Imp_Land AS m2 ON m2.lrsn=m1.lrsn

LEFT JOIN CTE_ImpBasic AS imp ON imp.lrsn = m1.lrsn










