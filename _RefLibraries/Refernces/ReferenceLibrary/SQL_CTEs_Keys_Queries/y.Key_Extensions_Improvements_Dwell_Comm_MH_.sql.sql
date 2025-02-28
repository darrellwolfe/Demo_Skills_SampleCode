-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

FIRST: Do you want the Worksheet (pending) data or the certified (historical) data?
Copy any of the following options into a test query to see results

*/

Declare @Year int = 2024; -- Set this to the year you're working with
Declare @EffYearCurrent varchar(8) = Cast(@Year as varchar) + '%';
Declare @EffYearPrevious varchar(8) = Cast(@Year - 1 as varchar) + '%';

CTE_ImprovementYears AS (
Select Distinct
i.lrsn
,STRING_AGG (i.year_built, ', ') AS year_built
,STRING_AGG (i.improvement_id, ', ') AS improvement_id
--i.year_built
--i.improvement_id

From improvements AS i
Join extensions AS e
  On i.lrsn = e.lrsn
  And i.extension = e.extension
  And e.status = 'A'

Where i.status = 'A'
--And e.eff_year LIKE '2023%'
And e.eff_year LIKE @EffYearPrevious
And i.improvement_id IN ('C','M','D','A01','A02','A03','A04','G01','G02','G03','G04','G05','G06','G07','G08')

Group By i.lrsn
)

------------------------------------
-- WORKSHEET Query with Columns
------------------------------------

DECLARE @Year INT = 20230101;

SELECT
  e.lrsn
, e.ext_id
, e.extension
, e.ext_description
, i.improvement_id
, i.imp_type

, a.land_line_number
, a.group_code
, impgroup.tbl_element_desc AS ImpGroup_Descr

, grades.tbl_element_desc AS Grade

, dw.dwelling_number
, dw.mkt_house_type
, htyp.tbl_element_desc AS HouseType

, cb.bldg_section
, cb.mkt_bldg_type
, cu.use_code

, mh.mh_make
, make.tbl_element_desc AS MH_Make_Desc
, mh.mh_model
, model.tbl_element_desc AS MH_Model_Desc
, mh.mh_serial_num
, mh.mhpark_code
, park.tbl_element_desc AS MH_Park_Desc

FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN allocations AS a ON a.lrsn=e.lrsn 
  AND a.extension=e.extension
  AND a.status = 'A'
  LEFT JOIN codes_table AS impgroup ON impgroup.tbl_element=a.group_code
    AND impgroup.code_status='A'
    AND impgroup.tbl_type_code = 'impgroup'
    --AND a.group_code IN ('01','03','04','05','06','07','09')
    
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M','C','D')
    --need codes to get the grade name, vs just the grade code#
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'




--manuf_housing, comm_bldg, dwellings all must be after e and i

--COMMERCIAL      
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='A'
    LEFT JOIN comm_uses AS cu ON cb.lrsn=cu.lrsn
      AND cb.extension = cu.extension
      AND cu.status='A'
      
--RESIDENTIAL DWELLINGS
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND dw.status='A'
      AND i.extension=dw.extension
  LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  
     
--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status='A'
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'

WHERE e.status = 'A'
  AND e.eff_year = @Year












------------------------------------
-- Certified Historical Query with Columns
------------------------------------

DECLARE @Year INT = 20230101;

SELECT
  e.lrsn
, e.ext_id
, e.extension
, e.ext_description
, i.improvement_id
, i.imp_type
, grades.tbl_element_desc AS Grade

, dw.dwelling_number
, dw.mkt_house_type
, htyp.tbl_element_desc AS HouseType

, cb.bldg_section
, cb.mkt_bldg_type
, cu.use_code

, mh.mh_make
, make.tbl_element_desc AS MH_Make_Desc
, mh.mh_model
, model.tbl_element_desc AS MH_Model_Desc
, mh.mh_serial_num
, mh.mhpark_code
, park.tbl_element_desc AS MH_Park_Desc

FROM extensions AS e 

JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='H'
      AND i.eff_year = @Year
      AND i.improvement_id IN ('M','D','C')
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
--manuf_housing, comm_bldg, dwellings all must be after e and i

--RESIDENTIAL DWELLINGS
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND i.extension=dw.extension
      AND dw.status='H'
      AND dw.eff_year = @Year
  LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  


--COMMERCIAL      
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='H'
      AND cb.eff_year = @Year
    LEFT JOIN comm_uses AS cu ON cb.lrsn=cu.lrsn
      AND cb.extension = cu.extension
      AND cu.status = 'H'
      AND cu.eff_year = @Year

--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status = 'H'
      AND mh.eff_year = @Year
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'
      
      
WHERE e.status = 'H'
  AND e.eff_year = @Year
  AND e.ext_description <> 'CONDO'










------------------------------------
-- Certified Historical < May need to factor for multiple changes to roll????
------------------------------------


FROM extensions AS e 

JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='H'
      AND i.eff_year = 20230101
      AND i.improvement_id IN ('M','D','C')
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
--manuf_housing, comm_bldg, dwellings all must be after e and i

--RESIDENTIAL DWELLINGS
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND i.extension=dw.extension
      AND dw.status='H'
      AND dw.eff_year = 20230101
  LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  


--COMMERCIAL      
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='H'
      AND cb.eff_year = 20230101
    LEFT JOIN comm_uses AS cu ON cb.lrsn=cu.lrsn
      AND cb.extension = cu.extension
      AND cu.status = 'H'
      AND cu.eff_year = 20230101

--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status = 'H'
      AND mh.eff_year = 20230101
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'



------------------------------------
-- WORKSHEET
------------------------------------

FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M','C','D')
    --need codes to get the grade name, vs just the grade code#
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
--manuf_housing, comm_bldg, dwellings all must be after e and i

--COMMERCIAL      
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='A'
    LEFT JOIN comm_uses AS cu ON cb.lrsn=cu.lrsn
      AND cb.extension = cu.extension
      AND cu.status='A'
      
--RESIDENTIAL DWELLINGS
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND dw.status='A'
      AND i.extension=dw.extension
  LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  
     
--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status='A'
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'

WHERE e.status = 'H'
  AND e.eff_year = @Year
  