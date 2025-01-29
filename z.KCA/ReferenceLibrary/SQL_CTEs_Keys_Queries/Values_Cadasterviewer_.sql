





-- !preview conn=conn


/*
AsTxDBProd
GRM_Main
*/

Declare @Year int = 2024; -- Input THIS year here

Declare @YearPrev int = @Year - 1; -- Input the year here

Declare @NCYear varchar(4) = 'NC' + Right(Cast(@Year as varchar), 2); -- This will create 'NC24'

Declare @NCYearPrevious varchar(4) = 'NC' + Right(Cast(@YearPrev as varchar), 2); -- This will create 'NC23'

Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year

Declare @EffYear0101PreviousLike varchar(8) = Cast(@YearPrev as varchar) + '%'; -- Generates '20230101' for the previous year


WITH

CTE_Cadasterviewer AS (
--------------------------------
--CadViewer AND cv.ValueTypeShortDescr = 'AssessedByCat'
--------------------------------
Select Distinct
cv.AssessmentYear
--,CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate]
,cv.CadRollDescr
,cv.RevObjId AS lrsn
--,cv.PIN
,cv.AIN
--,cv.TAGShortDescr
,cv.ValueAmount

--,cv.AddlAttribute
--,TRIM(LEFT (cv.AddlAttribute,3)) AS [Whatever]
--,cv.SecondaryAttribute
,cv.ValueTypeShortDescr
,cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId

--WHERE cv.AssessmentYear IN (@Year, @YearPrev)
--WHERE cv.AssessmentYear IN (@YearPrev)
WHERE cv.AssessmentYear IN (@Year)

--AND cv.ValueTypeShortDescr = 'AssessedByCat'
AND cv.ValueTypeShortDescr = 'HOEX_Exemption'
/*
ValueTypeShortDescr ValueTypeDescr
HOEX_Percent Homeowner Percent
HOEX_Cap Homeowner Cap
HOEX_CapOverride Homeowner Calculated Cap Override
HOEX_CapManual Homeowner Manual Cap Override
HOEX_EligibleVal Homeowner Eligible Value
HOEX_Exemption Homeowner Exemption
HOEX_ByCat Homeowner Exemption
HOEX_ImpOnly Homeowner Exemption Imp Only
*/
)


Select *
From CTE_Cadasterviewer

































/*


Select Distinct
cv.RevObjId AS [LRSN],
ValueTypeShortDescr,
ValueTypeDescr,
cv.FormattedValueAmount

FROM CadValueTypeAmount_V AS cv
  WHERE cv.AssessmentYear IN ('2023')
  AND cv.RevObjId = '520603'

Group By
cv.RevObjId,
ValueTypeShortDescr,
ValueTypeDescr,
cv.FormattedValueAmount
;


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


ValueTypeShortDescr ValueTypeDescr
HOEX_Percent Homeowner Percent
HOEX_Cap Homeowner Cap
HOEX_CapOverride Homeowner Calculated Cap Override
HOEX_CapManual Homeowner Manual Cap Override
HOEX_EligibleVal Homeowner Eligible Value
HOEX_Exemption Homeowner Exemption
HOEX_ByCat Homeowner Exemption
HOEX_ImpOnly Homeowner Exemption Imp Only

*/