-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT
  p.neighborhood,
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  p.SitusAddress,
  p.SitusCity,
  e.collection_date,
  e.appraisal_date

FROM TSBv_PARCELMASTER AS p
  JOIN extensions AS e ON p.lrsn = e.lrsn
    AND e.status = 'A'
    AND e.extension = 'L00'
    AND (e.collection_date < '2022-04-16'
    AND e.appraisal_date < '2022-04-16')

WHERE p.EffStatus = 'A'
  AND p.neighborhood IN ('1000', '1020', '5000', '5002', '6000', '6002', '9100', '9104', '9111', '9115', '9119', '9201', '9202', '9203', '9205', '9208', '9209', '9210', '9214', '9217', '9219')
  
ORDER BY
  p.SitusCity,
  p.neighborhood,
  p.AIN