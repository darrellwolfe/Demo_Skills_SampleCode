-- !preview conn=conn

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
p.permit_type AS PERMIT_TYPE#,
*/

SELECT DISTINCT
--Account Details
parcel.lrsn,
parcel.neighborhood AS GEO,
    CASE
        WHEN parcel.neighborhood >= 9000 THEN 'Manufactured_Homes'
        WHEN parcel.neighborhood >= 6003 THEN 'District_6'
        WHEN parcel.neighborhood = 6002 THEN 'Manufactured_Homes'
        WHEN parcel.neighborhood = 6001 THEN 'District_6'
        WHEN parcel.neighborhood = 6000 THEN 'Manufactured_Homes'
        WHEN parcel.neighborhood >= 5003 THEN 'District_5'
        WHEN parcel.neighborhood = 5002 THEN 'Manufactured_Homes'
        WHEN parcel.neighborhood = 5001 THEN 'District_5'
        WHEN parcel.neighborhood = 5000 THEN 'Manufactured_Homes'
        WHEN parcel.neighborhood >= 4000 THEN 'District_4'
        WHEN parcel.neighborhood >= 3000 THEN 'District_3'
        WHEN parcel.neighborhood >= 2000 THEN 'District_2'
        WHEN parcel.neighborhood >= 1021 THEN 'District_1'
        WHEN parcel.neighborhood = 1020 THEN 'Manufactured_Homes'
        WHEN parcel.neighborhood >= 1001 THEN 'District_1'
        WHEN parcel.neighborhood = 1000 THEN 'Manufactured_Homes'
        WHEN parcel.neighborhood >= 451 THEN 'Commercial'
        WHEN parcel.neighborhood = 450 THEN 'Specialized_Cell_Towers'
        WHEN parcel.neighborhood >= 1 THEN 'Commercial'
        WHEN parcel.neighborhood = 0 THEN 'N/A_or_Error'
        ELSE NULL
    END AS District,
LTRIM(RTRIM(parcel.ain)) AS AIN, 
CONCAT(LTRIM(RTRIM(parcel.ain)),',') AS AIN_LookUp,
LTRIM(RTRIM(parcel.pin)) AS PIN, 
LTRIM(RTRIM(parcel.SitusAddress)) AS SitusAddress,
LTRIM(RTRIM(parcel.SitusCity)) AS SitusCity,
--Permit Data
p.status,
LTRIM(RTRIM(p.permit_ref)) AS REFERENCE#,
LTRIM(RTRIM(p.permit_desc)) AS DESCRIPTION,
COALESCE(nc.memo_text, 'null') AS NC_Memos,
LTRIM(RTRIM(c.tbl_element_desc)) AS PERMIT_TYPE,
p.filing_date AS FILING_DATE,
f.field_out AS WORK_ASSIGNED_DATE,
p.callback AS CALLBACK_DATE,
f.field_in AS WORK_DUE_DATE,
p.cert_for_occ AS DATE_CERT_FOR_OCC,
p.permservice AS PERMANENT_SERVICE_DATE,
f.need_to_visit AS NEED_TO_VISIT, 
LTRIM(RTRIM(f.field_person)) AS APPRAISER,
f.date_completed AS COMPLETED_DATE,
--Other Dates
LTRIM(RTRIM(p.permit_source)) AS PERMIT_SOURCE,
--NOTES, CONCAT allows one line of notes instead of duplicate rows
m2.memo_id AS MEMO_ID,
LTRIM(RTRIM(CONCAT(
m2.memo_text,
'.', 
m3.memo_text,
'.', 
m4.memo_text,
'.', 
m5.memo_text,
'.', 
m6.memo_text,
'.', 
m7.memo_text
))) AS MemoText,
--Additional Data
p.cost_estimate AS COST_ESTIMATE,
p.sq_ft AS ESTIMATED_SF,
--Demographics
LTRIM(RTRIM(parcel.ClassCD)) AS ClassCD, 
LTRIM(RTRIM(parcel.DisplayName)) AS Owner, 
--Acres
parcel.Acres
--End SELECT


FROM KCv_PARCELMASTER1 AS parcel
JOIN permits AS p ON parcel.lrsn=p.lrsn
  --AND p.status= 'A' 

  LEFT JOIN field_visit AS f ON p.field_number=f.field_number
    AND f.status='A'
  
  LEFT JOIN memos AS m2 ON parcel.lrsn=m2.lrsn AND m2.memo_id = 'PERM' AND m2.memo_line_number = '2'
  LEFT JOIN memos AS m3 ON parcel.lrsn=m3.lrsn AND m3.memo_id = 'PERM' AND m3.memo_line_number = '3'
  LEFT JOIN memos AS m4 ON parcel.lrsn=m4.lrsn AND m4.memo_id = 'PERM' AND m4.memo_line_number = '4'
  LEFT JOIN memos AS m5 ON parcel.lrsn=m2.lrsn AND m2.memo_id = 'PERM' AND m2.memo_line_number = '5'
  LEFT JOIN memos AS m6 ON parcel.lrsn=m3.lrsn AND m3.memo_id = 'PERM' AND m3.memo_line_number = '6'
  LEFT JOIN memos AS m7 ON parcel.lrsn=m4.lrsn AND m4.memo_id = 'PERM' AND m4.memo_line_number = '7'

  LEFT JOIN memos AS nc ON parcel.lrsn=nc.lrsn AND nc.memo_id LIKE 'NC%'



LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type AND c.tbl_type_code= 'permits'
  AND c.code_status= 'A'

WHERE parcel.EffStatus= 'A'

/*
AND NOT (f.need_to_visit='N'
AND f.field_person IS NOT NULL
AND f.date_completed IS NOT NULL
    )
*/
ORDER BY GEO, PIN, REFERENCE#;
