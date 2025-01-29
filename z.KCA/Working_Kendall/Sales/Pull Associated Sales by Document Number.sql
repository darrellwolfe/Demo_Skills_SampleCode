-- !preview conn=con

SELECT DISTINCT
    t.DocNum AS [Document No.],
    LTRIM(RTRIM(parcel.pin)) AS [PIN],
    LTRIM(RTRIM(parcel.ain)) AS [AIN],
    LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
    parcel.neighborhood AS [GEO],
    t.AdjustedSalePrice,
    t.pxfer_date
    
FROM TSBv_PARCELMASTER AS parcel
JOIN transfer AS t ON parcel.lrsn = t.lrsn

WHERE parcel.neighborhood >= '9000'
AND t.pxfer_date >= '2023-01-01'
;