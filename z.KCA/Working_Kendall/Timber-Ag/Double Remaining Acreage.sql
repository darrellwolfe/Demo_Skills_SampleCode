-- !preview conn=con

SELECT 
  subquery.PIN,
  subquery.AIN,
  subquery.LandDetailType,
  subquery.RelMktLine,
  subquery.LandType,
  subquery.LDAcres
FROM (

SELECT
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  ld.LandDetailType,
  ld.RelMktLine,
  ld.LandType,
  ld.LDAcres,
  ld.SoilIdent,
  COUNT(p.AIN) OVER(PARTITION BY p.AIN) AS [AIN_Count]
  
FROM TSBv_PARCELMASTER AS p
JOIN LandHeader AS lh ON p.lrsn = lh.RevObjId
JOIN LandDetail AS ld ON lh.Id = ld.LandHeaderId

WHERE p.EffStatus = 'A'
  AND lh.LandModelId = '702023'
  AND lh.PostingSource = 'A'
  AND ld.EffStatus = 'A'
  AND ld.PostingSource = 'A'
  AND ld.LandType = '91'
  AND ld.RelMktLine = '0'

GROUP BY
  p.pin,
  p.AIN,
  ld.LandDetailType,
  ld.RelMktLine,
  ld.LandType,
  ld.LDAcres,
  ld.SoilIdent
) AS subquery
WHERE AIN_Count > 1