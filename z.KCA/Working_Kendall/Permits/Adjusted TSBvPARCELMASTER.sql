-- !preview conn=con

/*
AsTxDBProd
GRM_Main

TITLE HERE

*/

SELECT
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  TRIM(p.SitusAddress) AS [Situs_Address],
  TRIM(p.SitusCity) AS [Situs_City],
  p.neighborhood AS [GEO],
  p.EffStatus
  
FROM TSBv_PARCELMASTER AS p

WHERE
  p.pin NOT LIKE 'E%' 
  AND p.pin NOT LIKE 'U%'
  AND p.pin NOT LIKE 'G%'
  AND p.EffStatus = 'A'