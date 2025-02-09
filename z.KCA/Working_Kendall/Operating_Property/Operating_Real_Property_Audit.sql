SELECT
  TRIM(p.pin) AS PIN,
  TRIM(p.AIN) AS AIN,
  p.neighborhood AS GEO,
  p.DisplayDescr AS Legal_Descr,
  p.ClassCd AS PCC
  
FROM TSBv_PARCELMASTER AS p

WHERE p.DisplayDescr LIKE '% TCO%'
  AND p.EffStatus = 'A'
  
ORDER BY p.pin