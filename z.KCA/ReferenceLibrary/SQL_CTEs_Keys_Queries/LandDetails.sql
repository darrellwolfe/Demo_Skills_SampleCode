-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/


--Change year 2023, 2024, 2025, etc. '702023'
DECLARE @LandModelId INT = '702023';

-------------------------------------
-- CTE_LandDetails
-------------------------------------

WITH 

CTE_LandInfluenceCodesKey AS (
  SELECT
  tbl_element AS InfluenceCode,
  tbl_element_desc AS InfluenceCodeDescription
  FROM codes_table
  WHERE TRIM(tbl_type_code) LIKE 'landinf%'
  AND code_status='A'
),

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


-- CTE_LandDetails AS (

  SELECT
  lh.RevObjId AS lrsn,
  ld.LandDetailType,
  lh.TotalMktAcreage,
  lh.TotalMktValue,
  
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
  
  -- Land Influence Data
  li.InfluenceCode,
  lic.InfluenceCodeDescription,
  CASE
    WHEN lic.InfluenceCodeDescription IS NULL THEN NULL
    WHEN lic.InfluenceCodeDescription LIKE '%OCR%' THEN 'OCR'
    WHEN lic.InfluenceCodeDescription LIKE '%length%' THEN 'Length'
  ELSE 'Other'
  END AS LandInfluence_AdjustmentGroups,
  --STRING_AGG (li.InfluenceAmount, ',') AS InfluenceFactors,
  li.InfluenceAmount,
  -- li.InfluenceType 1 is percentages and type 2 is dollar amounts
  CASE
      WHEN li.InfluenceType = 1 THEN '1-Pct'
      ELSE '2-Val'
  END AS InfluenceType,
  li.PriceAdjustment,

ROW_NUMBER() OVER (PARTITION BY lh.RevObjId ORDER BY leg.LegendNum ASC) AS RowNumber
  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld 
  ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
  --Legend Key    
  LEFT JOIN CTE_LegendKey AS leg 
  ON ld.SiteRating = leg.Site_Rating
  --Land Types
  LEFT JOIN land_types AS lt 
  ON ld.LandType=lt.land_type
  --Land Influence
  LEFT JOIN LandInfluence AS li 
  ON li.ObjectId = ld.Id
    AND li.EffStatus='A' 
    AND li.PostingSource='A'
  --Land Influcnce Code Key for Description
  LEFT JOIN CTE_LandInfluenceCodesKey AS lic 
  ON lic.InfluenceCode=li.InfluenceCode
  
  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'

  --Change land model id for current year
    AND lh.LandModelId=@LandModelId
    AND ld.LandModelId=@LandModelId
    --AND ld.LandType IN ('9','31','32','90','94','95')
  --Looking for:
    AND lh.RevObjId= 2 --< For testing results
    
    
    --AND ld.LandType IN ('82')
    
    
    /*
    GROUP BY
  lh.RevObjId,
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
  leg.LegendNum,
  li.InfluenceCode,
  lic.InfluenceCodeDescription,
  li.InfluenceAmount,
  li.InfluenceType,
  li.PriceAdjustment
  */
  --)