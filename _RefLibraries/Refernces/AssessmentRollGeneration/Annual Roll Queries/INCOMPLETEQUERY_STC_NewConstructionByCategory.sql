
Declare @TaxYear int = 2024;


Declare @NewConstruction INT = 651;
--    651 NewConstByCat New Construction
--No values, bad category

Declare @ImpOnly_NetTaxable INT = 458;
--458	Net Imp Only	Net Taxable Value Imp Only

Declare @ImpOnly_Assessed INT = 103;
--103	Imp Assessed	Improvement Assessed

Declare @AssessedByCat INT = 470;
--470	AssessedByCat	Assessed Value

Declare @ValueTypehoex INT = 305;
--    305 HOEX_Exemption Homeowner Exemption



WITH

CTE_GroupCodeKey AS (
SELECT DISTINCT
    c.tbl_type_code AS CodeType
,   CONVERT(VARCHAR(255), TRIM(c.tbl_element)) AS GroupCode_Num
,    c.tbl_element_desc AS GroupCode_Description
,    CAST(LEFT(c.tbl_element, 2) AS INT) AS StateCodeNum

,    CASE
        WHEN c.tbl_element IN (  '01', '03', '04', '05', '06', '07', '09', '10', '10H', '11', '12', '12H', '13', '14', '15', '15H', '16', '17', 
    '18', '19', '20', '20H', '21', '22', '25L', '26LH', '27L') THEN 'Land'

        WHEN c.tbl_element IN ('25', '26', '26H', '27', '30', '31H', '32', '33', '34H', '35', '36', '37H', '38', '39', '41H', '42', '43', '45', 
    '46H', '47H', '48H', '49H', '50H', '51', '51P', '55H', '56P', '56Q', '56Q2', '56Q3', '57P', '58P', '58Q', '58Q2', 
    '58Q3', '58Q4', '59P', '59Q', '59Q2', '59Q3', '59Q4', '63P', '63Q', '63Q2', '63Q3', '63Q4', '65H', '66P', '67', 
    '67L', '67P', '68P', '68Q', '68Q2', '68Q3', '68Q4', '69P', '69Q', '69Q2', '69Q3', '69Q4', '70P', '71P', '71Q', 
    '71Q2', '71Q3', '71Q4', '72P', '72Q', '72Q2', '72Q3', '72Q4', '75P') THEN 'Improvement'

        WHEN c.tbl_element IN ('81', '81L', '81P', '81L') THEN 'Exempt_Other'

        WHEN c.tbl_element IN ('94') THEN 'Exempt_Pollution'

        WHEN c.tbl_element IN ('99', '98', '99P') THEN 'NonAllocated_Error'
    ELSE 'Review_Category'
    END AS Land_Improvement

,    CASE
        WHEN CHARINDEX('99', c.tbl_element) > 0 THEN 'Non-Allocated_Error'
        WHEN CHARINDEX('98', c.tbl_element) > 0 THEN 'Non-Allocated_Error'
        WHEN CHARINDEX('01', c.tbl_element) > 0 THEN 'Ag' --Or 'Timber_Ag'
        WHEN CHARINDEX('03', c.tbl_element) > 0 THEN 'Ag'--Or 'Timber_Ag'
        WHEN CHARINDEX('04', c.tbl_element) > 0 THEN 'Ag'--Or 'Timber_Ag'
        WHEN CHARINDEX('05', c.tbl_element) > 0 THEN 'Ag'--Or 'Timber_Ag'
        WHEN CHARINDEX('06', c.tbl_element) > 0 THEN 'Timber'--Or 'Timber_Ag'
        WHEN CHARINDEX('07', c.tbl_element) > 0 THEN 'Timber'--Or 'Timber_Ag'
        WHEN CHARINDEX('08', c.tbl_element) > 0 THEN 'Reforested_Expired'--Or 'Timber_Ag'
        WHEN CHARINDEX('09', c.tbl_element) > 0 THEN 'Mineral'--Or 'Timber_Ag'
        WHEN CHARINDEX('10', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('11', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('12', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('15', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('20', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('25', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('26', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('30', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('31', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('32', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('33', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('34', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('37', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('41', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('46', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('47', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('48', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('49', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('50', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('55', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('65', c.tbl_element) > 0 THEN 'Residential'
        WHEN CHARINDEX('13', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('14', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('16', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('17', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('18', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('21', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('22', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('27', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('35', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('36', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('38', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('39', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('42', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('43', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('51', c.tbl_element) > 0 THEN 'Commercial_Industrial'
        WHEN CHARINDEX('19', c.tbl_element) > 0 THEN 'Public_Owned'
        WHEN CHARINDEX('45', c.tbl_element) > 0 THEN 'Operating_Property'
        WHEN CHARINDEX('EXEMPT', c.tbl_element_desc) > 0 THEN 'Exempt_Property'
        WHEN CHARINDEX('OPERATING', c.tbl_element_desc) > 0 THEN 'Operating_Property'
        WHEN CHARINDEX('QIE', c.tbl_element_desc) > 0 THEN 'Qualified_Improvement_Expenditure'
        WHEN CHARINDEX('P', c.tbl_element) > 0 THEN 'Business_Personal_Property'
        ELSE NULL
    END AS Type_Key

FROM
    codes_table AS c
WHERE c.tbl_type_code = 'impgroup'
  AND c.code_status = 'A'
),

CTE_Improvements_YearBuilt AS (
----------------------------------
-- View/Master Query: Always e > i > then finally mh, cb, dw
----------------------------------
Select Distinct
--Extensions Table
e.lrsn,
e.extension,
e.ext_description,
i.imp_type,
i.year_built

--Extensions always comes first
FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M','C','D')
--Conditions
WHERE e.status = 'A'
AND i.year_built = @TaxYear-1
),


CTE_HOEX AS (
SELECT DISTINCT
i.RevObjId
/*
r.AssessmentYear,
r.Descr,
l.RollLevel,
i.RevObjId,
i.PIN,
i.AIN,
i.GeoCd,
c.ClassCd,
c.ValueType,
c.ValueAmount,
c.TypeCode,
c.Group_Code,
c.FullGroupCode
*/
FROM CadRoll AS r
JOIN CadLevel AS l ON r.Id = l.CadRollId
JOIN CadInv AS i ON l.Id = i.CadLevelId

JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id

Where r.AssessmentYear = @TaxYear
    And c.TaxYear = @TaxYear
    And c.ValueType = @ValueTypehoex -- Variable
),

CTE_NewConstCatTotals AS (
SELECT DISTINCT
r.AssessmentYear,
r.Descr,
l.RollLevel,
i.RevObjId,
i.PIN,
i.AIN,
i.GeoCd,
c.ClassCd,
year_built.year_built,
c.ValueType,
c.ValueAmount,
c.TypeCode,
c.Group_Code,
c.FullGroupCode,
gc.GroupCode_Description,
gc.Land_Improvement,
gc.Type_Key,

CASE 
    WHEN hoex.RevObjId IS NOT NULL THEN 'Owner_Occupied'
    WHEN hoex.RevObjId IS NULL THEN 'Not_Owner_Occupied'
    ELSE 'Review'
END AS 'Hoex_Check',

c.GroupCodeSysType,
c.ChgReasonShortDescr,
c.ChgReasonDesc


FROM CadRoll AS r
JOIN CadLevel AS l ON r.Id = l.CadRollId
JOIN CadInv AS i ON l.Id = i.CadLevelId

JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id

JOIN CTE_Improvements_YearBuilt AS year_built
    ON year_built.lrsn = i.RevObjId

LEFT JOIN CTE_GroupCodeKey AS gc
    On c.FullGroupCode = gc.GroupCode_Num

LEFT JOIN CTE_HOEX AS hoex
    On hoex.RevObjId = i.RevObjId

Where r.AssessmentYear = @TaxYear
    And c.TaxYear = @TaxYear
    And c.ValueType = @AssessedByCat -- Variable

    And gc.Land_Improvement = 'Improvement'
    --And gc.Type_Key = 'Residential'
)

Select 
SUM(ValueAmount) AS AssessedValues
--,Land_Improvement,Type_Key,Hoex_Check

From CTE_NewConstCatTotals

--Group by Land_Improvement,Type_Key,Hoex_Check