-- !preview conn=con

SELECT
  p.neighborhood AS [GEO],
  p.NeighborHoodName AS [GEO_Name],
  COUNT(p.lrsn) AS [Parcel_Count]
  
FROM TSBv_PARCELMASTER AS p

WHERE p.EffStatus = 'A'
  AND p.neighborhood <> '0'
  AND p.neighborhood IN ('42','9','29','34','40','43','44','45','801','802','803','804','805','806','807','808','809','810','811','812','813','814','815','816','817','818','819','820','821','822','823','824','825','826','827','828','829')

GROUP BY
  p.neighborhood,
  p.NeighborHoodName
  
ORDER BY
  p.neighborhood ASC