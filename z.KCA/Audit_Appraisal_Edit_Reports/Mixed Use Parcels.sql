SELECT DISTINCT
  p.lrsn AS [LRSN],
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  p.neighborhood AS [GEO],
  p.ClassCd AS [PCC],
  CASE
  WHEN ld.LandType = '9' OR ld.LandType = '90' THEN 'HOMESITE'
  ELSE 'NO HOMESITE'
  END AS [Homesite_Check]

FROM TSBv_PARCELMASTER AS p
  LEFT JOIN LandHeader AS lh ON p.lrsn = lh.RevObjId
    AND lh.EffStatus = 'A'
    AND lh.PostingSource = 'A'
  LEFT JOIN LandDetail AS ld ON lh.Id = ld.LandHeaderId
    AND ld.LandType IN ('9','90')
    AND ld.EffStatus = 'A'
    AND ld.PostingSource = 'A'

WHERE p.classcd = '441'
  AND p.EffStatus = 'A'
  AND lh.LandModelId = '702024'

ORDER BY 
AIN
;