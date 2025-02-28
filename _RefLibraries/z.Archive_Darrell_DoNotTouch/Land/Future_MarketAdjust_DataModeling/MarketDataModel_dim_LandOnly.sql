/*
-- !preview conn=conn
*/

/*
AsTxDBProd
GRM_Main
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


WITH

CTE_LandDetails AS (
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
  --And (ld.LAndType IN ('9','31','32') -- Residential Homesite
    --Or ld.LAndType IN ('11')) -- All Commercial Land
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
    
)

Select Distinct *
From CTE_LandDetails








/*
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

*/