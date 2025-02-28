-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
Cadastre Tax Roll Report
*/


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

-- DECLARE @Year INT = 2024; -- Input year
--DECLARE @TaxYear INT = 2023;

DECLARE @ValueType INT = 455;
/*
Join ValueType AS vt
--On vt.id = c.ValueType
id ShortDescr Descr
109 Total Value Total Value
320 Total Exemptions Total Exemptions
455 Net Tax Value Net Taxable Value
305 HOEX_Exemption Homeowner Exemption
*/



WITH

CTE_DistrictKey AS (
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
,pm.neighborhood AS GEO

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
)


SELECT DISTINCT
dk.District
,TRIM(i.GeoCd) AS GEO
,TRIM(i.TAGDescr) AS TAG
,i.RevObjId AS CadRoll_LRSN
,TRIM(i.PIN) AS PIN
,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
,c.ValueAmount  AS Cadaster_Value
 --sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,l.CadRollId
,l.RollLevel 
,i.TranId
,i.CadLevelId
,i.RevObjEffStatus


FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN CTE_DistrictKey AS dk
  On dk.GEO = i.GeoCd
JOIN tsbv_cadastre AS c 
   On c.CadRollId = r.Id
   And c.CadInvId = i.Id
   --And c.TypeCode = 'Net Tax Value'
   --And c.TypeCode = 'Total Value' -- Total Assessed Value
  And c.ValueType = @ValueType -- Variable
  --And c.ValueType = 455 -- Net Tax Value
  --And c.ValueType = 109 -- Total Assessed Value
  --And c.ValueType = 320 -- Total Exemptions
  --And c.ValueType = 305 -- Total HOEX Exemptions
    /*
    Join ValueType AS vt
    --On vt.id = c.ValueType
    id ShortDescr Descr
    109 Total Value Total Value
    320 Total Exemptions Total Exemptions
    455 Net Tax Value Net Taxable Value
    305 HOEX_Exemption Homeowner Exemption
    */


/*

CadRoll Table Id (r.Id) is the id for the specific tax roll desired. See CadRoll table or Schema in the Comptroller Reporting folder.
WHERE r.Id= '558'
WHERE r.Id IN ('558', '556', '555', '554')
Annual_TaxRollQuery2023.sql

Join ValueType AS vt
   On vt.id = c.ValueType
   --And vt.ShortDescr = 'Total Value' -- Total Assessed Value
   And vt.ShortDescr = 'Net Tax Value'
*/


WHERE r.AssessmentYear IN (@TaxYear)
--And i.AIN = '349655'



ORDER BY District, GEO, PIN;



/*
To find the value types (Net Taxable, Total Assessed, HOEX, etc...
From the cadaster, use the following)

Select Distinct
vt.id
,vt.ShortDescr
,vt.Descr
From ValueType AS vt
   
Order By vt.ShortDescr

In case you need to join:
--c.TypeCode is the vt.ShortDescr
-- From tsbv_cadastre AS c 
   --On vt.id = c.ValueType
   --And vt.ShortDescr 

Popular Ones we use:
id ShortDescr Descr

109 Total Value Total Value

320 Total Exemptions Total Exemptions

455 Net Tax Value Net Taxable Value

305 HOEX_Exemption Homeowner Exemption


Also Helpful:
103 Imp Assessed Improvement Assessed
102 Land Assessed Land Assessed
101 LandMarket Land Market Assessed
100 LandUse Land Use Assessed
108 LandUseAcres Land Use Acres
105 PP Assessed Personal Property Assessed
310 PP_Exemption PP Exemption 602KK
271 Timber Timber Program
107 Total Acres Total Acres
501 URD Total Base URD Base Total Value
601 URD Total Incr URD Increment Total Value

*/