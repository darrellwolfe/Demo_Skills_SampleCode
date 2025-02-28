


-------------------------------------
-- CTE_LandDetails
-------------------------------------

CTE_LandDetails AS (
SELECT
lh.RevObjId,
ld.LandDetailType,
ld.LandType,
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