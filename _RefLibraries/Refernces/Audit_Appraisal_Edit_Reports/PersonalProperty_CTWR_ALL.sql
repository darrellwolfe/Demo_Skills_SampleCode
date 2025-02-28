-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/


DECLARE @Year INT = 2024;  -- Change this value to 2022 or 2024 as desired


WITH 

CTE_CTWRs_ALL AS (
  --------------------------------
  --ParcelMaster CTWRs
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
  AND pm.neighborhood = 450

    
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

CTE_MemosCTWR AS (
----------------------------------------
-- Instead of Concat, use STRING_AGG to keep all memos on one row
----------------------------------------
SELECT DISTINCT
    m1.lrsn,
    STRING_AGG(CAST(m1.memo_text AS VARCHAR(MAX)), ', ') AS [MemoText_Cell]
FROM memos AS m1

WHERE m1.memo_id IN ('CELL') 
--WHERE m1.memo_id IN ('CELL','LAND','IMP') 
AND m1.memo_line_number <> 1

GROUP BY m1.lrsn

),

CTE_Memos_Imp_Land AS (
----------------------------------------
-- Instead of Concat, use STRING_AGG to keep all memos on one row
----------------------------------------
SELECT DISTINCT
    m1.lrsn,
    STRING_AGG(CAST(m1.memo_text AS VARCHAR(MAX)), ', ') AS [MemoText_ImpLand]
FROM memos AS m1

--WHERE m1.memo_id IN ('CELL') 
WHERE m1.memo_id IN ('LAND','IMP') 
AND m1.memo_line_number <> 1

GROUP BY m1.lrsn

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
  ctwr.lrsn,
  ctwr.PIN,
  ctwr.AIN,
  ctwr.ClassCD,
  ctwr.GEO,
  ctwr.GEO_Name,
  ctwr.TAG,
  ctwr.Owner,
  ctwr.SitusAddress,
  ctwr.SitusCity,
  ctwr.Improvement_Status,
  ctwr.CostingMethod,
  ctwr.WorkValue_Impv,
  ctwr.WorkValue_Total,
  cv.Cert_Imp,
  cv.Cert_Total_Value,
  (ctwr.WorkValue_Total - cv.Cert_Total_Value) AS DifferenceNewValue,
  m1.MemoText_Cell,
  m2.MemoText_ImpLand

FROM CTE_CTWRs_ALL as ctwr
LEFT JOIN CTE_MemosCTWR AS m1 ON m1.lrsn=ctwr.lrsn
LEFT JOIN CTE_Memos_Imp_Land AS m2 ON m2.lrsn=ctwr.lrsn
LEFT JOIN CTE_CertValues AS cv ON cv.lrsn=ctwr.lrsn















