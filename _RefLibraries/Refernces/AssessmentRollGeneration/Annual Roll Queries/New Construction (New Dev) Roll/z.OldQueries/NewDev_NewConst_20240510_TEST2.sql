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

--NOTE: For HOEX from Cadaster, it will only pull fro a locked roll
  --If the current year roll is locked, and you use @Year no values will populate
  --If the @YearPrev is used, you will pull last year's cadasters not this years

Declare @NCYear varchar(4) = 'NC' + Right(Cast(@Year as varchar), 2); -- This will create 'NC24'

Declare @NCYearPrevious varchar(4) = 'NC' + Right(Cast(@YearPrev as varchar), 2); -- This will create 'NC23'

Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year

Declare @EffYear0101PreviousLike varchar(8) = Cast(@YearPrev as varchar) + '%'; -- Generates '20230101' for the previous year


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
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod
From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),

CTE_ImpValDetail AS (

Select Distinct
vd.lrsn
,vd.extension
,vd.imp_type
,vd.improvement_id
,vd.line_number
,i.year_built
,i.year_remodeled
,vd.group_code
,vd.value
,vd.assess_val
,vd.value_type
,vd.inspection_date
,vd.eff_year
,CAST(CONVERT(char(8), vd.eff_year) AS DATE) AS OccupancyDate
,YEAR(CAST(CONVERT(char(8), vd.eff_year) AS DATE)) AS OccYear
,MONTH(CAST(CONVERT(char(8), vd.eff_year) AS DATE)) AS OccMonthNum
,DATENAME(MONTH,CAST(CONVERT(char(8), vd.eff_year) AS DATE)) AS OccMonth

/*
,CASE
  WHEN vd.value = vd.assess_val THEN 'OK'
  ELSE 'Check'
 END AS 'CheckValues'
,vd.val_det_int1
,vd.val_det_int2
,vd.val_seq_no
*/
From val_detail AS vd

Left Join extensions AS e 
  On vd.lrsn=e.lrsn --JOIN extensions between parcel and improvements to filter out voided records
    And e.extension=vd.extension 
    And e.status='A' 

Left Join improvements AS i 
  On e.lrsn=i.lrsn 
    And e.extension=i.extension 
    And vd.extension=i.extension 
    And vd.improvement_id = i.improvement_id
    And i.status='A' 
    
    
Where vd.status = 'A'
And vd.eff_year LIKE @EffYear0101PreviousLike
And vd.extension NOT LIKE 'L%'
And vd.group_code <> '81'
And vd.assess_val <> 0

And (
  (i.improvement_id IN ('D','M') AND i.year_built = @YearPrev)
  Or (i.improvement_id IN ('C') AND (i.year_built = @YearPrev OR i.year_remodeled = @YearPrev))
    )
--JOIN not LeftJoin, because i only want properties with these IMPs
--Improvements with YEAR BUILT
--YearFilters appklied in CTE
  --In this example:
  --eff_year is last year
  --year_built is last year (in 2024, I want year built's 2023)
  --In the Occupancy Roll, I want 2024
  --In the New Dev Roll I want last year's Occupancies, essentially
  --But for commercial, we add year remodeled which isn't an "occupancy" per se
  --So in June 2024, I want the NC23 2023 Occupancies, give or take
  --And v.eff_year = @EffYear0101Previous
    /*
    And (
      (i.improvement_id IN ('D','M') AND i.year_built = @YearPrev)
  	  Or (i.improvement_id IN ('C') AND (i.year_built = @YearPrev OR i.year_remodeled = @YearPrev))
  	    )
    */

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

CTE_Cadasterviewer AS (
--------------------------------
--CadViewer AND cv.ValueTypeShortDescr = 'AssessedByCat'
--------------------------------
Select Distinct
cv.AssessmentYear
--,CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate]
,cv.CadRollDescr
,cv.RevObjId AS lrsn
--,cv.PIN
--,cv.AIN
--,cv.TAGShortDescr
,cv.ValueAmount
--,cv.AddlAttribute
--,TRIM(LEFT (cv.AddlAttribute,3)) AS [Whatever]
--,cv.SecondaryAttribute
,cv.ValueTypeShortDescr
,cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId

--WHERE cv.AssessmentYear IN (@Year, @YearPrev)
--WHERE cv.AssessmentYear IN (@YearPrev)
WHERE cv.AssessmentYear IN (@Year)

--AND cv.ValueTypeShortDescr = 'AssessedByCat'
AND cv.ValueTypeShortDescr = 'HOEX_Exemption'
/*
ValueTypeShortDescr ValueTypeDescr
HOEX_Percent Homeowner Percent
HOEX_Cap Homeowner Cap
HOEX_CapOverride Homeowner Calculated Cap Override
HOEX_CapManual Homeowner Manual Cap Override
HOEX_EligibleVal Homeowner Eligible Value
HOEX_Exemption Homeowner Exemption
HOEX_ByCat Homeowner Exemption
HOEX_ImpOnly Homeowner Exemption Imp Only
*/
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
  --And memo_line_number = '1'
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
--,'Tag-Tif' AS TagTifCheck
,pmd.TAG
,CASE
  When tif.TIF IS NULL Then 'Non-TIF'
  When tif.TIF IS NOT NULL Then tif.TIF
  Else tif.TIF
 END AS TIF
--Values and Imps
,imp.extension
,imp.imp_type
,imp.improvement_id
,imp.year_built
,imp.year_remodeled
,imp.group_code
,imp.assess_val
,imp.inspection_date
,imp.OccupancyDate
,imp.OccYear
,imp.OccMonth
,imp.OccMonthNum
--TaxableValue --- Huh?
--BaseValue --- Huh?

,mhoex.ModifierDescr AS HOEX_Desc
,mhoex.ModifierPercent AS HOEX_Perc
,mhoex.OverrideAmount AS HOEX_OverrideAmount

,cad_hoex.CadRollDescr
,cad_hoex.ValueAmount AS HOEX_CadasterAmount
,cad_hoex.ValueTypeShortDescr AS HOEXCasaster


,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod

,murd.OverrideAmount AS URD_BaseValue
,(pmd.WorkValue_Total - murd.OverrideAmount) AS URD_IncrValue
, CASE
    WHEN (pmd.WorkValue_Total - murd.OverrideAmount) < 0 THEN 'URDISSUE'
    ELSE 'OK'
  END AS 'URDIncrCheck'

--,murd.ModifierDescr AS URD_Desc
--,murd.ModifierPercent AS URD_Perc
--,murd.OverrideAmount AS URD_Amount

--New Construction Related Notes	
,nc.NC
,b.BuildingNotes


/*


,murd.OverrideAmount AS URD_BaseValue
,(imp.imp_assess - murd.OverrideAmount) AS URD_IncrValue
--,murd.ModifierDescr AS URD_Desc
--,murd.ModifierPercent AS URD_Perc
--,murd.OverrideAmount AS URD_Amount
*/
/*
--Existence of 81s
,c81.extension AS Ex_81
,c81.improvement_id AS Imp_81
,c81.group_code AS GC_81
--Home Owner's Information


*/



FROM CTE_ParcelMaster AS pmd
--  ON xxxx.lrsn = pmd.lrsn
--JOIN not LeftJoin, because i only want properties with these IMPs
Join CTE_ImpValDetail AS imp
  On pmd.lrsn = imp.lrsn

--NC Memos
Left Join CTE_Memo_NC AS nc
  On pmd.lrsn = nc.lrsn
Left Join CTE_Memo_Building AS b
  On pmd.lrsn = b.lrsn

--Check TIFs
Left Join CTE_TAG_TA_TIF_Key AS tif
  On pmd.TAG = tif.TAG

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

Left Join CTE_Cadasterviewer AS cad_hoex
  On cad_hoex.lrsn = pmd.lrsn

--Where nc.NC IS NOT NULL
--Where b.BuildingNotes IS NOT NULL

WHERE GEO > 1000
  
Order by District, GEO, PIN, extension, group_code