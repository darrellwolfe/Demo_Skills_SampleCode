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
  WHEN pm.neighborhood = 0 THEN 'Other (PP, OP, NA, Error)'
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
,TRIM(pm.DisplayDescr) AS LegalDescription
,TRIM(pm.SitusAddress) AS SitusAddress
,pm.LegalAcres
,pm.Improvement_Status -- <Improved vs Vacant
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod

From TSBv_PARCELMASTER AS pm

Where pm.ClassCD NOT LIKE '070%'
--And pm.EffStatus = 'A'
),

CTE_TAG_TA_TIF_Key AS (

  SELECT DISTINCT 
  tag.Id AS TAGId,
  TRIM(tag.Descr) AS TAG,
  tif.Id AS TIFId,
  TRIM(tif.Descr) AS TIF,
  ta.Id AS TaxAuthId,
  TRIM(ta.Descr) AS TaxAuthority
  
  --TAG Table
  FROM TAG AS tag
  --TAGTIF Key
  LEFT JOIN TAGTIF 
    ON TAG.Id=TAGTIF.TAGId 
    AND TAGTIF.EffStatus = 'A'
  --TIF Table
  LEFT JOIN TIF AS tif 
    ON TAGTIF.TIFId=TIF.Id 
    AND TIF.EffStatus  = 'A'
  --TAGTaxAuthority Key
  LEFT JOIN TAGTaxAuthority 
    ON TAG.Id=TAGTaxAuthority.TAGId 
    AND TAGTaxAuthority.EffStatus = 'A'
  --TaxAuthority Table
  LEFT JOIN TaxAuthority AS ta 
    ON TAGTaxAuthority.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
  --CTE_ JOIN, only want TAGs in this TaxAuth
  
  WHERE tag.EffStatus = 'A'
--  AND ta.id = '242'
  And tif.Descr IS NOT NULL
  And tif.Descr LIKE '%URD%'
),

--Looking to see what PP accounts have a URD Modifier, to be compared with URD in the legal descriptions
CTE_ModURD  AS (
SELECT
lrsn,
BegTaxYear,
ExpirationYear,
TRIM(ModifierDescr) AS URDDescr,
ModifierPercent AS URDPerc,
OverrideAmount AS URDBase

FROM TSBv_MODIFIERS
WHERE ModifierDescr LIKE '%URD%'
AND ExpirationYear > 2024
--AND ModifierStatus='A'
--AND PINStatus='A'
/*
In many cases, working URD splits and segs, 
  the parcel is already inactive. 
  I need the modifier from the inactive parcel.
*/
)







SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,LEFT(pmd.PIN,5) AS PlatPINs
,pmd.AIN
,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.TAG
,ttt.TIF
,mURD.URDDescr
,mURD.BegTaxYear
,mURD.ExpirationYear
,mURD.URDBase
,mURD.URDPerc
,pmd.LegalAcres
,pmd.Owner
,pmd.LegalDescription
,pmd.SitusAddress
,pmd.Improvement_Status 
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod

FROM CTE_ParcelMaster AS pmd

LEFT JOIN CTE_TAG_TA_TIF_Key AS ttt
  On ttt.tag = pmd.tag

LEFT JOIN CTE_ModURD AS mURD 
  ON pmd.lrsn=mURD.lrsn


Order By District,GEO, PIN;

