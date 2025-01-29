-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/


DECLARE @Year INT = 2023;

DECLARE @YearMinusTen INT = @Year - 10;

WITH

CTE_CadasterViewer AS (
--------------------------------
--CadViewer AND cv.ValueTypeShortDescr = 'AssessedByCat'
--------------------------------
Select Distinct
cv.AssessmentYear,
--CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate],
cv.CadRollDescr,
--cv.RevObjId AS lrsn,
--cv.PIN,
--cv.AIN,
--cv.TAGShortDescr,
SUM(cv.ValueAmount) AS AssessedValueByCat,
cv.AddlAttribute AS GroupCodeDescr,
LTRIM(RTRIM(LEFT (cv.AddlAttribute,3))) AS [GroupCode]
--cv.SecondaryAttribute,
--cv.ValueTypeShortDescr,
--cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId

--WHERE cv.AssessmentYear BETWEEN @YearMinusTen AND @Year
WHERE cv.AssessmentYear = @Year
--WHERE cv.AssessmentYear BETWEEN 2013 AND 2023
AND cv.ValueTypeShortDescr = 'AssessedByCat'

GROUP BY
cv.AssessmentYear,
cv.CadRollDescr,
cv.AddlAttribute
),

CTE_AllocationsGroupCodeKey AS (
SELECT 
c.tbl_type_code AS CodeType
,c.tbl_element AS GroupCode_KC
,c.tbl_element_desc AS CodeDescription
,CASE 
    WHEN c.tbl_element_desc LIKE '%EXEMPT%' THEN 'Exempt_Property'
    WHEN c.tbl_element_desc LIKE '%OPERATING%' THEN 'Operating_Property'
    WHEN c.tbl_element_desc LIKE '%QIE%' THEN 'Qualified_Improvement_Expenditure'
    WHEN c.tbl_element LIKE '%P%' THEN 'Business_Personal_Property'
    WHEN LEFT(c.tbl_element,2) IN ('98','99') THEN 'Non-Allocated_Error'
    WHEN LEFT(c.tbl_element,2) IN ('25') THEN 'Common_Area'
    WHEN LEFT(c.tbl_element,2) IN ('81') THEN 'Exempt_Property'
    WHEN LEFT(c.tbl_element,2) IN ('19') THEN 'RightOfWay_ROW_Cat19'
    WHEN LEFT(c.tbl_element,2) IN ('45') THEN 'Operating_Property'
    
    WHEN LEFT(c.tbl_element,2) IN ('01','03','04','05','06','07','08','09','10','11','31','32','33') THEN 'Timber_Ag'
    WHEN LEFT(c.tbl_element,2) IN ('12','15','20','26','30','32','34','37','41') THEN 'Residential'
    WHEN LEFT(c.tbl_element,2) IN ('13','16','21','27','35','38','42') THEN 'Commercial'
    WHEN LEFT(c.tbl_element,2) IN ('14','17','22','36','39','43') THEN 'Industrial'
    WHEN LEFT(c.tbl_element,2) IN ('49','50','51') THEN 'Leased_Land'
    WHEN LEFT(c.tbl_element,2) IN ('46','47','48','55','65') THEN 'Mobile_Home'
    ELSE 'Other'
  END AS Category

FROM codes_table AS c
WHERE c.code_status = 'A' 
AND c.tbl_type_code = 'impgroup'
--ORDER BY c.tbl_element_desc;
)

Select Distinct
ccv.AssessmentYear
,ccv.CadRollDescr
,ccv.AssessedValueByCat
,ccv.GroupCodeDescr
,ccv.GroupCode
,agck.Category

From CTE_CadasterViewer AS ccv

Join CTE_AllocationsGroupCodeKey AS agck
  On agck.GroupCode_KC = ccv.GroupCode









--Darrell Wolfe 05/07/2024