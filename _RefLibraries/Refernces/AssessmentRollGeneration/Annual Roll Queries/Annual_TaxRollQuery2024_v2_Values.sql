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

--    305 HOEX_Exemption Homeowner Exemption
--    458 Net Imp Only Net Taxable Value Imp Only
--    103 Imp Assessed Improvement Assessed
--    102 Land Assessed Land Assessed
--    109 Total Value Total Value
Declare @ValueTypehoex INT = 305;
--    305 HOEX_Exemption Homeowner Exemption
Declare @ValueTypeimp INT = 103;
--    103 Imp Assessed Improvement Assessed
Declare @ValueTypeland INT = 102;
--    102 Land Assessed Land Assessed
Declare @ValueTypetotal INT = 109;
--    109 Total Value Total Value

WITH

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
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @ValueTypeimp -- Variable
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
),

CTE_Land AS (
SELECT DISTINCT
i.RevObjId AS lrsn
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
,c.ValueAmount  AS Cadaster_Value
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @ValueTypeland -- Variable
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
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @ValueTypetotal -- Variable
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
FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @ValueTypetotal -- Variable
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
)




Select
ct.lrsn
,cl.Cadaster_Value AS TotalLand
,ci.Cadaster_Value AS TotalImp
,ch.Cadaster_Value AS TotalHOEX
,ct.Cadaster_Value AS TotalAssessed
,cly.Cadaster_Value AS TotalAssessedLastYear
,ct.AssessmentType

From CTE_Total AS ct

Left Join CTE_IMP AS ci
  On ct.lrsn = ci.lrsn

Left Join CTE_Land AS cl
  On ct.lrsn = cl.lrsn

Left Join CTE_HOEX AS ch
  On ct.lrsn = ch.lrsn

Left Join CTE_TotalLastYear AS cly
  On ct.lrsn = cly.lrsn


--Where ct.lrsn = 5510207










