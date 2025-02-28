
/*
Audit_PermitsDetailed
Removed ones already completed
AsTxDBProd
GRM_Main


m1 not needed if we restrict results to those we want.Too many lines will make the report unreadable
LEFT JOIN memos AS m1 ON parcel.lrsn=m2.lrsn AND m2.memo_id = 'PERM' AND m2.memo_line_number = !'1'
Reference:
p.inactivedate,
p.field_number=f.field_number
Note Needed for view
p.permit_type AS [PERMIT_TYPE#],
*/

SELECT DISTINCT
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
CONCAT(LTRIM(RTRIM(parcel.ain)),',') AS [AIN_LookUp],
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
--Acres
parcel.Acres,

--Permit Data
LTRIM(RTRIM(p.permit_ref)) AS [REFERENCE#],
LTRIM(RTRIM(p.permit_desc)) AS [DESCRIPTION],
LTRIM(RTRIM(c.tbl_element_desc)) AS [PERMIT_TYPE],
p.callback AS [CALLBACK DATE],
f.field_in AS [WORK DUE DATE],
p.cert_for_occ AS [DATE CERT FOR OCC],
f.need_to_visit AS [NEED TO VISIT], 
LTRIM(RTRIM(f.field_person)) AS [APPRAISER],
f.date_completed AS [COMPLETED DATE],

--Additional Data
p.cost_estimate AS [COST ESTIMATE],
p.sq_ft AS [ESTIMATED SF],

--Other Dates
LTRIM(RTRIM(p.permit_source)) AS [PERMIT SOURCE],
p.filing_date AS [FILING DATE],
p.permservice AS [PERMANENT SERVICE DATE],
f.field_out AS [WORK ASSIGNED DATE]



--End SELECT

FROM KCv_PARCELMASTER1 AS parcel
JOIN permits AS p ON parcel.lrsn=p.lrsn
LEFT JOIN field_visit AS f ON p.field_number=f.field_number
LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type AND c.tbl_type_code= 'permits'

Where parcel.pin NOT LIKE '%KC%'

/*
WHERE parcel.EffStatus= 'A'
AND p.status= 'A' 
AND c.code_status= 'A'
AND NOT (f.need_to_visit='N'
AND f.field_person IS NOT NULL
AND f.date_completed IS NOT NULL
    )
*/

ORDER BY [GEO], [PIN], [REFERENCE#];
