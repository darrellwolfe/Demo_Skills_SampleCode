-- !preview conn=con

SELECT DISTINCT
  t.lrsn,
  t.AdjustedSalePrice AS [SalePrice],
  CAST(t.pxfer_date AS DATE) AS [SaleDate],
  TRIM(t.SaleDesc) AS [SaleDescr],
  TRIM(t.TfrType) AS [TranxType],
  TRIM(t.DocNum) AS [DocNum], -- Multiples will have the same DocNum
  parcel.neighborhood AS [GEO],
  LTRIM(RTRIM(parcel.pin)) AS [PIN],
  LTRIM(RTRIM(parcel.ain)) AS [AIN],
  LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
  TRIM(parcel.SitusCity) AS [SitusCity],
  t.GrantorName,
  t.GranteeName,
  t.deed_type

FROM transfer AS t 
LEFT JOIN TSBv_PARCELMASTER AS parcel 
  ON parcel.lrsn = t.lrsn


WHERE t.AdjustedSalePrice <> '0'
AND t.TfrType = 'M'
AND t.pxfer_date > '2022-01-01'

ORDER BY SaleDate, DocNum, GEO, PIN

;