/*
AsTxDBProd
GRM_Main
*/
-- !preview conn=con

SELECT 
parcel.lrsn,
parcel.pin,
TRIM(parcel.ain) AS [AIN], 
parcel.neighborhood, 
parcel.EffStatus,
p.permit_ref,
p.filing_date,
fv.need_to_visit,
fv.field_person,
fv.date_completed,
p.permservice,
m.memo_text


FROM TSBv_PARCELMASTER AS parcel
LEFT JOIN memos AS m ON parcel.lrsn=m.lrsn
    AND m.memo_id= 'NC23'
    AND m.memo_line_number > '1'
    AND m.memo_text IS NOT NULL
RIGHT JOIN permits AS p ON parcel.lrsn=p.lrsn
    AND p.status='A'
    AND p.permit_type='1'
JOIN field_visit AS fv ON p.lrsn=fv.lrsn AND p.field_number=fv.field_number
    AND fv.date_completed IS NOT NULL
    AND fv.need_to_visit='N'

WHERE parcel.EffStatus= 'A'

ORDER BY m.memo_text, parcel.neighborhood, parcel.pin
;