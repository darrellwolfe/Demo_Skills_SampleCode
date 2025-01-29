
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
If GetDate() < DateFromParts(Year(GetDate()), 1, 5)
    --Set @LandModelYear = 700000 + Year(GetDate()) - 1; -- Last year's value until April 1
    Set @LandModelYear = CONCAT('70', (Year(GetDate())-1)); -- Current year's value after April 1
Else
    --Set @LandModelYear = 700000 + Year(GetDate()); -- Current year's value after April 1
    Set @LandModelYear = CONCAT('70', Year(GetDate())); -- Current year's value after April 1

WITH

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
  lr.TAGFormatted,
  ROUND(lr.LevyRate,10) AS LevyRate,
  base.TotalBaseRate
--  CAST('154' AS INT) AS BLY_Rate_Per_Acre

FROM CTE_TA_PM AS pm

JOIN CTE_TA_LandDetails AS cld
  ON cld.RevObjId = pm.lrsn

JOIN CTE_TA_LevyRates AS lr
  ON pm.TAG = lr.TAG

JOIN CTE_LandDetails_TimberAg AS base
  ON base.lrsn=pm.lrsn

  --WHERE pm.lrsn = 30296 --<As test if needed
  --Where pm.AIN = '123237'
--  Where pm.AIN = '253955'