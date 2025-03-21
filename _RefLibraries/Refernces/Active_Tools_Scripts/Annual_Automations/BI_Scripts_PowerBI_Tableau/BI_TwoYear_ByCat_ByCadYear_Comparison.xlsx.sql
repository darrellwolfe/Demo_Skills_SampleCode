
DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;

--Change this to choose which day in January the program begins reading rolled over assets.
-- This checks if today's date is after January 15 of the current year
IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

    SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
    SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year

-- DECLARE @Year INT = 2024; -- Input year
--Declare @Year int = 2024; -- Input THIS year here

Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrev2 int = @Year - 2; -- Input the year here
Declare @YearPrev3 int = @Year - 3; -- Input the year here
Declare @YearPrev4 int = @Year - 4; -- Input the year here
Declare @YearPrev5 int = @Year - 5; -- Input the year here


Declare @EffYear0101Current varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous varchar(8) = Cast(@YearPrev as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous2 varchar(8) = Cast(@YearPrev2 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous3 varchar(8) = Cast(@YearPrev3 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous4 varchar(8) = Cast(@YearPrev4 as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @EffYear0101Previous5 varchar(8) = Cast(@YearPrev5 as varchar) + '0101'; -- Generates '20230101' for the previous year


Declare @ValEffDateCurrent date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @ValEffDatePrevious date = CAST(CAST(@YearPrev as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious2 date = CAST(CAST(@YearPrev2 as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious3 date = CAST(CAST(@YearPrev3 as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious4 date = CAST(CAST(@YearPrev4 as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year
Declare @ValEffDatePrevious5 date = CAST(CAST(@YearPrev5 as varchar) + '-01-01' AS DATE); -- Generates '2022-01-01' for the previous year


Declare @EffYearLike varchar(8) = Cast(@Year as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious varchar(8) = Cast(@YearPrev as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious2 varchar(8) = Cast(@YearPrev2 as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious3 varchar(8) = Cast(@YearPrev3 as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious4 varchar(8) = Cast(@YearPrev4 as varchar) + '%'; -- Generates '2023%' for the previous year
Declare @EffYearLikePrevious5 varchar(8) = Cast(@YearPrev5 as varchar) + '%'; -- Generates '2023%' for the previous year

Declare @ValueTypehoex INT = 305;
--    305 HOEX_Exemption Homeowner Exemption
Declare @ValueTypeimp INT = 103;
--    103 Imp Assessed Improvement Assessed
Declare @ValueTypeland INT = 102;
--    102 Land Assessed Land Assessed
Declare @ValueTypetotal INT = 109;
--    109 Total Value Total Value
Declare @NetTaxableValueImpOnly INT = 458;
--    458 Net Imp Only Net Taxable Value Imp Only
Declare @NetTaxableValueTotal INT = 455;
--    455 Net Tax Value Net Taxable Value
Declare @NewConstruction INT = 651;
--    651 NewConstByCat New Construction
Declare @AssessedByCat INT = 470;
--470 AssessedByCat Assessed Value

WITH 

CTE_AssessedByCat_Current AS (
SELECT DISTINCT
i.RevObjId AS lrsn
,TRIM(i.PIN) AS PIN
,TRIM(i.AIN ) AS AIN
,r.AssessmentYear

,TRIM(c.FullGroupCode) AS FullGroupCode

,SUM(c.ValueAmount) AS Cadaster_Value
/*
,c.ValueAmount  AS Cadaster_Value
--,TRIM(i.PIN) AS PIN
--,TRIM(i.AIN ) AS AIN
,c.TypeCode AS CadasterValyeType
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,i.ValEffDate
,c.TypeCode
,c.Group_Code
,c.FullGroupCode
,ROW_NUMBER() OVER (PARTITION BY i.RevObjId ORDER BY i.ValEffDate DESC) AS RowNum
*/

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @AssessedByCat -- Variable
/*
Declare @ValueTypeimp INT = 103;
--    103 Imp Assessed Improvement Assessed
Declare @ValueTypeland INT = 102;
--    102 Land Assessed Land Assessed
Declare @ValueTypetotal INT = 109;
--    109 Total Value Total Value
*/
WHERE r.AssessmentYear IN (@Year)
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
--And CAST(i.ValEffDate AS DATE) = @EffYear0101Previous
--And c.FullGroupCode NOT LIKE '81%'
--Group By i.RevObjId, c.FullGroupCode
--Group By r.AssessmentYear, c.FullGroupCode
Group By i.RevObjId, i.PIN, i.AIN, r.AssessmentYear, c.FullGroupCode

),

CTE_AssessedByCat_Previous AS (

SELECT DISTINCT
i.RevObjId AS lrsn
,TRIM(i.PIN) AS PIN
,TRIM(i.AIN ) AS AIN
,r.AssessmentYear

,TRIM(c.FullGroupCode) AS FullGroupCode

,SUM(c.ValueAmount) AS Cadaster_Value
/*
,c.ValueAmount  AS Cadaster_Value

,c.TypeCode AS CadasterValyeType
--sum(ValueAmount) 
,r.AssessmentYear
,r.Descr AS AssessmentType
,c.ChgReasonDesc
,i.ValEffDate
,c.TypeCode
,c.Group_Code
,c.FullGroupCode
,ROW_NUMBER() OVER (PARTITION BY i.RevObjId ORDER BY i.ValEffDate DESC) AS RowNum
*/

FROM CadRoll r
JOIN CadLevel l ON r.Id = l.CadRollId
JOIN CadInv i ON l.Id = i.CadLevelId
JOIN tsbv_cadastre AS c 
  On c.CadRollId = r.Id
  And c.CadInvId = i.Id
  And c.ValueType = @AssessedByCat -- Variable
/*
Declare @ValueTypeimp INT = 103;
--    103 Imp Assessed Improvement Assessed
Declare @ValueTypeland INT = 102;
--    102 Land Assessed Land Assessed
Declare @ValueTypetotal INT = 109;
--    109 Total Value Total Value
*/
WHERE r.AssessmentYear IN (@YearPrev)
--And CAST(i.ValEffDate AS DATE) = '2023-01-01'
--And CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
And CAST(i.ValEffDate AS DATE) = @EffYear0101Previous
--And c.FullGroupCode NOT LIKE '81%'
--Group By i.RevObjId, c.FullGroupCode
--Group By r.AssessmentYear, c.FullGroupCode
Group By i.RevObjId, i.PIN, i.AIN, r.AssessmentYear, c.FullGroupCode

),


CTE_AllocationsGroupCodeKey AS (
SELECT 
c.tbl_type_code AS CodeType
,TRIM(c.tbl_element) AS GroupCode_KC
,LEFT(TRIM(c.tbl_element),2) AS GroupCode_STC
,TRIM(c.tbl_element_desc) AS CodeDescription
,CASE 
    WHEN TRIM(c.tbl_element_desc) LIKE '%EXEMPT%' THEN 'Exempt_Property'
    WHEN TRIM(c.tbl_element_desc) LIKE '%OPERATING%' THEN 'Operating_Property'
    WHEN TRIM(c.tbl_element_desc) LIKE '%QIE%' THEN 'Qualified_Improvement_Expenditure'
    WHEN TRIM(c.tbl_element) LIKE '%P%' THEN 'Business_Personal_Property'
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('98','99') THEN 'Non-Allocated_Error'
    
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('25','26','27') THEN 'Condos'
    --WHEN LEFT(TRIM(c.tbl_element),2) IN ('25') THEN 'Common_Area'
    --WHEN LEFT(TRIM(c.tbl_element),2) IN ('26') THEN 'Condo_Residential'
    --WHEN LEFT(TRIM(c.tbl_element),2) IN ('27') THEN 'Condo_Commercial'
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('81') THEN 'Exempt_Property'
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('19') THEN 'RightOfWay_ROW_Cat19'

    WHEN LEFT(TRIM(c.tbl_element),2) IN ('49','50','51') THEN 'Imp_On_LeasedLand'
  
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('45') THEN 'Operating_Property'
    
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('12','15','20','34','37','41') THEN 'Residential'

    WHEN LEFT(TRIM(c.tbl_element),2) IN ('30','31','32') THEN 'Non-Res'

    WHEN LEFT(TRIM(c.tbl_element),2) IN ('13','16','21','35','38','42'
                        ,'14','17','22','36','39','43') THEN 'Commercial_Industrial'
    --WHEN LEFT(TRIM(c.tbl_element),2) IN ('13','16','21','35','38','42') THEN 'Commercial'
    --WHEN LEFT(TRIM(c.tbl_element),2) IN ('14','17','22','36','39','43') THEN 'Industrial'
    
    WHEN LEFT(TRIM(c.tbl_element),2) IN ('46','47','48','55','65') THEN 'Mobile_Home'

    WHEN LEFT(TRIM(c.tbl_element),2) IN ('01','03','04','05','06'
            ,'07','08','09','10','11','33') THEN 'Timber_Ag'

    ELSE 'Other'
  END AS Category

,CASE
  --Improvement Group Codes
  WHEN TRIM(c.tbl_element) IN (
      '25', '26', '26H', '27', '30', '31H', '32', '33', '34H', '35', '36', '37H', '38', '39', '41H', '42', '43', '45', 
      '46H', '47H', '48H', '49H', '50H', '51', '51P', '55H', '56P', '56Q', '56Q2', '56Q3', '57P', '58P', '58Q', '58Q2', 
      '58Q3', '58Q4', '59P', '59Q', '59Q2', '59Q3', '59Q4', '63P', '63Q', '63Q2', '63Q3', '63Q4', '65H', '66P', '67', 
      '67L', '67P', '68P', '68Q', '68Q2', '68Q3', '68Q4', '69P', '69Q', '69Q2', '69Q3', '69Q4', '70P', '71P', '71Q', 
      '71Q2', '71Q3', '71Q4', '72P', '72Q', '72Q2', '72Q3', '72Q4', '75P', '81', '81P')
      THEN 'GC_Improvement'
      --
  -- Land Group Codes
  WHEN TRIM(c.tbl_element) IN (
      '01', '03', '04', '05', '06', '07', '09', '10', '10H', '11', '12', '12H', '13', '14', '15', '15H', '16', '17', 
      '18', '19', '20', '20H', '21', '22', '25L', '26LH', '27L', '81L')
      THEN 'GC_Land'
  --Land_GroupCode
  ELSE 'OtherCode'
  END AS CodeClass

FROM codes_table AS c
WHERE c.tbl_type_code = 'impgroup'
--AND c.code_status = 'A' 
--AND c.tbl_element_desc LIKE '%condo%'
--ORDER BY c.tbl_element_desc;
),

CTE_Districts AS (
--------------------------------
--GEO Counts, GEO Names for Market Adjustments
--------------------------------
Select Distinct
  CASE
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
        WHEN pm.neighborhood = 0 THEN 'PP_N/A_or_Error'
        ELSE NULL
    END AS District
--GEO Information
,pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,pm.lrsn
From TSBv_PARCELMASTER AS pm
)

--,CTE_Final AS (
Select 
'28' AS KootenaiCounty
,d.District
,d.GEO
,d.GEO_Name
,c.lrsn
,c.PIN
,c.AIN
,c.FullGroupCode AS FullGroupCodeCurrent
,k.CodeDescription
,k.Category
,k.CodeClass
---2024
,c.AssessmentYear AS AssessmentYearCurrent
,c.Cadaster_Value AS CurrentYearValue
--2023
,p.AssessmentYear AS AssessmentYearPrevious
,p.Cadaster_Value AS PastYearValue

--2024 / 2023
,(c.Cadaster_Value - p.Cadaster_Value) AS ValueChange
,(Cast(c.Cadaster_Value AS Decimal(18,2)) / NULLIF(Cast(p.Cadaster_Value AS Decimal(18,2)), 0)) AS PerfOfChange


From CTE_AssessedByCat_Current AS c

Full Outer Join CTE_AssessedByCat_Previous AS p
  On c.lrsn = p.lrsn
  And c.FullGroupCode = p.FullGroupCode

Left Join CTE_AllocationsGroupCodeKey AS k
  On k.GroupCode_KC = c.FullGroupCode

Left Join CTE_Districts AS d
  On c.lrsn = d.lrsn

Order by d.District, d.GEO, c.PIN;