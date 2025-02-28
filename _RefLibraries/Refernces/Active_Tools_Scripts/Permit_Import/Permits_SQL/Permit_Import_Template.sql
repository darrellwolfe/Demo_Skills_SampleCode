
/*
AsTxDBProd
GRM_Main
*/
-- Re-Import;

SELECT
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
LTRIM(RTRIM(parcel.neighborhood)) AS [GEO],
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
'' AS permit_ref,
'' AS cost_estimate,
'' AS sq_ft,
'' AS filing_date,
'' AS callback,
'' AS inactivedate,
'' AS cert_for_occ,
'' AS permit_desc,
'' AS permit_type,
'' AS permit_source,
'' AS phone_number,
'' AS permit_char3,
'A' AS status_code,
'' AS permit_char20b,
'0' AS permit_int2,
'0' AS permit_int3,
'0' AS permit_int4,
'' AS permservice,
'' AS permit_fee

FROM KCv_PARCELMASTER1 AS parcel


WHERE parcel.EffStatus= 'A' 










