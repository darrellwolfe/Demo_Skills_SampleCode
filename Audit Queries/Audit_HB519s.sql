/*
AsTxDBProd
GRM_Main

Audit pulls only matching records, so looks for only HB519s

*/

SELECT 
parcel.lrsn,
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
parcel.neighborhood AS [GEO],
m.memo_text AS [MEMOS],
i.extension AS [IMP],
p.permit_ref AS [Permit Ref#],
p.permit_desc AS [Permit Description], 
CONVERT(VARCHAR, p.cert_for_occ, 101) AS [Occ Date],
CONVERT(VARCHAR, f.date_completed, 101) AS [Completed Date], 
f.need_to_visit AS [Visit Y_N], 
f.field_person AS [Appraiser]

FROM KCv_PARCELMASTER1 AS parcel
JOIN memos AS m ON (parcel.lrsn=m.lrsn AND m.memo_id = 'B519' AND m.memo_line_number = '1')
LEFT JOIN improvements AS i ON (parcel.lrsn=i.lrsn AND i.status = 'A')
LEFT JOIN permits AS p ON (parcel.lrsn=p.lrsn AND p.status= 'A')
LEFT JOIN field_visit AS f ON (p.lrsn=f.lrsn AND p.field_number=f.field_number)

WHERE parcel.EffStatus= 'A'


ORDER BY parcel.neighborhood, parcel.pin;
