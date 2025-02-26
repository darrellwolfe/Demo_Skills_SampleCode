-- !preview conn=con

SELECT
  p.neighborhood AS [GEO],
  p.NeighborHoodName AS [GEO_Name],
  COUNT(p.lrsn) AS [Parcel_Count]
  
FROM TSBv_PARCELMASTER AS p

WHERE p.EffStatus = 'A'
  AND p.neighborhood <> '0'
  AND p.neighborhood IN ('1','2','3','4','6','7','8','10','12','13','14','18','20','23','24','25','26','28')

GROUP BY
  p.neighborhood,
  p.NeighborHoodName
  
ORDER BY
  p.neighborhood ASC