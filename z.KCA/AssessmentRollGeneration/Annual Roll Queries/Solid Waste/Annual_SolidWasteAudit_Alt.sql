-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/


DECLARE @Year INT = 20230101;
DECLARE @Year_SA INT = 2022;

WITH 
--------------------------
-- Pulls in only parcels with an improvement 
-- C - Commercial, D - Residential Dwelling, M - Manufactered Home
-- H Historical Value of most recent tax year, pulls in certified fixtures
--------------------------
CTE_Improvement AS (

SELECT
  e.lrsn AS Ext_lrsn
, e.ext_id
, e.extension
, e.ext_description
, i.improvement_id
, i.imp_type
, grades.tbl_element_desc AS Grade

, dw.dwelling_number
, dw.mkt_house_type
, htyp.tbl_element_desc AS HouseType

, cb.bldg_section
, cb.mkt_bldg_type
, cu.use_code

, mh.mh_make
, make.tbl_element_desc AS MH_Make_Desc
, mh.mh_model
, model.tbl_element_desc AS MH_Model_Desc
, mh.mh_serial_num
, mh.mhpark_code
, park.tbl_element_desc AS MH_Park_Desc

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
  AND e.ext_description <> 'CONDO'
  --AND i.improvement_id = 'M'
  
),

--------------------------
--Pulls in only allocations with values, excludes exempt or true value = 0
--------------------------

CTE_Allocations AS (
  SELECT
    a.lrsn AS Allocation__lrsn
  , a.extension
  , a.improvement_id
  , a.group_code
  , a.property_class
  , SUM(a.cost_value) AS cost_value_sum
  --, a.recon_value
  --, a.market_value
  --, a.income_value

  FROM Allocations AS a
    WHERE (a.improvement_id = 'M' OR a.improvement_id = 'D' OR a.improvement_id = 'C')
      AND a.status = 'A'
      AND a.cost_value > 0
      AND (extension LIKE '%R%'OR extension LIKE '%C%')
      --AND a.group_code = '81'
      AND a.group_code NOT IN ('98','99')
    
    GROUP BY
    a.lrsn
  , a.extension
  , a.improvement_id
  , a.group_code
  , a.property_class
      
),

--------------------------
-- Pulls in all Special Assessments from most recent posted tax year
--------------------------
CTE_SpecialAssessement AS (
    SELECT
    sh.RevObjId AS SpecialAssess_lrsn
  --, TRIM(pm.AIN) AS AIN -- <For testing only
  , sd.Amount AS Increment
  , sh.BegEffYear AS SDYear
  , sd.BegEffYear AS SHYear
  , sh.Id AS SpecialHeader_Id
  , sd.Id AS SpecialDetail_Id
  , sh.SAId
  , sd.SAValueHeaderId
  , sd.ValueTypeId
  , sd.Basis
  
    FROM SAvalueHeader AS sh
    JOIN SAVALUEDETAIL AS sd ON sh.Id = sd.SAValueHeaderId
      AND sd.EffStatus = 'A'
      AND sd.BegEffYear = @Year_SA
   -- JOIN TSBV_PARCELMASTER AS pm ON pm.lrsn=sh.RevObjId -- <For testing only
    --    AND pm.EffStatus = 'A'

  WHERE sh.EffStatus = 'A'
    AND sh.SAId IN ('15','38')
    AND sh.BegEffYear = @Year_SA
  
 -- ORDER BY pm.AIN, sh.BegEffYear
),

CTE_Memos_SW AS (
  SELECT
  lrsn AS Memo_Lrsn_SW
  , COALESCE(memo_text, 'Default_Value') AS SolidWasteMemos
  
  FROM memos
  WHERE memo_id = 'ZS'
  AND status='A'
  AND memo_line_number <> 1
),

CTE_Memos_MHPrePay AS (
  SELECT DISTINCT
  lrsn AS Memo_Lrsn_MH
  , memo_id
  , COALESCE(memo_text, 'Default_Value') Memo_Text_MH
  FROM memos
  WHERE status='A'
  AND memo_id = 'MHPP'
  AND memo_line_number <> 1
  AND memo_text LIKE '%2023%'
  --AND memo_line_number = 1
)



SELECT DISTINCT
-- District Key
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

--CTEs
, pm.neighborhood AS GEO
, imp.Ext_lrsn AS RevObjId
, TRIM(pm.PIN) AS PIN
, TRIM(pm.AIN) AS AIN
, TRIM(pm.DisplayName) AS Owner
, TRIM(pm.SitusAddress) AS SitusAddress
, TRIM(pm.SitusCity) AS SitusCity
, sa.Increment
, sa.SHYear
, sa.SAId
, sa.SAValueHeaderId
, sa.ValueTypeId
, sa.Basis
, imp.ext_id
, imp.extension
, imp.ext_description
, imp.improvement_id
, imp.imp_type
, al.group_code
, al.cost_value_sum
, msw.SolidWasteMemos
, mmh.Memo_Text_MH

FROM CTE_Improvement AS imp
JOIN CTE_Allocations AS al ON al.Allocation__lrsn = imp.Ext_lrsn
JOIN TSBV_PARCELMASTER AS pm ON pm.lrsn=imp.Ext_lrsn
  AND pm.EffStatus = 'A'
  AND pm.neighborhood <> '450'

LEFT JOIN CTE_SpecialAssessement AS sa ON sa.SpecialAssess_lrsn = imp.Ext_lrsn

LEFT JOIN CTE_Memos_SW AS msw ON msw.Memo_Lrsn_SW=imp.Ext_lrsn

LEFT JOIN CTE_Memos_MHPrePay AS mmh ON mmh.Memo_Lrsn_MH=imp.Ext_lrsn

WHERE pm.AIN = '176159'

ORDER BY District, GEO, AIN;

/*
, sa.*
, al.*
, imp.*

LEFT JOIN CTE_DistrictKey AS dk ON dk.GEO = pm.neighborhood


CTE_DistrictKey AS (
SELECT
    CASE
        WHEN GEO >= 9000 THEN 'Manufactured_Homes'
        WHEN GEO >= 6003 THEN 'District_6'
        WHEN GEO = 6002 THEN 'Manufactured_Homes'
        WHEN GEO = 6001 THEN 'District_6'
        WHEN GEO = 6000 THEN 'Manufactured_Homes'
        WHEN GEO >= 5003 THEN 'District_5'
        WHEN GEO = 5002 THEN 'Manufactured_Homes'
        WHEN GEO = 5001 THEN 'District_5'
        WHEN GEO = 5000 THEN 'Manufactured_Homes'
        WHEN GEO >= 4000 THEN 'District_4'
        WHEN GEO >= 3000 THEN 'District_3'
        WHEN GEO >= 2000 THEN 'District_2'
        WHEN GEO >= 1021 THEN 'District_1'
        WHEN GEO = 1020 THEN 'Manufactured_Homes'
        WHEN GEO >= 1001 THEN 'District_1'
        WHEN GEO = 1000 THEN 'Manufactured_Homes'
        WHEN GEO >= 451 THEN 'Commercial'
        WHEN GEO = 450 THEN 'Specialized_Cell_Towers'
        WHEN GEO >= 1 THEN 'Commercial'
        WHEN GEO = 0 THEN 'N/A_or_Error'
        ELSE NULL
    END AS District,
    GEO
FROM (
    SELECT DISTINCT
        pm.neighborhood AS GEO
    FROM TSBv_PARCELMASTER AS pm
    WHERE pm.EffStatus = 'A'
    AND pm.neighborhood <> 0
) AS Subquery

),



*/