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

Declare @NCYearPrevious varchar(4) = 'NC' + Right(Cast(@YearPrev as varchar(4)), 2); -- This will create 'NC23'

Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year

Declare @EffYear0101PreviousLike varchar(8) = Cast(@YearPrev as varchar) + '%'; -- Generates '20230101' for the previous year
--Where eff_year LIKE '2023%'
--20230101
--20230804
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



CTE_Memo_602W AS (
Select
lrsn
--,memo_id
,STRING_AGG(memo_text, ' | ') AS DevExemption
--JOIN Memos, change to current year NC22, NC23
From memos 
--  ON parcel.lrsn=mNC.lrsn 
--Where memo_id IN ('602W','B519')
Where memo_id IN ('LAND')
And memo_text LIKE '%HB519%'
And memo_text LIKE '%2024%'
  --And memo_line_number = '1'
  And status = 'A'
Group By lrsn
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

CTE_CheckForMissingNC AS (
Select 
pmd.District
,pmd.GEO
,pmd.lrsn
,pmd.AIN
,pmd.PIN
,devex.DevExemption
,nc.NC
From CTE_ParcelMaster AS pmd

Join CTE_Memo_602W AS devex
  On devex.lrsn = pmd.lrsn

Left Join CTE_Memo_NC AS nc
  On nc.lrsn = pmd.lrsn
)

Select Distinct mnc.*
From CTE_CheckForMissingNC AS mnc
Where mnc.nc IS NULL






















