-- !preview conn=conn


/*
AsTxDBProd
GRM_Main
*/

-------------------------------------
-- RESIDENTIAL, COMMERCIAL and/or Manufactered Homes WORKSHEETS
-------------------------------------

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
      WHEN pm.neighborhood = '1000' THEN 'MH_Sales'
      WHEN pm.neighborhood = '1020' THEN 'MH_Sales'
      WHEN pm.neighborhood = '5000' THEN 'MH_Sales'
      WHEN pm.neighborhood = '5002' THEN 'MH_Sales'
      WHEN pm.neighborhood = '6000' THEN 'MH_Sales'
      WHEN pm.neighborhood = '6002' THEN 'MH_Sales'
      WHEN pm.neighborhood >= '9000' THEN 'MH_Sales'
    
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
--  WHERE pm.EffStatus = 'A'
  
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

-------------------------------------
--CTE_CertValues
-------------------------------------
CTE_CertValues AS (
  SELECT 
    v.lrsn,
    --Certified Values
    v.land_market_val AS [Cert_Land],
    v.imp_val AS [Cert_Imp],
    (v.imp_val + v.land_market_val) AS [Cert_Total],
    v.eff_year AS [Tax_Year],
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
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
    ctet.DocNumber,
    SUM(cv23.[Cert_Land]) AS [MultiSale_Land],
    SUM(cv23.[Cert_Imp]) AS [MultiSale_Imp],
    SUM(cv23.Cert_Total) AS [MultiSale_TotalSums],
    SUM(pm.WorkValue_Impv) AS [MultiSale_WorksheetImp]
    
  FROM CTE_TransferSales AS ctet -- ON t.lrsn for joins
  JOIN CTE_CertValues AS cv23 ON ctet.lrsn=cv23.lrsn
  JOIN CTE_ParcelMasterData AS pm ON ctet.lrsn=pm.lrsn

  WHERE
    ctet.TranxType = 'M' -- Filter only Multi-Sale cases
  GROUP BY
    ctet.DocNumber
),


-------------------------------------
--CTE_MarketAdjustmentNotes 
-- Using the memos table with SA and SAMH memo_id
--NOTES, CONCAT allows one line of notes instead of duplicate rows, TRIM removes spaces from boths ides
-------------------------------------

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

-------------------------------------
--CTE_MarketAdjustmentNotes 
-- Using the memos table with SA and SAMH memo_id
--NOTES, CONCAT allows one line of notes instead of duplicate rows, TRIM removes spaces from boths ides
-------------------------------------

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
    --AND lh.LandModelId='702023'
    --AND ld.LandModelId='702023'
    AND lh.LandModelId= @LandModelId
    AND ld.LandModelId= @LandModelId 
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
    --AND lh.LandModelId='702023'
    --AND ld.LandModelId='702023'
    AND lh.LandModelId= @LandModelId
    AND ld.LandModelId= @LandModelId 
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
    ct.DocNumber,
    SUM(cbsf.[CommSF]) AS [CommBldMultiSaleSF]
    
    --bring in this table
    
  FROM CTE_TransferSales AS ct -- ON t.lrsn for joins
  JOIN CTE_CommBldgSF AS cbsf ON ct.lrsn=cbsf.lrsn

  WHERE ct.TranxType = 'M' -- Filter only Multi-Sale cases
  GROUP BY     ct.DocNumber
),

-----------------------
--CTE_CommAcres pulls in Commercial SF for a $/SF Rate
-----------------------
CTE_CommAcres AS (
  SELECT
    pm.lrsn,
    SUM(pm.LegalAcres) AS [CommAcres]
    
  FROM TSBv_PARCELMASTER AS pm
  WHERE pm.EffStatus = 'A'    

  GROUP BY pm.lrsn
  
),

CTE_CommMultiSaleAcres AS (
  SELECT
    tsa.DocNumber,
    SUM(cbac.[CommAcres]) AS [CommMultiSaleAcres]

    --bring in this table
    
  FROM CTE_TransferSales AS tsa -- ON t.lrsn for joins
  JOIN CTE_CommAcres AS cbac 
    ON tsa.lrsn=cbac.lrsn
  WHERE tsa.TranxType = 'M' -- Filter only Multi-Sale cases
  GROUP BY tsa.DocNumber
),

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
)







-------------------------------------
-- End of CTEs
-------------------------------------






-------------------------------------
-- BEGIN SELECT


--START Primary Qeury, Driven by Transfer Table
--FROM Transfer table, JOIN CTEs

-------------------------------------

SELECT DISTINCT
pmd.District
-- # District SubClass
,pmd.District_SubClass
  --This query is driven by Transfer Table, sales in 2022-2023
  --Parcel Master Details
,pmd.GEO
--  pmd.[GEO_Name],
,tr.lrsn
,pmd.PIN
,pmd.AIN
,pmd.SitusAddress
--,pmd.[SitusCity],
,pmd.PCC_ClassCD
,CAST(LEFT(TRIM(pmd.PCC_ClassCD),3) AS INT) AS PCC_Num
----------------------------
--Commercial Start
---------------------------
,comm.use_codes
,comm.year_built
,comm.eff_year_built
,comm.year_remodeled
,comm.condition
,comm.GradeCode -- is this a code that needs a type key?
,comm.GradeType
-----------------------------
--Non-WF COMMERCIAL Land RATES
-----------------------------
--ACRES Calcs Legal, Site, Cat19 Waste, see CTE for details
-- Added [Cat19Waste] ISNULL and CASE to handle NAs
  --carea.CAREA_Acres,
  
--CAST (1 AS int) AS [Site_1_Acre], Comercial doesn't do "Site Value" this way
,ISNULL(c19.[Cat19Waste], 0) AS [Cat19Waste]
    --CASE 
      --  WHEN pmd.LegalAcres > 1 THEN pmd.LegalAcres - CAST(1 AS int) - ISNULL(c19.[Cat19Waste], 0)
      --  ELSE NULL
    --END AS [Remaining_Acres],
  --RemAcres.lcm AS RemAcresLCM,
  --RemAcres.LandType, -- Use as test for reference not in final workbook
-----------------------------
--Non-WF COMMERCIAL Land LEGEND and INFLUENCE
-----------------------------
--LEGEND CASE Land Detail
,legkey.Legend
,CASE
    WHEN legkey.Legend IS NULL THEN CAST(1 AS INT)
    ELSE legkey.LegendNum
  END AS Legend_Number

--INFLUENCE FACTOR CASE Land Detail
,cld.InfluenceType
  --cld.[InfluenceFactor(s)],
,CASE 
    WHEN cld.InfluenceType LIKE '1%' THEN CAST(TRIM(cld.InfluenceFactors) AS DECIMAL(10, 2)) / 100.0
    -- Without this (/100) it produces "10" for 10%, but we need it to be 0.10 for math.
    ELSE NULL 
  END AS InfluenceFactor1

,CASE 
    WHEN cld.InfluenceType LIKE '2%' THEN CAST(TRIM(cld.InfluenceFactors) AS INT)
    ELSE NULL 
  END AS InfluenceFactor2
---------------------------
--COMMERCIAL REQUIRES WORKSHEET VALUES
--Value Calculations
--------------------------
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
----------------------------
--Commercial End
---------------------------
---------------------------
--ALWAYS INCLUDE BELOW
--Value Calculations
--------------------------
--Certified Values 2023
,cv23.Cert_Land
,cv23.Cert_Imp
,cv23.Cert_Total
,pmd.WorkValue_Impv AS WorksheetValue_TOS_ImpValue
--Transfer Table Sale Details
,tr.SalePrice
,tr.SaleDate
,tr.SaleDescr
,tr.TranxType
,tr.DocNumber -- Multiples will have the same DocNum
,tr.GrantorName
,tr.GranteeName

---MultiSale Logic
,COALESCE(msv.MultiSale_Land, 0) AS MultiSale_Land
,COALESCE(msv.MultiSale_Imp, 0) AS MultiSale_Imp
,COALESCE(msv.MultiSale_TotalSums,  0) AS MultiSale_TotalSums
,COALESCE(msv.MultiSale_WorksheetImp, 0) AS MultiSale_WorksheetImp
--Improved vs vacant (unimproved)
,pmd.Improvement_Status
--------------------------------
--Commercial Square Foot and Acres
--------------------------------
,commsf.CommSF
--Commercial Improvement - $/SF Calcs
,(cv23.Cert_Total/commsf.CommSF) AS CertValue_SF
,(pmd.WorkValue_Impv/commsf.CommSF) AS WkSheetValue_SF
,(tr.SalePrice/commsf.CommSF) AS SalePrice_SF
,commsfMSale.CommBldMultiSaleSF
,(COALESCE(msv.MultiSale_TotalSums, 0) / commsfMSale.CommBldMultiSaleSF) AS MultiSalePrice_SF
,macres.CommMultiSaleAcres
,pmd.LegalAcres

-- "_" AS [NotesInSeperate part of sheet>>>],
  --Notes in the Proval Memo Headers SA or SAMH will show here
,Snotes.Sales_Notes
,Cnotes.Conf_Notes



----------------------------------
-- END SELECT
----------------------------------



----------------------------------
-- BEGIN TABLE JOINS
----------------------------------

--FROM The transfer table to start the filters
FROM CTE_TransferSales AS tr -- ON tr.lrsn for joins
--FROM CTE_ParcelMasterData AS pmd 
--CTEs
-- Join Parcel Master
JOIN CTE_ParcelMasterData AS pmd 
--LEFT JOIN CTE_TransferSales AS tr -- ON tr.lrsn for joins
  ON tr.lrsn=pmd.lrsn


  --comm improvements 
  LEFT JOIN CTE_Improvements_Commercial AS comm 
    ON tr.lrsn=comm.lrsn
    AND comm.RowNum = 1

    ----Certified Values
  LEFT JOIN CTE_CertValues AS cv23 
    ON tr.lrsn=cv23.lrsn
    AND cv23.RowNumber = '1'
  --msv. MultiSale Summed Values <-Complicated to set up, review CTEs
  LEFT JOIN CTE_MultiSaleSums AS msv 
    ON tr.DocNumber=msv.DocNumber
  --CTE_Cat19Waste  as c19.
  LEFT JOIN CTE_Cat19Waste AS c19 
    ON tr.lrsn=c19.lrsn
  -- Commercial Square Foot
  LEFT JOIN CTE_CommBldgSF AS commsf 
    ON tr.lrsn=commsf.lrsn
  --Commercial Bldg MultiSale Information, see CTEs
  --commsfMSale.[CommBldMultiSaleSF]
  LEFT JOIN CTE_CommBldMultiSaleSF AS commsfMSale 
    ON  tr.DocNumber=commsfMSale.DocNumber

  --Land Details CTE 
 --<< Can this be replaced with the new WF CTEs?? >>
    LEFT JOIN CTE_LandDetails AS cld 
      ON tr.lrsn=cld.lrsn
      AND cld.[RowNumber] = '1'
      
    LEFT JOIN CTE_LegendKey AS legkey
      ON legkey.Site_Rating=cld.SiteRating
    
  -- CommAcres
  LEFT JOIN CTE_CommMultiSaleAcres AS macres
    ON  tr.DocNumber=macres.DocNumber
    -- macres.CommMultiSaleAcres

  --Sales Analysis Memos from ProVal
  LEFT JOIN CTE_NotesSalesAnalysis AS Snotes 
    ON tr.lrsn=Snotes.lrsn
  --Confidential Notes from ProVal
  LEFT JOIN CTE_NotesConfidential AS Cnotes 
    ON tr.lrsn=Cnotes.lrsn



-------------------------------------
--BEGIN WHERE Conditions for t only, all others drive CTEs or JOINs
-------------------------------------

WHERE tr.status = 'A'
--AND pmd.AIN IN ('142762','135478','249334') -- Use to test cases only

-----------------------
----Filter for Commercial
-----------------------
AND pmd.[GEO] BETWEEN '1' AND '899'
--AND pmd.[GEO] = 1

AND tr.GrantorName <> tr.GranteeName

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