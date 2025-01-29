
Declare @TaxYear int;


--LevyRates will change every 11/15
-- Dynamically set the TaxYear based on the current date
If GetDate() < DateFromParts(Year(GetDate()), 11, 15)
    Set @TaxYear = Year(GetDate()) - 1; -- Last year until November 15
Else
    Set @TaxYear = Year(GetDate()); -- Current year after November 15


-- Declare @LandModelYear dynamically
Declare @LandModelYear int;
--DECLARE @LandModelYear INT = '702024';

-- Dynamically set the @LandModelYear based on the current date 
-- Dynamically set the @LandModelYear based on the current date 
If GetDate() < DateFromParts(Year(GetDate()), 1, 5)
    --Set @LandModelYear = 700000 + Year(GetDate()) - 1; -- Last year's value until April 1
    Set @LandModelYear = CONCAT('70', (Year(GetDate())-1)); -- Current year's value after April 1
Else
    --Set @LandModelYear = 700000 + Year(GetDate()); -- Current year's value after April 1
    Set @LandModelYear = CONCAT('70', Year(GetDate())); -- Current year's value after April 1


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
tag.Id AS TAGId
,TRIM(tag.Descr) AS TAG
,CONCAT(LEFT(TRIM(tag.Descr),3),'-',RIGHT(TRIM(tag.Descr),3)) AS TAGFormatted
,SUM(tr.TaxRate) AS LevyRate
--TAG Table
FROM TAG AS tag

--TAGTaxAuthority Key 
JOIN TAGTaxAuthority AS tta
    ON tag.Id=tta.TAGId 
    AND tta.EffStatus = 'A'
    AND tta.BegEffYear = (select max(BegEffYear) from TAGTaxAuthority AS ttasub where ttasub.id = tta.id AND ttasub.BegEffYear <= @TaxYear)

--TaxAuthority Table
JOIN TaxAuthority AS ta 
    ON tta.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
    AND ta.BegEffYear = (select max(BegEffYear) from TaxAuthority AS tasub where tasub.id = ta.id AND tasub.BegEffYear <= @TaxYear)

--Taf key connects TaxAuthority and Fund and TafRate connects to Taf
JOIN Taf AS taf
  ON taf.TaxAuthorityId = ta.id
  AND taf.EffStatus = 'A'
  AND taf.BegEffYear = (select max(BegEffYear) from Taf tafsub where tafsub.id = taf.id AND tafsub.BegEffYear <= @TaxYear)

--TafRate connects to Taf
JOIN TafRate tr
  ON tr.tafid = taf.id
  AND tr.TaxYear = @TaxYear
  AND tr.RateValueType IN (455, 456, 459, 460)
    --Levy on all values - Net Taxable Values
    --Levy on all values except OPT = vt456
    --Levy on all values except OPT, AG, and TIMBER = vt459
    --Levy on all values except OPT, and TIMBER = vt460
WHERE tag.EffStatus = 'A'
AND tag.BegEffYear = (select max(BegEffYear) from TAG AS tagsub where tagsub.id = tag.id AND tagsub.BegEffYear <= @TaxYear)
GROUP BY tag.Id, tag.Descr

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
  lr.TAGFormatted,
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
  ON pm.TAG = lr.TAG

LEFT JOIN CTE_SoilRates AS sr
  ON sr.lrsn=pm.lrsn

--WHERE pm.AIN = '149072'
--WHERE pm.AIN = '114667'
--WHERE pm.AIN = '245242'
--pm.lrsn = 30296 --<As test if needed
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  