-- !preview conn=con

SELECT DISTINCT
  p.pin,
  p.AIN,
  p.neighborhood,
  t.pxfer_date,
  t.DocNum,
  t.TfrType

FROM TSBv_PARCELMASTER AS p
  JOIN transfer AS t ON p.lrsn = t.lrsn
  
WHERE p.EffStatus = 'A'
  AND t.pxfer_date > '2022-01-01'
  AND t.TfrType = 'S'
  
ORDER BY t.DocNum
