-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT DISTINCT
    LTRIM(RTRIM(parcel.pin)) AS [PIN],
    LTRIM(RTRIM(parcel.ain)) AS [AIN],
    LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
    parcel.DisplayName,
    parcel.ClassCd,
    parcel.MailingAddress,
    parcel.MailingCityStZip,
    parcel.neighborhood AS [GEO]
    
FROM TSBv_PARCELMASTER AS parcel
  JOIN codes_table AS code ON parcel.ClassCd = code.tbl_element
    AND code.tbl_type_code = 'pcc'
    AND code.code_status = 'A'

WHERE parcel.neighborhood IN ('1','2','7','15','16','17')
  AND parcel.EffStatus = 'A'
  AND parcel.SitusAddress IS NOT NULL
  AND (code.tbl_element_desc LIKE '%imp%' 
  OR code.tbl_element_desc LIKE '%condo%' 
  OR code.tbl_element_desc LIKE '%mixed use%')
;