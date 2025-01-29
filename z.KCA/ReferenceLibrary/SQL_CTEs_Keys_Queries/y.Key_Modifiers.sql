-- !preview conn=conn


/*
AsTxDBProd
GRM_Main
*/






SELECT *

FROM Modifier

--WHERE EffStatus='A'
--AND Descr LIKE '%602KK%'

--Looking to see what PP accounts have a URD Modifier, to be compared with URD in the legal descriptions
CTE_ModURD (lrsn, [URD], [URD%], [URD$]) AS (
SELECT
lrsn,
BegTaxYear,
ExpirationYear,
TRIM(ModifierDescr) AS URDDescr,
ModifierPercent AS URDPerc,
OverrideAmount AS URDBase

FROM TSBv_MODIFIERS
WHERE ModifierStatus='A'
AND ModifierDescr LIKE '%URD%'
AND PINStatus='A'
AND ExpirationYear > 2024

),

,mURD.BegTaxYear
,mURD.ExpirationYear
,mURD.URDDescr
,mURD.URDPerc
,mURD.URDBase


LEFT JOIN CTE_ModURD AS mURD 
  ON pmd.lrsn=mURD.lrsn


/*

    lrsn,
    ModifierDescr,
    ModifierPercent,
    OverrideAmount 
    
    
SELECT *

FROM Modifier --< ONLY PULLS THE MODIFIER ITSELF, NOT THE ASSOCIATED PINS
WHERE EffStatus='A'
AND Descr LIKE '%602KK%'

FROM ModifierOutput -- oNLY SHOWS MODIFIER OUTPUT NOT LABELS



    
Select Distinct
tsbm.ModifierId,
tsbm.ModifierShortDescr,
tsbm.ModifierDescr

FROM TSBv_MODIFIERS AS tsbm --ON tsbm.lrsn=pm.lrsn
  WHERE tsbm.PINStatus='A'
  And tsbm.ModifierStatus = 'A'
  And tsbm.ExpirationYear >= 2023 -- Update each year
  --And tsbm.ModifierId IN ('7','41','42') 

ModifierId
ModifierShortDescr
ModifierDescr
1
Government
602A Government property
2
Religious
602B Religious corporations or societies
3
FratCharity
602C Fraternal/benevolent/charitable
5
School
602E School/Education
6
CemeteryLibr
602F Cemeteries/Libraries
7
_HOEXCap
602G Residential Improvements - Homeowners
9
SpecLand
602K Speculative Value of Ag Land
10
IrrigationWater
602N Irrigation water and structures
11
IrrigDrainage
602O Property used for Irrigation or Drainage
12
PollutionCtrl
602P Water/Air pollution control
18
SLS
State Land Sale
26
LandUse
Land Use Program
27
Timber
Timber Program
35
BusInvExempt
602W Business Inventory Exempt From Taxation
41
_HOEXCapCalc
Homeowner Calc Cap Override
42
_HOEXCapManual
Homeowner Manual Cap Override
53
URDBaseModifier
Total URD Base
54
PPExemption
PP Exemption 602KK


*/



