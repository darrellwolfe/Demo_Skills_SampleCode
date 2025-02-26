-- !preview conn=con
-- treat LH and LD as CTEs and join them after the fact

SELECT DISTINCT
  parcel.lrsn AS [LRSN],
  TRIM(parcel.pin) AS [PIN],
  TRIM(parcel.AIN) AS [AIN],
  ld.LandType AS [Land Type],
  ld.SoilIdent AS [Soil ID],
  ld.LDAcres AS [Grazing Acres],
  parcel.DisplayName AS [Owner Name],
  parcel.MailingAddress AS [Mailing Address],
  parcel.MailingCity AS [Mailing City],
  parcel.MailingState AS [Mailing State],
  parcel.MailingZip5Char

FROM TSBv_PARCELMASTER AS parcel
JOIN LandHeader AS lh ON parcel.lrsn = lh.RevObjId
JOIN LandDetail AS ld ON lh.Id = ld.LandHeaderId

WHERE lh.LandModelId = '702023'
AND ld.PostingSource = 'A'
AND ld.EffStatus = 'A'
AND parcel.EffStatus = 'A'
AND ld.SoilIdent IN ('G1','G2','G3')

ORDER BY
  parcel.DisplayName,
  PIN
;