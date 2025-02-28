DECLARE @CurrentLandModel INT = 702024;

SELECT DISTINCT
  p.lrsn AS [LRSN],
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  ld.LandType AS [Land Type],
  ld.SoilIdent AS [Soil ID],
  ld.LDAcres,
  p.DisplayName AS [Owner Name],
  p.MailingAddress AS [Mailing Address],
  p.MailingCity AS [Mailing City],
  p.MailingState AS [Mailing State],
  p.MailingZip5Char
  
FROM TSBv_PARCELMASTER AS p
JOIN LandHeader AS lh ON p.lrsn = lh.RevObjId
JOIN LandDetail AS ld ON lh.Id = ld.LandHeaderId

WHERE lh.LandModelId = @CurrentLandModel
AND ld.PostingSource = 'A'
AND ld.EffStatus = 'A'
AND p.EffStatus = 'A'
AND ld.SoilIdent IN ('G1','G2','G3')
AND ld.LandType = '52'

ORDER BY
  p.DisplayName,
  PIN