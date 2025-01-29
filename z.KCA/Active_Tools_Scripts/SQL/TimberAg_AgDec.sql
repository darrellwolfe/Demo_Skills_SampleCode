-- !preview conn=con
-- treat LH and LD as CTEs and join them after the fact

SELECT DISTINCT
  TRIM(parcel.pin) AS [PIN],
  TRIM(parcel.AIN) AS [AIN],
  parcel.DisplayName AS [Owner Name],  
  parcel.MailingAddress AS [Mailing Address],
  parcel.MailingCity AS [Mailing City],
  parcel.MailingState AS [Mailing State],
  parcel.MailingZip5Char AS [Mailing ZIP],  
  parcel.TotalAcres AS [Total Parcel Acres],  
  ld.LDAcres AS [AGDEC Acres]

FROM TSBv_PARCELMASTER AS parcel
JOIN LandHeader AS lh ON parcel.lrsn = lh.RevObjId
JOIN LandDetail AS ld ON lh.Id = ld.LandHeaderId

WHERE lh.LandModelId = '702023'
AND ld.PostingSource = 'A'
AND ld.EffStatus = 'A'
AND parcel.EffStatus = 'A'
AND ld.SoilIdent IN ('AGDEC')

ORDER BY
  PIN,
  parcel.DisplayName
;