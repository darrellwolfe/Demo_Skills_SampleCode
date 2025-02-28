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
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description

,CASE 
  WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
  WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416', '421', '435', '438', '442', '451', '527','461') THEN 'Commercial_Industrial'
  WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '546', '548', '549', '550', '555', '565','526','561') THEN 'Residential'
  WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
  WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'
  WHEN pm.ClassCD = '667' THEN 'Operating_Property'
  WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
  WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'
  ELSE 'Unasigned_or_OldInactiveParcel'
END AS Property_Class_Type
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
,c.ValueAmount  AS Cadaster_Value

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

CTE_IMP AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,SUM(c.ValueAmount) AS Cadaster_Value
/*
,c.ValueAmount  AS Cadaster_Value
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,i.ValEffDate
,c.TypeCode
,c.Group_Code
,c.FullGroupCode
,ROW_NUMBER() OVER (PARTITION BY i.RevObjId ORDER BY i.ValEffDate DESC) AS RowNum
*/

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @AssessedByCat -- Variable
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
--And i.RevObjId = 557941
--And i.RevObjId = 84329
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
--And CAST(i.ValEffDate AS DATE) = @ValEffDatePrevious
--IMP Group Codes
And c.FullGroupCode IN (
    '25', '26', '26H', '27', '30', '31H', '32', '33', '34H', '35', '36', '37H', '38', '39', '41H', '42', '43', '45', 
    '46H', '47H', '48H', '49H', '50H', '51', '51P', '55H', '56P', '56Q', '56Q2', '56Q3', '57P', '58P', '58Q', '58Q2', 
    '58Q3', '58Q4', '59P', '59Q', '59Q2', '59Q3', '59Q4', '63P', '63Q', '63Q2', '63Q3', '63Q4', '65H', '66P', '67', 
    '67L', '67P', '68P', '68Q', '68Q2', '68Q3', '68Q4', '69P', '69Q', '69Q2', '69Q3', '69Q4', '70P', '71P', '71Q', 
    '71Q2', '71Q3', '71Q4', '72P', '72Q', '72Q2', '72Q3', '72Q4', '75P') 
    --, '81', '81L', '81P'
And c.FullGroupCode NOT LIKE '81%'
Group By i.RevObjId
),

CTE_Land AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,SUM(c.ValueAmount) AS Cadaster_Value
/*
,c.ValueAmount  AS Cadaster_Value
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,i.ValEffDate
,c.TypeCode
,c.Group_Code
,c.FullGroupCode
,ROW_NUMBER() OVER (PARTITION BY i.RevObjId ORDER BY i.ValEffDate DESC) AS RowNum
*/

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @AssessedByCat -- Variable
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
--And i.RevObjId = 557941
--And i.RevObjId = 84329
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
--And CAST(i.ValEffDate AS DATE) = @ValEffDatePrevious
--IMP Group Codes
--LAND Group Codes
And c.FullGroupCode IN (
    '01', '03', '04', '05', '06', '07', '09', '10', '10H', '11', '12', '12H', '13', '14', '15', '15H', '16', '17', 
    '18', '19', '20', '20H', '21', '22', '25L', '26LH', '27L')
    --, '81L'
And c.FullGroupCode NOT LIKE '81%'
Group By i.RevObjId
),

CTE_Total AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,SUM(c.ValueAmount) AS Cadaster_Value
/*
,c.ValueAmount  AS Cadaster_Value
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,i.ValEffDate
,c.TypeCode
,c.Group_Code
,c.FullGroupCode
,ROW_NUMBER() OVER (PARTITION BY i.RevObjId ORDER BY i.ValEffDate DESC) AS RowNum
*/

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @AssessedByCat -- Variable
  
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
And c.FullGroupCode NOT LIKE '81%'
Group By i.RevObjId

),

CTE_TotalNetTax AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,SUM(c.ValueAmount) AS Cadaster_Value
/*
,c.ValueAmount  AS Cadaster_Value
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,i.ValEffDate
,c.TypeCode
,c.Group_Code
,c.FullGroupCode
,ROW_NUMBER() OVER (PARTITION BY i.RevObjId ORDER BY i.ValEffDate DESC) AS RowNum
*/

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @NetTaxableValueTotal -- Variable

/*
Declare @NetTaxableValueTotal INT = 455;
--    455 Net Tax Value Net Taxable Value
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
--And c.FullGroupCode NOT LIKE '81%'
Group By i.RevObjId

),

CTE_TotalLastYear AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,SUM(c.ValueAmount) AS Cadaster_Value
/*
,c.ValueAmount  AS Cadaster_Value
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,i.ValEffDate
,c.TypeCode
,c.Group_Code
,c.FullGroupCode
,ROW_NUMBER() OVER (PARTITION BY i.RevObjId ORDER BY i.ValEffDate DESC) AS RowNum
*/
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @AssessedByCat -- Variable
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
WHERE r.AssessmentYear IN (@YearPrev)
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
--And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
And CAST(i.ValEffDate AS DATE) = @ValEffDatePrevious
And c.FullGroupCode NOT LIKE '81%'
Group By i.RevObjId
),

CTE_ImpLastYear AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,SUM(c.ValueAmount) AS Cadaster_Value
/*
,c.ValueAmount  AS Cadaster_Value
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,i.ValEffDate
,c.TypeCode
,c.Group_Code
,c.FullGroupCode
,ROW_NUMBER() OVER (PARTITION BY i.RevObjId ORDER BY i.ValEffDate DESC) AS RowNum
*/

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @AssessedByCat -- Variable
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
WHERE r.AssessmentYear IN (@YearPrev)
--And i.RevObjId = 557941
--And i.RevObjId = 84329
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
--And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
And CAST(i.ValEffDate AS DATE) = @ValEffDatePrevious

--IMP Group Codes
And c.FullGroupCode IN (
    '25', '26', '26H', '27', '30', '31H', '32', '33', '34H', '35', '36', '37H', '38', '39', '41H', '42', '43', '45', 
    '46H', '47H', '48H', '49H', '50H', '51', '51P', '55H', '56P', '56Q', '56Q2', '56Q3', '57P', '58P', '58Q', '58Q2', 
    '58Q3', '58Q4', '59P', '59Q', '59Q2', '59Q3', '59Q4', '63P', '63Q', '63Q2', '63Q3', '63Q4', '65H', '66P', '67', 
    '67L', '67P', '68P', '68Q', '68Q2', '68Q3', '68Q4', '69P', '69Q', '69Q2', '69Q3', '69Q4', '70P', '71P', '71Q', 
    '71Q2', '71Q3', '71Q4', '72P', '72Q', '72Q2', '72Q3', '72Q4', '75P') 
    --, '81', '81L', '81P'
And c.FullGroupCode NOT LIKE '81%'
Group By i.RevObjId
),

CTE_LandLastYear AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,SUM(c.ValueAmount) AS Cadaster_Value
/*
,c.ValueAmount  AS Cadaster_Value
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,i.ValEffDate
,c.TypeCode
,c.Group_Code
,c.FullGroupCode
,ROW_NUMBER() OVER (PARTITION BY i.RevObjId ORDER BY i.ValEffDate DESC) AS RowNum
*/

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @AssessedByCat -- Variable
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
WHERE r.AssessmentYear IN (@YearPrev)
--And i.RevObjId = 557941
--And i.RevObjId = 84329
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
--And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
And CAST(i.ValEffDate AS DATE) = @ValEffDatePrevious
--IMP Group Codes
--LAND Group Codes
And c.FullGroupCode IN (
    '01', '03', '04', '05', '06', '07', '09', '10', '10H', '11', '12', '12H', '13', '14', '15', '15H', '16', '17', 
    '18', '19', '20', '20H', '21', '22', '25L', '26LH', '27L')
    --, '81L'
And c.FullGroupCode NOT LIKE '81%'
Group By i.RevObjId
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

CTE_FinalNewDev AS (
SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.Property_Class_Type
,tif.TIFId
,CASE
  When tif.TIF IS NULL Then 'Non-TIF'
  When tif.TIF IS NOT NULL Then tif.TIF
  Else tif.TIF
 END AS TIF
,murd.OverrideAmount AS URD_BaseValue
,pmd.TAG

,cl.Cadaster_Value AS TotalLand
--,cl.FullGroupCode AS LandGroupCodeThisYear
,ci.Cadaster_Value AS TotalImp
--,ci.FullGroupCode AS ImpGroupCodeThisYear
,CASE
  WHEN ch.Cadaster_Value IS NULL THEN 0
  WHEN ch.Cadaster_Value = 0 THEN 0
  ELSE ch.Cadaster_Value
 END AS TotalHOEX
--,ch.Cadaster_Value AS TotalHOEX
--,(ct.Cadaster_Value - ch.Cadaster_Value) AS NetAssessedAfterHOEX

,ct.Cadaster_Value AS TotalAssessed

,CASE
  WHEN cnt.Cadaster_Value IS NULL THEN 0
  WHEN cnt.Cadaster_Value = 0 THEN 0
  ELSE cnt.Cadaster_Value
 END AS TotalNetTaxable
--,cnt.Cadaster_Value AS TotalNetTaxable


--,cl.FullGroupCode AS TotalAssessedGroupCodeThisYear
--,ct.ValEffDate AS ThisYearTotalValEffDate

,CASE
  WHEN clly.Cadaster_Value IS NULL THEN 0
  WHEN clly.Cadaster_Value = 0 THEN 0
  ELSE clly.Cadaster_Value
 END AS TotalLandLastYear

,CASE
  WHEN cily.Cadaster_Value IS NULL THEN 0
  WHEN cily.Cadaster_Value = 0 THEN 0
  ELSE cily.Cadaster_Value
 END AS TotalImpLastYear
--,cily.FullGroupCode AS ImpGroupCodeLastYear
--,cily.Cadaster_Value AS TotalImpLastYear
--,cily.ValEffDate AS ThisYearImpValEffDate
--,(ci.Cadaster_Value - cily.Cadaster_Value) AS ImpDiff_YearOverYear

,CASE
  WHEN cly.Cadaster_Value IS NULL THEN 0
  WHEN cly.Cadaster_Value = 0 THEN 0
  ELSE cly.Cadaster_Value
 END AS TotalAssessedLastYear
--,cly.Cadaster_Value AS TotalAssessedLastYear
--,cly.ValEffDate AS LastYearTotalValEffDate
--,(ct.Cadaster_Value - cly.Cadaster_Value) AS TotalDiff_YearOverYear

/*
,ivd.ImpValDetail_YearBuilt
,ivd.ImpValDetail_YearRemodel
,ivd.ImpValDetail_GroupCode
,ivd.ImpValDetail_ImpId
,ivd.ImpValDetail_ImpType
,ivd.ImpValDetail_Extension
*/
--,ct.AssessmentType
,nc.NC
--,DevExemption.DevExemption

FROM CTE_ParcelMaster AS pmd
Left Join CTE_Total AS ct
  On pmd.lrsn = ct.lrsn

Left Join CTE_TotalNetTax AS cnt
  On pmd.lrsn = cnt.lrsn


Left Join CTE_Land AS cl
  On pmd.lrsn = cl.lrsn
  --And ct.FullGroupCode = cl.FullGroupCode

Left Join CTE_IMP AS ci
  On pmd.lrsn = ci.lrsn
  --And ct.FullGroupCode = ci.FullGroupCode

Left Join CTE_TotalLastYear AS cly
  On pmd.lrsn = cly.lrsn
  --And ct.FullGroupCode = cly.FullGroupCode

Left Join CTE_ImpLastYear AS cily
  On pmd.lrsn = cily.lrsn
  --And ct.FullGroupCode = cily.FullGroupCode

Left Join CTE_LandLastYear AS clly
  On pmd.lrsn = clly.lrsn
  --And ct.FullGroupCode = cily.FullGroupCode




Left Join CTE_HOEX AS ch
  On pmd.lrsn = ch.lrsn
  
--Check TIFs
Left Join CTE_TAG_TA_TIF_Key AS tif
  On pmd.TAG = tif.TAG

--Modifiers
Left Join TSBv_MODIFIERS AS murd 
  On pmd.lrsn=murd.lrsn 
	And murd.ModifierStatus='A' 
	And murd.ModifierDescr LIKE '%URD%' 
	And murd.ExpirationYear > @Year

--NC Memos
Left Join CTE_Memo_NC AS nc
  On pmd.lrsn = nc.lrsn

  /*
  
Left Join CTE_Memo_602W AS DevExemption
  On pmd.lrsn = DevExemption.lrsn  

Left Join CTE_ImpValDetail AS ivd
  On pmd.lrsn = ivd.lrsn
  And ivd.RowNum = 1
  
  
  vd.lrsn
  ,ROW_NUMBER() OVER (PARTITION BY vd.lrsn, vd.improvement_id ORDER BY vd.last_update_long DESC) AS RowNum
  ,vd.extension AS ImpValDetail_Extension
  ,vd.imp_type AS ImpValDetail_ImpType
  ,vd.improvement_id AS ImpValDetail_ImpId
  ,vd.line_number AS ImpValDetail_ImpLineNum
  */

--Where nc.NC NOT LIKE '%EXCLUDE%'
--And ivd.ImpValDetail_GroupCode <> '81'
--And ivd.ImpValDetail_GroupCode NOT LIKE '%81%'

)


Select Distinct
fnd.District
,fnd.GEO
,fnd.lrsn
,fnd.PIN
,fnd.AIN

,fnd.ClassCD
,fnd.Property_Class_Description
,fnd.Property_Class_Type

,fnd.TIFId
,fnd.TIF
,fnd.URD_BaseValue
,fnd.TAG

,'CurrentYear' AS CurrentYear
-- Current Year
,fnd.TotalLand
,fnd.TotalImp
,fnd.TotalHOEX
,fnd.TotalAssessed
,(fnd.TotalAssessed - fnd.TotalHOEX) AS NetAssessedAfterHOEX
,fnd.TotalNetTaxable

,'PreviousYear' AS PreviousYear
-- Previous Year
,fnd.TotalLandLastYear
,fnd.TotalImpLastYear
,fnd.TotalAssessedLastYear

,'AmountDiff' AS AmountDiff
,(fnd.TotalLand - fnd.TotalLandLastYear) AS DiffLand_YearOverYear
,(fnd.TotalImp - fnd.TotalImpLastYear) AS DiffImp_YearOverYear
,(fnd.TotalAssessed - fnd.TotalAssessedLastYear) AS DiffTotal_YearOverYear

,'PercOfChange' AS PercOfChange
,(fnd.TotalLand / NULLIF(fnd.TotalLandLastYear, 0)) AS PercChange_Land_YearOverYear
,(fnd.TotalImp / NULLIF(fnd.TotalImpLastYear, 0)) AS PercChange_Imp_YearOverYear
,(fnd.TotalAssessed / NULLIF(fnd.TotalAssessedLastYear, 0)) AS PercChange_Total_YearOverYear

,fnd.NC
--,fnd.DevExemption

From CTE_FinalNewDev AS fnd


Order By District, GEO, PIN;
