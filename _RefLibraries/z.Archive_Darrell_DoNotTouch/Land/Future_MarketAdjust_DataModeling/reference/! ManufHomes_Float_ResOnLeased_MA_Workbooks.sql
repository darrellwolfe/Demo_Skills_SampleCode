/*
-- !preview conn=conn
*/

/*
AsTxDBProd
GRM_Main
*/



Declare @Year int = 2024; -- Input THIS year here
--DECLARE @TaxYear INT;
--SET @TaxYear = YEAR(GETDATE());

Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here


Declare @MemoLastUpdatedNoEarlierThan date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @MemoLastUpdatedNoEarlierThan DATE = '2024-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022

Declare @PrimaryTransferDateFROM date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
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
      
      WHEN pm.neighborhood = '9103' AND (pm.ClassCD = 565 OR pm.ClassCD = 548) THEN 'MH_Sales'
      WHEN pm.neighborhood = '9103' AND (pm.ClassCD <> 565 OR pm.ClassCD <> 548) THEN 'MH_FloatRes_Sales'
--      WHEN pm.neighborhood = '9103' AND pm.pin NOT LIKE 'M%' THEN 'MH_FloatRes_Sales'         

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
CTE_TransferSales AS (
SELECT DISTINCT
--  pmd.[GEO_Name],
  t.lrsn,
  t.status,
--Transfer Table Sale Details
  t.AdjustedSalePrice AS SalePrice,
  CAST(t.pxfer_date AS DATE) AS SaleDate,
  TRIM(t.SaleDesc) AS SaleDescr,
  TRIM(t.TfrType) AS TranxType,
  TRIM(t.DocNum) AS DocNumber -- Multiples will have the same DocNum
FROM transfer AS t -- ON t.lrsn for joins
WHERE t.status = 'A'
  AND t.AdjustedSalePrice <> '0'
  AND t.pxfer_date BETWEEN @PrimaryTransferDateFROM AND @PrimaryTransferDateTO
),



------------------------------------
-- Notes
------------------------------------

CTE_NotesSalesAnalysis AS (
SELECT
  lrsn,
  STRING_AGG(memo_text, ' | ') AS NotesSalesAnalysis
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

-------------------------------------
--CTE_MarketAdjustmentNotes 
-- Using the memos table with SA and SAMH memo_id
--NOTES, CONCAT allows one line of notes instead of duplicate rows, TRIM removes spaces from boths ides
-------------------------------------

CTE_NotesConfidential AS (
SELECT
  lrsn,
  STRING_AGG(memo_text, ' | ') AS NotesConfidential
FROM memos

WHERE status = 'A'
AND memo_id IN ('NOTE','MHPP')
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
  --i.imp_size,
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
  dw.mkt_rdf AS [RDF], -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation
  
  --Commercial
  cu.use_code,
  
  --manuf_housing
      --codes_table 
      --AND make.tbl_type_code='mhmake'
      --AND model.tbl_type_code='mhmodel'    
      --AND park.tbl_type_code='mhpark'
  mh.mh_make AS [MHMake#],
  make.tbl_element_desc AS [MH_Make],
  mh.mh_model AS [MHModel#],
  model.tbl_element_desc AS [MH_Model],
  mh.mh_serial_num AS [VIN],
  mh.mhpark_code,
  park.tbl_element_desc AS [MH_Park]
  
  --Extensions always comes first
  FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
    -- AND e.status = 'A' -- Filter if joining this to another query
  JOIN improvements AS i ON e.lrsn=i.lrsn 
        AND e.extension=i.extension
        --AND i.status='A'
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
  AND i.improvement_id IN ('M')

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
),

  
-------------------------------------
-- CTE_Cat19Waste
-------------------------------------
CTE_Cat19Waste AS (
  SELECT
  lh.RevObjId AS [lrsn],
  ld.LandDetailType,
  ld.LandType,
  lt.land_type_desc,
  ld.SoilIdent,
  ld.LDAcres AS [Cat19Waste]
  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND lh.PostingSource=ld.PostingSource
  --Land Types
  LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type
  
  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'
    AND ld.PostingSource='A'
  --Change land model id for current year
    AND lh.LandModelId='702023'
    AND ld.LandModelId='702023'
  --Looking for:
    AND ld.LandType IN ('82')
    
),

-------------------------------------
-- CTE_LandDetails --cld
-------------------------------------

CTE_LandDetails AS (
  SELECT
  lh.RevObjId AS lrsn,
  ld.LandDetailType,
  ld.lcm,
  ld.LandType,
  lt.land_type_desc,
  ld.SoilIdent,
  ld.LDAcres,
  ld.ActualFrontage,
  ld.DepthFactor,
  ld.SoilProdFactor,
  ld.SmallAcreFactor,
  ld.SiteRating,
  TRIM (sr.tbl_element_desc) AS Legend,
ROW_NUMBER() OVER (PARTITION BY lh.RevObjId ORDER BY sr.tbl_element_desc ASC) AS RowNumber,
  li.InfluenceCode,
  STRING_AGG (li.InfluenceAmount, ',') AS InfluenceFactors,
  li.InfluenceAmount,
  CASE
      WHEN li.InfluenceType = 1 THEN '1-Pct'
      ELSE '2-Val'
  END AS [InfluenceType],
  li.PriceAdjustment
  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
  LEFT JOIN codes_table AS sr ON ld.SiteRating = sr.tbl_element
      AND sr.tbl_type_code='siterating  '

  --Land Types
  LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type
  
  --Land Influence
  LEFT JOIN LandInfluence AS li ON li.ObjectId = ld.Id
    AND li.EffStatus='A' 
    AND li.PostingSource='A'

  
  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'

  --Change land model id for current year
    AND lh.LandModelId='702023'
    AND ld.LandModelId='702023'
    AND ld.LandType IN ('9','31','32')

  --Looking for:
    --AND ld.LandType IN ('82')
    GROUP BY
  lh.RevObjId,
  ld.LandDetailType,
  ld.lcm,
  ld.LandType,
  lt.land_type_desc,
  ld.SoilIdent,
  ld.LDAcres,
  ld.ActualFrontage,
  ld.DepthFactor,
  ld.SoilProdFactor,
  ld.SmallAcreFactor,
  ld.SiteRating,
  sr.tbl_element_desc,
  li.InfluenceCode,
  li.InfluenceAmount,
  li.InfluenceType,
  li.PriceAdjustment
    
),

-----------------------
--CTE_LandDetailsRemAcre pulls the LCM and Land Type for only Remaining Acres legends.
-----------------------
CTE_LandDetailsRemAcre AS (
  SELECT
  lh.RevObjId AS [lrsn],
  ld.LandDetailType,
  ld.lcm,
  ld.LandType
  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
  LEFT JOIN codes_table AS sr ON ld.SiteRating = sr.tbl_element
      AND sr.tbl_type_code='siterating  '

WHERE ld.LandType IN ('91')
AND ld.lcm IN ('3','30')
),

-----------------------
--CTE_CommBldgSF pulls in Commercial SF for a $/SF Rate
-----------------------
CTE_CommBldgSF AS (
  SELECT
    lrsn,
    SUM(area) AS [CommSF]
  FROM comm_uses
  WHERE status = 'A'
  GROUP BY lrsn
  
),

CTE_CommBldMultiSaleSF AS (
  SELECT
    t.DocNum,
    SUM(cbsf.[CommSF]) AS [CommBldMultiSaleSF]
    
    --bring in this table
    
  FROM
    transfer AS t -- ON t.lrsn for joins
    
  JOIN CTE_CommBldgSF AS cbsf ON t.lrsn=cbsf.lrsn

  WHERE
    t.TfrType = 'M' -- Filter only Multi-Sale cases
  GROUP BY
    t.DocNum
),



-----------------------
--CTE_MH SF
-----------------------

CTE_MH_SF AS (
Select
lrsn,
SUM(imp_size) AS MH_SF

From improvements AS i
Where status = 'A'
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
        AND i.status='A'
        AND i.improvement_id IN ('M','C','D')
      --need codes to get the grade name, vs just the grade code#
      LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
        AND grades.tbl_type_code='grades'
        
  JOIN res_floor AS rf
  ON rf.lrsn=e.lrsn
  AND rf.extension=e.extension
  AND rf.dwelling_number=i.dwelling_number
  AND rf.status = 'A'

WHERE e.status = 'A'
--And rf.lrsn IN ('77068','76627','76661') -- Float Home Examples
--And rf.lrsn IN ('77068')
--,'76627','76661') -- Float Home Examples

Group By rf.lrsn

),

CTE_Total_MH_Float_SF AS (
SELECT DISTINCT
pmd.lrsn,
CASE
  WHEN mhsf.MH_SF IS NULL THEN 0
  ELSE mhsf.MH_SF
END AS MH_SF,
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

CTE_BedBath AS (
Select
dw.lrsn,
dw.Bedrooms,
dw.Full_Baths,
dw.Half_Baths,
((CAST(dw.full_baths AS DECIMAL (3,1))) + ( (CAST(dw.half_baths AS DECIMAL (3,1))) / 2)) AS Bath_Total

From dwellings AS dw
Where dw.status='A'
--And dw.lrsn IN ('77068','76627','76661','7645','7673','7679','7706') -- Float Home and MH Examples
),

CTE_MH_Float_Value AS (
Select Distinct
a.lrsn,
SUM(a.cost_value) AS MH_Float_Value

From allocations AS a
Where a.status='A'
AND a.improvement_id IN ('M','C','D')--And extension NOT LIKE 'L%'
AND a.extension NOT LIKE 'L%'

--AND a.improvement_id NOT IN ('M','C','D')--And extension NOT LIKE 'L%'
--And a.lrsn IN ('77068','76627','76661','7645','7673','7679','7706') -- Float Home Examples
--And a.lrsn IN ('77068')

Group By a.lrsn
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



-------------------------
--CTE_WaterFrontExtravaganza Madness
--Involves Multiple CTEs
-- -- CTE_LandInfluenceCodesKey
-- -- CTE_LegendKey
-- -- CTE_Legend_WF_90 
-- -- CTE_Legend_WF_94 
-- -- CTE_Legend_WF_95 
-- -- CTE_LandInfluence_Length 
-- -- CTE_LandInfluence_OCR 
-- -- CTE_LandInfluence_Other 
-- Only the final CTE_WaterFrontExtravaganza
--    needs to be pulled into the final query
-------------------------
--CTE_LandInfluenceCodesKey + CTE_LegendKey rquired to use Land Details
CTE_LandInfluenceCodesKey AS (
  SELECT
  tbl_element AS InfluenceCode,
  tbl_element_desc AS InfluenceCodeDescription,
    CASE
    WHEN tbl_element_desc IS NULL THEN NULL
    WHEN tbl_element_desc LIKE '%OCR%' THEN 'OCR'
    WHEN tbl_element_desc LIKE '%length%' THEN 'Length'
  ELSE 'Other'
  END AS LandInfluence_AdjustmentGroups
  
  FROM codes_table
  
  WHERE TRIM(tbl_type_code) LIKE 'landinf%'
  AND code_status='A'
),
--CTE_LandInfluenceCodesKey + CTE_LegendKey rquired to use Land Details
CTE_LegendKey AS (
  SELECT
  TRIM(sr.tbl_element) AS Site_Rating,
  TRIM(sr.tbl_element_desc) AS Legend,
  CASE
    WHEN TRIM(sr.tbl_element_desc) LIKE 'Leg%' THEN CAST(RIGHT(TRIM(sr.tbl_element_desc),2) AS INT)
    ELSE
      CASE
        WHEN sr.tbl_element_desc IS NULL THEN CAST(1 AS INT)
        WHEN sr.tbl_element_desc LIKE 'No%' THEN CAST(1 AS INT)
        WHEN sr.tbl_element_desc LIKE 'Average%' THEN CAST(2 AS INT)
        WHEN sr.tbl_element_desc LIKE 'Good%' THEN CAST(3 AS INT)
        WHEN sr.tbl_element_desc LIKE 'Excellent%' THEN CAST(4 AS INT)
        ELSE 0
      END
  END AS LegendNum

  FROM codes_table AS sr 
      
  WHERE sr.tbl_type_code='siterating'
  AND code_status = 'A'
  --JOIN ON
  --ON ld.SiteRating = sr.tbl_element
),

--------------NEW STARTS HERE ---------------------

CTE_Legend_WF_90 AS (
  SELECT
  lh.RevObjId AS lrsn,
  ld.Id AS LandInfluence_ObjectId,
  ld.LandDetailType,
  ld.lcm,
  ld.LandType,
  lt.land_type_desc,
  ld.SoilIdent,
  ld.ActualFrontage,
  ld.EffFrontage,
  ld.EffDepth,
  ld.LDAcres,
  ld.SqrFeet,
  ld.DepthFactor,
  ld.SoilProdFactor,
  ld.SmallAcreFactor,
  ld.SiteRating,
  leg.Legend,
  CASE
    WHEN leg.Legend IS NULL THEN CAST(1 AS INT)
    ELSE leg.LegendNum
  END AS Legend_Number,

ROW_NUMBER() OVER (PARTITION BY lh.RevObjId ORDER BY leg.LegendNum ASC) AS RowNumber
  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
  --Legend Key    
  LEFT JOIN CTE_LegendKey AS leg ON ld.SiteRating = leg.Site_Rating
  --Land Types
  LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type
  --Land Influence
  LEFT JOIN LandInfluence AS li ON li.ObjectId = ld.Id
    AND li.EffStatus='A' 
    AND li.PostingSource='A'
  --Land Influcnce Code Key for Description
  LEFT JOIN CTE_LandInfluenceCodesKey AS lic ON lic.InfluenceCode=li.InfluenceCode
  
  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'

  --Change land model id for current year
    AND lh.LandModelId='702023'
    AND ld.LandModelId='702023'
    AND ld.LandType IN ('90')
  --Looking for:
    --AND lh.RevObjId= 5 --< For testing results
    --AND ld.LandType IN ('82')

),

CTE_Legend_WF_94 AS (
  SELECT
  lh.RevObjId AS lrsn,
  ld.Id AS LandInfluence_ObjectId,
  ld.LandDetailType,
  ld.lcm,
  ld.LandType,
  lt.land_type_desc,
  ld.SoilIdent,
  ld.ActualFrontage,
  ld.EffFrontage,
  ld.EffDepth,
  ld.LDAcres,
  ld.SqrFeet,
  ld.DepthFactor,
  ld.SoilProdFactor,
  ld.SmallAcreFactor,
  ld.SiteRating,
  leg.Legend,
  CASE
    WHEN leg.Legend IS NULL THEN CAST(1 AS INT)
    ELSE leg.LegendNum
  END AS Legend_Number,

ROW_NUMBER() OVER (PARTITION BY lh.RevObjId ORDER BY leg.LegendNum ASC) AS RowNumber
  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
  --Legend Key    
  LEFT JOIN CTE_LegendKey AS leg ON ld.SiteRating = leg.Site_Rating
  --Land Types
  LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type
  --Land Influence
  LEFT JOIN LandInfluence AS li ON li.ObjectId = ld.Id
    AND li.EffStatus='A' 
    AND li.PostingSource='A'
  --Land Influcnce Code Key for Description
  LEFT JOIN CTE_LandInfluenceCodesKey AS lic ON lic.InfluenceCode=li.InfluenceCode
  
  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'

  --Change land model id for current year
    AND lh.LandModelId='702023'
    AND ld.LandModelId='702023'
    AND ld.LandType IN ('94')
  --Looking for:
    --AND lh.RevObjId= 5 --< For testing results
    --AND ld.LandType IN ('82')

),

CTE_Legend_WF_95 AS (
  SELECT
  lh.RevObjId AS lrsn,
  ld.Id AS LandInfluence_ObjectId,
  ld.LandDetailType,
  ld.lcm,
  ld.LandType,
  lt.land_type_desc,
  ld.SoilIdent,
  ld.ActualFrontage,
  ld.EffFrontage,
  ld.EffDepth,
  ld.LDAcres,
  ld.SqrFeet,
  ld.DepthFactor,
  ld.SoilProdFactor,
  ld.SmallAcreFactor,
  ld.SiteRating,
  leg.Legend,
  CASE
    WHEN leg.Legend IS NULL THEN CAST(1 AS INT)
    ELSE leg.LegendNum
  END AS Legend_Number,

ROW_NUMBER() OVER (PARTITION BY lh.RevObjId ORDER BY leg.LegendNum ASC) AS RowNumber
  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    ---AND li_length.ObjectId = ld.Id

  --Legend Key    
  LEFT JOIN CTE_LegendKey AS leg ON ld.SiteRating = leg.Site_Rating
  --Land Types
  LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'

  --Change land model id for current year
    AND lh.LandModelId='702023'
    AND ld.LandModelId='702023'
    AND ld.LandType IN ('95')
  --Looking for:
    --AND lh.RevObjId= 5 --< For testing results
    --AND ld.LandType IN ('82')

),

CTE_LandInfluence_Length AS (
SELECT DISTINCT
  lh.RevObjId,
  li.ObjectId,
  TRIM(li.InfluenceCode) AS InfluenceCode,
  --TRIM(lic.InfluenceCode) AS InfluenceCode2,
  lic.InfluenceCodeDescription,
  lic.LandInfluence_AdjustmentGroups AS Length,
  li.InfluenceAmount AS InfluenceAmount_Length,
    -- li.InfluenceType 1 is percentages and type 2 is dollar amounts
  CASE
    WHEN li.InfluenceType = 1 THEN '1-Pct'
    ELSE '2-Val'
  END AS InfluenceType_Length


  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
    
-- Land Influence Adjustment - Length
  LEFT JOIN LandInfluence AS li 
    ON li.ObjectId = ld.Id
    AND li.EffStatus='A' 
    AND li.PostingSource='A'

    
  JOIN CTE_LandInfluenceCodesKey AS lic
    ON TRIM(lic.InfluenceCode)=TRIM(li.InfluenceCode)
    AND lic.LandInfluence_AdjustmentGroups = 'Length'

  --Land Types
  LEFT JOIN land_types AS lt 
    ON ld.LandType=lt.land_type

WHERE li.InfluenceCode IS NOT NULL
AND li.InfluenceCode <> '0'
AND li.InfluenceCode <> ''
),

CTE_LandInfluence_OCR AS (
SELECT DISTINCT
  lh.RevObjId,
  li.ObjectId,
  TRIM(li.InfluenceCode) AS InfluenceCode,
  --TRIM(lic.InfluenceCode) AS InfluenceCode2,
  
  lic.InfluenceCodeDescription,
  lic.LandInfluence_AdjustmentGroups AS OCR,
  li.InfluenceAmount AS InfluenceAmount_OCR,
    -- li.InfluenceType 1 is percentages and type 2 is dollar amounts
  CASE
    WHEN li.InfluenceType = 1 THEN '1-Pct'
    ELSE '2-Val'
  END AS InfluenceType_OCR

  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
    
-- Land Influence Adjustment - Length
  LEFT JOIN LandInfluence AS li 
    ON li.ObjectId = ld.Id
    AND li.EffStatus='A' 
    AND li.PostingSource='A'

    
  JOIN CTE_LandInfluenceCodesKey AS lic
    ON TRIM(lic.InfluenceCode)=TRIM(li.InfluenceCode)
    AND lic.LandInfluence_AdjustmentGroups = 'OCR'

  --Land Types
  LEFT JOIN land_types AS lt 
    ON ld.LandType=lt.land_type

WHERE li.InfluenceCode IS NOT NULL
AND li.InfluenceCode <> '0'
AND li.InfluenceCode <> ''
),

CTE_LandInfluence_Other AS (
SELECT DISTINCT
  lh.RevObjId,
  li.ObjectId,
  TRIM(li.InfluenceCode) AS InfluenceCode,
  --TRIM(lic.InfluenceCode) AS InfluenceCode2,
  
  lic.InfluenceCodeDescription,
  lic.LandInfluence_AdjustmentGroups AS Other,
  li.InfluenceAmount AS InfluenceAmount_Other,
    -- li.InfluenceType 1 is percentages and type 2 is dollar amounts
  CASE
    WHEN li.InfluenceType = 1 THEN '1-Pct'
    ELSE '2-Val'
  END AS InfluenceType_Other

  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
    
-- Land Influence Adjustment - Length
  LEFT JOIN LandInfluence AS li 
    ON li.ObjectId = ld.Id
    AND li.EffStatus='A' 
    AND li.PostingSource='A'

    
  JOIN CTE_LandInfluenceCodesKey AS lic
    ON TRIM(lic.InfluenceCode)=TRIM(li.InfluenceCode)
    AND lic.LandInfluence_AdjustmentGroups = 'Other'

  --Land Types
  LEFT JOIN land_types AS lt 
    ON ld.LandType=lt.land_type

WHERE li.InfluenceCode IS NOT NULL
AND li.InfluenceCode <> '0'
AND li.InfluenceCode <> ''
),


CTE_WaterFrontExtravaganza AS (

SELECT DISTINCT
  pmd.lrsn,
--Waterfront CTE_Legend_WF 90
  legwf90.LandType AS WF90,
  legwf90.land_type_desc AS WF_Homesite,
  legwf90.ActualFrontage AS FF_90,
  --legwf90.SiteRating AS WF_SiteRating,
  legwf90.Legend AS WF90_LegendDesc,
  legwf90.Legend_Number AS WF90_Legend,
-- Land Influence Data
  li_length_90.Length AS Length_90,
  li_length_90.InfluenceAmount_Length AS InfluenceAmount_Length_90,
  li_length_90.InfluenceType_Length AS InfluenceType_Length_90,

  li_ocr_90.OCR AS OCR_90,
  li_ocr_90.InfluenceAmount_OCR AS InfluenceAmount_OCR_90,
  li_ocr_90.InfluenceType_OCR AS InfluenceType_OCR_90,
  
  li_other_90.Other AS Other_90,
  li_other_90.InfluenceAmount_Other AS InfluenceAmount_Other_90,
  li_other_90.InfluenceType_Other AS InfluenceType_Other_90,
  
--Waterfront CTE_Legend_WF 94
  legwf94.LandType AS WF94,
  legwf94.land_type_desc AS WF_Vacant_Buildable,
  legwf94.ActualFrontage AS FF_94,
  --legwf94.SiteRating AS WF_SiteRating,
  legwf94.Legend AS WF94_LegendDesc,
  legwf94.Legend_Number AS WF94_Legend,
-- Land Influence Data
  li_length_94.Length AS Length_94,
  li_length_94.InfluenceAmount_Length AS InfluenceAmount_Length_94,
  li_length_94.InfluenceType_Length AS InfluenceType_Length_94,

  li_ocr_94.OCR AS OCR_94,
  li_ocr_94.InfluenceAmount_OCR AS InfluenceAmount_OCR_94,
  li_ocr_94.InfluenceType_OCR AS InfluenceType_OCR_94,
  
  li_other_94.Other AS Other_94,
  li_other_94.InfluenceAmount_Other AS InfluenceAmount_Other_94,
  li_other_94.InfluenceType_Other AS InfluenceType_Other_94,


--Waterfront CTE_Legend_WF 95
  legwf95.LandType AS WF95,
  legwf95.land_type_desc AS WF_Vacant_NonBuildable,
  legwf95.ActualFrontage AS FF_95,
  --legwf95.SiteRating AS WF_SiteRating,
  legwf95.Legend AS WF95_LegendDesc,
  legwf95.Legend_Number AS WF95_Legend,
-- Land Influence Data
  li_length_95.Length AS Length_95,
  li_length_95.InfluenceAmount_Length AS InfluenceAmount_Length_95,
  li_length_95.InfluenceType_Length AS InfluenceType_Length_95,

  li_ocr_95.OCR AS OCR_95,
  li_ocr_95.InfluenceAmount_OCR AS InfluenceAmount_OCR_95,
  li_ocr_95.InfluenceType_OCR AS InfluenceType_OCR_95,
  
  li_other_95.Other AS Other_95,
  li_other_95.InfluenceAmount_Other AS InfluenceAmount_Other_95,
  li_other_95.InfluenceType_Other AS InfluenceType_Other_95

FROM CTE_ParcelMasterData AS pmd 
--ON t.lrsn=pmd.lrsn
/*
LEFT JOIN CTE_LandDetails AS cld ON pmd.lrsn=cld.lrsn
  AND cld.[RowNumber] = '1'
--cld. Land Details
*/
LEFT JOIN CTE_Legend_WF_90 AS legwf90 
  ON pmd.lrsn=legwf90.lrsn
  --Land Influence
  LEFT JOIN CTE_LandInfluence_Length AS li_length_90
    ON li_length_90.RevObjId=legwf90.lrsn
    AND li_length_90.ObjectId = legwf90.LandInfluence_ObjectId
  
  LEFT JOIN CTE_LandInfluence_OCR AS li_ocr_90
    ON li_ocr_90.RevObjId=legwf90.lrsn
    AND li_ocr_90.ObjectId = legwf90.LandInfluence_ObjectId
  
  LEFT JOIN CTE_LandInfluence_Other AS li_other_90
    ON li_other_90.RevObjId=legwf90.lrsn
    AND li_other_90.ObjectId = legwf90.LandInfluence_ObjectId


LEFT JOIN CTE_Legend_WF_94 AS legwf94 
  ON pmd.lrsn=legwf94.lrsn
  --Land Influence
  LEFT JOIN CTE_LandInfluence_Length AS li_length_94
    ON li_length_94.RevObjId=legwf94.lrsn
    AND li_length_94.ObjectId = legwf94.LandInfluence_ObjectId
  
  LEFT JOIN CTE_LandInfluence_OCR AS li_ocr_94
    ON li_ocr_94.RevObjId=legwf94.lrsn
    AND li_ocr_94.ObjectId = legwf94.LandInfluence_ObjectId
  
  LEFT JOIN CTE_LandInfluence_Other AS li_other_94
    ON li_other_94.RevObjId=legwf94.lrsn
    AND li_other_94.ObjectId = legwf94.LandInfluence_ObjectId


LEFT JOIN CTE_Legend_WF_95 AS legwf95 
  ON pmd.lrsn=legwf95.lrsn
  --Land Influence
  LEFT JOIN CTE_LandInfluence_Length AS li_length_95
    ON li_length_95.RevObjId=legwf95.lrsn
    AND li_length_95.ObjectId = legwf95.LandInfluence_ObjectId
  
  LEFT JOIN CTE_LandInfluence_OCR AS li_ocr_95
    ON li_ocr_95.RevObjId=legwf95.lrsn
    AND li_ocr_95.ObjectId = legwf95.LandInfluence_ObjectId
  
  LEFT JOIN CTE_LandInfluence_Other AS li_other_95
    ON li_other_95.RevObjId=legwf95.lrsn
    AND li_other_95.ObjectId = legwf95.LandInfluence_ObjectId

--WHERE pmd.lrsn= 5
--WHERE pmd.lrsn= 6
--WHERE pmd.lrsn= 6101
--WHERE pmd.lrsn= 6
--WHERE pmd.lrsn= 6
--AND lh.RevObjId= 53923
--AND t.lrsn= 53923

--ORDER BY lrsn

),

CTE_CAREA AS (
  SELECT 
  lh.RevObjId AS lrsn,
  
  --ld.Id AS LandInfluence_ObjectId,
  --ld.LandDetailType,
  --ld.lcm,
  --ld.LandType,
  --lt.land_type_desc,
  ld.LDAcres AS CAREA_Acres
  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
  --Land Types
  LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type
  
  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'

  --Change land model id for current year
    AND lh.LandModelId='702023'
    AND ld.LandModelId='702023'
    AND ld.LandType IN ('C')
  --Looking for:
    --AND lh.RevObjId= 5 --< For testing results
    --AND ld.LandType IN ('82')
),

-------------------------------------
--FIlters for which table the MH vs Float/R000 sales come from.
-------------------------------------
CTE_MH_Sales AS (
SELECT DISTINCT
pmdmh.lrsn
,pmdmh.PIN
,pmdmh.GEO
FROM CTE_ParcelMasterData AS pmdmh
WHERE pmdmh.District = 'Manufactured_Homes'
AND pmdmh.PIN LIKE 'M%'
--ORDER BY GEO
),
MH_ResFloat_Sales AS (
SELECT DISTINCT
pmdmhfs.lrsn
,pmdmhfs.PIN
,pmdmhfs.GEO
FROM CTE_ParcelMasterData AS pmdmhfs
WHERE pmdmhfs.District = 'Manufactured_Homes'
AND pmdmhfs.PIN NOT LIKE 'M%'
--ORDER BY GEO
)
-------------------------------------
-- End of CTEs
-------------------------------------

-------------------------------------
--START Primary Qeury, Driven by Transfer Table
--FROM Transfer table, JOIN CTEs
-------------------------------------
SELECT DISTINCT
pmd.District,
-- # District SubClass
pmd.District_SubClass,
  --This query is driven by Transfer Table, sales in 2022-2023
  --Parcel Master Details
  pmd.GEO,
--  pmd.[GEO_Name],
  tr.lrsn,
--  mhs.PIN AS HM_PIN,
--  mhfs.PIN AS MH_Float_PIN,
  pmd.PIN,
  pmd.AIN,
  CONCAT(pmd.SitusAddress, ' ', pmd.SitusCity) AS SitusAddress,
  --pmd.[SitusCity],
  pmd.PCC_ClassCD,
  CAST(LEFT(TRIM(pmd.PCC_ClassCD),3) AS INT) AS PCC_Num,

----------------------------
--Manufactered Home Start
---------------------------

----------------------------
--Residential Regular Start
---------------------------
--Qeury for Res, Comm, and Manufactered Homes is identical, include or exclude the columns with res,comm,mf
  --Residential Details
  res.year_built,
  res.eff_year_built,
  res.year_remodeled,
  --res.[GradeCode], -- is this a code that needs a key?
  TRIM(res.condition) AS Condition,
  TRIM(res.GradeType) AS Grade,
--  res.HouseType#, --?
  TRIM(res.HouseTypeName) AS HouseTypeName,
  res.RDF, -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation
  /*
-- THIS ONLY PULLS MH NOT FLOATS OR R000000. 

--MH Home Details
  mh.imp_type,
  mh.year_built,
  mh.eff_year_built,
  mh.year_remodeled,
  mh.condition,
  --mh.[GradeCode], -- is this a code that needs a key?
  mh.[GradeType],
--  mh.[HouseType#],
  mh.[HouseTypeName],
  mh.[RDF], -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation
  --mh.[MHMake#],
  mh.[MH_Make],
  --mh.[MHModel#],
  mh.[MH_Model],
  mh.[VIN],
  --mh.mhpark_code,
  mh.[MH_Park],
  */
-------------------------
-- SF and Other Improvement
-------------------------
  --mhsf.MH_SF,
  mhsf.Float_SF,
  --(mhsf.MH_SF + mhsf.Float_SF) AS Total_SF,
  bb.Bedrooms,
  bb.Full_Baths,
  bb.Half_Baths,
  bb.Bath_Total,



----------------------------
--Manufactered Home End
---------------------------



/*
carea.CAREA_Acres,

-----------------------------
--Non-WF Land
-----------------------------
--ACRES Calcs Legal, Site, Cat19 Waste, see CTE for details
-- Added [Cat19Waste] ISNULL and CASE to handle NAs
  pmd.LegalAcres,
  CAST (1 AS int) AS [Site_1_Acre],
  ISNULL(c19.[Cat19Waste], 0) AS [Cat19Waste],
    CASE 
        WHEN pmd.LegalAcres > 1 THEN pmd.LegalAcres - CAST(1 AS int) - ISNULL(c19.[Cat19Waste], 0)
        ELSE NULL
    END AS [Remaining_Acres],
  RemAcres.lcm AS RemAcresLCM,
  --RemAcres.LandType, -- Use as test for reference not in final workbook
*/

/*
-----------------------------
--Non-WF Land LEGEND and INFLUENCE START
-----------------------------
--LEGEND CASE Land Detail
  legkey.Legend,
  CASE
    WHEN legkey.Legend IS NULL THEN CAST(1 AS INT)
    ELSE legkey.LegendNum
  END AS Legend_Number,

--INFLUENCE FACTOR CASE Land Detail
  cld.InfluenceType,
  --cld.[InfluenceFactor(s)],
  CASE 
    WHEN cld.InfluenceType LIKE '1%' THEN CAST(TRIM(cld.InfluenceFactors) AS DECIMAL(10, 2)) / 100.0
    -- Without this (/100) it produces "10" for 10%, but we need it to be 0.10 for math.
    ELSE NULL 
  END AS InfluenceFactor1,
  CASE 
    WHEN cld.InfluenceType LIKE '2%' THEN CAST(TRIM(cld.InfluenceFactors) AS INT)
    ELSE NULL 
  END AS InfluenceFactor2,
-----------------------------
--Non-WF Land LEGEND and INFLUENCE END
-----------------------------
*/




/*
-------------------------
-- WaterFront START
-------------------------
--CTE_WaterFrontExtravaganza Madness
--Involves Multiple CTEs
-- -- CTE_LandInfluenceCodesKey
-- -- CTE_LegendKey
-- -- CTE_Legend_WF_90 
-- -- CTE_Legend_WF_94 
-- -- CTE_Legend_WF_95 
-- -- CTE_LandInfluence_Length 
-- -- CTE_LandInfluence_OCR 
-- -- CTE_LandInfluence_Other 
-- Only the final CTE_WaterFrontExtravaganza
--    needs to be pulled into the final query
--IF there are two Homesites, it will create two rows,
-- Appraisers will have to adjust manually, because if we don't pull that in, 
-- they'll be missing data they need to get the right ratio.
-------------------------

--Waterfront CTE_Legend_WF 90
--Marking out un-needed columns, 
--  but leaving as marked out in case they're needed for reference later.
-- InfluenceType_ is either 1-Pct or 2-Val
-- After reviewing original workbooks, they were based on percentage
-- commenting out the type for now.

  --wf.WF90,
  --wf.WF_Homesite,
  wf.FF_90,
  --wf.WF90_LegendDesc,
  wf.WF90_Legend,
  --wf.Length_90,
  CAST(wf.InfluenceAmount_Length_90 AS FLOAT)/100.00 AS Influence_Length_90,
  --wf.InfluenceType_Length_90,
  --wf.OCR_90,
  CAST(wf.InfluenceAmount_OCR_90 AS FLOAT)/100.00 AS Influence_OCR_90,
  --wf.InfluenceType_OCR_90,
  --wf.Other_90,
  CAST(wf.InfluenceAmount_Other_90 AS FLOAT)/100.00 AS Influence_Other_90,
  --wf.InfluenceType_Other_90,
--Waterfront CTE_Legend_WF 94
  --wf.WF94,
  --wf.WF_Vacant_Buildable,
  wf.FF_94,
  --wf.WF94_LegendDesc,
  wf.WF94_Legend,
  --wf.Length_94,
  CAST(wf.InfluenceAmount_Length_94 AS FLOAT)/100.00 AS Influence_Length_94,
  --wf.InfluenceType_Length_94,
  --wf.OCR_94,
  CAST(wf.InfluenceAmount_OCR_94 AS FLOAT)/100.00 AS Influence_OCR_94,
  --wf.InfluenceType_OCR_94,
  --wf.Other_94,
  CAST(wf.InfluenceAmount_Other_94 AS FLOAT)/100.00 AS Influence_Other_94,
  --wf.InfluenceType_Other_94,
--Waterfront CTE_Legend_WF 95
  --wf.WF95,
  --wf.WF_Vacant_NonBuildable,
  wf.FF_95,
  --wf.WF95_LegendDesc,
  wf.WF95_Legend,
  --wf.Length_95,
  CAST(wf.InfluenceAmount_Length_95 AS FLOAT)/100.00 AS Influence_Length_95,
  --wf.InfluenceType_Length_95,
  --wf.OCR_95,
  CAST(wf.InfluenceAmount_OCR_95 AS FLOAT)/100.00 AS Influence_OCR_95,
  --wf.InfluenceType_OCR_95,
  --wf.Other_95,
  CAST(wf.InfluenceAmount_Other_95 AS FLOAT)/100.00 AS Influence_Other_95,
  --wf.InfluenceType_Other_95,
-------------------------
-- WaterFront End
-------------------------
*/



---------------------------
--ALWAYS INCLUDE BELOW
--Value Calculations
  --------------------------
  mhval.MH_Float_Value AS Float_or_Res_Value,
  otherval.Other_Improv_Value,
  pmd.WorkValue_Impv AS WorksheetImpValue,
  --Certified Values 2023
  --cv23.Certified_Land,
  cv23.Certified_Imp,
  cv23.Certified_TotalValue,



--Transfer Table Sale Details
  tr.SalePrice,
  tr.SaleDate,
  tr.SaleDescr,
  tr.TranxType,
  tr.DocNumber, -- Multiples will have the same DocNum

---MultiSale Logic
  --COALESCE(msv.MultiSale_Land, 0) AS MultiSale_Land,-
--  COALESCE(msv.MultiSale_Imp, 0) AS MultiSale_Imp,
--  COALESCE(msv.MultiSale_TotalSums,  0) AS MultiSale_TotalSums,
--  COALESCE(msv.MultiSale_WorksheetImp, 0) AS MultiSale_WorksheetImp, 
--Improved vs vacant (unimproved)
  --pmd.Improvement_Status,
-- "_" AS [NotesInSeperate part of sheet>>>],
  --Notes in the Proval Memo Headers SA or SAMH will show here
  Snotes.NotesSalesAnalysis,
  Cnotes.NotesConfidential


--FROM The transfer table to start the filters
FROM CTE_TransferSales AS tr -- ON tr.lrsn for joins
--FROM CTE_ParcelMasterData AS pmd 
--CTEs
-- Join Parcel Master
JOIN CTE_ParcelMasterData AS pmd 
--LEFT JOIN CTE_TransferSales AS tr -- ON tr.lrsn for joins
  ON tr.lrsn=pmd.lrsn

LEFT JOIN CTE_MH_Sales AS mhs
  ON mhs.lrsn=pmd.lrsn

LEFT JOIN MH_ResFloat_Sales AS mhfs
  ON mhfs.lrsn=pmd.lrsn



-- res improvements 
  LEFT JOIN CTE_Improvements_Residential AS res 
    ON tr.lrsn=res.lrsn
  --comm improvements 
  LEFT JOIN CTE_Improvements_Commercial AS comm 
    ON tr.lrsn=comm.lrsn
    AND comm.RowNum = 1
  --manufactered home improvements
  LEFT JOIN CTE_Improvements_MH AS mh 
    ON tr.lrsn=mh.lrsn
    ----Certified Values
  LEFT JOIN CTE_CertValues AS cv23 
    ON tr.lrsn=cv23.lrsn
    AND cv23.RowNumber = '1'
  --msv. MultiSale Summed Values <-Complicated to set up, review CTEs
  LEFT JOIN CTE_MultiSaleSums AS msv 
    ON tr.DocNumber=msv.DocNum
  --CTE_Cat19Waste  as c19.
  LEFT JOIN CTE_Cat19Waste AS c19 
    ON tr.lrsn=c19.lrsn
  -- Commercial Square Foot
  LEFT JOIN CTE_CommBldgSF AS commsf 
    ON tr.lrsn=commsf.lrsn
  --Commercial Bldg MultiSale Information, see CTEs
  --commsfMSale.[CommBldMultiSaleSF]
  LEFT JOIN CTE_CommBldMultiSaleSF AS commsfMSale 
    ON  tr.DocNumber=commsfMSale.DocNum

  --Land Details CTE 
--<< Can this be replaced with the new WF CTEs?? >>
    LEFT JOIN CTE_LandDetails AS cld 
      ON tr.lrsn=cld.lrsn
      AND cld.[RowNumber] = '1'
      
    LEFT JOIN CTE_LegendKey AS legkey
      ON legkey.Site_Rating=cld.SiteRating

      
-- Remaining Acres needed its own CTE
  LEFT JOIN CTE_LandDetailsRemAcre AS RemAcres 
    ON tr.lrsn=RemAcres.lrsn
    
-- CAREA
  LEFT JOIN CTE_CAREA AS carea
    ON carea.lrsn=tr.lrsn

-- CTE_MH_SF + CTE_Float_SF = CTE_Total_MH_Float_SF
  LEFT JOIN CTE_Total_MH_Float_SF AS mhsf
    ON mhsf.lrsn=tr.lrsn

-- CTE_MH_SF + CTE_Float_SF = CTE_Total_MH_Float_SF
  LEFT JOIN CTE_BedBath AS bb
    ON bb.lrsn=tr.lrsn
    --bb.bedrooms,
    --bb.full_baths,
    --bb.half_baths,
    --bb.Bath_Total

-- CTE_MH_Float_Value
  LEFT JOIN CTE_MH_Float_Value AS mhval
    ON mhval.lrsn=tr.lrsn
  --  mhval.MH_Float_Value

-- CTE_Other_Improve_Value
  LEFT JOIN CTE_Other_Improve_Value AS otherval
    ON otherval.lrsn=tr.lrsn
  --otherval.Other_Improv_Value




-------------------------
--CTE_WaterFrontExtravaganza Madness
--Involves Multiple CTEs
-- -- CTE_LandInfluenceCodesKey
-- -- CTE_LegendKey
-- -- CTE_Legend_WF_90 
-- -- CTE_Legend_WF_94 
-- -- CTE_Legend_WF_95 
-- -- CTE_LandInfluence_Length 
-- -- CTE_LandInfluence_OCR 
-- -- CTE_LandInfluence_Other 
-- Only the final CTE_WaterFrontExtravaganza
--    needs to be pulled into the final query
--IF there are two Homesites, it will create two rows,
-- Appraisers will have to adjust manually, because if we don't pull that in, 
-- they'll be missing data they need to get the right ratio.
-------------------------
  LEFT JOIN CTE_WaterFrontExtravaganza AS wf 
    ON tr.lrsn=wf.lrsn
-------------------------

  --Sales Analysis Memos from ProVal
  LEFT JOIN CTE_NotesSalesAnalysis AS Snotes 
    ON tr.lrsn=Snotes.lrsn
  --Confidential Notes from ProVal
  LEFT JOIN CTE_NotesConfidential AS Cnotes 
    ON tr.lrsn=Cnotes.lrsn

-----------------------
--END FROM/JOINS
-----------------------

-------------------------------------
--BEGIN WHERE Conditions for t only, all others drive CTEs or JOINs
-------------------------------------
WHERE tr.status = 'A'
--AND pmd.AIN IN ('142762','135478','249334') -- Use to test cases only
--AND   tr.TranxType = 'M'
AND pmd.PCC_ClassCD NOT LIKE '565%'




/*
--WaterFront Test
AND (pmd.GEO BETWEEN '100' AND '199'
  OR pmd.GEO IN ('1008','1010','1410','1420','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507')
  OR pmd.GEO IN ('2105','2115','2125','2135','2145','2155')
  OR pmd.GEO IN ('3502','3503','3504','3505','3506')
  OR pmd.GEO IN ('4201','4202','4203','4204','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507')
  OR pmd.GEO IN ('5001','5004','5009','5010','5012','5015','5018','5020','5021','5024','5030','5033','5036','5039',
                                '5042','5045','5048','5051','5053','5054','5056','5057','5060','5063','5066','5069','5072','5075','5078',
                                '5081','5750','5753','5756','5759','5762','5765','5850','5853','5856')
  OR pmd.GEO BETWEEN '6100' AND '6123')
*/


/*
----Filter for Residential (Filters out Manufactered Homes)
AND pmd.[GEO] BETWEEN '1000' AND '6999'
AND pmd.[GEO] NOT IN ('1000','1020','5000','5002','6000','6002')
*/

--Tests Only Use
-- AND t.lrsn = '6827' -- Fill in whatever lrsn you want to test

/*
----Filter for Commercial
AND pmd.[GEO] BETWEEN '1' AND '899'
*/

----Filter for Manufactered Homes
AND (pmd.[GEO] > '9000' OR pmd.[GEO] IN ('1000','1020','5000','5002','6000','6002'))
AND (pmd.[PIN] LIKE ('M%') OR pmd.[PIN] LIKE ('L%') OR pmd.[PIN] LIKE ('R00%'))

/*
Residential, Commercial, and Manufactered Homes share same query with different filters/steps
Change the following:

SELECT statements should be 'res.','comm.', or 'mh.', comment out the others acccordingly.

--MH must keep res. and mh., res. is for Floathomes which are drawn in as regular stick homes.

--Commercial and MH may want columns removed that aren't used. 
  Can be done in SQL or "remove columns" steo in Power Query
  Benefit of doing it inside Power Query,
    when you update the year, you can paste the code and the columns will stay edited,
    whereas, doing it in SQL will cause you to lose that code, unless you comment out instead of delete

WHERE Conditions comment out the two you aren't using.

*/
-------------------------------------
-- GROUP BY
-------------------------------------

-------------------------------------
-- ORDER BY
-------------------------------------
ORDER BY
  District,
  GEO,
  PIN,
  DocNumber,
  SaleDate

-------------------------------------
--End QUERY
-------------------------------------
/*
-------------------------------------
-- Darrell Wolfe, Dyson Savage, Kendall Mallery, "The Hive"
-- DGW, Created 07/24/2023, on behalf of the Kootenai County Assessor's Office
-------------------------------------

-------------------------------------
08/01/2023 - Launch Pilot, Darrell Wolfe, Dyson Savage

-------------------------------------
09/06/2023 - Updated SQL and Workbook to handle new case for Remaining Acres discovered during Beta Launch
-- Discovered that Remaining Acres Arrray only work for most GEOs, some use a Per Acre Rate instead.
-- LCM 30 vs LCM 3
-- Added [Cat19Waste] ISNULL and CASE to handle NAs and calculate Remaining Acres
-- Other issues exist with LCM 2, 6, and 33, Dyson will look into sunsetting these or handling them.
  pmd.LegalAcres,
  CAST (1 AS int) AS [Site_1_Acre],
  ISNULL(c19.[Cat19Waste], 0) AS [Cat19Waste],
    CASE 
        WHEN pmd.LegalAcres > 1 THEN pmd.LegalAcres - CAST(1 AS int) - ISNULL(c19.[Cat19Waste], 0)
        ELSE NULL
    END AS [Remaining_Acres],

-- Added new CTE_LandDetailsRemAcre to pull remaining acres LCM Legend for calculations in workbook
-- Adjusted New Base Rem Acre formula, see Excl file: Excl_Calc_Remaining Acres
Darrell Wolfe, 09/06/2023

-------------------------------------
Describe Update here
Updated scripts, added CTEs and pulled in waterfront data, 
added over 500 lines of code to accomodate wf
10/19/2023 - 10/27/2023

-------------------------------------
Describe Update here


-------------------------------------
Describe Update here


-------------------------------------
Describe Update here


-------------------------------------
Describe Update here


*/