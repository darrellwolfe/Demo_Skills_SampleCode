-- !preview conn=con

---------
Select Distinct
a.lrsn,
a.extension,
a.land_line_number,
a.improvement_id,
a.cost_value,
a.group_code,
LEFT (a.group_code,2) AS [STC_GroupCode],
impgroup.tbl_element_desc AS [ImpGroup_Descr],
a.property_class,
pcc.tbl_element_desc AS [PCC_Descr],
MAX (a.last_update),
ROW_NUMBER() OVER (PARTITION BY a.lrsn ORDER BY a.last_update DESC) AS RowNum

From allocations AS a -- JOIN primary query on lrsn, extension, AND improvement_id
--Descriptions - Group Codes
Left Join codes_table AS impgroup ON impgroup.tbl_element=a.group_code
  AND impgroup.code_status='A'
  AND impgroup.tbl_type_code = 'impgroup'
--Descriptions - PCC
Left Join codes_table AS pcc ON pcc.tbl_element = a.property_class
  AND pcc.code_status='A'
  AND pcc.tbl_type_code = 'pcc'

--Where a.status='H'
Where a.status='A' -- Active is Worksheet, Historical is old, voided, and certified. Most recent H for certified.


GROUP BY
a.lrsn,
a.extension,
a.land_line_number,
a.improvement_id,
a.cost_value,
a.group_code,
impgroup.tbl_element_desc,
a.property_class,
pcc.tbl_element_desc,
a.last_update

Order By a.lrsn, a.group_code;

/*

--pcc
Select Distinct
pcc.tbl_type_code AS [PCC_Type],
pcc.tbl_element AS [PCC_Code],
pcc.tbl_element_desc AS [PCC_Descr]

From codes_table AS pcc
WHERE pcc.code_status='A'
AND pcc.tbl_type_code = 'pcc'

--impgroup
Select Distinct
impgroup.tbl_type_code AS [ImpType],
impgroup.tbl_element AS [ImpGroup_Code],
impgroup.tbl_element_desc AS [ImpGroup_Descr]

From codes_table AS impgroup
WHERE impgroup.code_status='A'
AND impgroup.tbl_type_code = 'impgroup'


*/