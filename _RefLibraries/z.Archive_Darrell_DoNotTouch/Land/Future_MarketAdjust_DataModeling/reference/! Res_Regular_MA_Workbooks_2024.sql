/*
-- !preview conn=conn
*/

/*
AsTxDBProd
GRM_Main
*/

-------------------------------------
-- RESIDENTIAL, COMMERCIAL And/or Manufactered Homes WORKSHEETS
-------------------------------------

/*
Residential, Commercial, And Manufactered Homes share same query with different filters/steps
Change the following:

Select statements should be 'res.','comm.', or 'mh.', comment out the others acccordingly.

--MH must keep res. And mh., res. is for Floathomes which are drawn in as regular stick homes.

--Commercial And MH may want columns removed that aren't used. 
  Can be done in SQL or "remove columns" steo in Power Query
  Benefit of doing it inside Power Query,
    when you update the year, you can paste the code And the columns will stay edited,
    Whereas, doing it in SQL will cause you to lose that code, unless you comment out instead of delete

Where Conditions comment out the two you aren't using.

*/





--For the Reval Year 25 04/16/2024-04/15/2025 use 2024 Sales
Declare @Year int = 2024; -- Input THIS year here

Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here

--VARCHAR String with the two letters plus last two of year, allows for NC Memos in this case
Declare @NCYear varchar(4) = 'NC' + Right(Cast(@Year as varchar), 2); -- This will create 'NC24'
Declare @NCYearPrevious varchar(4) = 'NC' + Right(Cast(@YearPrev as varchar), 2); -- This will create 'NC23'

Declare @MemoLastUpdatedNoEarlierThan date = CAST(CAST(@YearPrev as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
--Declare @MemoLastUpdatedNoEarlierThan DATE = '2022-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022

Declare @PrimaryTransferDateFrom date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @PrimaryTransferDateTO date = CAST(CAST(@Year as varchar) + '-12-31' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @PrimaryTransferDateFrom DATE = '2023-01-01';
--Declare @PrimaryTransferDateTO DATE = '2023-12-31';
--pxfer_date
--And tr.pxfer_date BETWEEN '2023-01-01' And '2023-12-31'


Declare @CertValueDateFrom varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @CertValueDateTO varchar(8) = Cast(@Year as varchar) + '1231'; -- Generates '20230101' for the previous year
--Declare @CertValueDateFrom INT = '20230101';
--Declare @CertValueDateTO INT = '20231231';
--v.eff_year
---Where v.eff_year BETWEEN 20230101 And 20231231

Declare @LAndModelId varchar(8) = '70' + Cast(@Year as varchar); -- Generates '702024/702023/702025' for the previous year
  --  And lh.LAndModelId='702023'



/*
--EXACT NO-DASHES '20230101'
Declare @EffYear0101Current varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101PreviousPrevious varchar(8) = Cast(@YearPrevPrev as varchar) + '0101'; -- Generates '20230101' for the previous year

--EXACT DASHES '2023-01-01'
Declare @ValEffDateCurrent date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @ValEffDatePrevious date = CAST(CAST(@YearPrev as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'

--LIKE Year with Perce Symbol 2023%
Declare @EffYear0101PreviousLike varchar(8) = Cast(@YearPrev as varchar) + '%'; -- Generates '20230101' for the previous year
--Where eff_year LIKE '2023%'Results include --20230101 --20230804
Declare @EffYear0101PreviousPreviousLike varchar(8) = Cast(@YearPrevPrev as varchar) + '%'; -- Generates '20230101' for the previous year
Declare @EffYear0101CurrentLike varchar(8) = Cast(@Year as varchar) + '%'; -- Generates '20230101' for the previous year

*/

-------------------------------------
-- CTEs will drive this report And combine in the main query
-------------------------------------
WITH

-------------------------------------
--CTE_MarketAdjustmentNotes 
-- Using the memos table with SA And SAMH memo_id
--NOTES, CONCAT allows one line of notes instead of duplicate rows, TRIM removes spaces From boths ides
-------------------------------------
-------------------------------------
--CTE_ParcelMasterData
-------------------------------------
CTE_ParcelMasterData AS (
  Select Distinct
    CASE
        WHEN pmd.GEO >= 9000 THEN 'Manufactured_Homes'
        WHEN pmd.GEO >= 6003 THEN 'District_6'
        WHEN pmd.GEO = 6002 THEN 'Manufactured_Homes'
        WHEN pmd.GEO = 6001 THEN 'District_6'
        WHEN pmd.GEO = 6000 THEN 'Manufactured_Homes'
        WHEN pmd.GEO >= 5003 THEN 'District_5'
        WHEN pmd.GEO = 5002 THEN 'Manufactured_Homes'
        WHEN pmd.GEO = 5001 THEN 'District_5'
        WHEN pmd.GEO = 5000 THEN 'Manufactured_Homes'
        WHEN pmd.GEO >= 4000 THEN 'District_4'
        WHEN pmd.GEO >= 3000 THEN 'District_3'
        WHEN pmd.GEO >= 2000 THEN 'District_2'
        WHEN pmd.GEO >= 1021 THEN 'District_1'
        WHEN pmd.GEO = 1020 THEN 'Manufactured_Homes'
        WHEN pmd.GEO >= 1001 THEN 'District_1'
        WHEN pmd.GEO = 1000 THEN 'Manufactured_Homes'
        WHEN pmd.GEO >= 451 THEN 'Commercial'
        WHEN pmd.GEO = 450 THEN 'Specialized_Cell_Towers'
        WHEN pmd.GEO >= 1 THEN 'Commercial'
        WHEN pmd.GEO = 0 THEN 'N/A_or_Error'
        ELSE NULL
    END AS District,
-- # District SubClass
CASE
    --Commercial # Income properties use regular template, for now. 
    --  May build something. Set up just in case. DGW 08/02/2023.
      WHEN pmd.GEO BETWEEN '1' And '27' THEN 'Comm_Sales'
      WHEN pmd.GEO = '28' THEN 'Comm_Sales' -- < -- Income properties but use regular template, for now. 08/02/2023
      WHEN pmd.GEO BETWEEN '29' And '41' THEN 'Comm_Sales'
      WHEN pmd.GEO = '41' THEN 'Comm_Sales'
      WHEN pmd.GEO = '42' THEN 'Section42_Workbooks'
      WHEN pmd.GEO = '43' THEN 'Comm_Sales'
      WHEN pmd.GEO = '44' THEN 'Comm_Sales' -- < -- Income properties but use regular template, for now. 08/02/2023
      WHEN pmd.GEO BETWEEN '45' And '99' THEN 'Comm_Sales'
      WHEN pmd.GEO BETWEEN '100' And '199' THEN 'Comm_Waterfront'
      WHEN pmd.GEO BETWEEN '200' And '899' THEN 'Comm_Sales'
    --D1
      WHEN pmd.GEO IN ('1008','1010','1410','1420','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507') THEN 'Res_Waterfront'
      WHEN pmd.GEO IN ('1998','1999') THEN 'Res_MultiFamily'
    --D2
      WHEN pmd.GEO IN ('2105','2115','2125','2135','2145','2155') THEN 'Res_Waterfront'
      WHEN pmd.GEO IN ('2996','2997','2998','2999') THEN 'Res_MultiFamily'
    --D3
      WHEN pmd.GEO IN ('3502','3503','3504','3505','3506') THEN 'Res_Waterfront'
      WHEN pmd.GEO IN ('3998','3999') THEN 'Res_MultiFamily'
    --D4
      WHEN pmd.GEO IN ('4201','4202','4203','4204','1430','1430','1440','1450','1501','1502','1503','1505','1506','1507') THEN 'Res_Waterfront'
      WHEN pmd.GEO IN ('4833','4840','4997','4998','4999') THEN 'Res_MultiFamily'
    --D5
      WHEN pmd.GEO IN ('5001','5004','5009','5010','5012','5015','5018','5020','5021','5024','5030','5033','5036','5039',
                                '5042','5045','5048','5051','5053','5054','5056','5057','5060','5063','5066','5069','5072','5075','5078',
                                '5081','5750','5753','5756','5759','5762','5765','5850','5853','5856') THEN 'Res_Waterfront'
      -- WHEN pmd.GEO IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D5 as of 08/02/2023
    --D6
      WHEN pmd.GEO BETWEEN '6100' And '6123' THEN 'Res_Waterfront'
      -- WHEN pmd.GEO IN ('','') THEN 'Res_MutliFamily' -- No MultiFamily in D6 as of 08/02/2023
    -- MH Sales Worksheet Type
      WHEN pmd.GEO = '1000' THEN 'MH_Sales'
      WHEN pmd.GEO = '1020' THEN 'MH_Sales'
      WHEN pmd.GEO = '5000' THEN 'MH_Sales'
      WHEN pmd.GEO = '5002' THEN 'MH_Sales'
      WHEN pmd.GEO = '6000' THEN 'MH_Sales'
      WHEN pmd.GEO = '6002' THEN 'MH_Sales'
      WHEN pmd.GEO >= '9000' THEN 'MH_Sales'
    
    --Else
      ELSE 'Res_Sales'
  END AS District_SubClass,
  --This query is driven by Transfer Table, sales in 2022-2023
  
  
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
  pm.WorkValue_LAnd,
  pm.WorkValue_Impv,
  pm.WorkValue_Total
  
  From TSBv_PARCELMASTER AS pm
  Where pm.EffStatus = 'A'
  
  ),
  
  -------------------------------------
--CTE_TransferSales
-------------------------------------
CTE_TransferSales AS (
Select Distinct
--  pmd.[GEO_Name],
  t.lrsn,
  t.status,
--Transfer Table Sale Details
  t.AdjustedSalePrice AS SalePrice,
  CAST(t.pxfer_date AS DATE) AS SaleDate,
  TRIM(t.SaleDesc) AS SaleDescr,
  TRIM(t.TfrType) AS TranxType,
  TRIM(t.DocNum) AS DocNumber -- Multiples will have the same DocNum
From transfer AS t -- ON t.lrsn for joins
Where t.status = 'A'
  And t.AdjustedSalePrice <> '0'
  And t.pxfer_date BETWEEN @PrimaryTransferDateFrom And @PrimaryTransferDateTO
  --And t.pxfer_date BETWEEN '2023-01-01' And '2023-12-31'
),

CTE_NotesSalesAnalysis AS (
Select
  lrsn,
  STRING_AGG(memo_text, ' | ') AS Sales_Notes
From memos

Where status = 'A'
And memo_id IN ('SA', 'SAMH')
And memo_line_number <> '1'
And last_update >= @MemoLastUpdatedNoEarlierThan

/*
And (memo_text LIKE '%/23 %'
    OR memo_text LIKE '%/2023 %'
    OR memo_text LIKE '%/24 %'
    OR memo_text LIKE '%/2024 %')
*/
GROUP BY lrsn
),

-------------------------------------
--CTE_MarketAdjustmentNotes 
-- Using the memos table with SA And SAMH memo_id
--NOTES, CONCAT allows one line of notes instead of duplicate rows, TRIM removes spaces From boths ides
-------------------------------------

CTE_NotesConfidential AS (
Select
  lrsn,
  STRING_AGG(memo_text, ' | ') AS Conf_Notes
From memos

Where status = 'A'
And memo_id IN ('NOTE')
And memo_line_number <> '1'
And last_update >= @MemoLastUpdatedNoEarlierThan

/*
And (memo_text LIKE '%/23 %'
    OR memo_text LIKE '%/2023 %'
    OR memo_text LIKE '%/24 %'
    OR memo_text LIKE '%/2024 %')
*/
GROUP BY lrsn

),

--Top value in ProVal
CTE_Market AS (
  Select 
    lrsn,
    --Certified Values
    v.lAnd_market_val AS Market_LAnd_PreEx,
    v.imp_val AS Market_Imp,
    (v.imp_val + v.lAnd_market_val) AS Market_Total,
    v.eff_year AS Tax_Year_Market,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  From valuation AS v
  Where v.eff_year BETWEEN @CertValueDateFrom And @CertValueDateTO
--Change to desired year
    And v.status = 'A'
),






-------------------------------------
--CTE_CertValues
-------------------------------------
CTE_CertValues AS (
  Select 
    v.lrsn,
    --Certified Values
    v.lAnd_market_val AS [Cert_LAnd_2023],
    v.imp_val AS [Cert_Imp_2023],
    (v.imp_val + v.lAnd_market_val) AS [Cert_Total_2023],
    v.eff_year AS [Tax_Year_2023],
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  From valuation AS v
  --Where v.eff_year BETWEEN 20230101 And 20231231
  Where v.eff_year BETWEEN @CertValueDateFrom And @CertValueDateTO

  
--Change to desired year
    And v.status = 'A'
),


-------------------------------------
-- Combined CTE for Improvements
-------------------------------------
CTE_Improvements AS (
  Select Distinct
    -- Extensions Table
    e.lrsn,
    e.extension,
    e.ext_description,
    e.data_collector,
    e.collection_date,
    e.appraiser,
    e.appraisal_date,
    
    -- Improvements Table
    i.imp_type,
    i.year_built,
    i.eff_year_built,
    i.year_remodeled,
    i.condition,
    i.grade AS GradeCode, 
    grades.tbl_element_desc AS GradeType,
    
    -- Residential Dwellings dw
    STRING_AGG(dw.mkt_house_type, ' | ') AS HouseTypeNum,
    STRING_AGG(htyp.tbl_element_desc, ' | ') AS HouseTypeName,
    dw.mkt_rdf AS [RDF],
    
    -- Commercial
    STRING_AGG(cu.use_code, ',') AS use_codes,
    
    -- Manufactured Housing
    mh.mh_make AS [MHMake#],
    make.tbl_element_desc AS [MH_Make],
    mh.mh_model AS [MHModel#],
    model.tbl_element_desc AS [MH_Model],
    mh.mh_serial_num AS [VIN],
    mh.mhpark_code,
    park.tbl_element_desc AS [MH_Park],
    
    ROW_NUMBER() OVER (PARTITION BY e.lrsn ORDER BY e.extension ASC) AS RowNum
    
  -- Extensions always comes first
  From extensions AS e
  JOIN improvements AS i ON e.lrsn = i.lrsn 
    And e.extension = i.extension
    And i.status = 'A'
    And i.improvement_id IN ('M', 'C', 'D')

    LEFT JOIN codes_table AS grades 
        ON i.grade = grades.tbl_element
        And grades.tbl_type_code = 'grades'
        And grades.code_status = 'A' 

  -- Residential Dwellings
  LEFT JOIN dwellings AS dw ON i.lrsn = dw.lrsn
    And dw.status = 'A'
    And i.extension = dw.extension

    LEFT JOIN codes_table AS htyp 
        ON dw.mkt_house_type = htyp.tbl_element 
        And htyp.tbl_type_code = 'htyp'
        And htyp.code_status = 'A' 

  -- Commercial
  LEFT JOIN comm_bldg AS cb ON i.lrsn = cb.lrsn 
    And i.extension = cb.extension
    And cb.status = 'A'
    LEFT JOIN comm_uses AS cu ON cb.lrsn = cu.lrsn
        And cb.extension = cu.extension
        And cu.status = 'A'
    
  -- Manufactured Housing
  LEFT JOIN manuf_housing AS mh ON i.lrsn = mh.lrsn 
    And i.extension = mh.extension
    And mh.status = 'A'
    LEFT JOIN codes_table AS make 
    ON mh.mh_make = make.tbl_element 
        And make.tbl_type_code = 'mhmake'
        And make.code_status = 'A' 

    LEFT JOIN codes_table AS model 
    ON mh.mh_model = model.tbl_element 
        And model.tbl_type_code = 'mhmodel'
        And model.code_status = 'A' 

    LEFT JOIN codes_table AS park 
    ON mh.mhpark_code = park.tbl_element 
        And park.tbl_type_code = 'mhpark'
        And park.code_status = 'A' 

    
  Where e.status = 'A'
  And (
    --Res Dwellings
      (i.improvement_id IN ('D')
    And (e.ext_description LIKE '%H1%'
      OR e.ext_description LIKE '%H-1%'
      OR e.ext_description LIKE '%ALU%')
      )
    Or
    -- MH Homes
      (i.improvement_id IN ('M')
    And (e.ext_description LIKE '%NREV%'
      OR e.ext_description LIKE '%FLOAT%'
      OR e.ext_description LIKE '%BOAT%')
      )
    Or
    --Commercial Buildings
      (i.improvement_id IN ('C'))
      )
  
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
    grades.tbl_element_desc,
    dw.mkt_rdf,
    cu.use_code,
    mh.mh_make,
    make.tbl_element_desc,
    mh.mh_model,
    model.tbl_element_desc,
    mh.mh_serial_num,
    mh.mhpark_code,
    park.tbl_element_desc
)


-------------------------------------
-- CTE_MultiSaleSums
-------------------------------------
-- Common Table Expression (CTE) to calculate the sums for Multi-Sale cases
CTE_MultiSaleSums AS (
  Select
    t.DocNum,
    SUM(cv23.[Cert_LAnd_2023]) AS [MultiSale_LAnd],
    SUM(cv23.[Cert_Imp_2023]) AS [MultiSale_Imp],
    SUM(cv23.Cert_Total_2023) AS [MultiSale_TotalSums],
    SUM(pm.WorkValue_Impv) AS [MultiSale_WorksheetImp]
    
  From transfer AS t -- ON t.lrsn for joins
  JOIN CTE_CertValues AS cv23 ON t.lrsn=cv23.lrsn
  JOIN CTE_ParcelMasterData AS pm ON t.lrsn=pm.lrsn

  Where
    t.TfrType = 'M' -- Filter only Multi-Sale cases
  GROUP BY
    t.DocNum
),

  
-------------------------------------
-- CTE_Cat19Waste
-------------------------------------
CTE_Cat19Waste AS (
  Select
  lh.RevObjId AS [lrsn],
  ld.LAndDetailType,
  ld.LAndType,
  lt.lAnd_type_desc,
  ld.SoilIdent,
  ld.LDAcres AS [Cat19Waste]
  
  --LAnd Header
  From LAndHeader AS lh
  --LAnd Detail
  JOIN LAndDetail AS ld ON lh.id=ld.LAndHeaderId 
    And ld.EffStatus='A' 
    And lh.PostingSource=ld.PostingSource
  --LAnd Types
  LEFT JOIN lAnd_types AS lt ON ld.LAndType=lt.lAnd_type
  
  Where lh.EffStatus= 'A' 
    And lh.PostingSource='A'
    And ld.PostingSource='A'
  --Looking for:82 Waste land type which is Cat19 Allocations Group Code
    And ld.LAndType IN ('82')
  --Change lAnd model id for current year
    And lh.LAndModelId=@LAndModelId
    And ld.LAndModelId=@LAndModelId
  --Declare @LAndModelId varchar(8) = '70' + Cast(@Year as varchar); -- Generates '702024/702023/702025' for the previous year
--    And lh.LAndModelId='702023'
--    And ld.LAndModelId='702023'
  
),

-------------------------------------
-- CTE_LAndDetails
-------------------------------------

CTE_LAndDetails AS (
  Select
  lh.RevObjId AS [lrsn],
  ld.LAndDetailType,
  ld.lcm,
  ld.LAndType,
  lt.lAnd_type_desc,
  ld.SoilIdent,
  ld.LDAcres,
  ld.ActualFrontage,
  ld.DepthFactor,
  ld.SoilProdFactor,
  ld.SmallAcreFactor,
  ld.SiteRating,
  TRIM (sr.tbl_element_desc) AS [Legend],
ROW_NUMBER() OVER (PARTITION BY lh.RevObjId ORDER BY sr.tbl_element_desc ASC) AS [RowNumber],
  li.InfluenceCode,
  STRING_AGG (li.InfluenceAmount, ',') AS [InfluenceFactor(s)],
  li.InfluenceAmount,
  CASE
      WHEN li.InfluenceType = 1 THEN '1-Pct'
      ELSE '2-Val'
  END AS [InfluenceType],
  li.PriceAdjustment
  
  --LAnd Header
  From LAndHeader AS lh
  --LAnd Detail
  JOIN LAndDetail AS ld ON lh.id=ld.LAndHeaderId 
    And ld.EffStatus='A' 
    And ld.PostingSource='A'
    And lh.PostingSource=ld.PostingSource
  LEFT JOIN codes_table AS sr ON ld.SiteRating = sr.tbl_element
      And sr.tbl_type_code='siterating  '

  --LAnd Types
  LEFT JOIN lAnd_types AS lt ON ld.LAndType=lt.lAnd_type
  
  --LAnd Influence
  LEFT JOIN LAndInfluence AS li ON li.ObjectId = ld.Id
    And li.EffStatus='A' 
    And li.PostingSource='A'

  
  Where lh.EffStatus= 'A' 
    And lh.PostingSource='A'
--Looking for: Residential HomeSite & Commercial Land
  And (ld.LAndType IN ('9','31','32') -- Residential Homesite
    Or ld.LAndType IN ('11')) -- All Commercial Land
--Change lAnd model id for current year
    And lh.LAndModelId=@LAndModelId
    And ld.LAndModelId=@LAndModelId
--Declare @LAndModelId varchar(8) = '70' + Cast(@Year as varchar); -- Generates '702024/702023/702025' for the previous year
  --And lh.LAndModelId='702023'
  --And ld.LAndModelId='702023'

    GROUP BY
  lh.RevObjId,
  ld.LAndDetailType,
  ld.lcm,
  ld.LAndType,
  lt.lAnd_type_desc,
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
--CTE_LAndDetailsRemAcre pulls the LCM And LAnd Type for only Remaining Acres legends.
-----------------------
CTE_LAndDetailsRemAcre AS (
  Select
  lh.RevObjId AS [lrsn]
  ,ld.LAndDetailType
  ,ld.lcm
  ,ld.LAndType
  ,ld.LDAcres
  ,ld.BaseRate
  --LAnd Header
  From LAndHeader AS lh
  --LAnd Detail
  JOIN LAndDetail AS ld ON lh.id=ld.LAndHeaderId 
    And ld.EffStatus='A' 
    And ld.PostingSource='A'
    And lh.PostingSource=ld.PostingSource
  LEFT JOIN codes_table AS sr ON ld.SiteRating = sr.tbl_element
      And sr.tbl_type_code='siterating'
--Looking for: Remaining Acres land type with the rem acres pricing methods
  Where ld.LAndType IN ('91')
  And ld.lcm IN ('3','30')
),

-----------------------
--CTE_CommBldgSF pulls in Commercial SF for a $/SF Rate
-----------------------
CTE_CommBldgSF AS (
  Select
    lrsn,
    SUM(area) AS [CommSF]
  From comm_uses
  Where status = 'A'
  GROUP BY lrsn
  
),

CTE_CommBldMultiSaleSF AS (
  Select
    t.DocNum,
    SUM(cbsf.[CommSF]) AS [CommBldMultiSaleSF]
    
    --bring in this table
    
  From
    transfer AS t -- ON t.lrsn for joins
    
  JOIN CTE_CommBldgSF AS cbsf ON t.lrsn=cbsf.lrsn

  Where
    t.TfrType = 'M' -- Filter only Multi-Sale cases
  GROUP BY
    t.DocNum
)


-------------------------------------
-- End of CTEs
-------------------------------------

-------------------------------------
--START Primary Qeury, Driven by Transfer Table
--From Transfer table, JOIN CTEs
-------------------------------------
Select Distinct

  --Parcel Master Details
  pmd.District,
  pmd.District_SubClass,
  pmd.[GEO],
--  pmd.[GEO_Name],
  tr.lrsn,
  pmd.[PIN],
  pmd.[AIN],
  pmd.[SitusAddress],
  
--Transfer Table Sale Details
  tr.SalePrice,
  tr.SaleDate,
  tr.SaleDescr,
  tr.TranxType,
  tr.DocNumber, -- Multiples will have the same DocNum
  --pmd.[SitusCity],
  pmd.[PCC_ClassCD],
  CAST(LEFT(TRIM(pmd.[PCC_ClassCD]),3) AS INT) AS [PCC#],

--Qeury for Res, Comm, And Manufactered Homes is identical, include or exclude the columns with res,comm,mf
  --Residential Details
  res.year_built,
  res.eff_year_built,
  res.year_remodeled,
  --res.[GradeCode], -- is this a code that needs a key?
  TRIM(res.[GradeType]) AS [Grade],
  TRIM(res.condition) AS [Condition],
  res.[HouseTypeNum],
  TRIM(res.[HouseTypeName]) AS [HouseTypeName],
  res.[RDF], -- Relative Desirability Facotor (RDF), see ProVal, Values, Cost Buildup, under depreciation

--ACRES Calcs Legal, Site, Cat19 Waste, see CTE for details
-- Added [Cat19Waste] ISNULL And CASE to hAndle NAs
  pmd.LegalAcres,
  CAST (1 AS int) AS [Site_1_Acre],
  ISNULL(c19.[Cat19Waste], 0) AS [Cat19Waste],
  CASE 
      WHEN pmd.LegalAcres > 1 THEN pmd.LegalAcres - CAST(1 AS int) - ISNULL(c19.[Cat19Waste], 0)
      ELSE NULL
  END AS [Remaining_Acres],
  RemAcres.lcm AS RemAcresLCM,
 --RemAcres.LDAcres,
  RemAcres.BaseRate AS RemAcres_BaseRate,
  
  --RemAcres.LAndType, -- Use as test for reference not in final workbook
--LEGEND CASE LAnd Detail
  cld.[Legend], -- Why isn't this pulling right?
  CASE
    WHEN cld.[Legend] LIKE 'Legend%' THEN CAST(RIGHT(cld.[Legend],2) AS INT)
    ELSE
      CASE
        WHEN cld.[Legend] LIKE 'No%' THEN CAST(1 AS INT)
        WHEN cld.[Legend] LIKE 'Average%' THEN CAST(2 AS INT)
        WHEN cld.[Legend] LIKE 'Good%' THEN CAST(3 AS INT)
        WHEN cld.[Legend] LIKE 'Excellent%' THEN CAST(4 AS INT)
        ELSE CAST(1 AS INT)
      END
  END AS [Legend#],
  
--INFLUENCE FACTOR CASE LAnd Detail
  cld.[InfluenceType],
  --cld.[InfluenceFactor(s)],
  CASE 
    WHEN cld.[InfluenceType] LIKE '1%' THEN CAST(TRIM(cld.[InfluenceFactor(s)]) AS DECIMAL(10, 2)) / 100.0
    -- Without this (/100) it produces "10" for 10%, but we need it to be 0.10 for math.
    ELSE NULL 
  END AS InfluenceFactor1,
  
  CASE 
    WHEN cld.[InfluenceType] LIKE '2%' THEN CAST(TRIM(cld.[InfluenceFactor(s)]) AS INT)
    ELSE NULL 
  END AS InfluenceFactor2,
  
  --Certified Values 2023
  cv23.[Cert_LAnd_2023],
  cv23.[Cert_Imp_2023],
  cv23.[Cert_Total_2023],
  pmd.WorkValue_Impv AS [WorksheetValue_TOS_ImpValue],

---MultiSale Logic
  COALESCE(msv.[MultiSale_LAnd], 0) AS [MultiSale_LAnd],
  COALESCE(msv.[MultiSale_Imp], 0) AS [MultiSale_Imp],
  COALESCE(msv.[MultiSale_TotalSums], 0) AS [MultiSale_TotalSums],
  COALESCE(msv.[MultiSale_WorksheetImp], 0) AS [MultiSale_WorksheetImp],
--Improved vs vacant (unimproved)
  pmd.Improvement_Status,
-- "_" AS [NotesInSeperate part of sheet>>>],
  --Notes in the Proval Memo Headers SA or SAMH will show here
  Snotes.[Sales_Notes],
  Cnotes.[Conf_Notes]





From CTE_TransferSales AS tr -- ON tr.lrsn for joins
--From transfer AS t -- ON t.lrsn for joins

--CTEs
JOIN
CTE_ParcelMasterData AS pmd ON tr.lrsn=pmd.lrsn
  --pmd.
  LEFT JOIN
  CTE_Improvements_Residential AS res ON tr.lrsn=res.lrsn
  --res.
  LEFT JOIN
  CTE_Improvements_Commercial AS comm ON tr.lrsn=comm.lrsn
  And comm.RowNum = 1
  --comm.
  LEFT JOIN
  CTE_Improvements_MH AS mh ON tr.lrsn=mh.lrsn
  --mh.
  ----Certified Values
  LEFT JOIN
  CTE_CertValues AS cv23 ON tr.lrsn=cv23.lrsn
    And cv23.RowNumber = '1'
  --cv23.
    LEFT JOIN 
  CTE_MultiSaleSums AS msv ON tr.DocNumber=msv.DocNum
  --msv. MultiSale Summed Values
  LEFT JOIN
  CTE_Cat19Waste AS c19 ON tr.lrsn=c19.lrsn
  --c19.
  LEFT JOIN
  CTE_LAndDetails AS cld ON tr.lrsn=cld.lrsn
    And cld.[RowNumber] = '1'
  --cld.
  LEFT JOIN
  CTE_CommBldgSF AS commsf ON tr.lrsn=commsf.lrsn
  --commsf
  LEFT JOIN
  CTE_CommBldMultiSaleSF AS commsfMSale ON  tr.DocNumber=commsfMSale.DocNum
  --commsfMSale.[CommBldMultiSaleSF]
  LEFT JOIN
  CTE_NotesSalesAnalysis AS Snotes ON tr.lrsn=Snotes.lrsn
  --Snotes.
  LEFT JOIN
  CTE_NotesConfidential AS Cnotes ON tr.lrsn=Cnotes.lrsn
  --Cnotes.
  LEFT JOIN
  CTE_LAndDetailsRemAcre AS RemAcres ON tr.lrsn=RemAcres.lrsn

-------------------------------------
--Where Conditions for t only, all others drive CTEs or JOINs
-------------------------------------
Where tr.status = 'A'


--And  pmd.GEO IN ('1252','3220')

----Filter for Residential (Filters out Manufactered Homes)
And pmd.[GEO] BETWEEN '1000' And '6999'
And pmd.[GEO] NOT IN ('1000','1020','5000','5002','6000','6002')



--Tests Only Use
-- And tr.lrsn = '6827' -- Fill in whatever lrsn you want to test

----Filter for Commercial
--And pmd.[GEO] BETWEEN '1' And '899'

----Filter for Manufactered Homes
--And (pmd.[GEO] > '9000' OR pmd.[GEO] IN ('1000','1020','5000','5002','6000','6002'))
--And (pmd.[PIN] LIKE ('M%') OR pmd.[PIN] LIKE ('L%') OR pmd.[PIN] LIKE ('R00%'))

/*
Residential, Commercial, And Manufactered Homes share same query with different filters/steps
Change the following:

Select statements should be 'res.','comm.', or 'mh.', comment out the others acccordingly.

--MH must keep res. And mh., res. is for Floathomes which are drawn in as regular stick homes.

--Commercial And MH may want columns removed that aren't used. 
  Can be done in SQL or "remove columns" steo in Power Query
  Benefit of doing it inside Power Query,
    when you update the year, you can paste the code And the columns will stay edited,
    Whereas, doing it in SQL will cause you to lose that code, unless you comment out instead of delete

Where Conditions comment out the two you aren't using.

*/
-------------------------------------
-- GROUP BY
-------------------------------------

-------------------------------------
-- ORDER BY
-------------------------------------
ORDER BY
  pmd.[GEO],
  pmd.[PIN],
  [DocNumber],
  pmd.[PCC_ClassCD],
  pmd.Improvement_Status,
  [SaleDate]

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
09/06/2023 - Updated SQL And Workbook to hAndle new case for Remaining Acres discovered during Beta Launch
-- Discovered that Remaining Acres Arrray only work for most GEOs, some use a Per Acre Rate instead.
-- LCM 30 vs LCM 3
-- Added [Cat19Waste] ISNULL And CASE to hAndle NAs And calculate Remaining Acres
-- Other issues exist with LCM 2, 6, And 33, Dyson will look into sunsetting these or hAndling them.
  pmd.LegalAcres,
  CAST (1 AS int) AS [Site_1_Acre],
  ISNULL(c19.[Cat19Waste], 0) AS [Cat19Waste],
    CASE 
        WHEN pmd.LegalAcres > 1 THEN pmd.LegalAcres - CAST(1 AS int) - ISNULL(c19.[Cat19Waste], 0)
        ELSE NULL
    END AS [Remaining_Acres],

-- Added new CTE_LAndDetailsRemAcre to pull remaining acres LCM Legend for calculations in workbook
-- Adjusted New Base Rem Acre formula, see Excl file: Excl_Calc_Remaining Acres
Darrell Wolfe, 09/06/2023

-------------------------------------
Describe Update here


-------------------------------------
Describe Update here


-------------------------------------
Describe Update here


-------------------------------------
Describe Update here


-------------------------------------
Describe Update here


*/