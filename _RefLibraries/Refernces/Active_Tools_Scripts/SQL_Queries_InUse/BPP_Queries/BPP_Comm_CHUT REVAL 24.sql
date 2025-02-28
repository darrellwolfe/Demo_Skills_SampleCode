-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/


DECLARE @Year INT = 2023;  -- Change this value to 2022 or 2024 as desired


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

CTE_Memos_CHUT_RY24 AS (
----------------------------------------
-- Instead of Concat, use STRING_AGG to keep all memos on one row
----------------------------------------
SELECT DISTINCT
    m1.lrsn,
    STRING_AGG(CAST(m1.memo_text AS VARCHAR(MAX)), ', ') AS [CHUT_RY24]
FROM memos AS m1

WHERE m1.memo_id IN ('CHI')
  AND m1.memo_line_number <> 1
  AND m1.memo_text LIKE '%RY24%'
  
GROUP BY m1.lrsn

),


CTE_InspectionDates AS (

SELECT
    e.lrsn,
    e.data_source_code,
    e.data_collector,
    e.collection_date
    -- pm.EffStatus

FROM extensions AS e

WHERE e.extension = 'L00'
    AND (e.collection_date >= {ts '2023-04-16 00:00:00'}
    AND e.collection_date < {ts '2024-04-15 00:00:01'})

),

CTE_AppraisalDates AS(

SELECT
    e.lrsn,
    e.data_source_code,
    e.appraiser,
    e.appraisal_date
    
FROM extensions AS e

WHERE e.extension = 'L00'
    AND (e.collection_date >= {ts '2023-04-16 00:00:00'}
    AND e.collection_date < {ts '2024-04-15 00:00:01'})

),

CTE_CertValues AS (
SELECT 
    v.lrsn,
    --Assessed Values
    v.land_assess AS [Assessed_Land],
    v.imp_assess AS [Assessed_Imp],
    (v.imp_assess + v.land_assess) AS [Assessed_Total_Value],
    v.eff_year AS [Tax_Year],
    v.land_market_val AS [Cert_Land],
    v.imp_val AS [Cert_Imp],
    (v.imp_val + v.land_market_val) AS [Cert_Total_Value],
    v.valuation_comment AS [Val_Comment],
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    
FROM valuation AS v
WHERE v.eff_year BETWEEN (@Year * 10000 + 101) AND (@Year * 10000 + 1231)  -- Calculating start and end dates of the year
AND v.status = 'A'

)


SELECT 
  pm1.lrsn,
  pm1.PIN,
  pm1.AIN,
  m3.CHUT_RY24, -- Main Item Reporting
  cl.data_collector,
  cl.collection_date,
  ap.appraiser,
  ap.appraisal_date,
  pm1.ClassCD,
  pm1.GEO,
  pm1.GEO_Name,
  pm1.TAG,
  pm1.Owner,
  pm1.SitusAddress,
  pm1.SitusCity,
  pm1.Improvement_Status,
  pm1.CostingMethod,
  pm1.WorkValue_Impv,
  pm1.WorkValue_Total,
  cv.Cert_Imp,
  cv.Cert_Total_Value,
  (pm1.WorkValue_Total - cv.Cert_Total_Value) AS DifferenceNewValue,
  m1.MemoText_CHUT,
  m2.MemoText_Imp_Land

FROM CTE_Memos_CHUT AS m1 
LEFT JOIN CTE_PARCELMASTER AS pm1 ON m1.lrsn=pm1.lrsn
LEFT JOIN CTE_CertValues AS cv ON cv.lrsn=pm1.lrsn
LEFT JOIN CTE_Memos_Imp_Land AS m2 ON m2.lrsn=m1.lrsn
LEFT JOIN CTE_Memos_CHUT_RY24 AS m3 ON m3.lrsn=m1.lrsn
  -- Example: RY24-ARDW-08/23
LEFT JOIN CTE_InspectionDates AS cl ON cl.lrsn=m1.lrsn
LEFT JOIN CTE_AppraisalDates AS ap ON ap.lrsn=m1.lrsn
