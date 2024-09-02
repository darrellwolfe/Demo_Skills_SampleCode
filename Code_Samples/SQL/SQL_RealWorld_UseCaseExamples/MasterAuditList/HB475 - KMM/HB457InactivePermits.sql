-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT 
parcel.lrsn,
parcel.pin, 
TRIM(parcel.ain) AS AIN,
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
LEFT JOIN transfer AS t ON parcel.lrsn=t.lrsn
RIGHT JOIN permits AS p ON parcel.lrsn=p.lrsn
    AND p.status='I'
    AND p.permit_type='1'
JOIN field_visit AS fv ON p.lrsn=fv.lrsn AND p.field_number=fv.field_number
    AND fv.date_completed >= '2022-10-01'

WHERE parcel.EffStatus= 'A'
AND m.memo_id <> 'NC22'
AND t.pxfer_date >= fv.date_completed AND t.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'

ORDER BY m.memo_text, parcel.neighborhood, parcel.pin
;