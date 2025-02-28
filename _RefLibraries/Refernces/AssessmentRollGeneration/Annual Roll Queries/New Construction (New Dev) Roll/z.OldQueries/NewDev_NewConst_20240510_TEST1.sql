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



Declare @Year int = 2024; -- Input THIS year here

Declare @YearPrev int = @Year - 1; -- Input the year here

Declare @NCYear varchar(4) = 'NC' + Right(Cast(@Year as varchar), 2); -- This will create 'NC24'

Declare @NCYearPrevious varchar(4) = 'NC' + Right(Cast(@YearPrev as varchar), 2); -- This will create 'NC24'

Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year

--Declare @EffYearLike varchar(4) = Cast(@YearPrev - 1 as varchar) + '%'; -- Generates '2023%' for the previous year



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
--,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.DisplayDescr) AS LegalDescription
,TRIM(pm.SitusAddress) AS SitusAddress

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),

CTE_Memo_NC AS (
Select
lrsn
--,memo_id
,STRING_AGG(memo_text, ' | ') AS NC
--JOIN Memos, change to current year NC22, NC23
From memos 
--  ON parcel.lrsn=mNC.lrsn 
WHere memo_id = @NCYearPrevious 
  And memo_line_number = '1'
  And status = 'A'
Group By lrsn
),


CTE_Memo_Building AS (
Select
lrsn
--,memo_id
,STRING_AGG(memo_text, ' | ') AS BuildingNotes
--JOIN Memos, change to current year B519
From memos
  --ON parcel.lrsn=mB519.lrsn 
  Where memo_id IN ('B519','6023','602W')
  And memo_line_number='1'
  And status = 'A'
  
Group By lrsn
),

CTE_TAG_TA_TIF_Key AS (
SELECT DISTINCT 
tag.Id AS TAGId
,TRIM(tag.Descr) AS TAG
,tif.Id AS TIFId
,TRIM(tif.Descr) AS TIF
--,ta.Id AS TaxAuthId
--,TRIM(ta.Descr) AS TaxAuthority

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
/*
--TAGTaxAuthority Key
LEFT JOIN TAGTaxAuthority 
  ON TAG.Id=TAGTaxAuthority.TAGId 
    AND TAGTaxAuthority.EffStatus = 'A'
--TaxAuthority Table
LEFT JOIN TaxAuthority AS ta 
  ON TAGTaxAuthority.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
--CTE_ JOIN, only want TAGs in this TaxAuth
*/
WHERE tag.EffStatus = 'A'
--AND ta.id = '242'

  
),

CTE_Cat81s AS (
Select
lrsn
,extension
,improvement_id
,group_code
--Allocations
From allocations AS a 
--ON parcel.lrsn=a.lrsn
Where a.status='A' 
And a.extension NOT LIKE 'L%'
And a.group_code = '81'
),

CTE_Imp AS (
Select Distinct
a.lrsn
,a.extension
,a.improvement_id
,a.group_code
,i.year_built
,i.year_remodeled
,v.imp_assess

--Allocations
From allocations AS a 

Join valuation AS v 
  On a.lrsn=v.lrsn
    And v.status = 'A'

Left Join extensions AS e 
  On a.lrsn=e.lrsn --JOIN extensions between parcel and improvements to filter out voided records
    And e.extension=a.extension 
    And e.status='A' 

Left Join improvements AS i 
  On e.lrsn=i.lrsn 
    And e.extension=i.extension 
    And a.extension=i.extension 
    And i.improvement_id = a.improvement_id
    And i.status='A' 

Where a.status = 'A'
  And a.extension NOT LIKE 'L%'
  And e.extension NOT LIKE 'L%'
  And a.group_code <> '81'

--YearFilters
  And v.eff_year = @EffYear0101Previous
  And (
      (i.improvement_id IN ('D','M') AND i.year_built = @YearPrev)
  	  Or (i.improvement_id IN ('C') AND (i.year_built = @YearPrev OR i.year_remodeled = @YearPrev))
  	  )
  	  

)


SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.Owner
,pmd.Property_Class_Description
,pmd.LegalDescription
,pmd.SitusAddress
,'Tag-Tif' AS TagTifCheck
,pmd.TAG
,CASE
  When tif.TIF IS NULL Then 'Non-TIF'
  When tif.TIF IS NOT NULL Then tif.TIF
  Else tif.TIF
 END AS TIF
,imp.group_code
,imp.imp_assess
--TaxableValue --- Huh?
--BaseValue --- Huh?
,murd.OverrideAmount AS URD_BaseValue
,(imp.imp_assess - murd.OverrideAmount) AS URD_IncrValue
--,murd.ModifierDescr AS URD_Desc
--,murd.ModifierPercent AS URD_Perc
--,murd.OverrideAmount AS URD_Amount

/*
,'Research_Items>' AS ResearchItems
--Improvements with value
,imp.extension
,imp.improvement_id
,imp.year_built
,imp.year_remodeled
--Existence of 81s
,c81.extension AS Ex_81
,c81.improvement_id AS Imp_81
,c81.group_code AS GC_81
--Home Owner's Information
,mhoex.ModifierDescr AS HOEX_Desc
,mhoex.ModifierPercent AS HOEX_Perc
,mhoex.OverrideAmount AS HOEX_Amount
--New Construction Related Notes	
,nc.NC
,b.BuildingNotes
--Property Information
*/



FROM CTE_ParcelMaster AS pmd
--  ON xxxx.lrsn = pmd.lrsn

Left Join CTE_Imp AS imp
  On pmd.lrsn = imp.lrsn
  
Left Join CTE_Memo_NC AS nc
  On pmd.lrsn = nc.lrsn

Left Join CTE_Memo_Building AS b
  On pmd.lrsn = b.lrsn

Left Join CTE_TAG_TA_TIF_Key AS tif
  On pmd.TAG = tif.TAG

Left Join CTE_Cat81s AS c81
  On pmd.lrsn = c81.lrsn

Left Join TSBv_MODIFIERS AS murd 
  On pmd.lrsn=murd.lrsn 
	And murd.ModifierStatus='A' 
	And murd.ModifierDescr LIKE '%URD%' 
	And murd.ExpirationYear > @Year
--modifier hoex
Left Join TSBv_MODIFIERS AS mhoex 
  On pmd.lrsn=mhoex.lrsn 
	And mhoex.ModifierStatus='A' 
	And mhoex.ModifierDescr LIKE '%Homeowner%' 
	And mhoex.ExpirationYear > @Year


Order By District, GEO, PIN;