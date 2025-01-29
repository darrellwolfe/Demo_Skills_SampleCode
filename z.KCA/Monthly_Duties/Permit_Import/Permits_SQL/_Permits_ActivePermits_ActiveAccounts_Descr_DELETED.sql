
WITH CTE_PermitCounter AS (
SELECT DISTINCT
--parcel.lrsn,
TRIM(p.permit_ref) AS REFERENCENum,
COUNT(TRIM(p.permit_ref)) AS Count
FROM permits AS p 
GROUP BY TRIM(p.permit_ref)
HAVING COUNT(TRIM(p.permit_ref)) > 1
)


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
        WHEN parcel.neighborhood = 0 THEN 'PersonalProperty_N/A_or_Error'
        ELSE NULL
    END AS District,
TRIM(parcel.ain) AS AIN, 
CONCAT(TRIM(parcel.ain),',') AS AIN_LookUp,
TRIM(parcel.pin) AS PIN, 
TRIM(parcel.SitusAddress) AS SitusAddress,
TRIM(parcel.SitusCity) AS SitusCity,
--StatusCheck
p.status AS PermitStatus,
parcel.EffStatus AS AccountStatus,
--Permit Data
TRIM(p.permit_ref) AS REFERENCENum,
TRIM(p.permit_desc) AS DESCRIPTION,
TRIM(c.tbl_element_desc) AS PERMIT_TYPE,
p.filing_date AS FILING_DATE,
f.field_out AS WORK_ASSIGNED_DATE,
p.callback AS CALLBACK_DATE,
f.field_in AS WORK_DUE_DATE,
p.cert_for_occ AS DATE_CERT_FOR_OCC,
p.permservice AS PERMANENT_SERVICE_DATE,
f.need_to_visit AS NEED_TO_VISIT, 
TRIM(f.field_person) AS APPRAISER,
f.date_completed AS COMPLETED_DATE,
--Other Dates
TRIM(p.permit_source) AS PERMIT_SOURCE,

--Additional Data
p.cost_estimate AS COST_ESTIMATE,
p.sq_ft AS ESTIMATED_SF,
--Demographics
TRIM(parcel.ClassCD) AS ClassCD, 
TRIM(parcel.DisplayName) AS Owner, 
--Acres
parcel.Acres,
--End SELECT
TRIM(parcel.DisplayDescr) AS LegalDescription


FROM KCv_PARCELMASTER1 AS parcel
JOIN permits AS p ON parcel.lrsn=p.lrsn
  AND p.status= 'A' 

  LEFT JOIN field_visit AS f ON p.field_number=f.field_number
    AND f.status='A'


LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type AND c.tbl_type_code= 'permits'
  AND c.code_status= 'A'

LEFT JOIN CTE_PermitCounter AS pc
  ON pc.REFERENCENum = TRIM(p.permit_ref)


WHERE parcel.EffStatus= 'A'
AND TRIM(parcel.DisplayDescr) LIKE '%DELETE%'
AND pc.REFERENCENum IS NULL -- Exclude rows that matched the CTE

ORDER BY GEO, PIN, REFERENCENum;
