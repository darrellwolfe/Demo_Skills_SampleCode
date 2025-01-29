SELECT DISTINCT
  p.lrsn AS LRSN,
  TRIM(p.pin) AS PIN,
  TRIM(p.AIN) AS AIN,
  TRIM(p.SitusAddress) AS Situs_Address,
  p.neighborhood AS GEO,
  CASE
    WHEN p.neighborhood >= 9000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 6003 THEN 'District_6'
    WHEN p.neighborhood = 6002 THEN 'Manufactured_Homes'
    WHEN p.neighborhood = 6001 THEN 'District_6'
    WHEN p.neighborhood = 6000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 5003 THEN 'District_5'
    WHEN p.neighborhood = 5002 THEN 'Manufactured_Homes'
    WHEN p.neighborhood = 5001 THEN 'District_5'
    WHEN p.neighborhood = 5000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 4000 THEN 'District_4'
    WHEN p.neighborhood >= 3000 THEN 'District_3'
    WHEN p.neighborhood >= 2000 THEN 'District_2'
    WHEN p.neighborhood >= 1021 THEN 'District_1'
    WHEN p.neighborhood = 1020 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 1001 THEN 'District_1'
    WHEN p.neighborhood = 1000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 451 THEN 'Commercial'
    WHEN p.neighborhood = 450 THEN 'Specialized_Cell_Towers'
    WHEN p.neighborhood >= 1 THEN 'Commercial'
    WHEN p.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS District, 
  fe.future_ext_id AS Extension,
  fe.future_chg_reason AS Future_Change_Reason,
  fe.ext_prop_cls_code AS Future_PCC,
  fe.actv_ext_val AS Active_Improvement_Value,
  fe.future_ext_val AS Future_Improvement_Value,
  CASE
  WHEN fe.future_chg_reason IN ('New Dwellings For Occupancy','NREV/MH For Occupancy') THEN (fe.actv_ext_val+fe.future_ext_val) 
  ELSE NULL
  END AS Promoted_Occupancy_Value
  

FROM TSBv_PARCELMASTER AS p
  JOIN FutureExtensions as fe ON p.lrsn = fe.lrsn
  
WHERE p.EffStatus = 'A'