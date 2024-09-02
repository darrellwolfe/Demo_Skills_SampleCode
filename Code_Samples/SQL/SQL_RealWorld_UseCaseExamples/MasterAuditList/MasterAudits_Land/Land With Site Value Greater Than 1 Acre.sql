-- !preview conn=con

/*
AsTxDBProd
GRM_Main

---------
--Select All
---------
Select Distinct *
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'


TotalMktAcreage
TotalUseAcreage
TotalMktValue

From LandHeader

*/




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
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity

,pm.LegalAcres
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod
,pm.Improvement_Status -- <Improved vs Vacant

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),

CTE_LandDetails AS (
SELECT
lh.RevObjId -- AS [lrsn],
,ld.LandDetailType
,ld.lcm
,ld.LandType
,lt.land_type_desc
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
,inf.tbl_element_desc AS InluenceDesc
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

  JOIN codes_table AS inf
    On inf.tbl_element = li.InfluenceCode
    And inf.tbl_type_code LIKE 'landinf'
    And inf.code_status = 'A'

WHERE lh.EffStatus= 'A' 
  AND lh.PostingSource='A'

  AND ld.LandType IN ('9','9V','31','32')
--  AND ld.LandType IN ('9','9V','31','32','90','94')

  --CHECK SITE VALUES
  
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
,ld.LandType
,lt.land_type_desc
,ld.SoilIdent
,ld.LDAcres
,ld.ActualFrontage
,ld.DepthFactor
,ld.SoilProdFactor
,ld.SmallAcreFactor
,ld.SiteRating
,inf.tbl_element_desc
,sr.tbl_element_desc
,li.InfluenceCode
,li.InfluenceAmount
,li.InfluenceType
,li.PriceAdjustment
    
)


SELECT DISTINCT
pmd.District
,pmd.ClassCd
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,cld.RevObjId -- AS [lrsn],
,pmd.PIN
,pmd.AIN

,pmd.LegalAcres
,cld.LDAcres AS LandLineAcres
,cld.land_type_desc
,cld.LandType
,cld.lcm
,cld.ActualFrontage AS WF_Frontage
,cld.SiteRating
,cld.Legend
,cld.RowNumber

,cld.SoilIdent
,cld.SoilProdFactor
,cld.DepthFactor
,cld.SmallAcreFactor
,cld.InluenceDesc
,cld.InfluenceCode
,cld.InfluenceFactors
,cld.InfluenceAmount
,cld.InfluenceType
,cld.PriceAdjustment


FROM CTE_LandDetails AS cld


JOIN CTE_ParcelMaster AS pmd
    ON cld.RevObjId=pmd.lrsn

WHERE cld.LDAcres > 1

ORDER BY District, GEO, PIN;
    
    
    
    
    
    
