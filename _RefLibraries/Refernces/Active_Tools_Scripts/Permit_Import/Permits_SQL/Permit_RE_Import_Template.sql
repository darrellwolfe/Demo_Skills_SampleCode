-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/


SELECT
  TRIM(pm.pin) AS PIN
,  TRIM(p.permit_ref) AS REFERENCE#
,  p.cost_estimate AS COST_ESTIMATE
,  p.sq_ft AS ESTIMATED_SF
,  p.filing_date AS FILING_DATE
,  p.callback AS CALLBACK_DATE
,  '' AS inactivedate
,  p.cert_for_occ AS DATE_CERT_FOR_OCC
,  TRIM(p.permit_desc) AS DESCRIPTION
,  p.permit_type
,  TRIM(p.permit_source) AS PERMIT_SOURCE
,  p.phone_number
,  '' AS permit_char3
,  'A' AS status_code
,  '' AS permit_char20b
,  '0' AS permit_int2
,  '0' AS permit_int3
,  '0' AS permit_int4
,  p.permservice AS PERMANENT_SERVICE_DATE
,  p.permit_fee
,  '>Additional' AS OtherInfo_FieldVisit
,  TRIM(c.tbl_element_desc) AS PERMIT_TYPE_Desc
,  f.field_out AS WORK_ASSIGNED_DATE
,  f.field_in AS WORK_DUE_DATE
,  f.need_to_visit AS NEED_TO_VISIT
,  TRIM(f.field_person) AS APPRAISER
,  f.date_completed AS COMPLETED_DATE
,  '>Additional' AS OtherInfo_Parcel
  --Account Details
,  pm.lrsn
,  pm.neighborhood AS GEO
,      CASE
          WHEN pm.neighborhood >= 9000 THEN 'Manufactured_Homes'
          WHEN pm.neighborhood >= 6003 THEN 'District_6'
          WHEN pm.neighborhood = 6002 THEN 'Manufactured_Homes'
          WHEN pm.neighborhood = 6001 THEN 'District_6'
          WHEN pm.neighborhood = 6000 THEN 'Manufactured_Homes'
          WHEN pm.neighborhood >= 5003 THEN 'District_5'
          WHEN pm.neighborhood = 5002 THEN 'Manufactured_Homes'
          WHEN pm.neighborhood = 5001 THEN 'District_5'
          WHEN pm.neighborhood = 5000 THEN 'Manufactured_Homes'
          WHEN pm.neighborhood >= 4000 THEN 'District_4'
          WHEN pm.neighborhood >= 3000 THEN 'District_3'
          WHEN pm.neighborhood >= 2000 THEN 'District_2'
          WHEN pm.neighborhood >= 1021 THEN 'District_1'
          WHEN pm.neighborhood = 1020 THEN 'Manufactured_Homes'
          WHEN pm.neighborhood >= 1001 THEN 'District_1'
          WHEN pm.neighborhood = 1000 THEN 'Manufactured_Homes'
          WHEN pm.neighborhood >= 451 THEN 'Commercial'
          WHEN pm.neighborhood = 450 THEN 'Specialized_Cell_Towers'
          WHEN pm.neighborhood >= 1 THEN 'Commercial'
          WHEN pm.neighborhood = 0 THEN 'N/A_or_Error'
          ELSE NULL
      END AS District
,  TRIM(pm.ain) AS AIN 
,  CONCAT(TRIM(pm.ain),',') AS AIN_LookUp
,  TRIM(pm.SitusAddress) AS SitusAddress
,  TRIM(pm.SitusCity) AS SitusCity


FROM permits AS p 

JOIN TSBv_PARCELMASTER AS pm ON pm.lrsn=p.lrsn
  AND pm.EffStatus = 'A'

LEFT JOIN field_visit AS f ON p.field_number=f.field_number
  AND f.status='A'

LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type AND c.tbl_type_code= 'permits'
  AND c.code_status= 'A'


WHERE p.status= 'A' 