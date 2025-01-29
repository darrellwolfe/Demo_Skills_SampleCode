SELECT 
p.lrsn, 
p.pin, 
p.ain, 
p.ClassCD, 
p.neighborhood, 
pm.permit_ref AS REFERENCE#,
pm.filing_date AS [FILING DATE],
pm.inactivedate,
pm.permit_desc AS DESCRIPTION,
pm.permit_type AS [PERMIT TYPE]

FROM TSBv_PARCELMASTER AS p
JOIN permits AS pm ON p.lrsn=pm.lrsn

WHERE p.EffStatus= 'A'
AND pm.permit_ref LIKE 'BLDR-24%'

ORDER BY p.neighborhood, p.pin;
