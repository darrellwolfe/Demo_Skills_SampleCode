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
/*
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
And i.eff_year LIKE @EffYear0101CurrentLike

,i.year_built AS ImpValDetail_YearBuilt
,i.year_remodeled AS ImpValDetail_YearRemodel



),
*/
CTE_ImpValDetail AS (
Select Distinct
vd.lrsn
,ROW_NUMBER() OVER (PARTITION BY vd.lrsn, vd.improvement_id ORDER BY vd.last_update_long DESC) AS RowNum
,vd.extension AS ImpValDetail_Extension
,vd.imp_type AS ImpValDetail_ImpType
,vd.improvement_id AS ImpValDetail_ImpId
,vd.line_number AS ImpValDetail_ImpLineNum

,vd.group_code AS ImpValDetail_GroupCode
,vd.value AS ImpValDetail_Value
,vd.assess_val AS ImpValDetail_AssessedValue
,vd.value_type AS ImpValDetail_ValueType
,vd.inspection_date AS ImpValDetail_InspectionDate
,vd.eff_year AS ImpValDetail_EffYear

,CAST(CONVERT(char(8), vd.eff_year) AS DATE) AS PostedDate

From val_detail AS vd
/*
Join CTE_Improvements AS i 
  On vd.lrsn=i.lrsn 
    And vd.extension=i.extension 
    And vd.improvement_id = i.improvement_id
    And RowNum = 1
*/
Where vd.status = 'A'
--And vd.eff_year LIKE @EffYear0101CurrentLike
And vd.eff_year LIKE @EffYear0101CurrentLike
And vd.group_code IN ('98','99')

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
)


Select Distinct
pmd.District
,pmd.GEO
,cvd.lrsn
,pmd.AIN
,pmd.PIN
,pmd.Owner
,cvd.ImpValDetail_GroupCode
,cvd.ImpValDetail_AssessedValue
,cvd.ImpValDetail_Extension
,cvd.ImpValDetail_ImpType
,cvd.ImpValDetail_ImpId

From CTE_ImpValDetail AS cvd
Join CTE_ParcelMaster AS pmd
  On pmd.lrsn = cvd.lrsn
  
  
Order By District, GEO, PIN;
  
  
  