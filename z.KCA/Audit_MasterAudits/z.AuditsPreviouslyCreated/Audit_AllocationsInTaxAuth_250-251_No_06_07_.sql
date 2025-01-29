-- !preview conn=con
/*
AsTxDBProd
GRM_Main
,mAcquisitionDate
,mAcquisitionValue
,mAppraisedValue
,mDescription
    
    SELECT *
FROM tPPAccount

*/

WITH 

-- Begin CTE Key
CTE_TAG_TA_TIF_Key AS (

  SELECT DISTINCT 
  tag.Id AS TAGId,
  TRIM(tag.Descr) AS TAG,
  tif.Id AS TIFId,
  TRIM(tif.Descr) AS TIF,
  ta.Id AS TaxAuthId,
  TRIM(ta.Descr) AS TaxAuthority
  
  --TAG Table
  FROM TAG AS tag
  --TAGTIF Key
  LEFT JOIN TAGTIF 
    ON TAG.Id=TAGTIF.TAGId 
    AND TAGTIF.EffStatus = 'A'
  --TIF Table
  LEFT JOIN TIF AS tif 
    ON TAGTIF.TIFId=TIF.Id 
    AND TIF.EffStatus  = 'A'
  --TAGTaxAuthority Key
  LEFT JOIN TAGTaxAuthority 
    ON TAG.Id=TAGTaxAuthority.TAGId 
    AND TAGTaxAuthority.EffStatus = 'A'
  --TaxAuthority Table
  LEFT JOIN TaxAuthority AS ta 
    ON TAGTaxAuthority.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
  --CTE_ JOIN, only want TAGs in this TaxAuth
  
  WHERE tag.EffStatus = 'A'
  AND ta.Id = 250
  
),

CTE_Allocations AS (
SELECT 
a.lrsn
, a.extension
, a.improvement_id
, a.group_code
, impgroup.tbl_element_desc AS ImpGroup_Descr
, market_value
, cost_value

FROM allocations AS a 

LEFT JOIN codes_table AS impgroup ON impgroup.tbl_element=a.group_code
  AND impgroup.code_status='A'
  AND impgroup.tbl_type_code = 'impgroup'

WHERE a.status='A' 
  --AND a.group_code IN ('01','03','04','05')
  --AND a.group_code IN ('01','03','04','05','06','07','09')
  AND a.group_code IN ('06','07') 
)
-- End CTE Key



Select Distinct
LTRIM(RTRIM(pm.lrsn)) AS [LRSN],
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.PropClassDescr)) AS [PCC],
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(pm.TAG)) AS [TAG],
LTRIM(RTRIM(pm.DisplayName)) AS [OwnerName],
--LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
--LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
tif.TaxAuthId,
tif.TaxAuthority,
ass.group_code,
ass.ImpGroup_Descr,

pm.WorkValue_Impv,
pm.WorkValue_Land,
pm.WorkValue_Total

From TSBv_PARCELMASTER AS pm

Join CTE_TAG_TA_TIF_Key AS tif
  ON pm.TAG = tif.TAG

Join CTE_Allocations AS ass
  ON pm.lrsn=ass.lrsn

Where pm.EffStatus = 'A'






