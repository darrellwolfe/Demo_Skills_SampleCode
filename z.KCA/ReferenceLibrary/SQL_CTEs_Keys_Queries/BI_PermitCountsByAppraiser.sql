-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

Select 
p.lrsn,
p.inactivedate,
p.last_update,
TRIM(p.permit_ref) AS REFERENCE#,
TRIM(p.permit_desc) AS DESCRIPTION,
p.permit_type,
TRIM(c.tbl_element_desc) AS PERMIT_TYPE_Description,
p.filing_date AS FILING_DATE,
f.field_out AS WORK_ASSIGNED_DATE,
p.callback AS CALLBACK_DATE,
f.field_in AS WORK_DUE_DATE,
p.cert_for_occ AS DATE_CERT_FOR_OCC,
p.permservice AS PERMANENT_SERVICE_DATE,
f.need_to_visit AS NEED_TO_VISIT, 
TRIM(f.field_person) AS APPRAISER,
f.date_completed AS COMPLETED_DATE,
TRIM(p.permit_source) AS PERMIT_SOURCE

From Permits AS p

LEFT JOIN field_visit AS f ON p.field_number=f.field_number
  --AND f.status='A'

LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type AND c.tbl_type_code= 'permits'
  AND c.code_status= 'A'

--Join TSBv_PARCELMASTER AS pm
--  ON p.lrsn=pm.lrsn 
  --AND pm.EffStatus = 'A'

--Where permit_ref IN ('L95S3016A')