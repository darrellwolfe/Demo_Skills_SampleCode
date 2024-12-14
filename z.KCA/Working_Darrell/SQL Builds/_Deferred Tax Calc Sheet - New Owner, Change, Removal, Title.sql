-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
LTRIM(RTRIM())

Active with 2023 Land Model and 2023 Levy Rates

*/

--Levy Rates Table, Check to make sure IT has this created
--Need to fin the root table instead of this view.
--FROM KCv_TAGLevyRate23a -- Change to KCv_TAGLevyRate24a in November Fall 2024

DECLARE @LandModelYear INT = '702024';

WITH

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

CTE_TA_LevyRates AS (
SELECT DISTINCT
TRIM(TAGDescr) AS TAGDescr,
TRIM(SUBSTRING(TAGDescr, 1, 3) + '-' + SUBSTRING(TAGDescr, 4, 3)) AS TAG_Formatted,
LevyRate
FROM KCv_TAGLevyRate23a -- Change to KCv_TAGLevyRate24a in November Fall 2024

),
-------------------------------------
-- CTE_LandDetails
-------------------------------------

CTE_LandDetails_TimberAg AS (
  SELECT
  lh.RevObjId AS [lrsn],
  lh.TotalMktValue,
  ld.SoilIdent,
  ld.LDAcres,
  ld.BaseRate
  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND lh.PostingSource='A'
    AND ld.PostingSource='A'

  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'

  --Change land model id for current year
    AND lh.LandModelId=@LandModelYear
    AND ld.LandModelId=@LandModelYear
    AND ld.SoilIdent IN ('Y1','Y2','Y3','Y4')
    AND ld.LandType IN ('61')
    --AND ld.LandType IN ('4','41','45','52','6','61','62','73','75','8')
    --AND ld.LandType IN ('9','31','32')
    --AND lh.RevObjId=30296
),




/*
Did not use CTE_Soil_Y table because the data is already 
the land detail query; however, left the CTE in case it is
helpful for research later
*/

CTE_SoilRates_YT AS (
Select
soil_id,
soil_rate1
From Soil
Where soil_id IN ('Y1','Y2','Y3','Y4','T1','T2','T3','T4')
),

CTE_SoilRates AS (

SELECT
  pm.lrsn,
  y1.SoilIdent AS SoilIdentY1,
  --y1.LDAcres AS LDAcresY1,
  SUM(CASE
    WHEN y1.LDAcres = 0 THEN 0
    WHEN y1.LDAcres IS NULL THEN 0
    ELSE y1.LDAcres
  END) AS  LDAcresY1,
  
  --y1.BaseRate AS BaseRateY1,

  (Select CTE_SoilRates_YT.soil_rate1 
  FROM CTE_SoilRates_YT 
  WHERE CTE_SoilRates_YT.soil_id IN ('T1')) AS BaseRateT1,
  
  (Select CTE_SoilRates_YT.soil_rate1 
  FROM CTE_SoilRates_YT 
  WHERE CTE_SoilRates_YT.soil_id IN ('Y1')) AS BaseRateY1,
    
  y2.SoilIdent AS SoilIdentY2,
  --y2.LDAcres AS LDAcresY2,
  SUM(CASE
    WHEN y2.LDAcres = 0 THEN 0
    WHEN y2.LDAcres IS NULL THEN 0
    ELSE y2.LDAcres
  END) AS  LDAcresY2,
  
  --y2.BaseRate AS BaseRateY2,
  (Select CTE_SoilRates_YT.soil_rate1 
    FROM CTE_SoilRates_YT 
    WHERE CTE_SoilRates_YT.soil_id IN ('T2')) AS BaseRateT2,
    
  (Select CTE_SoilRates_YT.soil_rate1 
  FROM CTE_SoilRates_YT 
  WHERE CTE_SoilRates_YT.soil_id IN ('Y2')) AS BaseRateY2,



  y3.SoilIdent AS SoilIdentY3,
  --y3.LDAcres AS LDAcresY3,
  SUM(CASE
    WHEN y3.LDAcres = 0 THEN 0
    WHEN y3.LDAcres IS NULL THEN 0
    ELSE y3.LDAcres
  END) AS  LDAcresY3,
  
  --y3.BaseRate AS BaseRateY3,
    (Select CTE_SoilRates_YT.soil_rate1 
    FROM CTE_SoilRates_YT 
    WHERE CTE_SoilRates_YT.soil_id IN ('T3')) AS BaseRateT3,

  (Select CTE_SoilRates_YT.soil_rate1 
  FROM CTE_SoilRates_YT 
  WHERE CTE_SoilRates_YT.soil_id IN ('Y3')) AS BaseRateY3,    
    

  y4.SoilIdent AS SoilIdentY4,
  --y4.LDAcres AS LDAcresY4,
  SUM(CASE
    WHEN y4.LDAcres = 0 THEN 0
    WHEN y4.LDAcres IS NULL THEN 0
    ELSE y4.LDAcres
  END) AS  LDAcresY4,  

  --y4.BaseRate AS BaseRateY4,
  (Select CTE_SoilRates_YT.soil_rate1 
    FROM CTE_SoilRates_YT 
    WHERE CTE_SoilRates_YT.soil_id IN ('T4')) AS BaseRateT4,

  (Select CTE_SoilRates_YT.soil_rate1 
  FROM CTE_SoilRates_YT 
  WHERE CTE_SoilRates_YT.soil_id IN ('Y4')) AS BaseRateY4
  
FROM CTE_TA_PM AS pm

LEFT JOIN CTE_LandDetails_TimberAg AS y1
  ON y1.lrsn=pm.lrsn
  AND y1.SoilIdent IN ('Y1')

LEFT JOIN CTE_LandDetails_TimberAg AS y2
  ON y2.lrsn=pm.lrsn
  AND y2.SoilIdent IN ('Y2')

LEFT JOIN CTE_LandDetails_TimberAg AS y3
  ON y3.lrsn=pm.lrsn
  AND y3.SoilIdent IN ('Y3')

LEFT JOIN CTE_LandDetails_TimberAg AS y4
  ON y4.lrsn=pm.lrsn
  AND y4.SoilIdent IN ('Y4')
  
  GROUP BY
  pm.lrsn,
  y1.SoilIdent,
  y2.SoilIdent,
  y3.SoilIdent,
  y4.SoilIdent
  
  
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
  --'1' AS Homesite_Acre,
  cld.TotalMktValue,
  lr.TAG_Formatted,
  ROUND(lr.LevyRate, 10) AS LevyRate,
  
  sr.SoilIdentY1,
  ROUND(sr.LDAcresY1,4) AS LDAcresY1,
  sr.BaseRateT1,
  sr.BaseRateY1,
  (sr.BaseRateT1-sr.BaseRateY1) AS Difference1,
  ((sr.BaseRateT1-sr.BaseRateY1)*sr.LDAcresY1) AS Deferred1,
  
  sr.SoilIdentY2,
  ROUND(sr.LDAcresY2,4) AS LDAcresY2,
  sr.BaseRateT2,
  sr.BaseRateY2,
    (sr.BaseRateT2-sr.BaseRateY2) AS Difference2,
  ((sr.BaseRateT2-sr.BaseRateY2)*sr.LDAcresY2) AS Deferred2,
  
  sr.SoilIdentY3,
  ROUND(sr.LDAcresY3,4) AS LDAcresY3,
  sr.BaseRateT3,
  sr.BaseRateY3,
    (sr.BaseRateT3-sr.BaseRateY3) AS Difference3,
  ((sr.BaseRateT3-sr.BaseRateY3)*sr.LDAcresY3) AS Deferred3,
  
  sr.SoilIdentY4,
  ROUND(sr.LDAcresY4,4) AS LDAcresY4,
  sr.BaseRateT4,
  sr.BaseRateY4,
  (sr.BaseRateT4-sr.BaseRateY4) AS Difference4,
  ((sr.BaseRateT4-sr.BaseRateY4)*sr.LDAcresY4) AS Deferred4
  
  --  CAST('154' AS INT) AS BLY_Rate_Per_Acre

FROM CTE_TA_PM AS pm

LEFT JOIN CTE_LandDetails_TimberAg AS cld
  ON cld.lrsn = pm.lrsn

LEFT JOIN CTE_TA_LevyRates AS lr
  ON pm.TAG = lr.TAGDescr

LEFT JOIN CTE_SoilRates AS sr
  ON sr.lrsn=pm.lrsn

--WHERE pm.AIN = '149072'
--WHERE pm.AIN = '114667'
--WHERE pm.AIN = '245242'
--pm.lrsn = 30296 --<As test if needed
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  