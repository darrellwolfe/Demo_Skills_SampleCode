-- !preview conn=con

SELECT
TRIM(p.pin) AS [PIN],
TRIM(p.AIN) AS [AIN],
p.neighborhood AS [GEO],
t.pxfer_date


FROM TSBv_PARCELMASTER AS p
  JOIN transfer AS t ON p.lrsn = t.lrsn
  
WHERE t.pxfer_date >= '2023-01-01'