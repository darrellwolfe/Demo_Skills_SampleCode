-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/


DECLARE @Year INT = 2023;

WITH

CTE_CadasterViewer AS (
--------------------------------
--CadViewer AND cv.ValueTypeShortDescr = 'AssessedByCat'
--------------------------------
Select Distinct
cv.AssessmentYear,
--CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate],
cv.CadRollDescr,
cv.RevObjId AS lrsn,
--cv.PIN,
--cv.AIN,
--cv.TAGShortDescr,
cv.ValueAmount AS NetTaxValue
--cv.AddlAttribute AS GroupCodeDescr,
--LTRIM(RTRIM(LEFT (cv.AddlAttribute,3))) AS [GroupCode]
--cv.SecondaryAttribute,
--cv.ValueTypeShortDescr,
--cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId

--WHERE cv.AssessmentYear BETWEEN @YearMinusTen AND @Year
WHERE cv.AssessmentYear = @Year
--WHERE cv.AssessmentYear BETWEEN 2013 AND 2023
--AND cv.ValueTypeShortDescr = 'AssessedByCat'
AND cv.ValueTypeShortDescr = 'Net Tax Value'

),

CTE_HOEX_Amount AS (
--------------------------------
--CadViewer AND cv.ValueTypeShortDescr = 'AssessedByCat'
--------------------------------
Select
cv.AssessmentYear,
CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate],
cv.CadRollDescr,
cv.RevObjId,
cv.PIN,
cv.AIN,
cv.TAGShortDescr,
cv.ValueAmount,
cv.AddlAttribute,
LTRIM(RTRIM(LEFT (cv.AddlAttribute,3))) AS [GroupCode],
cv.SecondaryAttribute,
cv.ValueTypeShortDescr,
cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId

WHERE cv.AssessmentYear IN ('2023')
AND cv.ValueTypeShortDescr = 'HOEX_Exemption'
--AND cv.ValueTypeShortDescr = 'AssessedByCat'
--Order By cv.PIN ;

/*
HOEX_CapOverride
HOEX_Cap
HOEligibleByCat
HOEX_EligibleVal
HOEX_Exemption
HOEX_ByCat
HOEX_ImpOnly
HOEX_CapManual
HOEX_Percent
*/
),

Select 

From 



Select Distinct
ccv.AssessmentYear

From CTE_CadasterViewer AS ccv

Join CTE_AllocationsGroupCodeKey AS agck
  On agck.GroupCode_KC = ccv.GroupCode

GROUP BY
ccv.AssessmentYear
,agck.Category







--Darrell Wolfe 05/07/2024