-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

NEW CONSTRUCTION Residential New construction
New Construction is current year values of improvements with a year built from 2019 for the 2020 New Development (information pulled from ProVal)
NewDevInitialQuery_Research > Where GEO > 999

NON RESIDENTIAL Commercial new construction, additions and alterations 
Non Residential are additions and alterations to commercial properties that are tracked via a spreadsheet annually
NewDevInitialQuery_Research > Where GEO BETWEEN 1 AND 999

PREVYRSHOMES Removal of exemption from 63-602W9(3) (HB475)
PrevYrsHomes are homes that were on the 2019 Occupancy roll that do not have a 2019 Year built (former HB475 Homes)
NewDev_PreviousYearHomes > Where imp.year_built <> cv.OccYear

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
--Where eff_year LIKE '2023%'
--20230101
--20230804
Declare @EffYear0101CurrentLike varchar(8) = Cast(@Year as varchar) + '%'; -- Generates '20230101' for the previous year


WITH


CTE_Improvements AS (
Select Distinct
i.lrsn
,ROW_NUMBER() OVER (PARTITION BY i.lrsn, i.extension, i.improvement_id ORDER BY i.last_update DESC) AS RowNum
,i.last_update
,i.eff_year
,i.extension
,i.improvement_id
,i.imp_type
,i.imp_line_number
,i.dwelling_number
,i.year_built
,i.year_remodeled

From improvements AS i 
Where i.status = 'H'
And (i.improvement_id IN ('C') AND (i.year_built = @YearPrev OR i.year_remodeled = @YearPrev))
And i.eff_year LIKE @EffYear0101PreviousLike
--And i.eff_year LIKE '2023%'
--And i.lrsn = 30340
--And i.lrsn = 70420
),

CTE_ImpValDetail AS (
Select Distinct
vd.lrsn
,ROW_NUMBER() OVER (PARTITION BY vd.lrsn, vd.improvement_id ORDER BY vd.last_update_long DESC) AS RowNum
,vd.extension AS ImpValDetail_Extension
,vd.imp_type AS ImpValDetail_ImpType
,vd.improvement_id AS ImpValDetail_ImpId
,vd.line_number AS ImpValDetail_ImpLineNum

,i.year_built AS ImpValDetail_YearBuilt
,i.year_remodeled AS ImpValDetail_YearRemodel

,vd.group_code AS ImpValDetail_GroupCode
,vd.value AS ImpValDetail_Value
,vd.assess_val AS ImpValDetail_AssessedValue
,vd.value_type AS ImpValDetail_ValueType
,vd.inspection_date AS ImpValDetail_InspectionDate
,vd.eff_year AS ImpValDetail_EffYear


,CAST(CONVERT(char(8), vd.eff_year) AS DATE) AS PostedDate
,YEAR(CAST(CONVERT(char(8), vd.eff_year) AS DATE)) AS PostedYear
,MONTH(CAST(CONVERT(char(8), vd.eff_year) AS DATE)) AS PostedMonthNum
,DATENAME(MONTH,CAST(CONVERT(char(8), vd.eff_year) AS DATE)) AS PostedMonth

From val_detail AS vd

Join CTE_Improvements AS i 
  On vd.lrsn=i.lrsn 
    And vd.extension=i.extension 
    And vd.improvement_id = i.improvement_id
    And RowNum = 1

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
--All items posted last year 
--Year Built in improvement id d, m, 
--Year Built or Remodeled in improvement id c
-- No Group Code 81s
-- No Zero Values

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
CTE_Valuation AS (
Select Distinct
v.lrsn
,v.imp_assess AS TotalAssessed_Imp
,v.land_assess AS TotalAssessed_LandValue
,(v.imp_assess + v.land_assess) AS TotalAssessed_Value
,v.imp_val AS TotalMarket_Imp
,v.land_market_val AS TotalAssessed_LandMarketVal
,(v.imp_val + v.land_market_val) AS TotalAppraisedMarketValue
,v.land_use_val AS TotalAssessed_LandUseValueOnly
,v.eff_year AS AssessedEffYear
,CAST(CONVERT(char(8), v.eff_year) AS DATE) AS AssessedValueDate
,YEAR(CAST(CONVERT(char(8), v.eff_year) AS DATE)) AS AssessedValueYear
,MONTH(CAST(CONVERT(char(8), v.eff_year) AS DATE)) AS AssessedValueMonthNum
,DATENAME(MONTH,CAST(CONVERT(char(8), v.eff_year) AS DATE)) AS AssessedValueMonth
,v.valuation_comment AS PostedValuationComment
,v.update_user_id
,v.last_update
,ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNum

From valuation AS v
Where v.status = 'A'
And v.eff_year LIKE @EffYear0101PreviousLike
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
And tif.Descr LIKE '%URD%'

--AND ta.id = '242'

  
),

--This is only needed if we want to pull in HOEX values from the cadaster
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
)

Select Distinct
cvd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.Owner
,pmd.TAG
,CASE
  When tif.TIF IS NULL Then 'Non-TIF'
  When tif.TIF IS NOT NULL Then tif.TIF
  Else tif.TIF
 END AS TIF
,cvd.ImpValDetail_GroupCode
,cvd.ImpValDetail_AssessedValue
,cvd.ImpValDetail_Extension
,cvd.ImpValDetail_ImpType
,cvd.ImpValDetail_ImpId
,cv.TotalAssessed_Imp
--,cv.TotalAssessed_LandValue
,cv.TotalAssessed_Value
,cvd.ImpValDetail_YearBuilt
,cvd.ImpValDetail_YearRemodel
,cvd.PostedYear
,cvd.PostedDate
--New Construction Related Notes	
,cv.PostedValuationComment
,nc.NC
,b.BuildingNotes
,'SeeAlso:' AS AdditionalInformation
,pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.Property_Class_Description
,pmd.LegalDescription
,pmd.SitusAddress
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod

,cvd.PostedMonthNum
,cvd.PostedMonth

,cv.TotalAssessed_Imp
,cv.TotalAssessed_LandValue
,cv.TotalAssessed_Value
,cv.TotalMarket_Imp
,cv.TotalAssessed_LandMarketVal
,cv.TotalAppraisedMarketValue
,cv.TotalAssessed_LandUseValueOnly
,cv.update_user_id
,cv.AssessedValueDate
,cv.AssessedValueYear
,cv.AssessedValueMonthNum
,cv.AssessedValueMonth

,mhoex.ModifierDescr AS HOEX_Desc
,mhoex.ModifierPercent AS HOEX_Perc
,mhoex.OverrideAmount AS HOEX_OverrideAmount

,cad_hoex.CadRollDescr
,cad_hoex.ValueAmount AS HOEX_CadasterAmount
,cad_hoex.ValueTypeShortDescr AS HOEXCasaster

,murd.OverrideAmount AS URD_BaseValue
,(cv.TotalAssessed_Value - murd.OverrideAmount) AS URD_IncrValue
, CASE
    WHEN (cv.TotalAssessed_Value - murd.OverrideAmount) < 0 THEN 'URDISSUE'
    ELSE 'OK'
  END AS 'URDIncrCheck'




From CTE_ParcelMaster AS pmd

--Values Queries
Join CTE_ImpValDetail AS cvd
  On cvd.lrsn = pmd.lrsn
  And RowNum = 1

--All items posted last year 
--Year Built in improvement id d, m, 
--Year Built or Remodeled in improvement id c
-- No Group Code 81s
-- No Zero Values

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
Left Join CTE_Valuation AS cv
  On cv.lrsn = pmd.lrsn
  And cv.RowNum = 1
  
--NC Memos
Left Join CTE_Memo_NC AS nc
  On pmd.lrsn = nc.lrsn
Left Join CTE_Memo_Building AS b
  On pmd.lrsn = b.lrsn

--Check TIFs
Left Join CTE_TAG_TA_TIF_Key AS tif
  On pmd.TAG = tif.TAG

--Modifiers
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
--This is only needed if we want to pull in HOEX values from the cadaster
Left Join CTE_Cadasterviewer AS cad_hoex
  On cad_hoex.lrsn = pmd.lrsn

--Where 

--WHERE GEO BETWEEN 1 AND 999
--WHERE GEO > 999
Where cvd.ImpValDetail_ImpId IN ('C')
--Where cvd.ImpValDetail_ImpId IN ('D','M')
  --And cv.PostedValuationComment LIKE '06%'
  --And cvd.ImpValDetail_YearBuilt <> cvd.PostedYear
  --And cvd.ImpValDetail_YearBuilt = cvd.PostedYear
--And pmd.lrsn = 2
  And cv.TotalAppraisedMarketValue > 0

/*
,cv.PostedValuationComment
,cvd.ImpValDetail_GroupCode
,cvd.ImpValDetail_AssessedValue
,cvd.ImpValDetail_Extension
,cvd.ImpValDetail_ImpType
,cvd.ImpValDetail_ImpId
,cv.TotalAssessed_Imp
,cv.TotalAssessed_Value
,cvd.ImpValDetail_YearBuilt
,cvd.ImpValDetail_YearRemodel
,cvd.PostedYear
,cvd.PostedDate
*/

Order by 
District, GEO, PIN, 
ImpValDetail_GroupCode, 
ImpValDetail_YearBuilt, 
ImpValDetail_YearRemodel;