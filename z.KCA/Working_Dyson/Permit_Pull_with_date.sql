SELECT 
parcel.lrsn, 
parcel.ain, 
parcel.SitusAddress, 
parcel.SitusCity,
parcel.neighborhood,  
parcel.DisplayDescr, 
parcel.EffStatus, 
f.date_completed, 
f.need_to_visit, 
f.field_person,
p.permit_ref AS REFERENCE#,
p.cost_estimate AS [COST ESTIMATE],
p.sq_ft AS [ESTIMATED SF],
p.filing_date AS [FILING DATE],
p.callback AS [CALLBACK DATE],
p.inactivedate,
p.cert_for_occ AS [DATE CERT FOR OCC],
p.permit_desc AS DESCRIPTION,
p.permit_type AS [PERMIT TYPE],
p.permit_source AS [PERMIT SOURCE],
p.permservice AS [PERMANENT SERVICE DATE],
f.field_out AS [WORK ASSIGNED DATE],
f.field_in AS [WORK DUE DATE]


FROM KCv_PARCELMASTER1 AS parcel
JOIN permits AS p ON parcel.lrsn=p.lrsn
JOIN field_visit AS f ON p.lrsn=f.lrsn AND p.field_number=f.field_number

WHERE parcel.EffStatus= 'A'
AND p.status= 'A' 

ORDER BY parcel.neighborhood, parcel.pin;
