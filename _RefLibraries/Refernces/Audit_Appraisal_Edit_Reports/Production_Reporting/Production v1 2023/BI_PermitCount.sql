-- !preview conn=con

SELECT
p.lrsn
,p.permit_type
,c.tbl_element_desc
,p.inactivedate
,f.date_completed
,f.field_person

FROM permits AS p 
---ON parcel.lrsn=p.lrsn

LEFT JOIN field_visit AS f ON p.field_number=f.field_number
  AND f.status='A'

LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type 
  AND c.tbl_type_code= 'permits'
  AND c.code_status= 'A'


WHERE p.status= 'I' 
AND p.inactivedate BETWEEN '2022-04-16' AND '2027-04-15'