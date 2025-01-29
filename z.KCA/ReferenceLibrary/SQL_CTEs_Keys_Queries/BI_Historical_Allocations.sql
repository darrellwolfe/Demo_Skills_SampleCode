-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

group_code
tbl_element_desc AS Imp_GroupCode_Desc

BI_Historical_Allocations

*/

SELECT DISTINCT
a.lrsn
, a.extension
, a.improvement_id
, a.property_class AS PCC_ClassCode
, a.group_code AS Imp_GroupCode
--, a.method
, a.last_update

FROM allocations AS a
