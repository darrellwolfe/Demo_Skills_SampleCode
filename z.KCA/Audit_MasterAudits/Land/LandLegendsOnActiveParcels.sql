-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

---------
--Select All
---------
Select Distinct *
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

*/


WITH

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
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
)

--Order By District,GEO;



SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.ClassCD
,pmd.Property_Class_Description

,cld.LandType
,cld.LandTypeDesc

,cld.lcm
,cld.LandMethodDesc

,cld.Legend

,cld.SoilIdent
,cld.LDAcres
,cld.ActualFrontage



FROM CTE_ParcelMaster AS pmd

JOIN CTE_LandDetails AS cld
  ON cld.RevObjId = pmd.lrsn


