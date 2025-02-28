DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year


DECLARE @LastUpdate DATE = CONCAT(@Year, '-01-01');
--AND lh.LastUpdate > '2023-01-01'
DECLARE @ThisYearMPPVFrom INT = CONCAT('70', @Year);
--AND lh.LandModelId = '702023'

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
,pm.EffStatus
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description

,CASE 
  WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040'
    , '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
  
  WHEN pm.ClassCD IN ('527', '526') THEN 'Condos'

  WHEN pm.ClassCD IN ('546', '548', '565') THEN 'Manufactered_Home'
  WHEN pm.ClassCD IN ('555') THEN 'Floathouse_Boathouse'
  WHEN pm.ClassCD IN ('550','549','451') THEN 'LeasedLand'

  WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416'
  , '421', '435', '438', '442', '461') THEN 'Commercial_Industrial'

  WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '561') THEN 'Residential'

  WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
  
  WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'

  WHEN pm.ClassCD = '667' THEN 'Operating_Property'
  WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
  WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'

  ELSE 'Unasigned_or_OldInactiveParcel'

END AS Property_Class_Type


,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.DisplayDescr) AS LegalDescription
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,TRIM(pm.SitusState) AS SitusState
,TRIM(pm.SitusZip) AS SitusZip

,TRIM(pm.AttentionLine) AS AttentionLine
,TRIM(pm.MailingAddress) AS MailingAddress
,TRIM(pm.AddlAddrLine) AS AddlAddrLine
,TRIM(pm.MailingCityStZip) AS MailingCityStZip
,TRIM(pm.MailingCity) AS MailingCity
,TRIM(pm.MailingState) AS MailingState
,TRIM(pm.MailingZip) AS MailingZip
,TRIM(pm.CountyNumber) AS CountyNumber

,CASE
  WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
  ELSE NULL
END AS County_Name

,pm.LegalAcres
, CASE
    WHEN pm.LegalAcres < 1 THEN 'Acres_LessThan_1'
    WHEN pm.LegalAcres BETWEEN 1 AND 4.9999 THEN 'Acres_1-5'
    WHEN pm.LegalAcres > 5 THEN 'Acres_Over_5'  
    ELSE NULL
  END AS Acres_Category
,pm.WorkValue_Land
,pm.WorkValue_Impv
,pm.WorkValue_Total
,pm.CostingMethod
,pm.Improvement_Status -- <Improved vs Vacant

From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),

CTE_Allocations AS (
SELECT 
a.lrsn
, a.extension
, a.improvement_id
, a.group_code
, impgroup.tbl_element_desc AS ImpGroup_Descr
, market_value
, cost_value

FROM allocations AS a 

LEFT JOIN codes_table AS impgroup ON impgroup.tbl_element=a.group_code
  AND impgroup.code_status='A'
  AND impgroup.tbl_type_code = 'impgroup'

WHERE a.status='A' 
  --AND a.group_code IN ('01','03','04','05')
  AND a.group_code IN ('01','03','04','05','06','07','09')
  --AND a.group_code IN ('06','07') 
),


CTE_LandDetails AS (
SELECT DISTINCT 
lh.RevObjId AS lrsn
,lh.TotalMktAcreage
,lh.TotalMktValue
,ld.LandType
,lt.land_type_desc
,ld.AppdValue
,ld.ActualFrontage
,ld.LDAcres
,ld.SoilIdent

--Land Header
FROM LandHeader AS lh
--AS lh ON lh.RevObjId=a.lrsn 

--Land Detail
LEFT JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND ld.PostingSource='A'
  AND ld.LandType IN ('4','41','45','52','6','61','62','73','75','8')
  --Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

  WHERE lh.EffStatus= 'A' 
  AND lh.PostingSource='A'
  AND lh.LastUpdate > @LastUpdate
  AND lh.LandModelId = @ThisYearMPPVFrom
),


Timber AS (
SELECT
lrsn,
TRIM(ModifierDescr) AS ModifierDescr,
ModifierPercent,
--CAST(OverrideAmount AS BIGINT) AS PPExemption602KK,
--TRY_CAST(ISNUMERIC(OverrideAmount) AS BIGINT) AS PPExemption602KK,
--CAST(OverrideAmount AS VARCHAR) AS PPExemption602KK,
CAST(OverrideAmount AS INT) AS ModifierAmount,
ExpirationYear
FROM TSBv_MODIFIERS
WHERE ModifierStatus='A'
--AND ModifierDescr LIKE '%Ag%'
AND PINStatus='A'
AND ExpirationYear > @CurrentYear
AND ModifierDescr LIKE '%Tim%'
),

Agriculture AS (
SELECT
lrsn,
TRIM(ModifierDescr) AS ModifierDescr,
ModifierPercent,
--CAST(OverrideAmount AS BIGINT) AS PPExemption602KK,
--TRY_CAST(ISNUMERIC(OverrideAmount) AS BIGINT) AS PPExemption602KK,
--CAST(OverrideAmount AS VARCHAR) AS PPExemption602KK,
CAST(OverrideAmount AS INT) AS ModifierAmount,
ExpirationYear
FROM TSBv_MODIFIERS
WHERE ModifierStatus='A'
--AND ModifierDescr LIKE '%Ag%'
AND PINStatus='A'
AND ExpirationYear > @CurrentYear
AND ModifierDescr LIKE '%Ag Land%'
)

SELECT DISTINCT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.Property_Class_Type

,cal.group_code
,cal.ImpGroup_Descr
,cld.LandType

,cld.land_type_desc

,tim.ModifierDescr

,ag.ModifierDescr

,CASE
  WHEN cal.group_code IS NOT NULL THEN 'Yes_Allocation'
  ELSE 'No_Allocation'
END AS 'AllocationCheck'

,CASE
  WHEN cld.LandType IS NOT NULL THEN 'Yes_LandType'
  ELSE 'No_LandType'
END AS 'LandTypeCheck'

,CASE
  WHEN ag.ModifierDescr IS NOT NULL THEN 'Yes_AgModifier'
  ELSE 'No_AgModifier'
END AS 'AgModifierCheck'

,CASE
  WHEN tim.ModifierDescr IS NOT NULL THEN 'Yes_TimberModifier'
  ELSE 'No_TimberModifier'
END AS 'TimberModifierCheck'


/*
,cld.AppdValue

,cal.market_value
,cal.cost_value

,cld.TotalMktAcreage
,cld.TotalMktValue
,cld.ActualFrontage
,cld.LDAcres
,cld.SoilIdent
,pmd.TAG
,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity
,pmd.SitusState
,pmd.SitusZip

,pmd.Owner
,pmd.AttentionLine
,pmd.MailingAddress
,pmd.AddlAddrLine
,pmd.MailingCityStZip
,pmd.MailingCity
,pmd.MailingState
,pmd.MailingZip
,pmd.CountyNumber
,pmd.County_Name

,pmd.LegalAcres
,pmd.Acres_Category
,pmd.WorkValue_Land
,pmd.WorkValue_Impv
,pmd.WorkValue_Total
,pmd.CostingMethod
,pmd.Improvement_Status 
*/

FROM CTE_ParcelMaster AS pmd
LEFT JOIN CTE_LandDetails AS cld ON cld.lrsn=pmd.lrsn
LEFT JOIN CTE_Allocations AS cal ON cal.lrsn=pmd.lrsn
LEFT JOIN Timber AS tim ON tim.lrsn=pmd.lrsn
LEFT JOIN Agriculture AS ag ON ag.lrsn=pmd.lrsn


Where pmd.EffStatus = 'A'
  AND pmd.ClassCD NOT LIKE '060%'
  AND pmd.ClassCD NOT LIKE '070%'
  AND pmd.ClassCD NOT LIKE '090%'

  AND (cal.group_code IS NOT NULL
  OR cld.LandType IS NOT NULL
  OR ag.ModifierDescr IS NOT NULL
  OR tim.ModifierDescr IS NOT NULL)

Order By District,GEO,PIN;
