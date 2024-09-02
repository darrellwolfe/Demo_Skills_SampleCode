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
p.status
, parcel.lrsn
,   CASE
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
    END AS District
, parcel.neighborhood AS GEO

, TRIM(parcel.ain) AS AIN
, CONCAT(TRIM(parcel.ain),',') AS AIN_LookUp
, TRIM(p.permit_ref) AS REFERENCE#
, TRIM(p.permit_desc) AS DESCRIPTION
, TRIM(c.tbl_element_desc) AS PERMIT_TYPE
, TRIM(parcel.pin) AS PIN
, TRIM(parcel.SitusAddress) AS SitusAddress
, TRIM(parcel.SitusCity) AS SitusCity
--Permit Data

, p.callback AS CALLBACK_DATE
, f.field_in AS WORK_DUE_DATE
, p.cert_for_occ AS DATE_CERT_FOR_OCC
, f.need_to_visit AS NEED_TO_VISIT
, TRIM(f.field_person) AS APPRAISER
, f.date_completed AS COMPLETED_DATE
--NOTES, CONCAT allows one line of notes instead of duplicate rows
, m1.memo_id AS MEMO_ID
, COALESCE(m1.memo_text, 'Default Value') AS Memos
--Additional Data
, p.cost_estimate AS COST_ESTIMATE
, p.sq_ft AS ESTIMATED_SF
--Other Dates
, TRIM(p.permit_source) AS PERMIT_SOURCE
, p.filing_date AS FILING_DATE
, p.permservice AS PERMANENT_SERVICE_DATE
, f.field_out AS WORK_ASSIGNED_DATE
--Demographics
, TRIM(parcel.ClassCD) AS ClassCD
, TRIM(parcel.DisplayName) AS Owner
--Acres
, parcel.Acres

--End SELECT

FROM KCv_PARCELMASTER1 AS parcel

-- Permits
JOIN permits AS p ON parcel.lrsn=p.lrsn
-- AND p.status= 'A' 

--Field Visits
LEFT JOIN field_visit AS f ON p.field_number=f.field_number

--Memos
LEFT JOIN memos AS m1 ON parcel.lrsn=m1.lrsn 
  AND m1.memo_id = 'PERM'

--Codes Table
LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type AND c.tbl_type_code= 'permits'
  AND c.code_status= 'A'
  
WHERE p.filing_date > '2013-01-01'
  AND parcel.EffStatus= 'A'
--  AND p.permit_type IN ('11','13')
  AND p.permit_type IN ('13')
  AND f.field_person IN ('CS')
--  AND f.field_out > ('2023-10-01')


--AND   p.permit_ref = 'RES22-1393'

--, TRIM(p.permit_ref) AS REFERENCE#


/*
AND NOT (f.need_to_visit='N'
AND f.field_person IS NOT NULL
AND f.date_completed IS NOT NULL
    )
*/
ORDER BY GEO, PIN, REFERENCE#;
