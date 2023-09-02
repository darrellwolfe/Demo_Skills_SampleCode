
/*
AsTxDBProd
GRM_Main
*/

SELECT 
parcel.lrsn,
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
parcel.neighborhood AS [GEO],
m.memo_text AS [MEMOS],
a.group_code AS [GroupCode],
a.property_class AS [ClassCode],
a.extension AS [Record],
a.improvement_id AS [ImpId],
CONVERT(VARCHAR, a.last_update, 101) AS [LastUpdate],
i.extension AS [IMP],
p.permit_ref AS [Permit Ref#],
p.permit_desc AS [Permit Description], 
CONVERT(VARCHAR, p.cert_for_occ, 101) AS [Occ Date],
CONVERT(VARCHAR, f.date_completed, 101) AS [Completed Date], 
f.need_to_visit AS [Visit Y_N], 
f.field_person AS [Appraiser]

FROM KCv_PARCELMASTER1 AS parcel
LEFT OUTER JOIN allocations AS a ON parcel.lrsn=a.lrsn AND a.status='A'
LEFT OUTER JOIN memos AS m ON parcel.lrsn=m.lrsn AND m.memo_id = 'B519' AND m.memo_line_number = '1' AND m.status='A'
LEFT OUTER JOIN improvements AS i ON parcel.lrsn=i.lrsn AND i.status = 'A'
LEFT OUTER JOIN permits AS p ON parcel.lrsn=p.lrsn AND p.status= 'A'
LEFT OUTER JOIN field_visit AS f ON p.lrsn=f.lrsn AND p.field_number=f.field_number

WHERE parcel.EffStatus= 'A'


ORDER BY parcel.neighborhood, parcel.pin;





