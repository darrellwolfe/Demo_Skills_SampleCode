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
p.permit_ref,
p.filing_date,
fv.need_to_visit,
fv.field_person,
fv.date_completed,
p.permservice,
t.pxfer_date,
m.memo_text


FROM KCv_PARCELMASTER1 AS parcel
LEFT JOIN memos AS m ON parcel.lrsn=m.lrsn
    AND m.memo_id= 'NC23'
    AND m.memo_line_number > '1'
    AND m.memo_text IS NULL
LEFT JOIN transfer AS t ON parcel.lrsn=t.lrsn
RIGHT JOIN permits AS p ON parcel.lrsn=p.lrsn
    AND p.status='A'
    AND p.permit_type='1'
JOIN field_visit AS fv ON p.lrsn=fv.lrsn AND p.field_number=fv.field_number
    AND fv.date_completed IS NOT NULL

WHERE parcel.EffStatus= 'A'
AND t.pxfer_date >= fv.date_completed

ORDER BY m.memo_text, parcel.neighborhood, parcel.pin
;
