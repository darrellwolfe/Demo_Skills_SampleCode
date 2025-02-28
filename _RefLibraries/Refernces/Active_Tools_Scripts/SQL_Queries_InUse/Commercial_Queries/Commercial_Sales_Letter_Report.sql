-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT DISTINCT
    t.DocNum AS [Document No.],
    t.pxfer_date AS [Transfer Date],
    t.GrantorName,
    t.GranteeName,
    LTRIM(RTRIM(parcel.pin)) AS [PIN],
    LTRIM(RTRIM(parcel.ain)) AS [AIN],
    LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
    parcel.MailingAddress,
    parcel.MailingCityStZip,
    parcel.neighborhood AS [GEO]
    
FROM TSBv_PARCELMASTER AS parcel
JOIN transfer AS t ON parcel.lrsn = t.lrsn

WHERE t.AdjustedSalePrice = '0'
AND t.pxfer_date >= '2023-01-01'
AND t.pxfer_date <= '2023-06-30'
AND parcel.neighborhood < '1000'
AND parcel.neighborhood <> '450'
AND t.GrantorName <> t.GranteeName
;