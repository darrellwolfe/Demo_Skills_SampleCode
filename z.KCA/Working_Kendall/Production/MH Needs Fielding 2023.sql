-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT DISTINCT
  p.lrsn,
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  p.neighborhood,
  e.collection_date,
  e.appraisal_date
  
FROM TSBv_PARCELMASTER AS p
  JOIN extensions as e ON p.lrsn = e.lrsn
    AND e.collection_date IS NULL
      OR e.collection_date < '2022-04-16'
      OR e.appraisal_date IS NULL
      OR e.appraisal_date < '2022-04-16'
    AND e.extension = 'L00'
    AND e.status = 'A'
WHERE p.EffStatus = 'A'
  AND p.neighborhood IN ('9201', '9202', '9203', '9205', '9208', '9209', '9210', '9214', '9217', '9219', '9104', '9111', '9115', '9119', '1000', '1020', '5000', '5002', '6000', '6002', '9100')
  