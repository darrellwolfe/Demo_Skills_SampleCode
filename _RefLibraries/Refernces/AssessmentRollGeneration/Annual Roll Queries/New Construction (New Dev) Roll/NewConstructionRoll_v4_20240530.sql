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

I ran this one script in Power Query,
then used it as a reference "ref" to build the individual buckets

-- To Find Cadaster Types
Select Distinct
vt.id
,vt.ShortDescr
,vt.Descr
From ValueType AS vt
--Where vt.Descr LIKE '%by%'
Order By vt.Descr

*/

Declare @Year int = 2024; -- Input THIS year here

Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here

--NOTE: For HOEX from Cadaster, it will only pull fro a locked roll
  --If the current year roll is locked, and you use @Year no values will populate
  --If the @YearPrev is used, you will pull last year's cadasters not this years

Declare @NCYear varchar(4) = 'NC' + Right(Cast(@Year as varchar), 2); -- This will create 'NC24'

Declare @NCYearPrevious varchar(4) = 'NC' + Right(Cast(@YearPrev as varchar), 2); -- This will create 'NC23'


--EXACT
Declare @EffYear0101Current varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101PreviousPrevious varchar(8) = Cast(@YearPrevPrev as varchar) + '0101'; -- Generates '20230101' for the previous year

-- Declaring and setting the current year effective date
--ONLY want the 01/01 values for each year, NOT the Occupancy values posted later in the year.
Declare @ValEffDateCurrent date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
-- Declaring and setting the previous year effective date
--ONLY want the 01/01 values for each year, NOT the Occupancy values posted later in the year.
Declare @ValEffDatePrevious date = CAST(CAST(@YearPrev as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'

--LIKE
Declare @EffYear0101PreviousLike varchar(8) = Cast(@YearPrev as varchar) + '%'; -- Generates '20230101' for the previous year
--Where eff_year LIKE '2023%'
--20230101
--20230804
Declare @EffYear0101PreviousPreviousLike varchar(8) = Cast(@YearPrevPrev as varchar) + '%'; -- Generates '20230101' for the previous year

Declare @EffYear0101CurrentLike varchar(8) = Cast(@Year as varchar) + '%'; -- Generates '20230101' for the previous year

Declare @ValueTypehoex INT = 305;
--    305 HOEX_Exemption Homeowner Exemption
Declare @ValueTypeimp INT = 103;
--    103 Imp Assessed Improvement Assessed
Declare @ValueTypeland INT = 102;
--    102 Land Assessed Land Assessed
Declare @ValueTypetotal INT = 109;
--    109 Total Value Total Value
Declare @NetTaxableValueImpOnly INT = 458;
--    458 Net Imp Only Net Taxable Value Imp Only
Declare @NetTaxableValueTotal INT = 455;
--    455 Net Tax Value Net Taxable Value

Declare @NewConstruction INT = 651;
--    651 NewConstByCat New Construction
Declare @AssessedByCat INT = 470;
--470 AssessedByCat Assessed Value

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
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.TAG) AS TAG
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),

CTE_ImpValDetail AS (
Select Distinct
vd.lrsn
,TRIM(vd.extension) AS extension --
,TRIM(e.ext_description) AS ext_description
,TRIM(vd.imp_type) AS imp_type
,TRIM(vd.improvement_id) AS improvement_id -- 
--,vd.line_number
,vd.group_code
,vd.value
,vd.assess_val
,vd.value_type
,i.year_built
,i.year_remodeled
,i.eff_year_built
,i.true_tax_value1
,CASE
  WHEN i.sound_value_code = '-1'THEN 'Pricing_Error'
  WHEN i.sound_value_code = '1' THEN 'Base_Rate'
  WHEN i.sound_value_code = '2' THEN 'Adjusted_Rate'
  WHEN i.sound_value_code = '3' THEN 'Replacement_Cost'
  WHEN i.sound_value_code = '4' THEN 'True_Tax_Value'
  WHEN i.sound_value_code = '5' THEN 'No_Value'
  WHEN i.sound_value_code = '6' THEN 'Override_Rate'
  ELSE NULL
END AS Sound_Value_Code_Key
,i.sound_value_code -- 3 means "None"
,i.sound_value_reason
,i.pct_complete
,TRIM(e.UserId) AS UserId
,e.date_priced
,vd.inspection_date
,vd.eff_year
,CAST(CONVERT(char(8), vd.eff_year) AS DATE) AS OccupancyDate
,YEAR(CAST(CONVERT(char(8), vd.eff_year) AS DATE)) AS OccYear
,MONTH(CAST(CONVERT(char(8), vd.eff_year) AS DATE)) AS OccMonthNum
,DATENAME(MONTH,CAST(CONVERT(char(8), vd.eff_year) AS DATE)) AS OccMonth

From val_detail AS vd

Join extensions AS e 
  On vd.lrsn=e.lrsn --JOIN extensions between parcel and improvements to filter out voided records
    And e.extension=vd.extension 
    And e.eff_year = @EffYear0101Current
    --LIKE @EffYear0101PreviousLike

Join improvements AS i 
  On e.lrsn=i.lrsn 
    And e.extension=i.extension 
    And vd.extension=i.extension 
    And vd.improvement_id = i.improvement_id
    And i.eff_year = @EffYear0101Current
    --LIKE @EffYear0101PreviousLike

Where vd.status = 'A'
And vd.eff_year = @EffYear0101Current
--LIKE @EffYear0101PreviousLike
And vd.extension NOT LIKE 'L%'
And vd.group_code <> '81'
And vd.assess_val <> 0
)


Select Distinct
pmd.District
,pmd.GEO
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.Owner
,ivd.extension
,ivd.ext_description
,ivd.imp_type
,ivd.improvement_id
,ivd.group_code
,ivd.value
,ivd.value_type
,ivd.year_built
,ivd.year_remodeled
,ivd.eff_year_built
,ivd.true_tax_value1
,ivd.Sound_Value_Code_Key
,ivd.sound_value_code
,ivd.sound_value_reason
,ivd.pct_complete
,ivd.UserId
,ivd.date_priced
,ivd.inspection_date
,ivd.eff_year
,ivd.OccupancyDate
,ivd.OccYear
,ivd.OccMonthNum
,ivd.OccMonth



From CTE_ParcelMaster AS pmd

Join CTE_ImpValDetail AS ivd
  On ivd.lrsn = pmd.lrsn


Where 
  (ivd.extension LIKE 'R%' AND ivd.year_built = '2023')
  OR 
  (ivd.extension LIKE 'C%' AND (ivd.year_built = '2023' OR ivd.year_remodeled = '2023'))









