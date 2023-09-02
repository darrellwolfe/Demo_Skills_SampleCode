
-- !preview conn=con

/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())

*/

DECLARE @LandModelId VARCHAR(10) = '702023';

WITH

CTE_TA_LandDetails AS (
  --Change land model id for current year
  SELECT
  lh.RevObjId,
  lh.TotalMktValue
  --Land Header
  FROM LandHeader AS lh
  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'
    --AND lh.LandModelId='702023'
    AND lh.LandModelId = @LandModelId
    --Looking for:
  -- AND lh.RevObjId = '1702' --< Used as a test case
),

CTE_TA_PM AS (
SELECT DISTINCT
  pm.lrsn,
  TRIM(pm.DisplayName) AS Owner,
  TRIM(pm.MailingAddress) AS MailingAddress,
  TRIM(pm.MailingCityStZip) AS MailingCityStZip,
  TRIM(pm.pin) AS PIN,
  TRIM(pm.AIN) AS AIN,
  TRIM(pm.TAG) AS TAG,
  TRIM(pm.DisplayDescr) AS Legal_Desc,
  pm.LegalAcres

FROM TSBv_PARCELMASTER AS pm
WHERE pm.EffStatus = 'A'
-- AND pm.AIN = '122283'
),


CTE_TA_LevyRates AS (
SELECT DISTINCT
TRIM(TAGDescr) AS TAGDescr,
TRIM(SUBSTRING(TAGDescr, 1, 3) + '-' + SUBSTRING(TAGDescr, 4, 3)) AS TAG_Formatted,
LevyRate
FROM KCv_TAGLevyRate22a -- Change to KCv_TAGLevyRate23a in Fall 2023

)


SELECT DISTINCT
  --Literals
  'KOOTENAI' AS County,
  '1' AS Homesite_Acre,
  CAST(GETDATE() AS DATE) AS Today,
  --ID
  pm.lrsn,
  cld.RevObjId,
  --Info
  pm.Owner,
  pm.MailingAddress,
  pm.MailingCityStZip,
  pm.PIN,
  pm.AIN,
  pm.TAG,
  pm.Legal_Desc,
  pm.LegalAcres,
  cld.TotalMktValue,
  lr.TAG_Formatted,
  lr.LevyRate,
  (cld.TotalMktValue/pm.LegalAcres) AS Current_Market_Value_Per_Acre,
  CAST('154' AS INT) AS BLY_Rate_Per_Acre

FROM CTE_TA_LandDetails AS cld

LEFT JOIN CTE_TA_PM AS pm
  ON cld.RevObjId = pm.lrsn

LEFT JOIN CTE_TA_LevyRates AS lr
  ON pm.TAG = lr.TAGDescr
-- WHERE AIN = '122283'

  