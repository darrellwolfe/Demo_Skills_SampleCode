-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/


--CTE_AllocationsGroupCodeKey AS (
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

ORDER BY c.tbl_element_desc;
--)



/*
,CASE
  WHEN LEFT(c.tbl_element,2) IN ('01','03','04','05','06','07','09','10',
                                '11','12','13','14','15','16','17','18',
                                '19','20','21','22','25','26','27','81') THEN 'State_Land'
  ELSE NULL
END AS State_Land

,CASE
  WHEN LEFT(c.tbl_element,2) BETWEEN '56' AND '72' THEN 'State_Imp'
  WHEN LEFT(c.tbl_element,2) IN ('25','26','30','32','34','35','36','37',
                                '38','39','41','42','43','46','47',
                                '48','49','50','51','55','65','81') THEN 'State_Imp'
  ELSE NULL
END AS State_Imp
*/