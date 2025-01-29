
-------------------------------------
-- CTE_LandDetails
-------------------------------------

CTE_LandDetails AS (
SELECT
lh.RevObjId -- AS [lrsn],
,ld.LandDetailType
,ld.lcm

,lm.method_desc AS LandMethodDesc

,ld.LandType
,lt.land_type_desc AS LandTypeDesc
,ld.SoilIdent
,ld.LDAcres
,ld.ActualFrontage
,ld.DepthFactor
,ld.SoilProdFactor
,ld.SmallAcreFactor
,ld.SiteRating
,TRIM (sr.tbl_element_desc) AS [Legend]
,ROW_NUMBER() OVER (PARTITION BY lh.RevObjId ORDER BY sr.tbl_element_desc ASC) AS [RowNumber]
,li.InfluenceCode
,STRING_AGG (li.InfluenceAmount, ',') AS [InfluenceFactors]
,li.InfluenceAmount
,CASE
      WHEN li.InfluenceType = 1 THEN '1-Pct'
      ELSE '2-Val'
 END AS [InfluenceType]
,li.PriceAdjustment

--Land Header
FROM LandHeader AS lh
--Land Detail
JOIN LandDetail AS ld 
  ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'

LEFT JOIN codes_table AS sr 
  ON ld.SiteRating = sr.tbl_element
    AND sr.tbl_type_code='siterating'

--Land Types
LEFT JOIN land_types AS lt 
  ON ld.LandType=lt.land_type

--Land Influence
LEFT JOIN LandInfluence AS li 
  ON li.ObjectId = ld.Id
    AND li.EffStatus='A' 
    AND li.PostingSource='A'

JOIN land_methods AS lm
  ON lm.method_number=ld.lcm
    AND lm.method_status='A'

WHERE lh.EffStatus= 'A' 
  AND lh.PostingSource='A'

  --AND lt.land_type_desc LIKE '%Site%'

--Change land model id for current year
  --AND lh.LandModelId=@LandModelID
  --AND ld.LandModelId=@LandModelID
  --AND ld.LandType IN ('9','31','32')

--Looking for:
  --AND ld.LandType IN ('82')
  GROUP BY
lh.RevObjId
,ld.LandDetailType
,ld.lcm
,lm.method_desc
,ld.LandType
,lt.land_type_desc
,ld.SoilIdent
,ld.LDAcres
,ld.ActualFrontage
,ld.DepthFactor
,ld.SoilProdFactor
,ld.SmallAcreFactor
,ld.SiteRating
,sr.tbl_element_desc
,li.InfluenceCode
,li.InfluenceAmount
,li.InfluenceType
,li.PriceAdjustment
    
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



-----------------------
--CTE_LandDetailsRemAcre pulls the LCM and Land Type for only Remaining Acres legends.
-----------------------
CTE_LandDetailsRemAcre AS (
  SELECT
  lh.RevObjId AS [lrsn]
  ,ld.LandDetailType
  ,ld.lcm
  ,ld.LandType
  ,ld.LDAcres
  ,ld.BaseRate
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource=ld.PostingSource
  LEFT JOIN codes_table AS sr ON ld.SiteRating = sr.tbl_element
      AND sr.tbl_type_code='siterating'

WHERE ld.LandType IN ('91')
AND ld.lcm IN ('3','30')
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
)