-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

CODES TABLE TESTING

*/
SELECT
CASE
  WHEN a.appeal_status = '1' THEN 'Entered'
  WHEN a.appeal_status = '6' THEN 'No Change'
  WHEN a.appeal_status = '7' THEN 'Corrected Notice'
ELSE NULL
END AS [Appeal Outcome],
a.lastupdate,
a.appeal_id AS [Appeal_No],
TRIM(p.AIN) AS [AIN],
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
p.neighborhood AS [GEO],
TRIM(p.pin) AS [PIN],
TRIM(p.DisplayName) AS [Owner]

FROM TSBv_PARCELMASTER AS p
JOIN appeals AS a ON p.lrsn=a.lrsn

WHERE p.EffStatus = 'A'
AND a.year_appealed = '2024'
AND a.det_type = 4
AND a.status = 'A'
AND a.appeal_status IN ('1','6','7')

ORDER BY
a.appeal_status,
a.lastupdate,
a.appeal_id
;