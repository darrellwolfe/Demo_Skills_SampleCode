DECLARE @Year INT = 2024;
DECLARE @YearPrev INT = @Year - 1;
DECLARE @YearPrev2 INT = @Year - 2;
DECLARE @YearPrev3 INT = @Year - 3;
DECLARE @YearPrev4 INT = @Year - 4;
DECLARE @YearPrev5 INT = @Year - 5;

DECLARE @EffYear0101Current VARCHAR(8) = CAST(@Year AS VARCHAR) + '0101';
DECLARE @EffYear0101Previous VARCHAR(8) = CAST(@YearPrev AS VARCHAR) + '0101';
DECLARE @EffYear0101Previous2 VARCHAR(8) = CAST(@YearPrev2 AS VARCHAR) + '0101';
DECLARE @EffYear0101Previous3 VARCHAR(8) = CAST(@YearPrev3 AS VARCHAR) + '0101';
DECLARE @EffYear0101Previous4 VARCHAR(8) = CAST(@YearPrev4 AS VARCHAR) + '0101';
DECLARE @EffYear0101Previous5 VARCHAR(8) = CAST(@YearPrev5 AS VARCHAR) + '0101';

DECLARE @ValEffDateCurrent DATE = CAST(CAST(@Year AS VARCHAR) + '-01-01' AS DATE);
DECLARE @ValEffDatePrevious DATE = CAST(CAST(@YearPrev AS VARCHAR) + '-01-01' AS DATE);
DECLARE @ValEffDatePrevious2 DATE = CAST(CAST(@YearPrev2 AS VARCHAR) + '-01-01' AS DATE);
DECLARE @ValEffDatePrevious3 DATE = CAST(CAST(@YearPrev3 AS VARCHAR) + '-01-01' AS DATE);
DECLARE @ValEffDatePrevious4 DATE = CAST(CAST(@YearPrev4 AS VARCHAR) + '-01-01' AS DATE);
DECLARE @ValEffDatePrevious5 DATE = CAST(CAST(@YearPrev5 AS VARCHAR) + '-01-01' AS DATE);

DECLARE @EffYearLike VARCHAR(8) = CAST(@Year AS VARCHAR) + '%';
DECLARE @EffYearLikePrevious VARCHAR(8) = CAST(@YearPrev AS VARCHAR) + '%';
DECLARE @EffYearLikePrevious2 VARCHAR(8) = CAST(@YearPrev2 AS VARCHAR) + '%';
DECLARE @EffYearLikePrevious3 VARCHAR(8) = CAST(@YearPrev3 AS VARCHAR) + '%';
DECLARE @EffYearLikePrevious4 VARCHAR(8) = CAST(@YearPrev4 AS VARCHAR) + '%';
DECLARE @EffYearLikePrevious5 VARCHAR(8) = CAST(@YearPrev5 AS VARCHAR) + '%';

DECLARE @ValueTypehoex INT = 305;
DECLARE @ValueTypeimp INT = 103;
DECLARE @ValueTypeland INT = 102;
DECLARE @ValueTypetotal INT = 109;
DECLARE @NetTaxableValueImpOnly INT = 458;
DECLARE @NetTaxableValueTotal INT = 455;
DECLARE @NewConstruction INT = 651;
DECLARE @AssessedByCat INT = 470;

WITH CTE_AssessedByCat_Current AS (
    SELECT DISTINCT
        i.RevObjId AS lrsn,
        TRIM(i.PIN) AS PIN,
        TRIM(i.AIN) AS AIN,
        r.AssessmentYear,
        TRIM(c.FullGroupCode) AS FullGroupCode,
        SUM(c.ValueAmount) AS Cadaster_Value
    FROM CadRoll r
    JOIN CadLevel l ON r.Id = l.CadRollId
    JOIN CadInv i ON l.Id = i.CadLevelId
    JOIN tsbv_cadastre AS c ON c.CadRollId = r.Id AND c.CadInvId = i.Id AND c.ValueType = @AssessedByCat
    WHERE r.AssessmentYear = @Year
        AND CAST(i.ValEffDate AS DATE) = @ValEffDateCurrent
    GROUP BY i.RevObjId, i.PIN, i.AIN, r.AssessmentYear, c.FullGroupCode
),
CTE_AssessedByCat_Previous AS (
    SELECT DISTINCT
        i.RevObjId AS lrsn,
        TRIM(i.PIN) AS PIN,
        TRIM(i.AIN) AS AIN,
        r.AssessmentYear,
        TRIM(c.FullGroupCode) AS FullGroupCode,
        SUM(c.ValueAmount) AS Cadaster_Value
    FROM CadRoll r
    JOIN CadLevel l ON r.Id = l.CadRollId
    JOIN CadInv i ON l.Id = i.CadLevelId
    JOIN tsbv_cadastre AS c ON c.CadRollId = r.Id AND c.CadInvId = i.Id AND c.ValueType = @AssessedByCat
    WHERE r.AssessmentYear = @YearPrev
        AND CAST(i.ValEffDate AS DATE) = @EffYear0101Previous
    GROUP BY i.RevObjId, i.PIN, i.AIN, r.AssessmentYear, c.FullGroupCode
),
CTE_AllocationsGroupCodeKey AS (
    SELECT
        c.tbl_type_code AS CodeType,
        TRIM(c.tbl_element) AS GroupCode_KC,
        LEFT(TRIM(c.tbl_element), 2) AS GroupCode_STC,
        TRIM(c.tbl_element_desc) AS CodeDescription,
        CASE
            WHEN TRIM(c.tbl_element_desc) LIKE '%EXEMPT%' THEN 'Exempt_Property'
            WHEN TRIM(c.tbl_element_desc) LIKE '%OPERATING%' THEN 'Operating_Property'
            WHEN TRIM(c.tbl_element_desc) LIKE '%QIE%' THEN 'Qualified_Improvement_Expenditure'
            WHEN TRIM(c.tbl_element) LIKE '%P%' THEN 'Business_Personal_Property'
            WHEN LEFT(TRIM(c.tbl_element), 2) IN ('98', '99') THEN 'Non-Allocated_Error'
            WHEN LEFT(TRIM(c.tbl_element), 2) IN ('25', '26', '27') THEN 'Condos'
            WHEN LEFT(TRIM(c.tbl_element), 2) IN ('81') THEN 'Exempt_Property'
            WHEN LEFT(TRIM(c.tbl_element), 2) IN ('19') THEN 'RightOfWay_ROW_Cat19'
            WHEN LEFT(TRIM(c.tbl_element), 2) IN ('49', '50', '51') THEN 'Imp_On_LeasedLand'
            WHEN LEFT(TRIM(c.tbl_element), 2) IN ('45') THEN 'Operating_Property'
            WHEN LEFT(TRIM(c.tbl_element), 2) IN ('12', '15', '20', '34', '37', '41') THEN 'Residential'
            WHEN LEFT(TRIM(c.tbl_element), 2) IN ('30', '31', '32') THEN 'Non-Res'
            WHEN LEFT(TRIM(c.tbl_element), 2) IN ('13', '16', '21', '35', '38', '42', '14', '17', '22', '36', '39', '43') THEN 'Commercial_Industrial'
            WHEN LEFT(TRIM(c.tbl_element), 2) IN ('46', '47', '48', '55', '65') THEN 'Mobile_Home'
            WHEN LEFT(TRIM(c.tbl_element), 2) IN ('01', '03', '04', '05', '06', '07', '08', '09', '10', '11', '33') THEN 'Timber_Ag'
            ELSE 'Other'
        END AS Category,
        CASE
            WHEN TRIM(c.tbl_element) IN ('25', '26', '26H', '27', '30', '31H', '32', '33', '34H', '35', '36', '37H', '38', '39', '41H', '42', '43', '45', '46H', '47H', '48H', '49H', '50H', '51', '51P', '55H', '56P', '56Q', '56Q2', '56Q3', '57P', '58P', '58Q', '58Q2', '58Q3', '58Q4', '59P', '59Q', '59Q2', '59Q3', '59Q4', '63P', '63Q', '63Q2', '63Q3', '63Q4', '65H', '66P', '67', '67L', '67P', '68P', '68Q', '68Q2', '68Q3', '68Q4', '69P', '69Q', '69Q2', '69Q3', '69Q4', '70P', '71P', '71Q', '71Q2', '71Q3', '71Q4', '72P', '72Q', '72Q2', '72Q3', '72Q4', '75P', '81', '81P') THEN 'GC_Improvement'
            WHEN TRIM(c.tbl_element) IN ('01', '03', '04', '05', '06', '07', '09', '10', '10H', '11', '12', '12H', '13', '14', '15', '15H', '16', '17', '18', '19', '20', '20H', '21', '22', '25L', '26LH', '27L', '81L') THEN 'GC_Land'
            ELSE 'OtherCode'
        END AS CodeClass
    FROM codes_table AS c
    WHERE c.tbl_type_code = 'impgroup'
),
CTE_Districts AS (
    SELECT DISTINCT
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
        END AS District,
        pm.neighborhood AS GEO,
        TRIM(pm.NeighborHoodName) AS GEO_Name,
        pm.lrsn
    FROM TSBv_PARCELMASTER AS pm
)
SELECT
    '28' AS KootenaiCounty,
    d_c.District,
    d_c.GEO,
    d_c.GEO_Name,
    c.lrsn,
    c.PIN,
    c.AIN,
    c.FullGroupCode AS FullGroupCodeCurrent,
    k.CodeDescription,
    k.Category,
    k.CodeClass,
    c.AssessmentYear AS AssessmentYearCurrent,
    c.Cadaster_Value AS CurrentYearValue,
    d_p.District,
    d_p.GEO,
    d_p.GEO_Name,
    p.AIN,
    p.PIN,
    p.FullGroupCode AS FullGroupCodePrevious,
    p.AssessmentYear AS AssessmentYearPrevious,
    p.Cadaster_Value AS PastYearValue,
    (c.Cadaster_Value - p.Cadaster_Value) AS ValueChange,
    TRY_CAST(c.Cadaster_Value AS DECIMAL(18,2)) / TRY_CAST(p.Cadaster_Value AS DECIMAL(18,2)) AS PerfOfChange
FROM CTE_AssessedByCat_Current AS c
LEFT JOIN CTE_Districts AS d_c ON c.lrsn = d_c.lrsn
FULL OUTER JOIN CTE_AssessedByCat_Previous AS p ON c.lrsn = p.lrsn AND c.FullGroupCode = p.FullGroupCode
LEFT JOIN CTE_Districts AS d_p ON p.lrsn = d_p.lrsn
LEFT JOIN CTE_AllocationsGroupCodeKey AS k ON k.GroupCode_KC = c.FullGroupCode
ORDER BY d_c.District, d_c.GEO, c.PIN;