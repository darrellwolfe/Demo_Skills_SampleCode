/*
AsTxDBProd
GRM_Main
*/

-- !preview conn=con

----------------------------------------
-- Allocations Query
----------------------------------------

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











----------------------------------------
-- Other Versions
----------------------------------------

--All

Select *
From allocations
Where last_update LIKE '%2023%'



--status='A'; but to get before and after, you need both active and historical status.
Select
a.lrsn,
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(a.group_code)) AS [KootenaiGroupCode],
LEFT(a.group_code,2) AS [StateGroupCode],
SUM(a.cost_value) AS Cost,
MAX(a.last_update) AS [FinalDate],
--a.last_update AS [FirstDate],
ROW_NUMBER() OVER (PARTITION BY a.lrsn ORDER BY a.last_update DESC) AS RowNum
--ASC) AS RowNum

From allocations AS a
JOIN TSBv_PARCELMASTER AS pm ON a.lrsn=pm.lrsn
  And pm.EffStatus='A'
  
--Where last_update LIKE '%2023%'
--Where a.last_update = '2023-05-03'
Where a.status = 'H'
--  And a.last_update >= '2023-05-03'
And last_update LIKE '%2023%'

Group By a.lrsn, pm.pin, pm.AIN, a.group_code, a.last_update;




--Option 2


Select
a.lrsn,
pm.AIN,
a.group_code,
SUM(a.cost_value) AS Cost,
MAX(a.last_update) AS [FinalDate],
a.last_update AS [FirstDate],
ROW_NUMBER() OVER (PARTITION BY a.lrsn ORDER BY a.last_update DESC) AS RowNum
--ASC) AS RowNum

From allocations AS a
Join TSBv_PARCELMASTER AS pm ON a.lrsn=pm.lrsn
  And EffStatus='A'
  
--Where last_update LIKE '%2023%'
--Where a.last_update = '2023-05-03'
Where a.last_update >= '2023-05-03'
  And status = 'H'

Group By a.lrsn, pm.AIN, a.group_code, a.last_update;