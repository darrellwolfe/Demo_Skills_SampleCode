UPDATE permits
SET status = 'I'
FROM KCv_PARCELMASTER1 AS parcel
JOIN permits ON parcel.lrsn = permits.lrsn
JOIN field_visit AS f ON permits.lrsn = f.lrsn AND permits.field_number = f.field_number
WHERE parcel.EffStatus = 'A'
AND permits.status = 'A'
AND f.date_completed IS NOT NULL
AND f.field_person IS NOT NULL
AND (f.need_to_visit IS NULL OR f.need_to_visit = 'N')
AND (permits.permit_desc NOT LIKE '%HB%' AND permits.permit_desc NOT LIKE '%INC%');
