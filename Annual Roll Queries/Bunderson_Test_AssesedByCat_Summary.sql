-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

SELECT * FROM information_schema.columns 
WHERE table_name LIKE 'TIF%';

--Find a table with a Column Name like...
SELECT * FROM information_schema.columns 
WHERE column_name LIKE 'TaxCalcDetail%';
*/




-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

SELECT * FROM information_schema.columns 
WHERE table_name LIKE 'TIF%';

--Find a table with a Column Name like...
SELECT * FROM information_schema.columns 
WHERE column_name LIKE 'TaxCalcDetail%';

CTE_ParcelMasterData AS (
SELECT DISTINCT
  pm.lrsn,
  TRIM(pm.pin) AS PIN,
  TRIM(pm.AIN) AS AIN,
  pm.neighborhood AS GEO,
  TRIM(pm.NeighborHoodName) AS GEO_Name,
  TRIM(pm.PropClassDescr) AS PCC_ClassCD,
  TRIM(pm.SitusAddress) AS SitusAddress,
  TRIM(pm.SitusCity) AS SitusCity,
  pm.LegalAcres,
  pm.Improvement_Status,
  pm.WorkValue_Land,
  pm.WorkValue_Impv,
  pm.WorkValue_Total
  
  FROM TSBv_PARCELMASTER AS pm
  WHERE pm.EffStatus = 'A'
  
  ),

*/


WITH

CTE_ParcelMasterData AS (
SELECT DISTINCT
  pm.lrsn
, CASE
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
, pm.neighborhood AS GEO
, TRIM(pm.NeighborHoodName) AS GEO_Name
,  TRIM(pm.pin) AS PIN
,  TRIM(pm.AIN) AS AIN
, pm.ClassCD
, TRIM(pm.PropClassDescr) AS Property_Class_Type
, CASE 
    WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
    WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416', '421', '435', '438', '442', '451', '527','461') THEN 'Commercial_Industrial'
    WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '546', '548', '549', '550', '555', '565','526','561') THEN 'Residential'
    WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
    WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'
    WHEN pm.ClassCD = '667' THEN 'Operating_Property'
    WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
    WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'
    ELSE 'Unasigned_or_OldInactiveParcel'
  END AS Property_Type_Class

  FROM TSBv_PARCELMASTER AS pm
  WHERE pm.EffStatus = 'A'
  
  ),

CTE_ImpKey AS (

SELECT
    c.tbl_type_code AS CodeType
,   CONVERT(VARCHAR(255), TRIM(c.tbl_element)) AS Imp_GroupCode_Num
,    c.tbl_element_desc AS Imp_GroupCode_Description
,    CAST(LEFT(c.tbl_element, 2) AS INT) AS StateCodeNum
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

CTE_HOEX AS (
--------------------------------
--CadViewer AND cv.ValueTypeShortDescr = 'AssessedByCat'
--------------------------------
Select
cv.AssessmentYear,
CONCAT ('01/01/',cv.AssessmentYear) AS AssessmentDate,
--cv.CadRollDescr,
--cv.TAGShortDescr,
cv.AddlAttribute,
TRIM(LEFT (cv.AddlAttribute,3)) AS [GroupCode_KC],
TRIM(LEFT (cv.AddlAttribute,2)) AS [GroupCode_State],
--cv.SecondaryAttribute,
--cv.ValueTypeShortDescr,
--cv.ValueTypeDescr
--COUNT(cv.RevObjId) AS PIN_COUNT,
--cv.PIN,
--cv.AIN,
SUM(cv.ValueAmount) AS Total_HOEX_Value

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId

WHERE cv.AssessmentYear IN ('2023')
AND cv.ValueTypeShortDescr = 'AssessedByCat'
--Order By cv.PIN ;

--AND cv.ValueTypeShortDescr = 'Net Tax Value'
--Order By cv.PIN ;

Group By
cv.AssessmentYear,
cv.AddlAttribute
),


CTE_CadValues AS (
--------------------------------
--CadViewer AND cv.ValueTypeShortDescr = 'AssessedByCat'
--------------------------------
Select
cv.AssessmentYear,
CONCAT ('01/01/',cv.AssessmentYear) AS AssessmentDate,
--cv.CadRollDescr,
--cv.TAGShortDescr,
cv.AddlAttribute,
TRIM(LEFT (cv.AddlAttribute,3)) AS [GroupCode_KC],
TRIM(LEFT (cv.AddlAttribute,2)) AS [GroupCode_State],
--cv.SecondaryAttribute,
--cv.ValueTypeShortDescr,
--cv.ValueTypeDescr
COUNT(cv.RevObjId) AS PIN_COUNT,
--cv.PIN,
--cv.AIN,
SUM(cv.ValueAmount) AS Total_Value

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId

WHERE cv.AssessmentYear IN ('2023')
AND cv.ValueTypeShortDescr = 'AssessedByCat'
--Order By cv.PIN ;

--AND cv.ValueTypeShortDescr = 'Net Tax Value'
--Order By cv.PIN ;

Group By
cv.AssessmentYear,
cv.AddlAttribute
)

SELECT DISTINCT
CASE
  WHEN cval.Total_Value BETWEEN 1 AND 25000 THEN 1
  WHEN cval.Total_Value BETWEEN 25001 AND 50000 THEN 2
  WHEN cval.Total_Value BETWEEN 50001 AND 75000 THEN 3
  WHEN cval.Total_Value BETWEEN 75001 AND 100000 THEN 4
  WHEN cval.Total_Value BETWEEN 100001 AND 125000 THEN 5
  WHEN cval.Total_Value BETWEEN 125001 AND 150000 THEN 6
  WHEN cval.Total_Value BETWEEN 150001 AND 175000 THEN 7
  WHEN cval.Total_Value BETWEEN 175001 AND 200000 THEN 8
  WHEN cval.Total_Value BETWEEN 200001 AND 225000 THEN 9
  WHEN cval.Total_Value BETWEEN 225001 AND 250000 THEN 10
  WHEN cval.Total_Value BETWEEN 250001 AND 275000 THEN 11
  WHEN cval.Total_Value BETWEEN 275001 AND 300000 THEN 12
  WHEN cval.Total_Value BETWEEN 300001 AND 325000 THEN 13
  WHEN cval.Total_Value BETWEEN 325001 AND 350000 THEN 14
  WHEN cval.Total_Value BETWEEN 400001 AND 425000 THEN 17
  WHEN cval.Total_Value BETWEEN 500001 AND 525000 THEN 21
  ELSE NULL -- This handles values outside of defined ranges
END AS BracketCategory,
ik.Type_Key,
cval.AssessmentYear,
cval.AssessmentDate,
cval.AddlAttribute,
cval.GroupCode_KC,
cval.GroupCode_State,
cval.PIN_COUNT,
cval.Total_Value,
hoex.Total_HOEX_Value

FROM CTE_CadValues AS cval
LEFT JOIN CTE_HOEX AS hoex ON cval.GroupCode_State = hoex.GroupCode_State


LEFT JOIN CTE_ImpKey AS ik ON cval.GroupCode_State = ik.StateCodeNum


