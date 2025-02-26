-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/


SELECT
    c.tbl_type_code AS CodeType
,   CONVERT(VARCHAR(255), TRIM(c.tbl_element)) AS Imp_GroupCode_Num
,    c.tbl_element_desc AS Imp_GroupCode_Description
,    CAST(LEFT(c.tbl_element, 2) AS INT) AS StateCode#
,    CASE
        WHEN CHARINDEX('99', c.tbl_element) > 0 THEN 'Non-Allocated_Error'
        WHEN CHARINDEX('98', c.tbl_element) > 0 THEN 'Non-Allocated_Error'
        WHEN CHARINDEX('01', c.tbl_element) > 0 THEN 'Timber_Ag'
        WHEN CHARINDEX('03', c.tbl_element) > 0 THEN 'Timber_Ag'
        WHEN CHARINDEX('04', c.tbl_element) > 0 THEN 'Timber_Ag'
        WHEN CHARINDEX('05', c.tbl_element) > 0 THEN 'Timber_Ag'
        WHEN CHARINDEX('06', c.tbl_element) > 0 THEN 'Timber_Ag'
        WHEN CHARINDEX('07', c.tbl_element) > 0 THEN 'Timber_Ag'
        WHEN CHARINDEX('08', c.tbl_element) > 0 THEN 'Timber_Ag'
        WHEN CHARINDEX('09', c.tbl_element) > 0 THEN 'Timber_Ag'
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
WHERE
    c.code_status = 'A'
    AND c.tbl_type_code = 'impgroup'
ORDER BY
    Imp_GroupCode_Num;
