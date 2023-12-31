-- !preview conn=con

/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/

WITH
  CTE_ZeroValues AS (
    Select Distinct
    v.lrsn,
    TRIM(pm.pin) AS [PIN],
    TRIM(pm.AIN) AS [AIN],
    pm.neighborhood AS [GEO],
    TRIM(pm.NeighborHoodName) AS [GEO_Name],
    v.land_use_val AS [Land_Certified],
    v.land_assess AS [Land_Assessed],
    pm.WorkValue_Land AS [Land_Worksheet],
    v.imp_val AS [Improvement_Certified],
    v.imp_assess AS [Improvement_Assessed],
    pm.WorkValue_Impv AS [Improvement_Worksheet],
    TRIM(v.valuation_comment) AS [Update_Comment],
    v.last_update,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS ROWNUM,
    TRIM(v.update_user_id) AS [LastUserInitials],
    STRING_AGG(ml.memo_text,'| ') AS [Land_Memos],
    STRING_AGG(mi.memo_text,'| ') AS [Imp_Memos]
  
  From valuation AS v
  JOIN TSBv_PARCELMASTER AS pm ON pm.lrsn = v.lrsn
    AND pm.EffStatus = 'A'
    AND pm.pin NOT LIKE 'E%'
    AND pm.pin NOT LIKE 'M%'
    AND pm.pin NOT LIKE 'G00%'
    AND pm.pin NOT LIKE 'UP%'
  LEFT JOIN memos AS ml ON v.lrsn = ml.lrsn
    AND ml.memo_line_number <> '1'
    AND ml.memo_id = 'LAND'
  LEFT JOIN memos AS mi ON v.lrsn = mi.lrsn
    AND mi.memo_line_number <> '1'
    AND mi.memo_id = 'IMP'
  
  
  Where v.Status='A'
  --Test for zero values all accross the board
  AND v.land_assess = '0'
  AND v.imp_assess = '0'
  AND v.imp_val = '0'
  AND v.land_market_val = '0'
  AND pm.WorkValue_Impv = '0'
  AND pm.WorkValue_Land = '0'
  
  GROUP BY
    v.lrsn,
    pm.pin,
    pm.AIN,
    pm.neighborhood,
    pm.NeighborHoodName,
    v.land_use_val,
    v.land_assess,
    pm.WorkValue_Land,
    v.imp_val,
    v.imp_assess,
    pm.WorkValue_Impv,
    v.valuation_comment,
    v.last_update,
    v.update_user_id

)


SELECT DISTINCT *
FROM CTE_ZeroValues
WHERE ROWNUM = 1
ORDER BY GEO, PIN;

