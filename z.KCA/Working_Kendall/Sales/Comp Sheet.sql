-- !preview conn=con

SELECT DISTINCT
    parcel.lrsn,
    LTRIM(RTRIM(parcel.pin)) AS [PIN],
    LTRIM(RTRIM(parcel.ain)) AS [AIN],
    t.pxfer_date AS [Transfer Date],
    t.AdjustedSalePrice AS [Sales Price],
    parcel.LegalAcres AS [Acres],
    cb.total_area AS [Bldg SF],
    parcel.WorkValue_Land AS [Land Value],
    i.year_built AS [Year Built],
    parcel.WorkValue_Impv AS [Improvement Value],
    LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
    CONCAT(LTRIM(RTRIM(parcel.ain)), ',') AS [AIN_LookUp],
    parcel.neighborhood AS [GEO],
    LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
    parcel.PropClassDescr,
    i.extension

FROM TSBv_PARCELMASTER AS parcel
JOIN transfer AS t ON parcel.lrsn = t.lrsn
AND t.pxfer_date > '2022-01-01'
AND t.AdjustedSalePrice <> '0'
LEFT JOIN comm_bldg AS cb ON parcel.lrsn = cb.lrsn
AND cb.status = 'A'
LEFT JOIN improvements AS i ON parcel.lrsn = i.lrsn
AND i.extension = 'C01'
AND i.status = 'A'

WHERE parcel.neighborhood = '17'

GROUP BY
    parcel.lrsn,
    parcel.pin,
    parcel.ain,
    t.pxfer_date,
    t.AdjustedSalePrice,
    parcel.LegalAcres,
    cb.total_area,
    parcel.neighborhood,
    parcel.SitusAddress,
    parcel.SitusCity,
    parcel.PropClassDescr,
    parcel.WorkValue_Land,
    parcel.WorkValue_Impv,
    i.year_built,
    i.extension