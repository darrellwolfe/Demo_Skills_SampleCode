-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
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

--Order By District,GEO;

-----------------------
--CTE_LandDetailsRemAcre pulls the LCM and Land Type for only Remaining Acres legends.
-----------------------
CTE_LandDetailsRemAcre AS (
  SELECT
  lh.RevObjId
  ,ld.LandDetailType
  ,ld.lcm
  ,ld.LandType
  ,ld.LDAcres
  ,ld.BaseRate
  ,lt.land_type_desc
  
  ,ROW_NUMBER() OVER (PARTITION BY lh.RevObjId ORDER BY ld.LDAcres DESC) AS rn
  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld 
    ON lh.id=ld.LandHeaderId 
      AND ld.EffStatus='A' 
      AND ld.PostingSource='A'

  LEFT JOIN land_types AS lt 
    ON ld.LandType=lt.land_type

  LEFT JOIN codes_table AS sr 
    ON ld.SiteRating = sr.tbl_element
      AND sr.tbl_type_code='siterating'

WHERE lh.EffStatus='A'
AND lh.PostingSource='A'
AND ld.LandType IN ('91')
AND ld.lcm IN ('3','30')

)


SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,df.RevObjId
,pmd.PIN
,pmd.AIN
,df.land_type_desc

/*
,df.LDAcres
,df.LandDetailType
,df.lcm

,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.TAG
,pmd.Owner
,pmd.SitusAddress
,pmd.SitusCity
*/

FROM CTE_LandDetailsRemAcre AS df

JOIN CTE_ParcelMaster AS pmd
    ON df.RevObjId=pmd.lrsn

WHERE rn > 1
ORDER BY RevObjId;

