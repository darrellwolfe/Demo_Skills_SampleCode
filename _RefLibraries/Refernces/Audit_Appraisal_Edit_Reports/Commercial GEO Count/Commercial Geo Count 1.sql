-- !preview conn=con

SELECT
  p.neighborhood AS [GEO],
  p.NeighborHoodName AS [GEO_Name],
  COUNT(p.lrsn) AS [Parcel_Count]
  
FROM TSBv_PARCELMASTER AS p

WHERE p.EffStatus = 'A'
  AND p.neighborhood <> '0'
  AND p.neighborhood IN ('15','16','17','21','22','27','30','31','32','33','35','36','37','38','39','47','95','101','102','103','104','106','108','109','110')

GROUP BY
  p.neighborhood,
  p.NeighborHoodName
  
ORDER BY
  p.neighborhood ASC