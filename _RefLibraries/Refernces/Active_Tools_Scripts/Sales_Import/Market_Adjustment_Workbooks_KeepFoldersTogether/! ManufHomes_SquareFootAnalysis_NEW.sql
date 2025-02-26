-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/


DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;
--Declare @Year int = 2025; -- Input THIS year here
--DECLARE @TaxYear INT;
--SET @TaxYear = YEAR(GETDATE());

IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year



Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here


Declare @MemoLastUpdatedNoEarlierThan date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @MemoLastUpdatedNoEarlierThan DATE = '2024-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022

Declare @PrimaryTransferDateFROM date = CAST(CAST(@Year - 2 as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @PrimaryTransferDateTO date = CAST(CAST(@Year as varchar) + '-12-31' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @PrimaryTransferDateFROM DATE = '2024-01-01';
--Declare @PrimaryTransferDateTO DATE = '2024-12-31';
--pxfer_date
--AND tr.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'

Declare @CertValueDateFROM varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @CertValueDateTO varchar(8) = Cast(@Year as varchar) + '1231'; -- Generates '20230101' for the previous year
--Declare @CertValueDateFROM INT = '20240101';
--Declare @CertValueDateTO INT = '20241231';
--v.eff_year
---WHERE v.eff_year BETWEEN 20230101 AND 20231231

Declare @LandModelId varchar(6) = '70' + Cast(@Year as varchar); -- Generates '702023' for the previous year
    --AND lh.LandModelId='702023'
    --AND ld.LandModelId='702023'
    --AND lh.LandModelId= @LandModelId
    --AND ld.LandModelId= @LandModelId 

Declare @pxfer_date_from date = CAST(CAST(@Year - 2 as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @pxfer_date_to date = CAST(CAST(@Year as varchar) + '-12-31' AS DATE); -- Generates '2023-01-01' for the current year
--AND t.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'
--AND t.pxfer_date BETWEEN @pxfer_date_to AND @pxfer_date_from

Declare @modelyear INT = @Year;
--Declare @modelyear INT = '2023';
--AND nf.res_model_serial='2023'
--AND nf.res_model_serial=@modelyear



-------------------------------------
-- BEGIN CTEs
-------------------------------------

-------------------------------------
-- CTEs will drive this report and combine in the main query
-------------------------------------
WITH
-------------------------------------
--CTE_ParcelMasterData
-------------------------------------
CTE_ParcelMasterData AS (
SELECT DISTINCT
CASE
WHEN pm.neighborhood >= 9000 THEN 'Manufactured_Homes'
WHEN pm.neighborhood >= 6003 THEN 'District_6'
WHEN pm.neighborhood = 6002 THEN 'Manufactured_Homes'
WHEN pm.neighborhood = 6001 THEN 'District_6'
WHEN pm.neighborhood = 6000 THEN 'Manufactured_Homes'
WHEN pm.neighborhood >= 5003 THEN 'District_5'
WHEN pm.neighborhood = 5002 THEN 'Manufactured_Homes'
WHEN pm.neighborhood = 5001 THEN 'District_5'
WHEN pm.neighborhood = 5000 THEN 'Manufactured_Homes'
WHEN pm.neighborhood >= 4000 THEN 'District_4'
WHEN pm.neighborhood >= 3000 THEN 'District_3'
WHEN pm.neighborhood >= 2000 THEN 'District_2'
WHEN pm.neighborhood >= 1021 THEN 'District_1'
WHEN pm.neighborhood = 1020 THEN 'Manufactured_Homes'
WHEN pm.neighborhood >= 1001 THEN 'District_1'
WHEN pm.neighborhood = 1000 THEN 'Manufactured_Homes'
WHEN pm.neighborhood >= 451 THEN 'Commercial'
WHEN pm.neighborhood = 450 THEN 'Specialized_Cell_Towers'
WHEN pm.neighborhood >= 1 THEN 'Commercial'
WHEN pm.neighborhood = 0 THEN 'N/A_or_Error'
ELSE NULL
END AS District,
-- # District SubClass
CASE
--Commercial # Income properties use regular template, for now. 
--  May build something. Set up just in case. DGW 08/02/2023.
WHEN pm.neighborhood BETWEEN '1' AND '27' THEN 'Comm_Sales'
WHEN pm.neighborhood = '28' THEN 'Comm_Sales' -- < -- Income properties but use regular template, for now. 08/02/2023
WHEN pm.neighborhood BETWEEN '29' AND '41' THEN 'Comm_Sales'
WHEN pm.neighborhood = '41' THEN 'Comm_Sales'
WHEN pm.neighborhood = '42' THEN 'Section42_Workbooks'
WHEN pm.neighborhood = '43' THEN 'Comm_Sales'
WHEN pm.neighborhood = '44' THEN 'Comm_Sales' -- < -- Income properties but use regular template, for now. 08/02/2023
WHEN pm.neighborhood BETWEEN '45' AND '99' THEN 'Comm_Sales'
WHEN pm.neighborhood BETWEEN '100' AND '199' THEN 'Comm_Waterfront'
WHEN pm.neighborhood BETWEEN '200' AND '899' THEN 'Comm_Sales'
--D1
WHEN pm.neighborhood IN ('1008','1010','1410','1420','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507') THEN 'Res_Waterfront'
WHEN pm.neighborhood IN ('1998','1999') THEN 'Res_MultiFamily'
--D2
WHEN pm.neighborhood IN ('2105','2115','2125','2135','2145','2155') THEN 'Res_Waterfront'
WHEN pm.neighborhood IN ('2996','2997','2998','2999') THEN 'Res_MultiFamily'
--D3
WHEN pm.neighborhood IN ('3502','3503','3504','3505','3506') THEN 'Res_Waterfront'
WHEN pm.neighborhood IN ('3998','3999') THEN 'Res_MultiFamily'
--D4
WHEN pm.neighborhood IN ('4201','4202','4203','4204','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507') THEN 'Res_Waterfront'
WHEN pm.neighborhood IN ('4833','4840','4997','4998','4999') THEN 'Res_MultiFamily'
--D5
WHEN pm.neighborhood IN ('5001','5004','5009','5010','5012','5015','5018','5020','5021','5024','5030','5033','5036','5039',
                    '5042','5045','5048','5051','5053','5054','5056','5057','5060','5063','5066','5069','5072','5075','5078',
                    '5081','5750','5753','5756','5759','5762','5765','5850','5853','5856') THEN 'Res_Waterfront'
-- WHEN pm.neighborhood IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D5 as of 08/02/2023
--D6
WHEN pm.neighborhood BETWEEN '6100' AND '6123' THEN 'Res_Waterfront'
-- WHEN pm.neighborhood IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D6 as of 08/02/2023
-- MH Sales Worksheet Type
WHEN pm.neighborhood = '1000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
WHEN pm.neighborhood = '1000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'

WHEN pm.neighborhood = '1020' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
WHEN pm.neighborhood = '1020' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      

WHEN pm.neighborhood = '5000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
WHEN pm.neighborhood = '5000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      

WHEN pm.neighborhood = '5002' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
WHEN pm.neighborhood = '5002' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      

WHEN pm.neighborhood = '6000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
WHEN pm.neighborhood = '6000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'         

WHEN pm.neighborhood = '6002' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
WHEN pm.neighborhood = '6002' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'  

WHEN pm.neighborhood = '9103' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
WHEN pm.neighborhood = '9103' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'      

WHEN pm.neighborhood >= '9000' AND pm.pin LIKE 'M%' THEN 'MH_Sales'
WHEN pm.neighborhood >= '9000' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'    

WHEN pm.neighborhood = '9999' AND pm.pin LIKE 'M%' THEN 'MH_Sales_InResGeos'
WHEN pm.neighborhood >= '9999' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_SalesInResGeos'  

--Else
ELSE 'Res_Sales'
END AS District_SubClass,
pm.lrsn,
TRIM(pm.pin) AS PIN,
TRIM(pm.AIN) AS AIN,
pm.neighborhood AS GEO,
TRIM(pm.NeighborHoodName) AS GEO_Name,
TRIM(pm.PropClassDescr) AS PCC_ClassCD,
TRIM(pm.SitusAddress) AS SitusAddress,
TRIM(pm.SitusCity) AS SitusCity,
pm.LegalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total

FROM TSBv_PARCELMASTER AS pm
--WHERE pm.EffStatus = 'A'

),


-------------------------------------
--CTE_TransferSales
-------------------------------------
CTE_DocCounts AS (
  SELECT 
    DocNum,
    COUNT(DocNum) AS NumOccurrences
  FROM transfer
  WHERE status = 'A'
    AND AdjustedSalePrice <> '0'
    AND pxfer_date BETWEEN @PrimaryTransferDateFROM AND @PrimaryTransferDateTO
  GROUP BY DocNum
),

CTE_TransferSales AS (
SELECT DISTINCT
  t.lrsn
  ,TRIM(t.GrantorName) GrantorName
  ,TRIM(t.GranteeName) GranteeName
  ,t.status
  ,t.AdjustedSalePrice AS SalePrice
  ,CAST(t.pxfer_date AS DATE) AS SaleDate
  ,TRIM(t.SaleDesc) AS SaleDescr
  ,CASE 
    WHEN dc.NumOccurrences > 1 THEN 'M' 
    ELSE 'S' 
  END AS TranxType
  ,TRIM(t.DocNum) AS DocNumber
FROM transfer AS t
JOIN CTE_DocCounts AS dc ON t.DocNum = dc.DocNum
WHERE t.status = 'A'
  AND t.AdjustedSalePrice <> '0'
  AND t.pxfer_date BETWEEN @PrimaryTransferDateFROM AND @PrimaryTransferDateTO
  AND t.deed_type = 'fu'
),


CTE_GEOFACTORS AS (
--------------------------------
--GEO_Factors
--------------------------------

SELECT 

nf.neighborhood AS [GEO],
nf.nei_rating AS [Rating],
nf.cost_or_market AS [Cost_Market],

--For MA Worksheets
CASE
  WHEN nf.value_mod_default = 0
  THEN 1.00
  ELSE CAST(nf.value_mod_default AS DECIMAL(10,2)) / 100 
END AS [Workbook_GeoFactor],
--For MA Worksheets
CASE
  WHEN nf.value_mod_other = 0
  THEN 1.00
  ELSE CAST(nf.value_mod_other AS DECIMAL(10,2)) / 100 
END AS [Worksheet_OtherType],
--For Database
CASE
  WHEN nf.value_mod_default = 0
  THEN 100
  ELSE nf.value_mod_default
END AS [Database_GeoFacter],
--For Database
CASE
  WHEN nf.value_mod_other  = 0
  THEN 100
  ELSE nf.value_mod_other 
END AS [Database_OtherType],

nf.res_model_serial AS [ModelYear],
nf.last_update_long AS [LastUpdated],
nf.UserID AS [UpdatedBy]

FROM neigh_res_impr as nf -- Nieghborhood Factor

WHERE nf.status='A'
AND nf.inactivate_date='99991231'
--AND nf.res_model_serial='2023'
AND nf.res_model_serial=@modelyear
--Filter by desired year

--ORDER BY nf.neighborhood;
),

CTE_BedBath AS (
Select
dw.lrsn,
dw.Bedrooms,
dw.Full_Baths,
dw.Half_Baths,
((CAST(dw.full_baths AS DECIMAL (3,1))) + ( (CAST(dw.half_baths AS DECIMAL (3,1))) / 2)) AS Bath_Total

From dwellings AS dw
Where dw.status IN ('A','F')
--And dw.lrsn IN ('77068','76627','76661','7645','7673','7679','7706') -- Float Home and MH Examples
),

CTE_Other_Improve_Value AS (
Select Distinct
a.lrsn,
SUM(a.cost_value) AS Other_Improv_Value

From allocations AS a
Where a.status='A'
--AND a.improvement_id IN ('M','C','D')--And extension NOT LIKE 'L%'
AND a.improvement_id NOT IN ('M','C','D')--And extension NOT LIKE 'L%'
AND a.extension NOT LIKE 'L%'

--And a.lrsn IN ('77068','76627','76661','7645','7673','7679','7706') -- Float Home Examples
--And a.lrsn IN ('77068')

Group By a.lrsn
),

CTE_MH_TotalBaseRate AS (
Select
lrsn
,mh_length
,mh_width
,total_base_price1 AS ProVal_BaseRate_SqFt_Value
,subtot2_1
,subtot3_1
,subtot4_1
,reproduction_cost1

From dwellings
Where status IN ('A','F')
--And improvement_id = 'M'
--Group By lrsn
--And lrsn = 562833
),

-----------------------
--CTE_MH SF
-----------------------

CTE_MH_SF AS (
Select
lrsn,
SUM(imp_size) AS MH_SF_Total

From improvements AS i
Where status IN ('A','F')
And improvement_id IN ('M','D') 
Group By lrsn
),

CTE_Float_SF AS (
Select Distinct
rf.lrsn,
SUM(rf.finish_living_area) AS Float_SF
--rf.floor_key

  FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
    -- AND e.status = 'A' -- Filter if joining this to another query
  JOIN improvements AS i ON e.lrsn=i.lrsn 
        AND e.extension=i.extension
        AND i.status IN ('A','F')
        AND i.improvement_id IN ('M','C','D')
      --need codes to get the grade name, vs just the grade code#
      LEFT JOIN codes_table AS grades 
      ON i.grade = grades.tbl_element
        AND grades.tbl_type_code='grades'
        AND grades.code_status = 'A'   
        
  JOIN res_floor AS rf
  ON rf.lrsn=e.lrsn
  AND rf.extension=e.extension
  AND rf.dwelling_number=i.dwelling_number
  AND rf.status IN ('A','F')

WHERE e.status IN ('A','F')
--And rf.lrsn IN ('77068','76627','76661') -- Float Home Examples
--And rf.lrsn IN ('77068')
--,'76627','76661') -- Float Home Examples

Group By rf.lrsn

),

CTE_Total_MH_Float_SF AS (
SELECT DISTINCT
pmd.lrsn,
CASE
  WHEN mhsf.MH_SF_Total IS NULL THEN 0
  ELSE mhsf.MH_SF_Total
END AS MH_SF_Total,
CASE
  WHEN flsf.Float_SF IS NULL THEN 0
  ELSE flsf.Float_SF
END AS Float_SF

FROM CTE_ParcelMasterData AS pmd 
--LEFT JOIN CTE_TransferSales AS tr -- ON tr.lrsn for joins
  --ON tr.lrsn=pmd.lrsn

  LEFT JOIN CTE_MH_SF AS mhsf
    ON mhsf.lrsn=pmd.lrsn

-- CTE_Float_SF
  LEFT JOIN CTE_Float_SF AS flsf
    ON flsf.lrsn=pmd.lrsn
-- flsf.Float_SF

),

-------------------------------------
--CTE_Improvements_Residential
-------------------------------------
CTE_Improvements_Residential AS (
----------------------------------
-- View/Master Query: Always e > i > then finally mh, cb, dw
----------------------------------
Select Distinct
--Extensions Table
e.lrsn,
e.extension,
e.ext_description,
e.data_collector,
e.collection_date,
e.appraiser,
e.appraisal_date,
--Improvements Table
  --codes_table 
  --AND park.tbl_type_code='grades'
i.imp_type,
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade AS [GradeCode], -- is this a code that needs a key?
grades.tbl_element_desc AS [GradeType],

-- Residential Dwellings dw
  --codes_table
  -- AND htyp.tbl_type_code='htyp'  
dw.mkt_house_type AS [HouseType#],
htyp.tbl_element_desc AS [HouseTypeName],
dw.mkt_rdf AS [RDF] -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation


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
      AND grades.code_status = 'A'   

--manuf_housing, comm_bldg, dwellings all must be after e and i
--RESIDENTIAL DWELLINGS
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND dw.status='A'
      AND i.extension=dw.extension
  LEFT JOIN codes_table AS htyp 
  ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  
    AND htyp.code_status = 'A'   
     
--MANUFACTERED HOUSING
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

--Conditions
WHERE e.status = 'A'
AND i.improvement_id IN ('D','M')
AND (e.ext_description LIKE '%H1%'
  OR e.ext_description LIKE '%H-1%'
  OR e.ext_description LIKE '%NREV%'
  OR e.ext_description LIKE '%FLOAT%'
  OR e.ext_description LIKE '%BOAT%'
     )
--Order by e.lrsn
),

-------------------------------------
--CTE_Improvements_Commercial
-------------------------------------
CTE_Improvements_Commercial AS (
----------------------------------
-- View/Master Query: Always e > i > then finally mh, cb, dw
-- IN JOIN for Commercial, ensure AND RowNum = 1
----------------------------------

Select Distinct
--Extensions Table
e.lrsn,
e.extension,
e.ext_description,
e.data_collector,
e.collection_date,
e.appraiser,
e.appraisal_date,
--Improvements Table
  --codes_table 
  --AND park.tbl_type_code='grades'
i.imp_type,
--Commercial
STRING_AGG(cu.use_code, ',') AS use_codes,
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade AS [GradeCode], -- is this a code that needs a key?
grades.tbl_element_desc AS [GradeType],
ROW_NUMBER() OVER (PARTITION BY e.lrsn ORDER BY e.extension ASC) AS RowNum

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
      AND grades.code_status='A'
--manuf_housing, comm_bldg, dwellings all must be after e and i
--COMMERCIAL      
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='A'
    LEFT JOIN comm_uses AS cu ON cb.lrsn=cu.lrsn
      AND cb.extension = cu.extension
      AND cu.status='A'

WHERE e.status = 'A'
AND i.improvement_id IN ('C')

GROUP BY
e.lrsn,
e.extension,
e.ext_description,
e.data_collector,
e.collection_date,
e.appraiser,
e.appraisal_date,
i.imp_type,
i.year_built,
i.eff_year_built,
i.year_remodeled,
i.condition,
i.grade,
grades.tbl_element_desc
),






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
,mh.mh_make AS [MHMakeNum]
,make.tbl_element_desc AS [MH_Make]
,mh.mh_model AS [MHModelNum]
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
,dw.mkt_house_type AS [HouseTypeNum]
,htyp.tbl_element_desc AS [HouseTypeName]

,dw.mh_length
,dw.mh_width

,(dw.mh_length * dw.mh_width) AS MH_SF
-- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation

,dw.total_base_price1 AS TotalBaseValue_SFV
--ProVal Values BuildUp Total Base Value

,CASE
  WHEN (dw.total_base_price1) < 0 THEN NULL
  WHEN (dw.total_base_price1) = 0 THEN NULL
  WHEN (dw.mh_length) = 0 THEN NULL
  WHEN (dw.mh_width) = 0 THEN NULL

  ELSE  (dw.total_base_price1 / (dw.mh_length * dw.mh_width))
  
END AS Base_by_SFValue

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
  * (dw.mkt_rdf * 0.010)) AS FinalValuePreGeoFactor

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
    LEFT JOIN codes_table AS grades 
    ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
--manuf_housing, comm_bldg, dwellings all must be after e and i

--RESIDENTIAL DWELLINGS
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND dw.status='A'
      AND i.extension=dw.extension
  LEFT JOIN codes_table AS htyp 
  ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  
    AND htyp.code_status = 'A'
     
  --MANUFACTERED HOUSING
  LEFT JOIN manuf_housing AS mh 
    ON i.lrsn=mh.lrsn 
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
    
WHERE e.status IN ('A','F')
AND i.improvement_id IN ('M')

--And e.lrsn IN ('18138','8677','25261','565970')
--And e.lrsn = 565970 
-- Test LRSN
),

CTE_NotesSalesAnalysis AS (
SELECT
  lrsn,
  STRING_AGG(memo_text, ' | ') AS Sales_Notes
FROM memos

WHERE status = 'A'
AND memo_id IN ('SA', 'SAMH')
AND memo_line_number <> '1'
AND last_update >= @MemoLastUpdatedNoEarlierThan

/*
AND (memo_text LIKE '%/23 %'
    OR memo_text LIKE '%/2023 %'
    OR memo_text LIKE '%/24 %'
    OR memo_text LIKE '%/2024 %')
*/
GROUP BY lrsn

),

CTE_NotesConfidential AS (
SELECT
  lrsn,
  STRING_AGG(memo_text, ' | ') AS Conf_Notes
FROM memos

WHERE status = 'A'
AND memo_id IN ('NOTE')
AND memo_line_number <> '1'
AND last_update >= @MemoLastUpdatedNoEarlierThan

/*
AND (memo_text LIKE '%/23 %'
    OR memo_text LIKE '%/2023 %'
    OR memo_text LIKE '%/24 %'
    OR memo_text LIKE '%/2024 %')
*/
GROUP BY lrsn

),



-------------------------------------
--CTE_CertValues
-------------------------------------
CTE_CertValues AS (
  SELECT 
    v.lrsn,
    --Certified Values
    v.land_market_val AS [Certified_Land],
    v.imp_val AS [Certified_Imp],
    (v.imp_val + v.land_market_val) AS [Certified_TotalValue],
    v.eff_year AS [Tax_Year],
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  --WHERE v.eff_year BETWEEN 20230101 AND 20231231
  WHERE v.eff_year BETWEEN @CertValueDateFROM AND @CertValueDateTO

  
--Change to desired year
    AND v.status = 'A'
),

-------------------------------------
-- CTE_MultiSaleSums
-------------------------------------
-- Common Table Expression (CTE) to calculate the sums for Multi-Sale cases
CTE_MultiSaleSums AS (
SELECT
t.DocNum,
SUM(cv23.[Certified_Land]) AS [MultiSale_Land],
SUM(cv23.[Certified_Imp]) AS [MultiSale_Imp],
SUM(cv23.Certified_TotalValue) AS [MultiSale_TotalSums],
SUM(pm.WorkValue_Impv) AS [MultiSale_WorksheetImp]

FROM transfer AS t -- ON t.lrsn for joins
JOIN CTE_CertValues AS cv23 ON t.lrsn=cv23.lrsn
JOIN CTE_ParcelMasterData AS pm ON t.lrsn=pm.lrsn

WHERE
t.TfrType = 'M' -- Filter only Multi-Sale cases
GROUP BY
t.DocNum
)














-------------------------------------
-- END CTEs
-------------------------------------










-------------------------------------
-- BEGIN Selects
-------------------------------------

SELECT DISTINCT
pmd.District
,pmd.District_SubClass
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,CONCAT(pmd.SitusAddress, ' ', pmd.SitusCity) AS SitusAddress
,pmd.SitusCity
,pmd.PCC_ClassCD
,CAST(LEFT(TRIM(pmd.PCC_ClassCD),3) AS INT) AS PCC_Num
--  mh.HouseType#,
,mh.HouseTypeNum
,mh.HouseTypeName
--MH Home Details
,mh.ext_description
,mh.imp_type
--mh.MHMake#,
,mh.MH_Make
--mh.MHModel#,
,mh.MH_Model
,mh.VIN
--mh.mhpark_code,
,mh.MH_Park

,mh.year_built
,mh.eff_year_built
,mh.year_remodeled

,mh.condition
--  mh.GradeCode, -- is this a code that needs a key?
,mh.GradeType

-- mhsf.Float_SF,
-- (mhsf.MH_SF + mhsf.Float_SF) AS Total_SF,
,bb.Bedrooms
,bb.Full_Baths
,bb.Half_Baths
,bb.Bath_Total

,mh.mh_length
,mh.mh_width
,mh.MH_SF
--,cmhsf.MH_SF_Total

--(tbr.ProVal_BaseRate_SqFt_Value * gf.Workbook_Factor) AS ''
,mh.TotalBaseValue_SFV
,mh.Base_by_SFValue

--,mh.SubTotal_1Unit
--,mh.SubTotal_AllUnits
--,mh.SubTotalGaragesPorches
--,mh.TotalAdjustedBaseValue
,mh.GradeAdjustedBaseValue

,mh.PhysDep
,mh.PhysDepAmount
,mh.FunctDep
,mh.FunctDepAmount
,mh.ObsDep
,mh.ObsDepAmount

,mh.Base_LessDepreciation

,mh.RDF
,mh.RDF_Percentage

,mh.FinalValuePreGeoFactor

,gf.Workbook_GeoFactor
,gf.Database_GeoFacter

,(mh.FinalValuePreGeoFactor * gf.Workbook_GeoFactor) AS FinalValueWithGeoFactor

,otherval.Other_Improv_Value
,pmd.WorkValue_Impv AS ProValWorksheetImpValue

,tr.SaleDescr
,tr.TranxType
,tr.DocNumber -- Multiples will have the same DocNum
,tr.SaleDate
,tr.SalePrice
,tr.GrantorName
,tr.GranteeName





--Notes in the Proval Memo Headers SA or SAMH will show here
,Snotes.Sales_Notes
,Cnotes.Conf_Notes

--, ---Don't run until I tell you so

/*
pmd.*
,cf.*
,tr.*
,bb.*
,otherval.*
,tbr.*
,mhsf.*
,mh.* --Improvements MH
,cval.*
,msv.*
,Snotes.*
,Cnotes.*
*/
-------------------------------------
-- END Selects
-------------------------------------


-------------------------------------
-- BEGIN JOINS
-------------------------------------
--FROM The transfer table to start the filters
FROM CTE_ParcelMasterData AS pmd 

--manufactered home improvements
JOIN CTE_Improvements_MH AS mh 
  ON pmd.lrsn=mh.lrsn
--???????????????????? Is this better JOIN or LEFT JOIN 

LEFT JOIN CTE_GEOFACTORS AS gf
  ON pmd.GEO = gf.GEO

LEFT JOIN CTE_TransferSales AS tr -- ON pmd.lrsn for joins
  ON tr.lrsn=pmd.lrsn
  And tr.status = 'A'

-- res improvements 
LEFT JOIN CTE_Improvements_Residential AS res 
  ON pmd.lrsn=res.lrsn
--comm improvements 
LEFT JOIN CTE_Improvements_Commercial AS comm 
  ON pmd.lrsn=comm.lrsn
  AND comm.RowNum = 1

-- CTE_MH_SF + CTE_Float_SF = CTE_Total_MH_Float_SF
LEFT JOIN CTE_BedBath AS bb
  ON bb.lrsn=pmd.lrsn
  --bb.bedrooms,
  --bb.full_baths,
  --bb.half_baths,
  --bb.Bath_Total

-- CTE_Other_Improve_Value
LEFT JOIN CTE_Other_Improve_Value AS otherval
  ON otherval.lrsn=pmd.lrsn
--otherval.Other_Improv_Value

LEFT JOIN CTE_MH_TotalBaseRate AS tbr
  ON tbr.lrsn = pmd.lrsn

LEFT JOIN CTE_Total_MH_Float_SF AS cmhsf
  ON cmhsf.lrsn = pmd.lrsn

  ----Certified Values
LEFT JOIN CTE_CertValues AS cval
  ON pmd.lrsn=cval.lrsn
  AND cval.RowNumber = '1'

--msv. MultiSale Summed Values <-Complicated to set up, review CTEs
LEFT JOIN CTE_MultiSaleSums AS msv 
  ON tr.DocNumber=msv.DocNum

--Sales Analysis Memos from ProVal
LEFT JOIN CTE_NotesSalesAnalysis AS Snotes 
  ON pmd.lrsn=Snotes.lrsn
--Confidential Notes from ProVal
LEFT JOIN CTE_NotesConfidential AS Cnotes 
  ON pmd.lrsn=Cnotes.lrsn

-------------------------------------
-- END JOINs
-------------------------------------

WHERE tr.GrantorName <> tr.GranteeName



-------------------------------------
-- BEGIN CONDITIONS
-------------------------------------

--WHERE pmd.PIN LIKE ('M%')
--AND tr.SalePrice > 0
--AND pmd.lrsn = 81121

-------------------------------------
-- END CONDITIONS
-------------------------------------


-------------------------------------
-- ORDER BY
-------------------------------------
ORDER BY
pmd.District
,pmd.GEO
,pmd.PIN
,tr.DocNumber
,tr.SaleDate
