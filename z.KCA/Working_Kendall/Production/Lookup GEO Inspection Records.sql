-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT
  p.neighborhood,
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  e.collection_date,
  e.appraisal_date
  
FROM TSBv_PARCELMASTER AS p
  JOIN extensions AS e ON p.lrsn = e.lrsn
    AND e.status = 'A'
    AND e.extension = 'L00'

WHERE p.EffStatus = 'A'
  AND p.neighborhood IN ('1000')
  
ORDER BY
  e.appraisal_date