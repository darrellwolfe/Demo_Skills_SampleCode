-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT DISTINCT
  p.ClassCd,
  p.SitusAddress,
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  p.DisplayName,
  p.MailingAddress,
  p.MailingCityStZip,
  p.neighborhood
FROM TSBv_PARCELMASTER AS p

WHERE p.EffStatus = 'A'
  AND p.neighborhood = '28'
  AND p.ClassCd NOT IN ('421','413','525')
;