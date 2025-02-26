-- !preview conn=con

SELECT
  p.neighborhood AS [GEO],
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN]

FROM TSBv_PARCELMASTER AS p

WHERE p.neighborhood = '0'
  AND p.EffStatus = 'A'
  AND p.pin NOT LIKE 'E%'
  AND p.pin NOT LIKE 'U%'
  AND p.pin NOT LIKE 'G%'
  
ORDER BY p.pin
  