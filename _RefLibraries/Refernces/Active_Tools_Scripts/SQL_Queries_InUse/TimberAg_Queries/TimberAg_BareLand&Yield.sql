-- !preview conn=con

SELECT 
 TRIM(p.AIN) AS [AIN],
 TRIM(p.pin) AS [PIN],
 ld.SoilIdent AS [Soil_ID],
 ld.LandLineNumber,
 ld.LandDetailType,
 ld.PrimaryUse,
 ld.RelMktLine,
 ld.LandType,
 ld.lcm,
 ld.LDAcres,
 ld.SoilIdent,
 ld.SiteRating

FROM TSBv_PARCELMASTER AS p
JOIN LandHeader AS lh ON p.lrsn = lh.RevObjId
JOIN LandDetail AS ld ON lh.Id = ld.LandHeaderId

WHERE ld.SoilIdent LIKE 'Y%'
AND ld.LandDetailType = 'M'
AND p.EffStatus = 'A'
AND lh.PostingSource = 'A'
AND ld.EffStatus = 'A'
AND ld.PostingSource = 'A'
