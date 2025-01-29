-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

---------
--Select All
---------
Select Distinct *
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

*/


--WITH CTE_ImpBasic AS (
----------------------------------
-- View/Master Query: Always e > i > then finally mh, cb, dw
----------------------------------
Select Distinct
--Extensions Table
e.lrsn,
e.extension,
e.ext_description,
i.imp_type,
cu.use_code,
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade AS [GradeCode], -- is this a code that needs a key?
grades.tbl_element_desc AS [GradeType]

--Extensions always comes first
FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M','C','D')
    --need codes to get the grade name, vs just the grade code#
    LEFT JOIN codes_table AS grades 
    ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      And code_status = 'A'
      
--COMMERCIAL      
LEFT JOIN comm_bldg AS cb 
  ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='A'
    LEFT JOIN comm_uses AS cu 
    ON cb.lrsn=cu.lrsn
      AND cb.extension = cu.extension
      AND cu.status='A'

WHERE e.status = 'A'
--)













