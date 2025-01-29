/*
AsTxDBProd
GRM_Main
*/

SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
v.last_update,
v.change_reason,
v.valuation_comment,
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
LTRIM(RTRIM(parcel.TAG)) AS [TAG], 
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity]

FROM KCv_PARCELMASTER1 AS parcel
JOIN valuation AS v ON parcel.lrsn=v.lrsn


WHERE parcel.EffStatus= 'A'
AND v.eff_year='20230101'
    AND v.last_update > '2023-05-08' 
-- Whatever date the final cadaster was built
    -- AND v.last_update BETWEEN '2023-05-15' AND '2023-07-01'

ORDER BY parcel.neighborhood, parcel.pin;











