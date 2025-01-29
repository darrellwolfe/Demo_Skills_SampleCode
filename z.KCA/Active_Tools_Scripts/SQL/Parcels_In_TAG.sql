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



Declare @CadasterYear int = 2023;

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
,pm.Improvement_Status -- <Improved vs Vacant
,TRIM(pm.TAG) AS TAG
,pm.LegalAcres
,TRIM(pm.DisplayDescr) AS LegalDescription
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity


/*
,TRIM(pm.DisplayName) AS Owner

,TRIM(pm.SitusState) AS SitusState
,TRIM(pm.SitusZip) AS SitusZip

,TRIM(pm.AttentionLine) AS AttentionLine
,TRIM(pm.MailingAddress) AS MailingAddress
,TRIM(pm.AddlAddrLine) AS AddlAddrLine
,TRIM(pm.MailingCityStZip) AS MailingCityStZip
,TRIM(pm.MailingCity) AS MailingCity
,TRIM(pm.MailingState) AS MailingState
,TRIM(pm.MailingZip) AS MailingZip
,TRIM(pm.CountyNumber) AS CountyNumber

,CASE
  WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
  ELSE NULL
END AS County_Name

,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod

*/

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
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

),

--Declare @CadasterYear int = 2023

CTE_CadasterValues AS (
 Select Distinct
 TaxYear
 ,CadRollId
 ,TypeCode
 ,r.Descr AS AssessmentType
 ,TAG
 ,LRSN
 ,ValueAmount  AS Cadaster_Value
 --sum(ValueAmount) 
  --,tta.TaxAuthorityId
 From tsbv_cadastre AS c 
 Join TagTaxAuthority AS tta
   On tta.tagid = c.tagid
   And tta.EffStatus = 'A'
   And tta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority ttasub where ttasub.id = tta.id and ttasub.BegEffYear <= @CadasterYear)
 Join TaxAuthority AS ta
   On ta.id = tta.TaxAuthorityId
   And ta.EffStatus = 'A'
   And ta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority tasub where tasub.id = ta.id and tasub.BegEffYear <= @CadasterYear)
 Join Taf
   On taf.TaxAuthorityId = ta.id
   And taf.EffStatus = 'A'
   And taf.BegEffYear = (select max(BegEffYear) from Taf tafsub where tafsub.id = taf.id and tafsub.BegEffYear <= @CadasterYear)
 Join Fund AS f
   On f.id = taf.fundId
   And f.EffStatus = 'A'
   And f.BegEffYear = (select max(BegEffYear) from Fund fsub where fsub.id = f.id and fsub.BegEffYear <= @CadasterYear)
 Join ValueType AS vt
   On vt.id = c.ValueType
   --And vt.ShortDescr = 'Total Value'
 Join CadRoll AS r
   On c.CadRollId = r.Id
   --And r.Id = '563'


 Where c.taxyear = @CadasterYear
 And TypeCode = 'Net Tax Value'
 )

--Order By District,GEO;


SELECT DISTINCT

pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.ClassCD
,pmd.Property_Class_Description
--,pmd.Property_Class_Type
,pmd.TAG
--,tag_tif.
,tag_tif.TIF
,tag_tif.TaxAuthority

--,pmd.lrsn
,pmd.PIN
,pmd.AIN

,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity
--,CONCAT(pmd.SitusCity, ', ', pmd.SitusState, ' ', pmd.SitusZip) AS FullAddress
,pmd.LegalAcres
,pmd.Improvement_Status 
,cad.Cadaster_Value
,cad.TypeCode
,cad.AssessmentType


FROM CTE_ParcelMaster AS pmd

JOIN CTE_TAG_TA_TIF_Key AS tag_tif
  ON tag_tif.TAG = pmd.TAG
  And tag_tif.TaxAuthId = '242'
  And tag_tif.TaxAuthority = '242-HAUSER LAKE FIRE'

  --ta.id = '242' -- Hauser Fire District
JOIN CTE_CadasterValues AS cad
  ON cad.LRSN = pmd.lrsn

  
Order By District, GEO, PIN;




