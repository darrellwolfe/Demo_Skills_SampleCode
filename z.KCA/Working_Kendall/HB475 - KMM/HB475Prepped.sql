SELECT 
parcel.lrsn,
parcel.pin, 
parcel.ain, 
parcel.neighborhood, 
parcel.EffStatus,
m.memo_line_number,
m.memo_text

FROM KCv_PARCELMASTER1 as parcel
JOIN memos as m ON parcel.lrsn=m.lrsn

WHERE parcel.EffStatus= 'A'
AND m.memo_id= 'NC24'
AND m.memo_line_number = '2'

ORDER BY parcel.neighborhood, parcel.pin
;
