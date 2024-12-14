-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
LTRIM(RTRIM())

Active with 2023 Land Model and 2023 Levy Rates

*/

DECLARE @LandModelYear INT = '702024';

--Levy Rates Table, Check to make sure IT has this created
--Need to fin the root table instead of this view.
--FROM KCv_TAGLevyRate23a -- Change to KCv_TAGLevyRate24a in November Fall 2024

WITH

CTE_TA_LevyRates AS (
SELECT DISTINCT
TRIM(TAGDescr) AS TAGDescr,
TRIM(SUBSTRING(TAGDescr, 1, 3) + '-' + SUBSTRING(TAGDescr, 4, 3)) AS TAG_Formatted,
LevyRate
FROM KCv_TAGLevyRate23a -- Change to KCv_TAGLevyRate24a in November Fall 2024

),
/*
CTE_Soil AS (
Select
soil_id,
soil_rate1
From Soil
Where soil_id IN ('Y1','Y2','Y3','Y4','T1','T2','T3','T4')
),
*/
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
),

CTE_TA_LandDetails AS (
  --Change land model id for current year
  SELECT
  lh.RevObjId,
  lh.TotalMktValue
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND ld.LandModelId=@LandModelYear

  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'
  --Change land model id for current year
    --AND lh.LandModelId='702023'
    --AND ld.LandModelId='702023'
    AND lh.LandModelId=@LandModelYear
    AND ld.SoilIdent IN ('Y1','Y2','Y3','Y4')
    --AND ld.SoilIdent IN ('Y1','Y2','Y3','Y4','T1','T2','T3','T4')
    AND ld.LandType IN ('61')
    --AND ld.LandType IN ('9','31','32')
    --AND lh.RevObjId=30296
  
  --GROUP BY lh.RevObjId
  --ld.SoilIdent,
  --ld.LDAcres

),
-------------------------------------
-- CTE_LandDetails
-------------------------------------

CTE_LandDetails_TimberAg AS (
  SELECT
  lh.RevObjId AS lrsn,
  --ld.SoilIdent,
  --ld.LDAcres,
  SUM(ld.BaseRate) AS TotalBaseRate
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND ld.LandModelId=@LandModelYear

  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'
  --Change land model id for current year
    --AND lh.LandModelId='702023'
    --AND ld.LandModelId='702023'
    AND lh.LandModelId=@LandModelYear
    AND ld.SoilIdent IN ('Y1','Y2','Y3','Y4')
    AND ld.LandType IN ('61')

    --AND ld.SoilIdent IN ('Y1','Y2','Y3','Y4','T1','T2','T3','T4')
    --AND ld.LandType IN ('9','31','32')
    --AND lh.RevObjId=30296
  
  GROUP BY lh.RevObjId
  --ld.SoilIdent,
  --ld.LDAcres
)


SELECT DISTINCT
  --Literals
  'KOOTENAI' AS County,
  CAST(GETDATE() AS DATE) AS Today,
  pm.Owner,
  pm.MailingAddress,
  pm.MailingCityStZip,
  pm.PIN,
  pm.AIN,
  pm.TAG,
  pm.Legal_Desc,
  ROUND(pm.LegalAcres,4) AS LegalAcres,
  '1' AS Homesite_Acre,
  cld.TotalMktValue,
  lr.TAG_Formatted,
  ROUND(lr.LevyRate,10) AS LevyRate,
  base.TotalBaseRate
--  CAST('154' AS INT) AS BLY_Rate_Per_Acre

FROM CTE_TA_PM AS pm

JOIN CTE_TA_LandDetails AS cld
  ON cld.RevObjId = pm.lrsn

JOIN CTE_TA_LevyRates AS lr
  ON pm.TAG = lr.TAGDescr

JOIN CTE_LandDetails_TimberAg AS base
  ON base.lrsn=pm.lrsn

  --WHERE pm.lrsn = 30296 --<As test if needed
  --Where pm.AIN = '123237'
  Where pm.AIN = '253955'