-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

File: PM070_CurrentAndPriorValuesCat1Thru5
Based on: PM070_tsbsp_CPCertCat1thru5_Stored_Procedure

Original Creation Notes:
--File Name: CPCertCat1Thru5
--Despription: Value and acres spread for cat 1-5 for cur and prev years
--Original Author: Sandy Bowens (State Tax Commission)
--Date created: 10/24/2017
--Last Modified: 05/01/2020

--    Modification History
--    sab 10/24/2017 WO17656 - 1.)List PIN, CAT, Acres and Value for 2016 and 2017 for comparison of categories 1,2,3,4,5. 
--    sab 05/01/2020 WO20226 - 1.)Report should on bring in annual values, not supplemental.
--    DGW 03/06/2024 Adapted for Kootenai County Assessor's Office to run in Excel instead of Crystal

Notes:
c.CadInvId is unique to each parcel and each cadaster, so lrsn 2 has a diff c.CadInvId in 2017 and 2022.

The AddlObjectId refers to the GroupCode/Category in SysType.
table.column
ValueTypeAmount.AddlObjectId = SysType.id
id shortDescr descr
1200300 01 01 Irr ag                                                       
1200301 02  02 Irr pasture                                                  
1200302 03  03 Non-irr ag                                                   
1200303 04  04 Irr grazing/meadow                                           
1200304 05  05 Dry grazing     

Select
id
,shortDescr
,descr
From SysType
--Where AddlObjectId IN ('1200300','1200301','1200302','1200303','1200304')
Where id IN ('1200300','1200301','1200302','1200303','1200304')

id ShortDescr Descr
470 AssessedByCat Assessed Value
471 AcresByCat Acres

Select
id,
ShortDescr,
Descr
From ValueType 
--Where AddlObjectId IN ('1200300','1200301','1200302','1200303','1200304')
--Where id IN ('1200300','1200301','1200302','1200303','1200304')
Where id IN ('470','471')

This is the Per Acre BLY
AND c.ValueType = 112
Id ShortDescr Descr
101 LandMarket Land Market Assessed
112 PABLYV 07 Per Acre BLY (Bare Land Yield)

Select
Id,
ShortDescr,
Descr
From ValueType
Where Id IN ('112','101')

*/


DECLARE @TaxYear INT = '2023';
--Use the current tax year, 
-- the CTE_Temp_Prior auto subtracts one year to get prior year

DECLARE @ValueTypeAssessedValue INT = '470';
DECLARE @ValueTypeAcres INT = '471';

  --AND c.ValueType = 101 -- LandMarket
  --AND c.ValueType = 112 -- PABLYV
  --AND c.ValueType = 471 -- AcresByCat
  --AND c.ValueType = 470 -- AssessedByCat


WITH
/*
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
,TRIM(pm.TAG) AS TAG

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
),
*/

------ VALUES


CTE_CurrentValue AS (
Select 
c.LRSN
,TRIM(c.PIN) AS PIN
,TRIM(c.AIN) AS AIN
,c.Tag
,c.TaxYear AS CurrYear
--,c.Group_Code
--,c.ValueAmount

, CASE
  WHEN c.Group_Code = 01 THEN c.ValueAmount
END AS Cat01c

, CASE
  WHEN c.Group_Code = 02 THEN c.ValueAmount
END AS Cat02c

, CASE
  WHEN c.Group_Code = 03 THEN c.ValueAmount
END AS Cat03c

, CASE
  WHEN c.Group_Code = 04 THEN c.ValueAmount
END AS Cat04c

, CASE
  WHEN c.Group_Code = 05 THEN c.ValueAmount
END AS Cat05c


From tsbv_cadastre AS c

Join ValueTypeAmount AS v
  On v.HeaderId = c.CadInvId 
  And v.ValueTypeId = @ValueTypeAssessedValue
  And v.AddlObjectId IN ('1200300','1200301','1200302','1200303','1200304')
  --HeaderId = c.CadInvId 

Where c.TaxYear = @TaxYear
  --AND c.ValueType = 101 -- LandMarket
  --AND c.ValueType = 112 -- PABLYV
  --AND c.ValueType = 471 -- AcresByCat
  --AND c.ValueType = 470 -- AssessedByCat
  --AND c.ValueType = @ValueTypeAssessedValue -- Variable
  AND c.ValueType = 109 -- Variable
  AND c.RollCaste = 16001
  And c.Group_Code IN ('01','02','03','04','05')
  
),


CTE_PriorValue AS (
Select 
c.LRSN AS PriorLRSN
,TRIM(c.PIN) AS PIN
,TRIM(c.AIN) AS AIN
,c.TaxYear AS PriorYear
--,c.Group_Code
--,c.ValueAmount

, CASE
  WHEN c.Group_Code = 01 THEN c.ValueAmount
END AS Cat01p

, CASE
  WHEN c.Group_Code = 02 THEN c.ValueAmount
END AS Cat02p

, CASE
  WHEN c.Group_Code = 03 THEN c.ValueAmount
END AS Cat03p

, CASE
  WHEN c.Group_Code = 04 THEN c.ValueAmount
END AS Cat04p

, CASE
  WHEN c.Group_Code = 05 THEN c.ValueAmount
END AS Cat05p

From tsbv_cadastre AS c

Join ValueTypeAmount AS v
  On v.HeaderId = c.CadInvId 
  And v.ValueTypeId = @ValueTypeAssessedValue
  And v.AddlObjectId IN ('1200300','1200301','1200302','1200303','1200304')
  --HeaderId = c.CadInvId 

Where c.TaxYear = @TaxYear - 1
  --AND c.ValueType = 101 -- LandMarket
  --AND c.ValueType = 112 -- PABLYV
  --AND c.ValueType = 471 -- AcresByCat
  --AND c.ValueType = 470 -- AssessedByCat
  --AND c.ValueType = @ValueTypeAssessedValue -- Variable
  AND c.ValueType = 109 -- Variable
  AND c.RollCaste = 16001
  And c.Group_Code IN ('01','02','03','04','05')

),

----- ACRES

CTE_CurrentAcres AS (
Select 
c.LRSN
,TRIM(c.PIN) AS PIN
,TRIM(c.AIN) AS AIN
,c.TaxYear AS CurrYear
--,c.Group_Code
--,c.ValueAmount

, CASE
  WHEN c.Group_Code = 01 THEN c.ValueAmount
END AS Acres01c

, CASE
  WHEN c.Group_Code = 02 THEN c.ValueAmount
END AS Acres02c

, CASE
  WHEN c.Group_Code = 03 THEN c.ValueAmount
END AS Acres03c

, CASE
  WHEN c.Group_Code = 04 THEN c.ValueAmount
END AS Acres04c

, CASE
  WHEN c.Group_Code = 05 THEN c.ValueAmount
END AS Acres05c


From tsbv_cadastre AS c

Join ValueTypeAmount AS v
  On v.HeaderId = c.CadInvId 
  And v.ValueTypeId = @ValueTypeAcres
  And v.AddlObjectId IN ('1200300','1200301','1200302','1200303','1200304')
  --HeaderId = c.CadInvId 

Where c.TaxYear = @TaxYear
  --AND c.ValueType = 101 -- LandMarket
  --AND c.ValueType = 112 -- PABLYV
  --AND c.ValueType = 471 -- AcresByCat
  --AND c.ValueType = 470 -- AssessedByCat
  --AND c.ValueType = @ValueTypeAssessedValue -- Variable
  AND c.ValueType = 109 -- Variable
  AND c.RollCaste = 16001
  And c.Group_Code IN ('01','02','03','04','05')
  
),


CTE_PriorAcres AS (
Select 
c.LRSN AS PriorLRSN
,TRIM(c.PIN) AS PIN
,TRIM(c.AIN) AS AIN
,c.TaxYear AS PriorYear
--,c.Group_Code
--,c.ValueAmount

, CASE
  WHEN c.Group_Code = 01 THEN c.ValueAmount
END AS Acres01p

, CASE
  WHEN c.Group_Code = 02 THEN c.ValueAmount
END AS Acres02p

, CASE
  WHEN c.Group_Code = 03 THEN c.ValueAmount
END AS Acres03p

, CASE
  WHEN c.Group_Code = 04 THEN c.ValueAmount
END AS Acres04p

, CASE
  WHEN c.Group_Code = 05 THEN c.ValueAmount
END AS Acres05p

From tsbv_cadastre AS c

Join ValueTypeAmount AS v
  On v.HeaderId = c.CadInvId 
  And v.ValueTypeId = @ValueTypeAcres
  And v.AddlObjectId IN ('1200300','1200301','1200302','1200303','1200304')
  --HeaderId = c.CadInvId 

Where c.TaxYear = @TaxYear - 1
  --AND c.ValueType = 101 -- LandMarket
  --AND c.ValueType = 112 -- PABLYV
  --AND c.ValueType = 471 -- AcresByCat
  --AND c.ValueType = 470 -- AssessedByCat
  --AND c.ValueType = @ValueTypeAssessedValue -- Variable
  AND c.ValueType = 109 -- Variable
  AND c.RollCaste = 16001
  And c.Group_Code IN ('01','02','03','04','05')

)



Select
/*
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.PIN
,pmd.TAG
*/
cv.LRSN
,cv.PIN
,cv.AIN
,cv.Tag
,cv.CurrYear

,cv.Cat01c
,ca.Acres01c
,cv.Cat02c
,ca.Acres02c
,cv.Cat03c
,ca.Acres03c
,cv.Cat04c
,ca.Acres04c
,cv.Cat05c
,ca.Acres05c

,pv.PriorLRSN
,pv.PriorYear
,pv.Cat01p
,pa.Acres01p
,pv.Cat02p
,pa.Acres02p
,pv.Cat03p
,pa.Acres03p
,pv.Cat04p
,pa.Acres04p
,pv.Cat05p
,pa.Acres05p

FROM CTE_CurrentValue AS cv

JOIN CTE_CurrentAcres AS ca
  ON ca.LRSN = cv.LRSN

JOIN CTE_PriorValue AS pv
  ON pv.PriorLRSN = cv.LRSN

JOIN CTE_PriorAcres AS pa
  ON pa.PriorLRSN = cv.LRSN




Order by 2
--From CTE_ParcelMaster AS pmd

--Order By pmd.District,pmd.GEO,pmd.PIN;



/*
Converting report from TSB Dashboard view not in our database to SQL
Table View in Crystal is: TSBsp_tsb_CPCertCat1Thru5;1
Report Name: PM070_CurrentAndPriorValuesCat1Thru5

c=Current
{TSBsp_tsb_CPCertCat1Thru5;1.cat01c} +
{TSBsp_tsb_CPCertCat1Thru5;1.cat02c} +
{TSBsp_tsb_CPCertCat1Thru5;1.cat03c} + 
{TSBsp_tsb_CPCertCat1Thru5;1.cat04c} +
{TSBsp_tsb_CPCertCat1Thru5;1.cat05c}

p=Prior
{TSBsp_tsb_CPCertCat1Thru5;1.cat01p} +
{TSBsp_tsb_CPCertCat1Thru5;1.cat02p} +
{TSBsp_tsb_CPCertCat1Thru5;1.cat03p} +
{TSBsp_tsb_CPCertCat1Thru5;1.cat04p} +
{TSBsp_tsb_CPCertCat1Thru5;1.cat05p}

"PIN"	"TAG"	Status

"Curr Year"	
"CurrCat01"	
"CurrAcres01"	
"CurrCat02"	
"CurrAcres02"	
"CurrCat03"	
"CurrAcres03"	
"CurrCat04"	
"CurrAcres04"	
"CurrCat05"	
"CurrAcres05"	

"PriorYear"	
"PriorCat01"	
"PriorAcres01"	
"PriorCat02"	
"PriorAcres02"	
"PriorCat03"	
"PriorAcres03"	
"PriorCat04"	
"PriorAcres04"	
"PriorCat05"	
"PriorAcres05"


Categories unclear, requested clarification from 
'Sandy Bowens' and 'Brad Broenneke'

Darrell G Wolfe 
Created 03/05/2024


*/



