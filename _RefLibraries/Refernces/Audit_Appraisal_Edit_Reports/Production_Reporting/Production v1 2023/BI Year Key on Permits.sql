-- !preview conn=conn


SELECT
  p.inactivedate
, YEAR(p.inactivedate) AS Year_Key
, FORMAT(CONVERT(DATETIME, CONCAT(YEAR(p.inactivedate), '-01-01')), 'MM/dd/yyyy') AS Year_Date

FROM permits AS p 
---ON parcel.lrsn=p.lrsn

LEFT JOIN field_visit AS f ON p.field_number=f.field_number
  AND f.status='A'

LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type 
  AND c.tbl_type_code= 'permits'
  AND c.code_status= 'A'


WHERE p.status= 'I' 
AND p.inactivedate BETWEEN '2022-04-16' AND '2027-04-15'