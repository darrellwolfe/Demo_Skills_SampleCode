-- !preview conn=conn



 /*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/

-------------------------------------
--CTE_Improvements_MH Manufactered Home
-------------------------------------
CTE_Improvements_MH AS (
----------------------------------
-- View/Master Query: Always e > i > then finally mh, cb, dw
----------------------------------
Select Distinct
--Extensions Table
e.lrsn
,e.extension
,e.ext_description
--,e.data_collector
--,e.collection_date
--,e.appraiser
--,e.appraisal_date

--Improvements Table
  --codes_table 
  --AND park.tbl_type_code='grades'
,i.imp_type
--manuf_housing
    --codes_table 
    --AND make.tbl_type_code='mhmake'
    --AND model.tbl_type_code='mhmodel'    
    --AND park.tbl_type_code='mhpark'
,mh.mh_make AS [MHMake#]
,make.tbl_element_desc AS [MH_Make]
,mh.mh_model AS [MHModel#]
,model.tbl_element_desc AS [MH_Model]
,mh.mh_serial_num AS [VIN]
,mh.mhpark_code
,park.tbl_element_desc AS [MH_Park]
--i.imp_size
,i.year_built
,i.eff_year_built
,i.year_remodeled
,i.condition
,i.grade AS [GradeCode] -- is this a code that needs a key?
,grades.tbl_element_desc AS [GradeType]



-- Residential Dwellings dw
  --codes_table
  -- AND htyp.tbl_type_code='htyp'  
,dw.mkt_house_type AS [HouseType#]
,htyp.tbl_element_desc AS [HouseTypeName]

,dw.mh_length
,dw.mh_width

,(dw.mh_length * dw.mh_width) AS MH_SF
-- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation

,dw.total_base_price1 AS TotalBaseValue_SFV
--ProVal Values BuildUp Total Base Value

,dw.subtot2_1 AS SubTotal_1Unit
--ProVal Values BuildUp SubTotal 1 Unit
--This ads the Adjustments and Features to the Total Base

,dw.subtot3_1  AS SubTotal_AllUnits
--ProVal Values BuildUp This sums the unit total if there are more than one unit

,dw.exfeat_adj1 AS SubTotalGaragesPorches
--ProVal Values BuildUp sum of the Garages and Porches submenu only

,dw.subtot4_1 AS TotalAdjustedBaseValue
--ProVal Values BuildUp This is the SF Base + Adj and Features + Garages and Porches

,dw.reproduction_cost1 AS GradeAdjustedBaseValue
--ProVal Values BuildUp This takes Total Adjusted Base and factors for Grade
,i.phys_depreciation1
,(i.phys_depreciation1 * 0.010) AS PhysDep
,(dw.reproduction_cost1 * (i.phys_depreciation1 * 0.010)) AS PhysDepAmount


,i.funct_depreciation
,(i.funct_depreciation * 0.010) AS FunctDep
,(dw.reproduction_cost1 * (i.funct_depreciation * 0.010)) AS FunctDepAmount

,i.obs_depreciation
,(i.obs_depreciation * 0.010) AS ObsDep
,(dw.reproduction_cost1 * (i.obs_depreciation * 0.010)) AS ObsDepAmount

,FLOOR(
    (dw.reproduction_cost1)
  - (dw.reproduction_cost1 * (i.phys_depreciation1 * 0.010))
  - (dw.reproduction_cost1 * (i.funct_depreciation * 0.010))
  - (dw.reproduction_cost1 * (i.obs_depreciation * 0.010))
    ) AS Base_LessDepreciation

--,dw.
--GradeAdjustedBaseValue + GEO Factor
--ProVal Values BuildUp This takes Total Adjusted Base and factors for Grade

,dw.mkt_rdf AS RDF
,(dw.mkt_rdf * 0.010) AS RDF_Percentage
--reproduction_cost1 - Depreciation + Factor

,FLOOR(
    ((dw.reproduction_cost1)
  - (dw.reproduction_cost1 * (i.phys_depreciation1 * 0.010))
  - (dw.reproduction_cost1 * (i.funct_depreciation * 0.010))
  - (dw.reproduction_cost1 * (i.obs_depreciation * 0.010)))
  * (dw.mkt_rdf * 0.010)) AS FinalValue

,CASE
  WHEN (dw.reproduction_cost1) < 0 THEN NULL
  WHEN (dw.reproduction_cost1) = 0 THEN NULL
  WHEN (dw.mh_length) = 0 THEN NULL
  WHEN (dw.mh_width) = 0 THEN NULL

  ELSE  FLOOR(
          ((dw.reproduction_cost1)
        - (dw.reproduction_cost1 * (i.phys_depreciation1 * 0.010))
        - (dw.reproduction_cost1 * (i.funct_depreciation * 0.010))
        - (dw.reproduction_cost1 * (i.obs_depreciation * 0.010)))
        * (dw.mkt_rdf * 0.010))
        / (dw.mh_length * dw.mh_width)
END AS MHValue_SF





--Extensions always comes first
FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status IN ('A','F')
      --AND i.status='A'
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
      AND mh.status IN ('A','F')
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'
    
WHERE e.status IN ('A','F')
AND i.improvement_id IN ('M')

--And e.lrsn IN ('18138','8677','25261','565970')
--And e.lrsn = 565970 
-- Test LRSN
),


