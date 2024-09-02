-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

--DECLARE @VariableName INT = '';

--Change year 2023, 2024, 2025, etc. '702023'
DECLARE @LandModelId INT = '702024';


WITH

CTE_ParcelMaster AS (
--------------------------------
--ParcelMaster
--------------------------------
Select Distinct
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
END AS District

-- # District SubClass
,pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
,pm.LegalAcres


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
AND pm.neighborhood <> 0
AND pm.neighborhood IS NOT NULL
),

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
),

CTE_LandDetails AS (
  SELECT
  lh.RevObjId AS lrsn
, ld.LandType
,  CONCAT_WS('-',ld.LandType,lt.land_type_desc) AS LandType_Desc
--,  ld.LandType
--,  lt.land_type_desc
--,  ld.LDAcres
--,  leg.Legend
  
  --  STRING_AGG ( xxx , ',') AS xxx
--,  STRING_AGG (ld.LandType, ',') AS LandType
--,  STRING_AGG (lt.land_type_desc, ',') AS land_type_desc
,  STRING_AGG (ld.LDAcres, ', ') AS LDAcres
,  STRING_AGG (leg.Legend, ', ') AS Legend

/*
,  ld.LandDetailType
,  lh.TotalMktAcreage
,  lh.TotalMktValue
,  ld.lcm
,  ld.SoilIdent
,  ld.ActualFrontage
,  ld.EffFrontage
,  ld.EffDepth
,  ld.SqrFeet
,  ld.DepthFactor
,  ld.SoilProdFactor
,  ld.SmallAcreFactor
,  ld.SiteRating
,  CASE
    WHEN leg.Legend IS NULL THEN CAST(1 AS INT)
    ELSE leg.LegendNum
  END AS Legend_Number
  
  -- Land Influence Data
,  li.InfluenceCode
,  lic.InfluenceCodeDescription
,  CASE
    WHEN lic.InfluenceCodeDescription IS NULL THEN NULL
    WHEN lic.InfluenceCodeDescription LIKE '%OCR%' THEN 'OCR'
    WHEN lic.InfluenceCodeDescription LIKE '%length%' THEN 'Length'
  ELSE 'Other'
  END AS LandInfluence_AdjustmentGroups
  
,  STRING_AGG (li.InfluenceAmount, ',') AS InfluenceAmount
--STRING_AGG (li.InfluenceType, ',') AS InfluenceType,
--  li.InfluenceAmount,
  -- li.InfluenceType 1 is percentages and type 2 is dollar amounts
,  CASE
      WHEN li.InfluenceType = 1 THEN '1-Pct'
      ELSE '2-Val'
  END AS InfluenceType
  
,  li.PriceAdjustment

, ROW_NUMBER() OVER (PARTITION BY lh.RevObjId ORDER BY leg.LegendNum ASC) AS RowNumber
  */
  
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
    --AND lh.LandModelId=@LandModelId
    --AND ld.LandModelId=@LandModelId
    --AND ld.LandType IN ('9','31','32','90','94','95')
  --Looking for:
    --AND lh.RevObjId= 532911 --< For testing results
    --AND ld.LandType IN ('82')
    
    
  GROUP BY
  lh.RevObjId

--  ld.LDAcres
,  ld.LandType
,  lt.land_type_desc
--  leg.Legend

/*
  ld.LandDetailType,
  lh.TotalMktAcreage,
  lh.TotalMktValue,
  ld.lcm,
  ld.SoilIdent,
  ld.ActualFrontage,
  ld.EffFrontage,
  ld.EffDepth,
  
  ld.SqrFeet,
  ld.DepthFactor,
  ld.SoilProdFactor,
  ld.SmallAcreFactor,
  ld.SiteRating,
  li.InfluenceCode,
  lic.InfluenceCodeDescription,
  li.PriceAdjustment,
  leg.LegendNum,
  li.InfluenceType
*/
),

CTE_WorksheetMarketValues AS(
SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_inc AS Worksheet_Land,
    (r.income_value - r.land_mkt_val_cost) AS Worksheet_Imp,
    r.income_value AS Worksheet_Total

FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status = 'W'
AND r.method = 'I' 
--AND r.land_model = @LandModelId

UNION ALL

SELECT 
    r.lrsn,
    r.method AS PriceMethod,
    r.land_mkt_val_cost AS Worksheet_Land,
    r.cost_value AS Worksheet_Imp,
    (r.cost_value + r.land_mkt_val_cost) AS Worksheet_Total
    
FROM reconciliation AS r 
--ON parcel.lrsn = r.lrsn
WHERE r.status='W'
AND r.method = 'C' 
--AND r.land_model = @LandModelId

--ORDER BY GEO, PIN;
)

SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN

,ws.Worksheet_Imp
,ws.Worksheet_Land
,ws.Worksheet_Total
,ws.PriceMethod
,pmd.LegalAcres

,'>LandDetails>' AS LandDetails
,land.LandType_Desc
,land.Legend AS Legend_Land
,land.LDAcres AS LDAcres_Land
--,STRING_AGG (CONCAT_WS('-',land.LandType,land.land_type_desc), ',') AS LandType
--,STRING_AGG (land.Legend, ',') AS Legend_Land
--,STRING_AGG (CAST(land.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Land

,rem.LandType_Desc
,rem.Legend AS Legend_Rem
,rem.LDAcres AS LDAcres_Rem
--,STRING_AGG (CONCAT_WS('-',rem.LandType,rem.land_type_desc), ',') AS LandType_Rem
--,STRING_AGG (rem.Legend, ',') AS Legend_Rem
--,STRING_AGG (CAST(rem.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Rem

,carea.LandType_Desc
,carea.Legend AS Legend_Carea
,carea.LDAcres AS LDAcres_Carea
--,STRING_AGG (CONCAT_WS('-',carea.LandType,carea.land_type_desc), ',') AS LandType_Carea
--,STRING_AGG (carea.Legend, ',') AS Legend_Carea
--,STRING_AGG (CAST(carea.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Carea

,nonb.LandType_Desc
,nonb.Legend AS Legend_NonBuild
,nonb.LDAcres AS LDAcres_NonBuild
--,STRING_AGG (CONCAT_WS('-',nonb.LandType,nonb.land_type_desc), ',') AS LandType_NonBuild
--,STRING_AGG (nonb.Legend, ',') AS Legend_NonBuild
--,STRING_AGG (CAST(nonb.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_NonBuild

,waste.LandType_Desc
,waste.Legend AS Legend_Waste
,waste.LDAcres AS LDAcres_Waste
--,STRING_AGG (CONCAT_WS('-',waste.LandType,waste.land_type_desc), ',') AS LandType_Waste
--,STRING_AGG (waste.Legend, ',') AS Legend_Waste
--,STRING_AGG (CAST(waste.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Waste

,timber.LandType_Desc
,timber.Legend AS Legend_Timber
,timber.LDAcres AS LDAcres_Timber
--,STRING_AGG (CONCAT_WS('-',timber.LandType,timber.land_type_desc), ',') AS LandType_Timber
--,STRING_AGG (timber.Legend, ',') AS Legend_Timber
--,STRING_AGG (CAST(timber.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Timber

,ex.LandType_Desc
,ex.Legend AS Legend_Exempt
,ex.LDAcres AS LDAcres_Exempt
--,STRING_AGG (CONCAT_WS('-',ex.LandType,ex.land_type_desc), ',') AS LandType_Exempt
--,STRING_AGG (ex.Legend, ',') AS Legend_Exempt
--,STRING_AGG (CAST(ex.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Exempt

,other.LandType_Desc
,other.Legend AS Legend_Other
,other.LDAcres AS LDAcres_Other
--,STRING_AGG (CONCAT_WS('-',other.LandType,other.land_type_desc), ',') AS LandType_Other
--,STRING_AGG (other.Legend, ',') AS Legend_Other
--,STRING_AGG (CAST(other.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Other



FROM CTE_ParcelMaster AS pmd

Left Join CTE_WorksheetMarketValues AS ws
  On ws.lrsn = pmd.lrsn
  
Left Join CTE_LandDetails AS land
  ON land.lrsn = pmd.lrsn
  And land.LandType IN ('9','9V','31','32','90','94','11','12')

Left Join CTE_LandDetails AS rem
  ON rem.lrsn = pmd.lrsn
  And rem.LandType IN ('91')

Left Join CTE_LandDetails AS carea
  ON carea.lrsn = pmd.lrsn
  And carea.LandType IN ('C','CA')

Left Join CTE_LandDetails AS nonb
  ON nonb.lrsn = pmd.lrsn
  And nonb.LandType IN ('33','95')

Left Join CTE_LandDetails AS waste
  ON waste.lrsn = pmd.lrsn
  And waste.LandType IN ('82') 

Left Join CTE_LandDetails AS timber
  ON timber.lrsn = pmd.lrsn
  And land.LandType IN ('01','02','03','04','05','06','07','08','46','52','61','62','73','75')

Left Join CTE_LandDetails AS ex
  ON ex.lrsn = pmd.lrsn
  And ex.LandType IN ('81') 

Left Join CTE_LandDetails AS other
  ON other.lrsn = pmd.lrsn
  And other.LandType IN ('MB','MV','93') 

--Order By AIN;
--And pmd.lrsn = 70757 -- for test only

--Where pmd.AIN = '309026'
Where pmd.AIN = '309027'



Group By 
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,ws.Worksheet_Imp
,ws.Worksheet_Land
,ws.Worksheet_Total
,ws.PriceMethod
,pmd.LegalAcres



,land.LandType_Desc
,land.Legend --AS Legend_Land
,land.LDAcres --AS LDAcres_Land
--,STRING_AGG (CONCAT_WS('-',land.LandType,land.land_type_desc), ',') AS LandType
--,STRING_AGG (land.Legend, ',') AS Legend_Land
--,STRING_AGG (CAST(land.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Land

,rem.LandType_Desc
,rem.Legend --AS Legend_Rem
,rem.LDAcres --AS LDAcres_Rem
--,STRING_AGG (CONCAT_WS('-',rem.LandType,rem.land_type_desc), ',') AS LandType_Rem
--,STRING_AGG (rem.Legend, ',') AS Legend_Rem
--,STRING_AGG (CAST(rem.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Rem

,carea.LandType_Desc
,carea.Legend --AS Legend_Carea
,carea.LDAcres --AS LDAcres_Carea
--,STRING_AGG (CONCAT_WS('-',carea.LandType,carea.land_type_desc), ',') AS LandType_Carea
--,STRING_AGG (carea.Legend, ',') AS Legend_Carea
--,STRING_AGG (CAST(carea.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Carea

,nonb.LandType_Desc
,nonb.Legend --AS Legend_NonBuild
,nonb.LDAcres --AS LDAcres_NonBuild
--,STRING_AGG (CONCAT_WS('-',nonb.LandType,nonb.land_type_desc), ',') AS LandType_NonBuild
--,STRING_AGG (nonb.Legend, ',') AS Legend_NonBuild
--,STRING_AGG (CAST(nonb.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_NonBuild

,waste.LandType_Desc
,waste.Legend --AS Legend_Waste
,waste.LDAcres --AS LDAcres_Waste
--,STRING_AGG (CONCAT_WS('-',waste.LandType,waste.land_type_desc), ',') AS LandType_Waste
--,STRING_AGG (waste.Legend, ',') AS Legend_Waste
--,STRING_AGG (CAST(waste.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Waste

,timber.LandType_Desc
,timber.Legend --AS Legend_Timber
,timber.LDAcres --AS LDAcres_Timber
--,STRING_AGG (CONCAT_WS('-',timber.LandType,timber.land_type_desc), ',') AS LandType_Timber
--,STRING_AGG (timber.Legend, ',') AS Legend_Timber
--,STRING_AGG (CAST(timber.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Timber

,ex.LandType_Desc
,ex.Legend --AS Legend_Exempt
,ex.LDAcres --AS LDAcres_Exempt
--,STRING_AGG (CONCAT_WS('-',ex.LandType,ex.land_type_desc), ',') AS LandType_Exempt
--,STRING_AGG (ex.Legend, ',') AS Legend_Exempt
--,STRING_AGG (CAST(ex.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Exempt

,other.LandType_Desc
,other.Legend --AS Legend_Other
,other.LDAcres --AS LDAcres_Other
--,STRING_AGG (CONCAT_WS('-',other.LandType,other.land_type_desc), ',') AS LandType_Other
--,STRING_AGG (other.Legend, ',') AS Legend_Other
--,STRING_AGG (CAST(other.LDAcres AS NVARCHAR(10)), ',') AS LDAcres_Other





Order By GEO, PIN
