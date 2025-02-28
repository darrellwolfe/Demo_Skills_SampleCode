SELECT DISTINCT
TRIM(p.pin) AS PIN, 
TRIM(p.SitusAddress) AS SitusAddress,
TRIM(pe.permit_ref) AS REFERENCE#

FROM TSBv_PARCELMASTER AS p
JOIN permits AS pe ON p.lrsn=pe.lrsn
  AND pe.status= 'A' 
  LEFT JOIN field_visit AS fv ON pe.field_number=fv.field_number
    AND fv.status='A'

WHERE p.EffStatus= 'A'
AND fv.field_out IS NULL
AND pe.permit_type <> '9'