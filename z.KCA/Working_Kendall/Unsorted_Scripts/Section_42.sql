-- !preview conn=conn

SELECT TRIM(p.AIN)

FROM TSBv_PARCELMASTER AS p

WHERE p.EffStatus = 'A'
  AND p.neighborhood = '42'