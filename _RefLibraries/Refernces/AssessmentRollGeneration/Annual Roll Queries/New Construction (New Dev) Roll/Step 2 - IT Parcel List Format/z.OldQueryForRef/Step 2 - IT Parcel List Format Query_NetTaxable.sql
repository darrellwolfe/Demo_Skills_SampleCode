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
,TRIM(pm.TAG) AS TAG
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
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
),

--For each of the CadRoll values in the CTEs below
--ONLY want the 01/01 values for each year, NOT the Occupancy values posted later in the year.
CTE_HOEX AS (
SELECT DISTINCT
i.RevObjId AS lrsn
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
,c.ValueAmount  AS Cadaster_Value
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,CAST(i.ValEffDate AS DATE) AS ValEffDate

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @ValueTypehoex -- Variable
/*
Declare @ValueTypehoex INT = 305;
--    305 HOEX_Exemption Homeowner Exemption
Declare @ValueTypeimp INT = 103;
--    103 Imp Assessed Improvement Assessed
Declare @ValueTypeland INT = 102;
--    102 Land Assessed Land Assessed
Declare @ValueTypetotal INT = 109;
--    109 Total Value Total Value
*/
WHERE r.AssessmentYear IN (@Year)
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
--And CAST(i.ValEffDate AS DATE) = @ValEffDatePrevious
),

CTE_Total AS (
SELECT DISTINCT
i.RevObjId AS lrsn
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
,c.ValueAmount  AS Cadaster_Value
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,CAST(i.ValEffDate AS DATE) AS ValEffDate

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @NetTaxableValueTotal -- Variable
/*
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
*/
WHERE r.AssessmentYear IN (@Year)
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
--And CAST(i.ValEffDate AS DATE) = @ValEffDatePrevious
),

CTE_IMP AS (
SELECT DISTINCT
i.RevObjId AS lrsn
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
,c.ValueAmount  AS Cadaster_Value
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,CAST(i.ValEffDate AS DATE) AS ValEffDate

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @NetTaxableValueImpOnly -- Variable
/*
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
*/
WHERE r.AssessmentYear IN (@Year)
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
--And CAST(i.ValEffDate AS DATE) = @ValEffDatePrevious
),

CTE_Land AS (
SELECT DISTINCT
ct.lrsn
, CASE
    WHEN ci.Cadaster_Value IS NULL THEN ct.Cadaster_Value
    ELSE ct.Cadaster_Value - ci.Cadaster_Value
  END AS Cadaster_Value

From CTE_Total AS ct
Left Join CTE_IMP AS ci
  On ct.lrsn = ci.lrsn

),


CTE_TotalLastYear AS (
SELECT DISTINCT
i.RevObjId AS lrsn
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
,c.ValueAmount  AS Cadaster_Value
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,CAST(i.ValEffDate AS DATE) AS ValEffDate
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @NetTaxableValueTotal -- Variable
/*
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
*/
WHERE r.AssessmentYear IN (@YearPrev)
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
--And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
And CAST(i.ValEffDate AS DATE) = @ValEffDatePrevious
),

CTE_ImpLastYear AS (
SELECT DISTINCT
i.RevObjId AS lrsn
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
,c.ValueAmount  AS Cadaster_Value
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,CAST(i.ValEffDate AS DATE) AS ValEffDate
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @NetTaxableValueImpOnly -- Variable
/*
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
*/
WHERE r.AssessmentYear IN (@YearPrev)
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
--And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
And CAST(i.ValEffDate AS DATE) = @ValEffDatePrevious
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
And i.eff_year LIKE @EffYear0101PreviousLike

And (i.improvement_id IN ('D','M') AND i.year_built = @YearPrev)
  OR (i.improvement_id LIKE 'A%' AND i.year_built = @YearPrev)
  OR (i.improvement_id IN ('D','M') AND i.year_built = @YearPrev-1)
  OR (i.improvement_id LIKE 'A%' AND i.year_built = @YearPrev-1)
  OR (i.improvement_id IN ('C') AND i.year_built = @YearPrev)
  OR (i.improvement_id IN ('C') AND i.year_remodeled = @YearPrev)
  OR (i.improvement_id IN ('C') AND i.year_built = @YearPrev-1)
  
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

,TRIM(vd.group_code) AS ImpValDetail_GroupCode
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
And vd.eff_year LIKE @EffYear0101Current
--And vd.eff_year LIKE @EffYear0101CurrentLike
--And vd.eff_year LIKE @EffYear0101PreviousLike
And vd.extension NOT LIKE 'L%'
--And vd.group_code <> '81'
--And vd.group_code NOT LIKE '%81%'
And vd.assess_val <> 0

And (i.improvement_id IN ('D','M') AND i.year_built = @YearPrev)
  OR (i.improvement_id LIKE 'A%' AND i.year_built = @YearPrev)
  OR (i.improvement_id IN ('D','M') AND i.year_built = @YearPrev-1)
  OR (i.improvement_id LIKE 'A%' AND i.year_built = @YearPrev-1)
  OR (i.improvement_id IN ('C') AND i.year_built = @YearPrev)
  OR (i.improvement_id IN ('C') AND i.year_remodeled = @YearPrev)
  OR (i.improvement_id IN ('C') AND i.year_built = @YearPrev-1)

),


CTE_FinalNewDev AS (
SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,tif.TIFId
,CASE
  When tif.TIF IS NULL Then 'Non-TIF'
  When tif.TIF IS NOT NULL Then tif.TIF
  Else tif.TIF
 END AS TIF
,murd.OverrideAmount AS URD_BaseValue
,pmd.TAG

,cl.Cadaster_Value AS TotalLand
,ci.Cadaster_Value AS TotalImp
,ch.Cadaster_Value AS TotalHOEX
,ct.Cadaster_Value AS TotalAssessed
,ct.ValEffDate AS ThisYearTotalValEffDate

,CASE
  WHEN cily.Cadaster_Value IS NULL THEN 0
  WHEN cily.Cadaster_Value = 0 THEN 0
  ELSE cily.Cadaster_Value
 END AS TotalImpLastYear
--,cily.Cadaster_Value AS TotalImpLastYear
,cily.ValEffDate AS ThisYearImpValEffDate
--,(ci.Cadaster_Value - cily.Cadaster_Value) AS ImpDiff_YearOverYear

,CASE
  WHEN cly.Cadaster_Value IS NULL THEN 0
  WHEN cly.Cadaster_Value = 0 THEN 0
  ELSE cly.Cadaster_Value
 END AS TotalAssessedLastYear
--,cly.Cadaster_Value AS TotalAssessedLastYear
,cly.ValEffDate AS LastYearTotalValEffDate
--,(ct.Cadaster_Value - cly.Cadaster_Value) AS TotalDiff_YearOverYear

,ivd.ImpValDetail_YearBuilt
,ivd.ImpValDetail_YearRemodel
,ivd.ImpValDetail_GroupCode
,ivd.ImpValDetail_ImpId
,ivd.ImpValDetail_ImpType
,ivd.ImpValDetail_Extension
--,ct.AssessmentType
,nc.NC

FROM CTE_ParcelMaster AS pmd
--NC Memos
Join CTE_Memo_NC AS nc
  On pmd.lrsn = nc.lrsn

Join CTE_Total AS ct
  On pmd.lrsn = ct.lrsn

Left Join CTE_Land AS cl
  On pmd.lrsn = cl.lrsn

Left Join CTE_IMP AS ci
  On pmd.lrsn = ci.lrsn

Left Join CTE_HOEX AS ch
  On pmd.lrsn = ch.lrsn

Left Join CTE_TotalLastYear AS cly
  On pmd.lrsn = cly.lrsn

Left Join CTE_ImpLastYear AS cily
  On pmd.lrsn = cily.lrsn

--Check TIFs
Left Join CTE_TAG_TA_TIF_Key AS tif
  On pmd.TAG = tif.TAG

--Modifiers
Left Join TSBv_MODIFIERS AS murd 
  On pmd.lrsn=murd.lrsn 
	And murd.ModifierStatus='A' 
	And murd.ModifierDescr LIKE '%URD%' 
	And murd.ExpirationYear > @Year

Left Join CTE_ImpValDetail AS ivd
  On pmd.lrsn = ivd.lrsn
  And ivd.RowNum = 1
  /*
  vd.lrsn
  ,ROW_NUMBER() OVER (PARTITION BY vd.lrsn, vd.improvement_id ORDER BY vd.last_update_long DESC) AS RowNum
  ,vd.extension AS ImpValDetail_Extension
  ,vd.imp_type AS ImpValDetail_ImpType
  ,vd.improvement_id AS ImpValDetail_ImpId
  ,vd.line_number AS ImpValDetail_ImpLineNum
  */

Where nc.NC NOT LIKE '%EXCLUDE%'
And ivd.ImpValDetail_GroupCode <> '81'
And ivd.ImpValDetail_GroupCode NOT LIKE '%81%'
)


Select Distinct
fnd.*
,(fnd.TotalImp - fnd.TotalImpLastYear) AS DiffImp_YearOverYear
,(fnd.TotalAssessed - fnd.TotalAssessedLastYear) AS DiffTotal_YearOverYear

From CTE_FinalNewDev AS fnd


Order By District, GEO, PIN;
