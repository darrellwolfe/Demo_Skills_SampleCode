-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

SELECT DISTINCT
TRIM(p.permit_type) AS Permit_Type
,TRIM(c.tbl_element_desc) AS Permit_Description
, CASE
    WHEN p.permit_type IN ('1','2','PO') THEN 10
    WHEN p.permit_type IN ('3','4','12','13','14','99') THEN 5
    WHEN p.permit_type IN ('5','6','10','11','15') THEN 3
    WHEN p.permit_type IN ('9') THEN 1
    ELSE NULL
  END AS Point_Key
, CASE
    WHEN p.permit_type IN ('1','2','PO') THEN (COUNT(p.lrsn)*10)
    WHEN p.permit_type IN ('3','4','12','13','14','99') THEN (COUNT(p.lrsn)*5)
    WHEN p.permit_type IN ('5','6','10','11','15') THEN (COUNT(p.lrsn)*3)
    WHEN p.permit_type IN ('9') THEN (COUNT(p.lrsn)*1)
    ELSE NULL
  END AS Points_Since_2013

FROM permits AS p 
---ON parcel.lrsn=p.lrsn

LEFT JOIN field_visit AS f ON p.field_number=f.field_number
  AND f.status='A'
  AND f.field_in IS NOT NULL
  AND f.field_in > '2012-12-31'
LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type 
  AND c.tbl_type_code= 'permits'
  --AND c.code_status= 'A'

WHERE p.permit_type IS NOT NULL
AND p.permit_type <> '0'
AND p.status= 'I'

GROUP BY
p.permit_type
,c.tbl_element_desc

ORDER BY Permit_Description