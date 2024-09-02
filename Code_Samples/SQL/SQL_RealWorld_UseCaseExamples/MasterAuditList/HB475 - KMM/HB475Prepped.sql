-- !preview conn=conn

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
m.memo_line_number,
STRING_SPLIT(m.memo_text,'-') AS Test
m.memo_text

FROM KCv_PARCELMASTER1 as parcel
JOIN memos as m ON parcel.lrsn=m.lrsn

WHERE parcel.EffStatus= 'A'
AND m.memo_id= 'NC23'
AND m.memo_line_number > '1'

ORDER BY parcel.neighborhood, parcel.pin
;
