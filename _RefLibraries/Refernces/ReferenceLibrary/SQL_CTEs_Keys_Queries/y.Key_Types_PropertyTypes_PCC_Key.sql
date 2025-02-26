-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

group_code
tbl_element_desc AS Imp_GroupCode_Desc


*/


SELECT 
c.tbl_type_code AS CodeType
, CONVERT(VARCHAR(255), TRIM(c.tbl_element)) AS PCC_Code_Num
, c.tbl_element_desc AS PCC_CodeDescription
, CASE 
    WHEN c.tbl_element IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
    WHEN c.tbl_element IN ('314', '317', '322', '336', '339', '343', '413', '416', '421', '435', '438', '442', '451', '527','461') THEN 'Commercial_Industrial'
    WHEN c.tbl_element IN ('411', '512', '515', '520', '534', '537', '541', '546', '548', '549', '550', '555', '565','526','561') THEN 'Residential'
    WHEN c.tbl_element IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
    WHEN c.tbl_element IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'
    WHEN c.tbl_element = '667' THEN 'Operating_Property'
    WHEN c.tbl_element = '681' THEN 'Exempt_Property'
    WHEN c.tbl_element = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'
    ELSE 'Unasigned_or_OldInactiveParcel'
  END AS Property_Type_Class

FROM codes_table AS c
WHERE code_status= 'A' AND tbl_type_code= 'pcc'
ORDER BY PCC_Code_Num;