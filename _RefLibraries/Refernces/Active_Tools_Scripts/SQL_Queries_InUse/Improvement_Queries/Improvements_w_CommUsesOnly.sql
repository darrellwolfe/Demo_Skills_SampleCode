WITH CTE_Improvements AS (
Select Distinct
cu.use_code AS Comm_use_codes
FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query

JOIN improvements AS i ON e.lrsn=i.lrsn 
    AND e.extension=i.extension
    AND i.status='A'
--    AND i.improvement_id IN ('M','C','D')

    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
    AND grades.tbl_type_code='grades'

LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
    AND dw.status='A'
    AND i.extension=dw.extension
    LEFT JOIN codes_table AS htyp 
        ON dw.mkt_house_type = htyp.tbl_element 
        AND htyp.tbl_type_code='htyp'  
        AND htyp.code_status = 'A'
        
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
    AND i.extension=mh.extension
    AND mh.status='A'
    LEFT JOIN codes_table AS make 
        ON mh.mh_make=make.tbl_element 
        AND make.tbl_type_code='mhmake'
            AND make.code_status = 'A'
    LEFT JOIN codes_table AS model 
        ON mh.mh_model=model.tbl_element 
        AND model.tbl_type_code='mhmodel'
            AND model.code_status = 'A'
    LEFT JOIN codes_table AS park 
        ON mh.mhpark_code=park.tbl_element 
        AND park.tbl_type_code='mhpark'
        AND park.code_status = 'A'

LEFT JOIN comm_bldg AS cb 
    ON i.lrsn=cb.lrsn 
    AND i.extension=cb.extension
    AND cb.status='A'
    LEFT JOIN comm_uses AS cu 
        ON cb.lrsn=cu.lrsn
        AND cb.extension = cu.extension
        AND cu.status='A'

  --Conditions
  WHERE e.status = 'A'
    --AND i.improvement_id IN ('M','C','D')
)


Select Distinct
imp.*

From CTE_Improvements AS imp
--Where imp.HouseTypeName LIKE '%Town%'

