/*
AsTxDBProd
GRM_Main
*/

SELECT 
parcel.lrsn,
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
parcel.neighborhood AS [GEO],
a.group_code AS [Allocation]


FROM KCv_PARCELMASTER1 AS parcel
JOIN allocations AS a ON parcel.lrsn=a.lrsn AND a.status='A'


WHERE parcel.EffStatus= 'A'
AND a.group_code IN ('81','81L')

ORDER BY parcel.neighborhood, parcel.pin;
