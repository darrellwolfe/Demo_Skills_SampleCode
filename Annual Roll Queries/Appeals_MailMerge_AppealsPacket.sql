-- !preview conn=conn


---------------------
--Appeals Mail Merger
---------------------
/*
AsTxDBProd
GRM_Main

*/


/*
Select *
From Appeals
Where Status = 'A'
--And file_date > '2023-01-01'
*/

/*

Nevermind - dang broken allocations

Select Distinct
al.lrsn,
al.property_class AS [PCC],
pcc.tbl_element_desc AS [PropertyClass]
--al.group_code AS [GroupCode],
--impgroup.tbl_element_desc AS [ImpGroup],

FROM allocations AS al -- ON pm.lrsn=al.lrsn
  -- AND al.status='A'
    --Join codes_table to allocations
  JOIN codes_table AS impgroup ON al.group_code=impgroup.tbl_element 
    AND impgroup.code_status='A'
    AND impgroup.tbl_type_code IN ('impgroup')
      --Join codes_table to allocations
  JOIN codes_table AS pcc ON al.property_class=pcc.tbl_element 
    AND pcc.code_status='A'
    AND pcc.tbl_type_code IN ('pcc')

WHERE al.status='A'
  AND al.extension = 'L00'

Group By
al.lrsn,
al.property_class,
pcc.tbl_element_desc
--al.group_code,
--impgroup.tbl_element_desc

*/

WITH

CTE_CertVal AS (
  Select 
      v.lrsn,
      v.land_market_val AS [Cert Land],
      v.imp_val AS [Cert Imp],
      (v.imp_val + v.land_market_val) AS [Cert Total Value],
      v.last_update AS [Last_Updated],
  ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNum
  
  From valuation AS v --ON pm.lrsn = v.lrsn
  Where v.status = 'A'
    AND v.eff_year BETWEEN 20230101 AND 20231231
),

CTE_Imp AS (

Select
  lrsn,
  extension AS [Record#],
  imp_type AS [BldgUse],
  year_built,
  eff_year_built,
  year_remodeled

From improvements

Where status='A'
AND improvement_id IN ('D','C','M')

)

SELECT Distinct
pm.lrsn,
a.appeal_id,
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
a.hear_date AS [DATE],
a.hear_date AS [TIME],
--I think this will work for Oral v Written local_grounds
a.local_grounds AS [Oral_Written],
LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
--Where is this
'' AS [BuildingUseOrDescription],
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(a.assignedto)) AS [Appraiser],
--Bring in Title from Appraiser Key (Merge in Power Query)
--al.property_class AS [PCC],
--pcc.tbl_element_desc AS [PropertyClass],
--al.group_code AS [GroupCode],
--impgroup.tbl_element_desc AS [ImpGroup],
pm.LegalAcres,
--Certified Values
cv.[Cert Land],
cv.[Cert Imp],
cv.[Cert Total Value],
cv.[Last_Updated]

FROM TSBv_PARCELMASTER AS pm
JOIN appeals AS a ON pm.lrsn=a.lrsn 
  --AND a.lastupdate > '2023-01-01'
  AND a.appeal_id LIKE '23%'

--Update Date as needed

Left JOIN CTE_CertVal AS cv ON pm.lrsn = cv.lrsn
  And RowNum = '1'

/*
LEFT JOIN allocations AS al ON pm.lrsn=al.lrsn
  AND al.status='A'
    --Join codes_table to allocations
  LEFT JOIN codes_table AS impgroup ON al.group_code=impgroup.tbl_element 
    AND impgroup.code_status='A'
    AND impgroup.tbl_type_code IN ('impgroup')
      --Join codes_table to allocations
  LEFT JOIN codes_table AS pcc ON al.property_class=pcc.tbl_element 
    AND pcc.code_status='A'
    AND pcc.tbl_type_code IN ('pcc')
*/
  
  

WHERE pm.EffStatus = 'A'

GROUP BY
pm.lrsn,
a.appeal_id,
pm.pin,
pm.AIN,
a.hear_date,
a.hear_date,
a.local_grounds,
pm.DisplayName,
pm.SitusAddress,
pm.neighborhood,
a.assignedto,
--al.property_class,
--pcc.tbl_element_desc,
--al.group_code,
--impgroup.tbl_element_desc,
pm.LegalAcres,
--Certified Values
cv.[Cert Land],
cv.[Cert Imp],
cv.[Cert Total Value],
cv.[Last_Updated]




ORDER BY GEO, PIN;