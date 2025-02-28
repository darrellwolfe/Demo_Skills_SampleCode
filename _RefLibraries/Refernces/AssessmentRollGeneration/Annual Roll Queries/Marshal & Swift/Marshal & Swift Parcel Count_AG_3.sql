-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

Select Distinct 
Count(pm.lrsn) AS CountOfLRSN
From KCv_PARCELMASTER1 AS pm
Where pm.EffStatus = 'A'


Select Distinct 
Count(pm.lrsn) AS CountOfLRSN
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

, a.extension
, a.improvement_id
, a.group_code
, impgroup.tbl_element_desc AS ImpGroup_Descr
, market_value
, cost_value


*/


--Count of AG Parcels Only
SELECT 
COUNT(a.lrsn) CountOfLRSNs
--, impgroup.tbl_element_desc AS ImpGroup_Descr

FROM allocations AS a 

LEFT JOIN codes_table AS impgroup ON impgroup.tbl_element=a.group_code
  AND impgroup.code_status='A'
  AND impgroup.tbl_type_code = 'impgroup'

WHERE a.status='A' 
  AND a.group_code IN ('01','03','04','05')
  --AND a.group_code IN ('01','03','04','05','06','07','09')
  --AND a.group_code IN ('06','07') 
/*
GROUP BY
impgroup.tbl_element_desc
*/