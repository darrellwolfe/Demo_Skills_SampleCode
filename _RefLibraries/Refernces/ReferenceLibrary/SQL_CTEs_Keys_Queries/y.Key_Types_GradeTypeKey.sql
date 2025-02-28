-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/




SELECT DISTINCT
i.grade AS GradeCode -- is this a code that needs a key from codes table
, grades.tbl_element_desc AS GradeType

FROM improvements AS i
--ON e.lrsn=i.lrsn 
--AND e.extension=i.extension
--AND i.status='A'
--AND i.improvement_id IN ('M','C','D')
  --need codes to get the grade name, vs just the grade code#
  LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
    AND grades.tbl_type_code='grades'
    
ORDER BY GradeCode;