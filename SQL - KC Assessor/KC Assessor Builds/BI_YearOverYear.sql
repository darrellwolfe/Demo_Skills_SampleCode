
/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())

-- Some common filters
-- WHERE cv.AssessmentYear LIKE '2023%'
-- AND cv.CadRollDescr NOT LIKE '%Personal%'
-- AND cv.AIN = '193308'


See bottom for complete list of CadViewer Description Types
Common: 

ValueTypeShortDescr is cleaner than ValueTypeDescr
FYI - Assessed Value (aka AssessedByCat, this is the individual improvements, not the total imp or total value)

ValueTypeDescr
Homeowner Exemption
Land Assessed
Net Taxable Value
Net Taxable Value Excludes Ag and Timber
PP Exemption 602KK
Personal Property Assessed
Total Exemptions
Total Value
URD Base Total Value
URD Increment Total Value

ValueTypeShortDescr
HOEX_Exemption
Land Assessed
Net Tax Value
Net Minus Ag/Tbr
PP_Exemption
PP Assessed
Total Exemptions
Total Value
URD Total Base
URD Total Incr


*/

--------------------------------
--Cadaster + ParcelMaster All
--------------------------------



Select Distinct
--Cadaster Info
cv.AssessmentYear,
CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate],
cv.CadRollDescr,
cv.CadRollId,
cv.CadLevelId,
cv.CadInvId,
cv.RollLevel,
-- Parcel Info from Cad Viewer
cv.RevObjId AS [LRSN],
cv.PIN,
-- Parcel Info from Parcel Master
LTRIM(RTRIM(pm.pin)) AS [PIN_Check],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD],
LTRIM(RTRIM(pm.TAG)) AS [TAG],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
pm.LegalAcres,
--Cadaster Values
cv.ValueTypeShortDescr,
cv.ValueTypeDescr,
cv.ValueAmount,
cv.CalculatedAmount,
cv.FormattedValueAmount

FROM CadValueTypeAmount_V AS cv
JOIN TSBv_PARCELMASTER AS pm ON pm.lrsn = cv.RevObjId
  AND pm.EffStatus = 'A'
  AND pm.PropClassDescr NOT LIKE '%070%'

WHERE cv.AssessmentYear IN ('2023','2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
  AND cv.ValueTypeShortDescr IN (
      'HOEX_Exemption',
      'Land Assessed',
      'Net Tax Value',
      'Net Minus Ag/Tbr',
      'PP_Exemption',
      'PP Assessed',
      'Total Exemptions',
      'Total Value',
      'URD Total Base',
      'URD Total Incr')

Group By
cv.AssessmentYear,
cv.CadRollDescr,
cv.CadRollId,
cv.CadLevelId,
cv.CadInvId,
cv.RollLevel,
cv.RevObjId,
cv.PIN,
pm.pin,
pm.AIN,
pm.neighborhood,
pm.NeighborHoodName,
pm.PropClassDescr,
pm.TAG,
pm.SitusAddress,
pm.SitusCity,
pm.LegalAcres,
cv.ValueTypeShortDescr,
cv.ValueTypeDescr,
cv.ValueAmount,
cv.CalculatedAmount,
cv.FormattedValueAmount

--Order By [GEO],[SitusCity],[ClassCD];























--------------------------------
--ParcelMaster
--------------------------------

Select Distinct
pm.lrsn,
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD],
LTRIM(RTRIM(pm.TAG)) AS [TAG],
LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
pm.LegalAcres,
pm.TotalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total,
pm.CostingMethod

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
AND pm.PropClassDescr NOT LIKE '%070%'


Group By
pm.lrsn,
pm.pin,
pm.AIN,
pm.PropClassDescr,
pm.neighborhood,
pm.NeighborHoodName,
pm.TAG,
pm.DisplayName,
pm.SitusAddress,
pm.SitusCity,
pm.LegalAcres,
pm.TotalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total,
pm.CostingMethod

Order By GEO, PIN;


--------------------------------
--CadViewer AND cv.ValueTypeDescr = 'Net Taxable Value'
--------------------------------

-- Sum Total by Year

Select
cv.CadRollDescr,
cv.AssessmentYear,
CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate],
SUM(cv.ValueAmount) AS [NetTaxableValue],
cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
WHERE cv.AssessmentYear IN ('2023','2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
AND cv.ValueTypeDescr = 'Net Taxable Value'

Group By
cv.CadRollDescr,
cv.AssessmentYear,
cv.AssessmentYear,
cv.ValueTypeDescr

Order By cv.AssessmentYear 

-- ALL PINS

Select
cv.AssessmentYear,
CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate],
cv.CadRollDescr,
cv.CadRollId,
cv.CadLevelId,
cv.CadInvId,
cv.RollLevel,
cv.RevObjId,
cv.PIN,
cv.AIN,
cv.TAGShortDescr,
cv.ValueAmount AS [NetTaxableValue],
cv.CalculatedAmount,
cv.FormattedValueAmount,
cv.ValueTypeShortDescr,
cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
WHERE cv.AssessmentYear IN ('2023','2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
--AND cv.ValueTypeDescr = 'Net Taxable Value'

Order By cv.PIN 


--------------------------------
--CadViewer AND cv.ValueTypeDescr = 'Total Value'
--------------------------------


-- ALL PINS

Select
cv.AssessmentYear,
CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate],
cv.CadRollDescr,
cv.CadRollId,
cv.CadLevelId,
cv.CadInvId,
cv.RollLevel,
cv.RevObjId,
cv.PIN,
cv.AIN,
cv.TAGShortDescr,
cv.ValueAmount AS [TotalAssessedValue],
cv.CalculatedAmount,
cv.FormattedValueAmount,
cv.ValueTypeShortDescr,
cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
WHERE cv.AssessmentYear IN ('2023','2022','2021','2020','2019','2018')
AND cv.ValueTypeDescr = 'Total Value'

Order By cv.PIN 

--------------------------------
--CadViewer AND cv.ValueTypeDescr = 'Total Exemptions'
--------------------------------


--ALL PINS 

Select
cv.AssessmentYear,
CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate],
cv.CadRollDescr,
cv.CadRollId,
cv.CadLevelId,
cv.CadInvId,
cv.RollLevel,
cv.RevObjId,
cv.PIN,
cv.AIN,
cv.TAGShortDescr,
cv.ValueAmount AS [TotalExemptionValue],
cv.CalculatedAmount,
cv.FormattedValueAmount,
cv.ValueTypeShortDescr,
cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
WHERE cv.AssessmentYear IN ('2023','2022','2021','2020','2019','2018')
--WHERE cv.AssessmentYear IN ('2023','2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
AND cv.ValueTypeDescr = 'Total Exemptions'

Order By cv.PIN 





--------------------------------
--CadViewer AND cv.ValueTypeDescr = 'xxxxxx'
--------------------------------

Select
cv.AssessmentYear,
CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate],
cv.CadRollDescr,
cv.CadRollId
cv.CadLevelId
cv.CadInvId
cv.RollLevel,
cv.RevObjId,
cv.PIN,
cv.AIN,
cv.TAGShortDescr,
cv.ValueAmount AS [xxxxxx],
cv.CalculatedAmount,
cv.FormattedValueAmount,
cv.ValueTypeShortDescr,
cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
WHERE cv.AssessmentYear IN ('2023','2022','2021','2020','2019','2018')
AND cv.ValueTypeDescr = 'xxxxxx'

Order By cv.PIN 






/*

--------------------------------
--CadViewer TEST LIST
--------------------------------

Select DISTINCT
cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
WHERE cv.AssessmentYear IN ('2023','2022','2021','2020','2019','2018')

GROUP BY
cv.ValueTypeDescr

Order By cv.ValueTypeDescr 
-- Some common filters
-- WHERE cv.AssessmentYear LIKE '2023%'
-- AND cv.CadRollDescr NOT LIKE '%Personal%'
-- AND cv.AIN = '193308'

ValueTypeShortDescr

DefLand
PABLYV
PAMV
SpecLand
PPExemptionCap
PollutionControl
BusInvExempt
AQUIFER
AQUAOP
AcresByCat
AssessedByCat
DEF08
SpecLandDeferred
ExemptStatute
HOEX_CapOverride
HOEX_Cap
HOEligibleByCat
HOEX_EligibleVal
HOEX_Exemption
HOEX_ByCat
HOEX_ImpOnly
HOEX_CapManual
HOEX_Percent
Imp Assessed
Land Assessed
LandMarket
LandUseAcres
LandUse
PreferentialUse
Months
Net Tax Value
Net Minus Ag/Tbr
Fire Tax
Flood Tax
Net Minus Tbr
Net Imp Only
OPT Assessed
PP_Exemption
PTRBenefit
PTRElgImpV
PTRElgLandV
PTRHO
PTRHoImpOnly
PTRImp
PTRLand
PTRValue
PTRValImpOnly
PP Assessed
PPExemptionByCat
PCAssessed
PollContrByCat
BAYWTR
CATFP
CATFPA
CITYCDA
DALTON
CITYPF
COUNTY
DALTIRR
DD#1
GRFERRY
HLKSWR
HACKNEY
HARRISON
HAYDEN
IDPAN
IDPFPA
KINGSCAT
KOOTWTR
LKSHWY
MICAFP
MICAFPA
NKOOTWTR
OHIOMTC
RATHDRUM
REMINGTN
TWWTR
WJOEFP
WJOEFPA
WDCOMM
WDPRES
SLS
SupValCat
SUP Net Tax Val
SupProratedVal
SupValCatPro
SUPTaxFire
SUPTaxExclAgTbr
SUPTaxFlood
SUPTaxExclTbr
Timber
Total Acres
SUP_Annual_AgTbr
SUP_Annual_Flood
SUP_Annual_Fire
SUP_Annual_Tbr
SUP_Annual_Imp
SUP_Annual_Net
Total Exemptions
Total Value
URDBaseExAgTSUPP
URDBaseFireSUPP
URDBaseFloodSUPP
URDBaseExTbSUPP
URDBaseImpOnSUPP
URDTotalBaseSUPP
URDIncrExAgTSUPP
URDIncrFireSUPP
URDIncrFloodSUPP
URDIncrExTbSUPP
URDIncrImpOnSUPP
URDTotalIncrSUPP
URDBaseModifier
URDBaseFire
URDBaseExclAgTbr
URDBaseFlood
URDBaseExclTbr
URDBaseImpOnly
URD Total Base
UR_BaseByCat
URDIncrExclAgTbr
URDIncrFlood
URDIncrFire
URDIncrExclTbr
URDIncrImpOnly
URD Total Incr
UR_IncrByCat
YIELD08


ValueTypeDescr

07 Deferred Land Value
07 Per Acre BLY
07 Per Acre Market
602K Speculative Value of Ag Land
602KK PP Exemption Cap
602P Pollution Control
602W Business Inventory Exempt From Taxation
AQUIFER PROTECTION
AQUIFER PROTECTION OP
Acres
Assessed Value
DEFERRED
Deferred Speculative Land
Exempt by Statute
Homeowner Calculated Cap Override
Homeowner Cap
Homeowner Eligible
Homeowner Eligible Value
Homeowner Exemption
Homeowner Exemption Imp Only
Homeowner Manual Cap Override
Homeowner Percent
Improvement Assessed
Land Assessed
Land Market Assessed
Land Use Acres
Land Use Assessed
Land Use Program
Months
Net Taxable Value
Net Taxable Value Excludes Ag and Timber
Net Taxable Value Excludes Opt
Net Taxable Value Excludes PP and OPT
Net Taxable Value Excludes Timber
Net Taxable Value Imp Only
Operating Property Assessed
PP Exemption 602KK
PTR Benefit
PTR Eligible Imp Value
PTR Eligible Land Value
PTR Homeowners Exemption
PTR Homeowners Exemption Imp Only
PTR Imp Percent
PTR Land Percent
PTR Taxable Value
PTR Taxable Value Imp Only
Personal Property Assessed
Personal Property Exemption
Pollution Control Assessed
Pollution Control Exemption
S/A-BAYVW WTR/SW
S/A-CATALDO FP
S/A-CATALDO-FPA
S/A-CITY CDA
S/A-CITY DALTON
S/A-CITY PF
S/A-COUNTY
S/A-DALT IRR
S/A-DD#1
S/A-GR FERRY
S/A-H LK SWR
S/A-HACKNEY
S/A-HARRISON
S/A-HAYDEN
S/A-ID PANHANDLE
S/A-ID PNHDL-FPA
S/A-KING CAT
S/A-KOOTENAI WATER
S/A-LAKES HWY
S/A-MICA FP
S/A-MICA-FPA
S/A-N KOOTENAI WATER
S/A-OHIO MTC
S/A-RATHDRUM
S/A-REMINGTON
S/A-TWIN LKS WTR
S/A-W ST JOE FP
S/A-W ST JOE FPA
S/A-WASTE DISP-COMM
S/A-WASTE DISP-RES
State Land Sale
Supplemental Assessed Value By Cat
Supplemental Net Taxable Value
Supplemental Prorated Value
Supplemental Prorated Value By Cat
Supplemental Taxable  Excludes Timber
Supplemental Taxable Excludes Ag/Timber/OPT
Supplemental Taxable Excludes PP
Supplemental Taxable Excludes Timber
Timber Program
Total Acres
Total Annual/Supp Net Excludes Ag/Timber/OPT
Total Annual/Supp Net Excludes PP
Total Annual/Supp Net Excludes PP and OPT
Total Annual/Supp Net Excludes Timber
Total Annual/Supp Net Imp Only
Total Annual/Supp Net Values
Total Exemptions
Total Value
URD ANNUAL/SUPP Base Total Excludes Ag/Timber/OPT
URD ANNUAL/SUPP Base Total Excludes OPT
URD ANNUAL/SUPP Base Total Excludes PP and OPT
URD ANNUAL/SUPP Base Total Excludes Timber
URD ANNUAL/SUPP Base Total Imp Only
URD ANNUAL/SUPP Base Total Value
URD ANNUAL/SUPP Incr Total Excludes Ag/Timber/OPT
URD ANNUAL/SUPP Incr Total Excludes OPT
URD ANNUAL/SUPP Incr Total Excludes PP and OPT
URD ANNUAL/SUPP Incr Total Excludes Timber
URD ANNUAL/SUPP Incr Total Imp Only
URD ANNUAL/SUPP Incr Total Value
URD Base Modifier
URD Base Total  Excludes Timber
URD Base Total Excludes Ag/Timber/OPT
URD Base Total Excludes PP and OPT
URD Base Total Excludes Timber
URD Base Total Imp Only
URD Base Total Value
URD Base by Cat
URD Increment Total Excludes Ag/Timber/OPT
URD Increment Total Excludes PP and OPT
URD Increment Total Excludes Timber
URD Increment Total Imp Only
URD Increment Total Value
URD Increment by Cat
YIELD

*/