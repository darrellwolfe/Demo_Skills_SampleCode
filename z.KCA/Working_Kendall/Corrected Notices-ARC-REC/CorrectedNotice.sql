SELECT DISTINCT
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
CONCAT(LTRIM(RTRIM(parcel.ain)),',') AS [AIN_LookUp],
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
m.memo_id,
m.memo_text

FROM TSBv_PARCELMASTER AS parcel
JOIN memos as m ON parcel.lrsn=m.lrsn

WHERE m.memo_id = 'AR'
AND m.memo_text LIKE '%-06/23 corrected notice%'

GROUP BY
parcel.lrsn,
parcel.ain,
parcel.pin,
parcel.neighborhood,
parcel.SitusAddress,
parcel.SitusCity,
m.memo_id,
m.memo_text
