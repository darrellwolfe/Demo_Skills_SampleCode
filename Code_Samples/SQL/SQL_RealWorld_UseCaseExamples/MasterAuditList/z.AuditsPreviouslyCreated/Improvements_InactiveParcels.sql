-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

Solid Waste Audit SQL (Darrell Wolfe, KC Assessor)
03/20/2024
11:22 AM

=Calculate(
SUM(Res_Difference_YearOverYear) if ISBLANK(ext_description)
)

=Calculate(
SUM(Comm_Difference_YearOverYear) if ISBLANK(ext_description)
)

*/

DECLARE @Year INT = 20230101;
-- @Year is for improvements

DECLARE @Year_SA INT = 2023;
-- @Year_SA os for Solid Waste Audit, current year

WITH

CTE_ParcelMaster AS (
  --------------------------------
  --ParcelMaster
  --------------------------------
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
    WHEN pm.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS District
,pm.lrsn
,pm.neighborhood AS GEO
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
--,STRING_AGG(TRIM(pm.SitusAddress), ', ') AS SitusAddress
--,STRING_AGG(TRIM(pm.SitusCity), ', ') AS SitusCity

,STRING_AGG(TRIM(pm.DisplayName), ', ') AS Owner
,pm.EffStatus AS EffStatus_In_ProVal

  From TSBv_PARCELMASTER AS pm

  Where pm.EffStatus = 'I'
  
/*
  Where pm.EffStatus = 'A'
    AND pm.ClassCD NOT LIKE '060%'
    AND pm.ClassCD NOT LIKE '070%'
    AND pm.ClassCD NOT LIKE '090%'
*/
  GROUP BY
  pm.lrsn
  ,pm.neighborhood
  ,pm.pin
  ,pm.AIN
  ,pm.SitusCity
  ,pm.SitusAddress
  ,pm.ClassCD
  ,pm.PropClassDescr
  ,pm.EffStatus
),


CTE_Improvement_CMD AS (

SELECT DISTINCT
  e.lrsn AS Ext_lrsn
  ,TRIM(e.ext_description) AS ext_description
  ,TRIM(i.improvement_id) AS improvement_id
  
  
--,STRING_AGG (TRIM(e.ext_description), ', ') AS ext_description

--,STRING_AGG (CAST(TRIM(e.extension) AS NVARCHAR(MAX)), ', ') AS extension
--,STRING_AGG (CAST(TRIM(e.ext_description) AS VARCHAR(MAX)), ', ') AS ext_description
--,STRING_AGG (CAST(TRIM(i.improvement_id) AS NVARCHAR(MAX)), ', ') AS improvement_id
--,STRING_AGG(CAST(SUBSTRING(e.ext_description, 1, 100) AS NVARCHAR(MAX)), ',')  AS ext_description

FROM extensions AS e 

JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='H'
      AND i.eff_year = @Year
      AND i.improvement_id IN ('M','D','C')
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
--manuf_housing, comm_bldg, dwellings all must be after e and i

--RESIDENTIAL DWELLINGS
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND i.extension=dw.extension
      AND dw.status='H'
      AND dw.eff_year = @Year
  LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  


--COMMERCIAL      
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='H'
      AND cb.eff_year = @Year
    LEFT JOIN comm_uses AS cu ON cb.lrsn=cu.lrsn
      AND cb.extension = cu.extension
      AND cu.status = 'H'
      AND cu.eff_year = @Year

--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status = 'H'
      AND mh.eff_year = @Year
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'
      
      
WHERE e.status = 'H'
  AND e.eff_year = @Year
--  AND e.ext_description <> 'CONDO'
-- We specifically rejected CONDO from the list, don't know why but we did it on purpose.
  --AND i.improvement_id = 'M'
--GROUP BY e.lrsn

),


CTE_ImprovementAGG_CMD AS (
SELECT
Ext_lrsn
,STRING_AGG(CAST(SUBSTRING(ext_description, 1, 100) AS VARCHAR(20)), ', ') AS ext_description
,STRING_AGG(CAST(SUBSTRING(improvement_id, 1, 100) AS VARCHAR(20)), ', ') AS improvement_id


--,STRING_AGG(ext_description, ',')  AS ext_description

FROM CTE_Improvement_CMD
GROUP BY Ext_lrsn
),

CTE_Improvement_Not_CMD AS (

SELECT DISTINCT
  e.lrsn AS Ext_lrsn
  ,TRIM(e.ext_description) AS ext_description
  ,TRIM(i.improvement_id) AS improvement_id

--,STRING_AGG (TRIM(e.ext_description), ', ') AS ext_description

--,STRING_AGG (CAST(TRIM(e.extension) AS NVARCHAR(MAX)), ', ') AS extension
--,STRING_AGG (CAST(TRIM(e.ext_description) AS VARCHAR(MAX)), ', ') AS ext_description
--,STRING_AGG (CAST(TRIM(i.improvement_id) AS NVARCHAR(MAX)), ', ') AS improvement_id
--,STRING_AGG(CAST(SUBSTRING(e.ext_description, 1, 100) AS NVARCHAR(MAX)), ',')  AS ext_description

FROM extensions AS e 

JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='H'
      AND i.eff_year = @Year
      AND i.improvement_id NOT IN ('M','D','C')
    LEFT JOIN codes_table AS grades ON i.grade = grades.tbl_element
      AND grades.tbl_type_code='grades'
      
--manuf_housing, comm_bldg, dwellings all must be after e and i

--RESIDENTIAL DWELLINGS
LEFT JOIN dwellings AS dw ON i.lrsn=dw.lrsn
      AND i.extension=dw.extension
      AND dw.status='H'
      AND dw.eff_year = @Year
  LEFT JOIN codes_table AS htyp ON dw.mkt_house_type = htyp.tbl_element 
    AND htyp.tbl_type_code='htyp'  


--COMMERCIAL      
LEFT JOIN comm_bldg AS cb ON i.lrsn=cb.lrsn 
      AND i.extension=cb.extension
      AND cb.status='H'
      AND cb.eff_year = @Year
    LEFT JOIN comm_uses AS cu ON cb.lrsn=cu.lrsn
      AND cb.extension = cu.extension
      AND cu.status = 'H'
      AND cu.eff_year = @Year

--MANUFACTERED HOUSING
LEFT JOIN manuf_housing AS mh ON i.lrsn=mh.lrsn 
      AND i.extension=mh.extension
      AND mh.status = 'H'
      AND mh.eff_year = @Year
  LEFT JOIN codes_table AS make ON mh.mh_make=make.tbl_element 
    AND make.tbl_type_code='mhmake'
  LEFT JOIN codes_table AS model ON mh.mh_model=model.tbl_element 
    AND model.tbl_type_code='mhmodel'
  LEFT JOIN codes_table AS park ON mh.mhpark_code=park.tbl_element 
    AND park.tbl_type_code='mhpark'
      
      
WHERE e.status = 'H'
  AND e.eff_year = @Year
--  AND e.ext_description <> 'CONDO'
-- We specifically rejected CONDO from the list, don't know why but we did it on purpose.
  --AND i.improvement_id = 'M'
--GROUP BY e.lrsn

),


CTE_ImprovementAGG_Not_CMD AS (
SELECT
Ext_lrsn
,STRING_AGG(CAST(SUBSTRING(ext_description, 1, 100) AS VARCHAR(20)), ', ') AS ext_description
,STRING_AGG(CAST(SUBSTRING(improvement_id, 1, 100) AS VARCHAR(20)), ', ') AS improvement_id

FROM CTE_Improvement_Not_CMD
GROUP BY Ext_lrsn
)


SELECT DISTINCT
--c_pm.*

c_pm.PIN
,c_pm.AIN
--,imp.extension
,imp.ext_description AS Dwelling_Imps
,imp.improvement_id AS Dwelling_IDs
,imp_NotDwellings.improvement_id AS Non_Dwelling_IDs

,c_pm.Owner
,c_pm.SitusAddress
,c_pm.SitusCity
,c_pm.EffStatus_In_ProVal
,c_pm.District
,c_pm.GEO
,c_pm.Property_Class_Description
--,c_pm.ClassCD
,c_pm.lrsn



FROM CTE_ParcelMaster AS c_pm

LEFT JOIN CTE_ImprovementAGG_CMD AS imp 
  ON c_pm.lrsn=imp.Ext_lrsn

LEFT JOIN CTE_ImprovementAGG_Not_CMD AS imp_NotDwellings 
  ON c_pm.lrsn=imp_NotDwellings.Ext_lrsn

WHERE c_pm.GEO <> 0
AND c_pm.GEO IS NOT NULL

--Here is my question:
AND (imp.improvement_id IS NOT NULL
    OR imp_NotDwellings.improvement_id IS NOT NULL
    )



/*


  
LEFT JOIN CTE_Memos_MHPrePay AS mmh 
  ON mmh.Memo_Lrsn_MH=c_pm.lrsn
*/

/*
WHERE sa.Increment > 0
AND sa.Increment IS NOT NULL
AND imp.improvement_id IS NULL
--AND c_pm.AIN IN ('100333')  --Test Only
*/

-- WHERE c_pm.PIN LIKE 'M%'
-- AND (c_pm.Extracted_Situs='100333'
--     OR c_situs.AIN = '100333')



Order By c_pm.District,c_pm.GEO,c_pm.PIN;