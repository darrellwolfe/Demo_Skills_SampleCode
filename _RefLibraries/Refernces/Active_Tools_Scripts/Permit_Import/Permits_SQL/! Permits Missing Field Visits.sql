
WITH

CTE_CountPermitsActive AS (
SELECT DISTINCT
parcel.lrsn
,COUNT(p.permit_ref) AS PermitCount
FROM KCv_PARCELMASTER1 AS parcel
JOIN permits AS p ON parcel.lrsn=p.lrsn
  AND p.status= 'A' 
WHERE parcel.EffStatus= 'A'
GROUP BY parcel.lrsn
)

SELECT DISTINCT
--Account Details
TRIM(p.permit_ref) AS REFERENCE#,
TRIM(p.permit_desc) AS DESCRIPTION,
TRIM(parcel.ain) AS AIN, 
TRIM(parcel.pin) AS PIN, 
TRIM(parcel.SitusAddress) AS SitusAddress,
TRIM(parcel.SitusCity) AS SitusCity,
parcel.lrsn,
counts.PermitCount


FROM KCv_PARCELMASTER1 AS parcel
JOIN permits AS p ON parcel.lrsn=p.lrsn
  AND p.status= 'A' 

  LEFT JOIN field_visit AS f ON p.field_number=f.field_number
    AND f.status='A'


LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type AND c.tbl_type_code= 'permits'
  AND c.code_status= 'A'

LEFT JOIN CTE_CountPermitsActive AS counts
    On counts.lrsn = parcel.lrsn

WHERE parcel.EffStatus= 'A'
  AND f.field_out IS NULL
  AND p.permit_type <> '9'

ORDER BY PermitCount ASC, PIN, REFERENCE#;
