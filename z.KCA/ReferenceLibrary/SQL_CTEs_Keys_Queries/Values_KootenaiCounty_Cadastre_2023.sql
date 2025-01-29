/*
AsTxDBProd
GRM_Main
*/

WITH

CTE_TotalValue AS(
-- ALL PINS
Select
cv.AssessmentYear,
cv.CadRollDescr,
cv.RevObjId,
cv.ValueAmount AS [Certified_Value],
cv.ValueTypeShortDescr,
cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
WHERE cv.AssessmentYear IN ('2023')
--,'2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
AND cv.ValueTypeShortDescr = 'Total Value'

),

CTE_Exemption AS(
-- ALL PINS
Select
cv.AssessmentYear,
cv.CadRollDescr,
cv.RevObjId,
cv.ValueAmount AS [Total_Exemptions],
cv.ValueTypeShortDescr,
cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
WHERE cv.AssessmentYear IN ('2023')
--,'2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
AND cv.ValueTypeShortDescr = 'Total Exemptions'

),

CTE_NetTaxable AS(
-- ALL PINS
Select
cv.AssessmentYear,
cv.CadRollDescr,
cv.RevObjId,
cv.ValueAmount AS [NetTaxableValue],
cv.ValueTypeShortDescr,
cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
WHERE cv.AssessmentYear IN ('2023')
--,'2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
AND cv.ValueTypeShortDescr = 'Net Tax Value'


)

--End CTE start Query

Select
cv.RevObjId,
cv.PIN,
cv.AIN,
cv.TAGShortDescr,
cv.AssessmentYear,
cv.CadRollDescr,
--CTE
tv.[Certified_Value],
tv.ValueTypeShortDescr,
tv.ValueTypeDescr,
--CTE
ex.[Total_Exemptions],
ex.ValueTypeShortDescr,
ex.ValueTypeDescr,
--CTE
nt.[NetTaxableValue],
nt.ValueTypeShortDescr,
nt.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
JOIN CTE_NetTaxable AS nt ON cv.RevObjId=nt.RevObjId
JOIN CTE_Exemption AS ex ON cv.RevObjId=ex.RevObjId
JOIN CTE_TotalValue AS tv ON cv.RevObjId=tv.RevObjId


WHERE cv.AssessmentYear IN ('2023')
--,'2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
--AND cv.ValueTypeShortDescr = 'Total Value'

Order By cv.PIN;





