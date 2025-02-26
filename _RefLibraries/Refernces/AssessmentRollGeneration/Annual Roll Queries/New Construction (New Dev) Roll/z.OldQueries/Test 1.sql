-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/
/*
SELECT *
From valuation AS v
Where v.status = 'A'
And v.eff_year LIKE '2023%'
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

Declare @EffYear0101CurrentLike varchar(8) = Cast(@Year as varchar) + '%'; -- Generates '20230101' for the previous year


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

CTE_Valuation AS (
SELECT
v.lrsn
,v.last_update
,v.imp_assess
,v.land_assess
,v.land_market_val
,(v.imp_assess + v.land_market_val) AS TotalAppraisedMarket
,(v.imp_assess + v.land_market_val) AS TotalAssessed
,v.land_use_val
,v.eff_year
,CAST(CONVERT(char(8), v.eff_year) AS DATE) AS OccupancyDate
,YEAR(CAST(CONVERT(char(8), v.eff_year) AS DATE)) AS OccYear
,MONTH(CAST(CONVERT(char(8), v.eff_year) AS DATE)) AS OccMonthNum
,DATENAME(MONTH,CAST(CONVERT(char(8), v.eff_year) AS DATE)) AS OccMonth
,v.valuation_comment
,v.update_user_id

From valuation AS v




Where v.status = 'A'
And v.eff_year LIKE @EffYear0101PreviousLike
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
--And vd.eff_year LIKE @EffYear0101CurrentLike
And vd.eff_year LIKE @EffYear0101PreviousLike

And vd.extension NOT LIKE 'L%'
And vd.group_code <> '81'
And vd.assess_val <> 0



--And (vd.assess_val <> 0 OR vd.assess_val IS NOT NULL)
--And (vd.improvement_id IN ('C','M','D','A01')
  --  OR vd.improvement_id LIKE 'A%')

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





Select Distinct
pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.Owner
,pmd.TAG
,CASE
  When tif.TIF IS NULL Then 'Non-TIF'
  When tif.TIF IS NOT NULL Then tif.TIF
  Else tif.TIF
 END AS TIF

,imp.group_code
,imp.assess_val

,imp.year_built AS YearBuilt
,cv.OccYear AS PostedOccYear

,'SeeAlso:' AS AdditionalInformation
,pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.Property_Class_Description
,pmd.LegalDescription
,pmd.SitusAddress

,cv.last_update
,cv.imp_assess
,cv.land_assess
,cv.land_market_val
,cv.TotalAppraisedMarket
,cv.TotalAssessed
,cv.land_use_val
,cv.eff_year
,cv.OccupancyDate
,cv.OccYear
,cv.OccMonthNum
,cv.OccMonth
,cv.valuation_comment
,cv.update_user_id

,imp.extension
,imp.imp_type
,imp.improvement_id
,imp.year_built
,imp.year_remodeled
--,imp.group_code
--,imp.assess_val
,imp.inspection_date
,imp.OccupancyDate
,imp.OccYear
,imp.OccMonth
,imp.OccMonthNum

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
,CASE
WHEN  imp.year_built <> cv.OccYear THEN 'Check'
ELSE 'OK'
END AS 'Check'
,imp.year_built
,cv.OccYear
*/

--valuation_comment
From CTE_Valuation AS cv
Join CTE_ParcelMaster AS pmd
  On cv.lrsn = pmd.lrsn

Join CTE_ImpValDetail AS imp
  On pmd.lrsn = imp.lrsn
--  And imp.year_built <> imp.OccYear
  
--Check TIFs
Left Join CTE_TAG_TA_TIF_Key AS tif
  On pmd.TAG = tif.TAG

Left Join CTE_Cadasterviewer AS cad_hoex
  On cad_hoex.lrsn = pmd.lrsn
  
--NC Memos
Left Join CTE_Memo_NC AS nc
  On pmd.lrsn = nc.lrsn
Left Join CTE_Memo_Building AS b
  On pmd.lrsn = b.lrsn

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










Where valuation_comment LIKE '06%'
--And v.lrsn = 2
And imp.year_built <> cv.OccYear
/*
PREVYRSHOMES Removal of exemption from 63-602W9(3) (HB475)
PrevYrsHomes are homes (Ex: that were on the 2019 Occupancy roll that do not have a 2019 Year built (former HB475 Homes)
NewDev_PreviousYearHomes > Where imp.year_built <> cv.OccYear

,CASE
WHEN  imp.year_built <> cv.OccYear THEN 'Check'
ELSE 'OK'
END AS 'Check'
,imp.year_built
,cv.OccYear
*/

--valuation_comment
--01- Reval/Market Adj.
--06- Occupancy
--10- Cancellation
--38- Subsequent Assessment
--43- Assessment Roll


--Order by lrsn






/*
Worksheet/Certified 2024
lrsn = 2
In ProVal:
ProVal Cert 2024 Land Market 438,458 = 2024 v.land_market_val 438,458

ProVal Cert 2024 Land Assessed 271,495 = 2024 v.land_assess 271,495

ProVal Cert 2024 Land Use 1,495 = 2024 v.land_use_val 1,495

(allocations)
Homesite 10H $270,000  + 07 Bare Forest $1,495
  = $271,495

ProVal uses Either Or with land. 
  Either the 91 Remaining Acres OR the 61 Timberland
  Dependin on "use", but both land lines have to have the timber allocation
    either 06 or 07 to make that function work

--,(v.land_assess - v.land_use_val) AS AssesedLand
Assessed minus use equals the missing allocation Homesite

ProVal Cert 2024 Imp Market 347,150 = 2024 v.imp_assess 347,510
6:45 pm
8.15 pm

*/