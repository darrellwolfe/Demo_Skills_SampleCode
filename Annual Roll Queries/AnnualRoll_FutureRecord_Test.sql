/*
AsTxDBProd
GRM_Main

FUTURE RECORD TEST QUERY


*/

SELECT
--IMP MEMO, FILTERED FOR "FUTURE RECORD" 
LTRIM(RTRIM(m.memo_text)) AS [FUTURE_RECORDS],
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
CONCAT(LTRIM(RTRIM(parcel.ain)),',') AS [AIN_LookUp],
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],

--Demographics
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner]
--End SELECT

FROM KCv_PARCELMASTER1 AS parcel
INNER JOIN memos AS m ON parcel.lrsn=m.lrsn AND m.memo_id = 'IMP' AND m.memo_text LIKE '%FUTURE RECORD TEST%'


WHERE parcel.EffStatus= 'A'

ORDER BY [GEO], [PIN];
