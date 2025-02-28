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

*/

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
)