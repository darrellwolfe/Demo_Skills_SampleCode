-- !preview conn=con


/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/



-------------------------------------
-- RESIDENTIAL WORKSHEETS
-------------------------------------
-------------------------------------
-- CTEs will drive this report and combine in the main query
-------------------------------------
WITH

-------------------------------------
--CTE_MarketAdjustmentNotes 
-- Using the memos table with SA and SAMH memo_id
--NOTES, CONCAT allows one line of notes instead of duplicate rows, TRIM removes spaces from boths ides
-------------------------------------

CTE_MarketAdjustmentNotes AS (
  Select Distinct
    m1.lrsn,
    LTRIM(RTRIM(CONCAT(
    m2.memo_text,
    '.', 
    m3.memo_text,
    '.', 
    m4.memo_text,
    '.', 
    m5.memo_text,
    '.', 
    m6.memo_text,
    '.', 
    m7.memo_text
    ))) AS [MarketAdjustmentNotes]

  From memos AS m1
  LEFT JOIN memos AS m2 ON m1.lrsn=m2.lrsn AND m2.memo_line_number = '2'
    AND m2.status = 'A'
    AND m2.memo_id IN ('SA','SAMH')
  LEFT JOIN memos AS m3 ON m1.lrsn=m3.lrsn AND m3.memo_line_number = '3'
    AND m3.status = 'A'
    AND m3.memo_id IN ('SA','SAMH')
  LEFT JOIN memos AS m4 ON m1.lrsn=m4.lrsn AND m4.memo_line_number = '4'
    AND m4.status = 'A'
    AND m4.memo_id IN ('SA','SAMH')
  LEFT JOIN memos AS m5 ON m1.lrsn=m2.lrsn AND m2.memo_line_number = '5'
    AND m5.status = 'A'
    AND m5.memo_id IN ('SA','SAMH')
  LEFT JOIN memos AS m6 ON m1.lrsn=m3.lrsn AND m3.memo_line_number = '6'
    AND m6.status = 'A'
    AND m6.memo_id IN ('SA','SAMH')
  LEFT JOIN memos AS m7 ON m1.lrsn=m4.lrsn AND m4.memo_line_number = '7'
    AND m7.status = 'A'
    AND m7.memo_id IN ('SA','SAMH')
  --------------------------
  -- SA Sales Analysis, SAMH Sales Analyis MH (Mobile Home) are seperate Memo Headers in ProVal
  --------------------------
  Where m1.memo_id IN ('SA','SAMH')
  AND m1.status = 'A'

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
       )
  --Order by e.lrsn
),

-------------------------------------
--CTE_Improvements_Commercial
-------------------------------------
CTE_Improvements_Commercial AS (
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
  --Commercial
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

),

-------------------------------------
--CTE_Improvements_MF
-------------------------------------
CTE_Improvements_MF AS (
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
  AND i.improvement_id IN ('M')

),

-------------------------------------
--CTE_ParcelMasterData
-------------------------------------
CTE_ParcelMasterData AS (
  Select Distinct
  pm.lrsn,
  LTRIM(RTRIM(pm.pin)) AS [PIN],
  LTRIM(RTRIM(pm.AIN)) AS [AIN],
  pm.neighborhood AS [GEO],
  LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
  LTRIM(RTRIM(pm.PropClassDescr)) AS [PCC_ClassCD],
  LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
  LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
  pm.LegalAcres,
  pm.Improvement_Status,
  pm.WorkValue_Land,
  pm.WorkValue_Impv,
  pm.WorkValue_Total
  
  From TSBv_PARCELMASTER AS pm
  Where pm.EffStatus = 'A'
  
  ),
  
  -------------------------------------
  --CTE_CertValues2023
  -------------------------------------
    CTE_CertValues2023 AS (
      SELECT 
        v.lrsn,
        --Certified Values
        v.land_market_val AS [Cert_Land_2023],
        v.imp_val AS [Cert_Imp_2023],
        (v.imp_val + v.land_market_val) AS [Cert_Total_2023],
        v.eff_year AS [Tax_Year_2023],
        ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
      FROM valuation AS v
      WHERE v.eff_year BETWEEN 20230101 AND 20231231
  --Change to desired year
        AND v.status = 'A'
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
-- CTE_LandDetails
-------------------------------------

CTE_LandDetails AS (
  SELECT
  lh.RevObjId AS [lrsn],
  ld.LandDetailType,
  ld.LandType,
  lt.land_type_desc,
  ld.SoilIdent,
  ld.LDAcres,
  ld.ActualFrontage,
  ld.DepthFactor,
  ld.SoilProdFactor,
  ld.SmallAcreFactor,
  ld.SiteRating,
  TRIM (sr.tbl_element_desc) AS [Legend],
  li.InfluenceCode,
  STRING_AGG (li.InfluenceAmount, ',') AS [InfluenceFactor(s)],
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
    
)

-------------------------------------
-- End of CTEs
-------------------------------------

-------------------------------------
--Start of Primary Qeury, Driven by Transfer Table
--FROM Transfer table, JOIN CTEs
-------------------------------------
SELECT DISTINCT
  --This query is driven by Transfer Table, sales in 2022-2023
  --Parcel Master Details
  pmd.[GEO],
--  pmd.[GEO_Name],
  t.lrsn,
  pmd.[PIN],
  pmd.[AIN],
  pmd.[SitusAddress],
  --pmd.[SitusCity],
  pmd.[PCC_ClassCD],
  CAST(LEFT(TRIM(pmd.[PCC_ClassCD]),3) AS INT) AS [PCC#],
  res.year_built,
  res.eff_year_built,
  res.year_remodeled,
  --res.[GradeCode], -- is this a code that needs a key?
  TRIM(res.[GradeType]) AS [Grade],
  TRIM(res.condition) AS [Condition],
  res.[HouseType#],
  TRIM(res.[HouseTypeName]) AS [HouseTypeName],
  res.[RDF], -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation
  --Cat19 Waste, see CTE for details
  pmd.LegalAcres,
  CAST (1 AS int) AS [Site_1_Acre],
  c19.[Cat19Waste],
--LEGEND CASE Land Detail
  cld.[Legend],
  CASE
    WHEN cld.[Legend] LIKE 'Legend%' THEN CAST(RIGHT(cld.[Legend],2) AS INT)
    ELSE
      CASE
        WHEN cld.[Legend] LIKE 'No%' THEN CAST(1 AS INT)
        WHEN cld.[Legend] LIKE 'Average%' THEN CAST(2 AS INT)
        WHEN cld.[Legend] LIKE 'Good%' THEN CAST(3 AS INT)
        WHEN cld.[Legend] LIKE 'Excellent%' THEN CAST(4 AS INT)
        ELSE 0
      END
  END AS [Legend#],
--INFLUENCE FACTOR CASE Land Detail
  cld.[InfluenceType],
  --cld.[InfluenceFactor(s)],
  CASE 
    WHEN cld.[InfluenceType] LIKE '1%' THEN CAST(TRIM(cld.[InfluenceFactor(s)]) AS INT)
    ELSE NULL 
  END AS InfluenceFactor1,
  CASE 
    WHEN cld.[InfluenceType] LIKE '2%' THEN CAST(TRIM(cld.[InfluenceFactor(s)]) AS INT)
    ELSE NULL 
  END AS InfluenceFactor2,
  --Certified Values 2023
  cv23.[Cert_Land_2023],
  cv23.[Cert_Imp_2023],
  cv23.[Cert_Total_2023],
  pmd.WorkValue_Impv AS [WorksheetValue_TOS_ImpValue],
    --Transfer Table Sale Details
  t.AdjustedSalePrice AS [SalePrice],
  CAST(t.pxfer_date AS DATE) AS [SaleDate],
  TRIM(t.SaleDesc) AS [SaleDescr],
  TRIM(t.TfrType) AS [TranxType],
  TRIM(t.DocNum) AS [Doc#], -- Multiples will have the same DocNum
  --TRY_CAST(TRIM(t.DocNum) AS INT) AS [Doc#], -- Multiples will have the same DocNum
  --Residential Details
  pmd.Improvement_Status,
 -- "_" AS [NotesInSeperate part of sheet>>>],
  --Notes in the Proval Memo Headers SA or SAMH will show here
  notes.[MarketAdjustmentNotes],

--Commercial
  comm.use_code,
  comm.year_built,
  comm.eff_year_built,
  comm.year_remodeled,
  comm.condition,
  comm.[GradeCode], -- is this a code that needs a key?
  comm.[GradeType]



FROM transfer AS t -- ON t.lrsn for joins
--CTEs
JOIN
CTE_ParcelMasterData AS pmd ON t.lrsn=pmd.lrsn

LEFT JOIN
CTE_MarketAdjustmentNotes AS notes ON t.lrsn=notes.lrsn

LEFT JOIN
CTE_Improvements_Residential AS res ON t.lrsn=res.lrsn

LEFT JOIN
CTE_Improvements_Commercial AS comm ON t.lrsn=comm.lrsn

LEFT JOIN
CTE_Improvements_MF AS mf ON t.lrsn=mf.lrsn

LEFT JOIN
CTE_CertValues2023 AS cv23 ON t.lrsn=cv23.lrsn
  AND cv23.RowNumber = '1'

LEFT JOIN
CTE_Cat19Waste AS c19 ON t.lrsn=c19.lrsn

LEFT JOIN
CTE_LandDetails AS cld ON t.lrsn=cld.lrsn

-------------------------------------
--WHERE Conditions for t only, all others drive CTEs or JOINs
-------------------------------------
WHERE t.status = 'A'
AND t.AdjustedSalePrice <> '0'
AND t.pxfer_date BETWEEN '2022-01-01' AND '2023-12-31'
--Filter for Commercial
AND pmd.[GEO] BETWEEN '1' AND '999'
-------------------------------------
-- Order By
-------------------------------------
ORDER BY
  pmd.[GEO],
  pmd.[PIN],
  pmd.[PCC_ClassCD],
  pmd.Improvement_Status,
  t.pxfer_date

-------------------------------------
--End QUERY
-------------------------------------

-------------------------------------
-- Darrell Wolfe, Dyson Savage, Kendall Mallery, "The Hive"
-- DGW, Created 07/24/2023, on behalf of the Kootenai County Assessor's Office
-------------------------------------