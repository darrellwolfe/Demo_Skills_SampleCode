-- !preview conn=conn


WITH 
  CTE_LandDetails AS (
  SELECT
  lh.RevObjId,
  ld.LandDetailType,
  ld.LandType,
  ld.lcm,
  lt.land_type_desc,
  ld.SoilIdent,
  ld.LDAcres,
  ld.ActualFrontage,
  ld.DepthFactor,
  ld.SoilProdFactor,
  ld.SmallAcreFactor
  
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND lh.PostingSource=ld.PostingSource
  --Land Types
  LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type
  
  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'
    AND ld.PostingSource='A'
  --Change land model id for current year
    AND lh.LandModelId='702023'
    AND ld.LandModelId='702023'
  --Looking for:
    --AND ld.LandType IN ('82')
  )

SELECT DISTINCT
  pm.lrsn,
  pm.neighborhood AS GEO,
  clt.LandDetailType,
  clt.lcm,
  clt.LandType,
  clt.land_type_desc,
  clt.SoilIdent,
  clt.LDAcres,
  clt.ActualFrontage,
  clt.DepthFactor,
  clt.SoilProdFactor,
  clt.SmallAcreFactor,
  pm.DisplayName AS Owner,
  pm.MailingAddress,
  pm.MailingCityStZip,
  pm.pin,
  pm.AIN,
  pm.TAG,
  pm.DisplayDescr AS Legal_Desc,
  pm.LegalAcres

FROM TSBv_PARCELMASTER AS pm
LEFT JOIN CTE_LandDetails AS clt
  ON pm.lrsn=clt.RevObjId

WHERE pm.EffStatus = 'A'
--AND clt.LandType IN ('2','6','33')
--AND clt.lcm IN ('30')
--AND clt.lcm IN ('3') -- None in both 3 & 30. Good to know. So I can build both into one cell on the worksheet.
AND clt.LandType = '32'
AND clt.lcm IN ('2','32')
AND pm.neighborhood = 1615