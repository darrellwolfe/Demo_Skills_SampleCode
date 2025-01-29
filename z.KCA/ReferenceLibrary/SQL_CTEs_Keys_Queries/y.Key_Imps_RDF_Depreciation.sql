-- !preview conn=conn

 /*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/

WITH 

CTE_Improvements_Residential AS (
----------------------------------
-- View/Master Query: Always e > i > then finally mh, cb, dw
----------------------------------
Select Distinct
--Extensions Table
e.lrsn
,e.extension
,e.ext_description
,i.improvement_id
,i.imp_type

,dw.mkt_house_type
,htyp.tbl_element_desc AS [HouseTypeName]
,dw.mkt_rdf -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation

,i.phys_depreciation1
,i.phys_depre_value1
,i.phys_depre_value3
,i.phys_depreciation3
,i.ovrride_phys_depr
,i.funct_depreciation
,i.funct_depre_value1
,i.funct_depre_value3
,i.obs_depreciation
,i.obs_depre_value1
,i.obs_depre_value3
,i.calc_obs_dep

,dw.rdf_inf1_code
,dw.rdf_inf1_desc
,dw.rdf_inf1_percent

,dw.rdf_inf2_code
,dw.rdf_inf2_desc
,dw.rdf_inf2_percent

,dw.rdf_inf3_code
,dw.rdf_inf3_desc
,dw.rdf_inf3_percent

,i.pct_complete

--Extensions always comes first
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

--Conditions
WHERE e.status = 'A'
AND i.improvement_id IN ('D','M')
AND (e.ext_description LIKE '%H1%'
  OR e.ext_description LIKE '%H-1%'
  OR e.ext_description LIKE '%NREV%'
  )
--Order by e.lrsn
)

SELECT *
FROM CTE_Improvements_Residential

