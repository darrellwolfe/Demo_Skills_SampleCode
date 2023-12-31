-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

*/

DECLARE @Year INT = 20230101;
DECLARE @Year_SA INT = 2023;

WITH

CTE_ParcelMaster AS (
  --------------------------------
  --ParcelMaster
  --------------------------------
  Select Distinct
  pm.lrsn
, TRIM(pm.DisplayName) AS Owner
, CASE
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
, pm.neighborhood AS GEO
, TRIM(pm.NeighborHoodName) AS GEO_Name
,  TRIM(pm.pin) AS PIN
,  TRIM(pm.AIN) AS AIN
, pm.DisplayDescr
, SUBSTRING(
      pm.DisplayDescr,
      CASE 
          WHEN CHARINDEX('SITUS#', pm.DisplayDescr) > 0 THEN CHARINDEX('SITUS#', pm.DisplayDescr) + 6
          WHEN CHARINDEX('SITUS #', pm.DisplayDescr) > 0 THEN CHARINDEX('SITUS #', pm.DisplayDescr) + 7
          ELSE 0
      END,
      6
  ) AS Extracted_Situs

, pm.ClassCD
, TRIM(pm.PropClassDescr) AS Property_Class_Type
, CASE 
    WHEN pm.ClassCD IN ('010', '020', '021', '022', '030', '031', '032', '040', '050', '060', '070', '080', '090') THEN 'Business_Personal_Property'
    WHEN pm.ClassCD IN ('314', '317', '322', '336', '339', '343', '413', '416', '421', '435', '438', '442', '451', '527','461') THEN 'Commercial_Industrial'
    WHEN pm.ClassCD IN ('411', '512', '515', '520', '534', '537', '541', '546', '548', '549', '550', '555', '565','526','561') THEN 'Residential'
    WHEN pm.ClassCD IN ('441', '525', '690') THEN 'Mixed_Use_Residential_Commercial'
    WHEN pm.ClassCD IN ('101','103','105','106','107','110','118') THEN 'Timber_Ag_Land'
    WHEN pm.ClassCD = '667' THEN 'Operating_Property'
    WHEN pm.ClassCD = '681' THEN 'Exempt_Property'
    WHEN pm.ClassCD = 'Unasigned' THEN 'Unasigned_or_OldInactiveParcel'
    ELSE 'Unasigned_or_OldInactiveParcel'
  END AS Property_Type_Class
, TRIM(pm.TAG) AS TAG
--,  TRIM(pm.DisplayName)) AS Owner
, TRIM(pm.SitusAddress) AS SitusAddress
, TRIM(pm.SitusCity) AS SitusCity
, TRIM(pm.SitusState) AS SitusState
, TRIM(pm.SitusZip) AS SitusZip
, TRIM(pm.CountyNumber) AS CountyNumber
, CASE
    WHEN pm.CountyNumber = '28' THEN 'Kootenai_County'
    ELSE NULL
  END AS County_Name
,  pm.LegalAcres
,  pm.Improvement_Status -- <Improved vs Vacant


  From TSBv_PARCELMASTER AS pm
  
  Where pm.EffStatus = 'A'
    --AND pm.ClassCD NOT LIKE '010%'
    --AND pm.ClassCD NOT LIKE '020%'
    --AND pm.ClassCD NOT LIKE '021%'
    --AND pm.ClassCD NOT LIKE '022%'
    --AND pm.ClassCD NOT LIKE '030%'
    --AND pm.ClassCD NOT LIKE '031%'
    --AND pm.ClassCD NOT LIKE '032%'
    AND pm.ClassCD NOT LIKE '060%'
    AND pm.ClassCD NOT LIKE '070%'
    AND pm.ClassCD NOT LIKE '090%'
      
  Group By
  pm.lrsn
, pm.DisplayName
, pm.pin
, pm.PINforGIS
, pm.AIN
, pm.DisplayDescr
, pm.ClassCD
, pm.PropClassDescr
, pm.neighborhood
, pm.NeighborHoodName
, pm.TAG
--  pm.DisplayName,
, pm.SitusAddress
, pm.SitusCity
, pm.SitusState
, pm.SitusZip
, pm.CountyNumber
, pm.LegalAcres
, pm.Improvement_Status

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
),

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
  
)


SELECT 
--c_pm.*
c_pm.lrsn
,c_pm.District
,c_pm.GEO
,c_pm.GEO_Name
,c_pm.PIN
,c_pm.AIN
,c_pm.Owner
--,c_situs.AIN AS Situs_AIN
,c_pm.DisplayDescr
,c_pm.Extracted_Situs
,c_pm.ClassCD
,c_pm.Property_Class_Type
,c_pm.SitusAddress
,c_pm.SitusCity
, imp.ext_id
, imp.extension
, imp.ext_description
, imp.improvement_id
, imp.imp_type
, sa.Increment
, sa.SHYear
, sa.SAId
, sa.SAValueHeaderId
, sa.ValueTypeId
, sa.Basis
, msw.SolidWasteMemos
, mmh.Memo_Text_MH

FROM CTE_ParcelMaster AS c_pm
LEFT JOIN CTE_ParcelMaster AS c_situs
  ON c_situs.AIN = c_pm.Extracted_Situs

LEFT JOIN CTE_Improvement AS imp ON c_pm.lrsn=imp.Ext_lrsn

LEFT JOIN CTE_SpecialAssessement AS sa ON sa.SpecialAssess_lrsn = c_pm.lrsn
LEFT JOIN CTE_Memos_SW AS msw ON msw.Memo_Lrsn_SW=c_pm.lrsn
LEFT JOIN CTE_Memos_MHPrePay AS mmh ON mmh.Memo_Lrsn_MH=c_pm.lrsn


WHERE sa.Increment > 0
AND sa.Increment IS NOT NULL
AND imp.improvement_id IS NULL
--AND c_pm.AIN IN ('100333')  --Test Only


-- WHERE c_pm.PIN LIKE 'M%'
-- AND (c_pm.Extracted_Situs='100333'
--     OR c_situs.AIN = '100333')


Order By District,GEO;




















