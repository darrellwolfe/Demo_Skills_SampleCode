
-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

SELECT * FROM information_schema.columns 
WHERE column_name LIKE '%Acres%';
*/

DECLARE @Year INT = 20230101;
DECLARE @LastUpdateYear VARCHAR(10) = '2023-01-01';

WITH 

CTE_Allocations AS (
SELECT
  e.lrsn
, e.ext_id
, e.extension
, e.ext_description
, a.land_line_number
, a.group_code
, impgroup.tbl_element_desc AS ImpGroup_Descr
, a.cost_value

FROM extensions AS e

JOIN allocations AS a ON a.lrsn=e.lrsn 
  AND a.extension=e.extension
  AND a.status = 'A'

JOIN codes_table AS impgroup ON impgroup.tbl_element=a.group_code
    AND impgroup.code_status='A'
    AND impgroup.tbl_type_code = 'impgroup'
    AND a.group_code NOT LIKE '81%'
    AND a.group_code NOT LIKE '99%'
    AND a.group_code NOT LIKE '98%'
    --AND a.group_code IN ('01','03','04','05')
    --AND a.group_code IN ('01','03','04','05','06','07','09')

WHERE e.status = 'A'
  AND e.eff_year = @Year
  AND e.extension LIKE 'L%'
),

CTE_LandDetails AS (
SELECT 
lh.RevObjId AS lrsn
,lh.TotalMktAcreage
,lh.TotalMktValue
,ld.LandLineNumber
,ld.LandType
,lt.land_type_desc
,ld.AppdValue
,ld.ActualFrontage
,ld.LDAcres AS Land_Detail_Acres
,ld.SoilIdent
, CASE
    WHEN lh.TotalMktAcreage < 5 THEN 'Under_5_Acres'
    WHEN lh.TotalMktAcreage >= 5 AND ld.LDAcres < 10 THEN '5-9_Acres'
    WHEN lh.TotalMktAcreage >= 10 AND ld.LDAcres < 15 THEN '10-14_Acres'
    WHEN lh.TotalMktAcreage >= 15 AND ld.LDAcres < 20 THEN '15-19_Acres'
    WHEN lh.TotalMktAcreage >= 20 AND ld.LDAcres < 50 THEN '20-49_Acres'
    WHEN lh.TotalMktAcreage >= 50 THEN '50_Plus_Acres'
    ELSE 'Review'
  END AS TotalMktAcre_Size_Groups
, CASE
    WHEN ld.LDAcres < 5 THEN 'Under_5_Acres'
    WHEN ld.LDAcres >= 5 AND ld.LDAcres < 10 THEN '5-9_Acres'
    WHEN ld.LDAcres >= 10 AND ld.LDAcres < 15 THEN '10-14_Acres'
    WHEN ld.LDAcres >= 15 AND ld.LDAcres < 20 THEN '15-19_Acres'
    WHEN ld.LDAcres >= 20 AND ld.LDAcres < 50 THEN '20-49_Acres'
    WHEN ld.LDAcres >= 50 THEN '50_Plus_Acres'
    ELSE 'Review'
  END AS LandDetailAcre_Size_Groups

--Land Header
FROM LandHeader AS lh
--AS lh ON lh.RevObjId=a.lrsn 

--Land Detail
LEFT JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND ld.PostingSource='A'
  --AND ld.LandType IN ('4','41','45','52','6','61','62','73','75','8')
  --Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

  WHERE lh.EffStatus= 'A' 
  AND lh.PostingSource='A'
  AND lh.LastUpdate > @LastUpdateYear
  
),

CTE_ImpCat AS (
SELECT
    c.tbl_type_code AS CodeType
,   CONVERT(VARCHAR(255), TRIM(c.tbl_element)) AS Imp_GroupCode_Num
,    c.tbl_element_desc AS Imp_GroupCode_Description
,    CAST(LEFT(c.tbl_element, 2) AS INT) AS StateCode#
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
    END AS Imp_Type_Key
FROM
    codes_table AS c
WHERE c.tbl_type_code = 'impgroup'
  AND c.code_status = 'A'

),

CTE_Cert AS (
  SELECT 
    lrsn,
    --Certified Values
    v.land_market_val AS CertValue_Land_NoEx,
    v.imp_val AS CertValue_Imp,
    (v.imp_val + v.land_market_val) AS CertValue_Total,
    v.eff_year AS Tax_Year,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
    AND v.status = 'A'
),

CTE_Assessed AS (
  SELECT 
    lrsn,
    --Assessed Values
    v.land_assess AS AssessedValue_Land_wEx,
    v.imp_assess AS AssessedValue_Imp,
    (v.imp_assess + v.land_assess) AS AssessedValue_Total,
    v.eff_year AS Tax_Year,
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
  FROM valuation AS v
  WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
    AND v.status = 'A'
)
  
  
  --------------------------------
  --ParcelMaster
  --------------------------------
  Select Distinct
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
, TRIM(pm.pin) AS PIN
, TRIM(pm.AIN) AS AIN

, crt.CertValue_Land_NoEx
, crt.CertValue_Imp
, crt.CertValue_Total
  --Assessed Values
, asd.AssessedValue_Land_wEx
, asd.AssessedValue_Imp
, asd.AssessedValue_Total

, cal.ext_id
, cal.extension
, cal.ext_description
, cal.land_line_number AS Allocations_LandLineNumber --<As Quality Check
, cld.LandLineNumber AS LandDetail_LandLineNumber --<As Quality Check
, impkey.Imp_Type_Key
, cal.group_code AS Imp_GroupCode
, cal.ImpGroup_Descr
, cld.LandType
, cld.land_type_desc AS LandType_Description
, cal.cost_value AS ProVal_Line_Value
, cld.AppdValue AS Appraised_Line_Value
, cld.Land_Detail_Acres
,  pm.LegalAcres
, cld.TotalMktAcre_Size_Groups
, cld.LandDetailAcre_Size_Groups
, cld.TotalMktAcreage
, cld.TotalMktValue
, cld.ActualFrontage
, cld.SoilIdent



, pm.ClassCD AS PCC_ClassCD
, TRIM(pm.PropClassDescr) AS PCC_Property_Class_Type
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
, TRIM(pm.TAG) AS TAG
--,  TRIM(pm.DisplayName)) AS Owner
, TRIM(pm.SitusAddress) AS SitusAddress
, TRIM(pm.SitusCity) AS SitusCity
, TRIM(pm.SitusState) AS SitusState
, TRIM(pm.SitusZip) AS SitusZip
, TRIM(pm.CountyNumber) AS CountyNumber
, CASE
    WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
    ELSE NULL
  END AS County_Name
,  pm.Improvement_Status -- <Improved vs Vacant



FROM TSBv_PARCELMASTER AS pm

JOIN CTE_Allocations AS cal ON cal.lrsn=pm.lrsn

JOIN CTE_ImpCat AS impkey ON impkey.Imp_GroupCode_Num=cal.group_code

JOIN CTE_LandDetails AS cld ON cld.lrsn=cal.lrsn
  AND cal.land_line_number=cld.LandLineNumber

LEFT JOIN CTE_Cert AS crt ON pm.lrsn = crt.lrsn

LEFT JOIN CTE_Assessed AS asd ON pm.lrsn = asd.lrsn

Where pm.EffStatus = 'A'
  AND pm.ClassCD NOT LIKE '060%' -- <Invalid Personal Property Parcels
  AND pm.ClassCD NOT LIKE '070%' -- <Invalid Personal Property Parcels
  AND pm.ClassCD NOT LIKE '090%' -- <Invalid Personal Property Parcels
  AND cal.land_line_number=cld.LandLineNumber
  --AND pm.lrsn = '2' --<Used to debug
  AND crt.RowNumber=1
  AND asd.RowNumber=1; -- End Query
  
  



