-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT 
parcel.lrsn,
parcel.pin, 
parcel.ain, 
parcel.neighborhood, 
parcel.EffStatus,
m.memo_text

FROM KCv_PARCELMASTER1 AS parcel
LEFT JOIN memos AS m ON parcel.lrsn=m.lrsn

WHERE parcel.EffStatus= 'A'
AND m.memo_id= '6023'
AND m.memo_line_number = '2'

ORDER BY parcel.neighborhood, parcel.pin
;