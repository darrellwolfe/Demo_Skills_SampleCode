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



Declare @Year int = 2024; -- This is the year today, for the CURRENT base.

Declare @CadasterYear int = 2022; -- Year base needs to be established

WITH 

CTE_ParcelMaster AS (
--------------------------------
--ParcelMaster
--------------------------------
Select Distinct
pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description

,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.DisplayDescr) AS LegalDescription
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,pm.WorkValue_Total
,pm.Improvement_Status -- <Improved vs Vacant


From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
--AND pm.ClassCD NOT LIKE '070%'
And pm.ClassCD IN ('020', '021', '022', '030', '031', '032')
    --, '040', '050', '060', '070', '080', '090')

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
 ,ValueAmount  AS Cadaster_Value_NetTax
 --sum(ValueAmount) 

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
 ),
 
 CTE_TAG_TA_TIF_Key AS (
  SELECT DISTINCT 
  tag.Id AS TAGId,
  TRIM(tag.Descr) AS TAG,
  tif.Id AS TIFId,
  TRIM(tif.Descr) AS TIF,
  ROW_NUMBER() OVER (PARTITION BY tif.Descr ORDER BY tif.Id DESC) AS RowNum,
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
  And tif.Id IS NOT NULL
  And tif.Descr LIKE '%URD%'
--  	And murd.ModifierDescr LIKE '%URD%' 
  /*
  GROUP BY 
  tag.Id
  ,tag.Descr
  ,tif.Id
  ,ta.Id
  ,ta.Descr
  */
)

--Order By District,GEO;



SELECT DISTINCT
pmd.lrsn
,pmd.PIN
,pmd.AIN
--,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.TAG
,tag_tif.TIF
--,cv.TaxYear
--,cv.CadRollId
,cv.TypeCode
,cv.AssessmentType
--,cv.TAG
--,cv.LRSN
,pmd.WorkValue_Total

,cv.Cadaster_Value_NetTax

,murd.OverrideAmount AS URD_BaseValue

,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity
,pmd.Owner


FROM CTE_ParcelMaster AS pmd
  
LEFT JOIN CTE_TAG_TA_TIF_Key AS tag_tif
  On pmd.TAG = tag_tif.TAG
  And RowNum = 1

LEFT JOIN CTE_CadasterValues AS cv
  ON cv.lrsn = pmd.lrsn

Left Join TSBv_MODIFIERS AS murd 
  On pmd.lrsn=murd.lrsn 
	And murd.ModifierStatus='A' 
	And murd.ModifierDescr LIKE '%URD%' 
	And murd.ExpirationYear > @Year

Order By pmd.Property_Class_Description, pmd.PIN;


