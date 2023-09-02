


-------------------------------------
-- CTE_LandDetails
-------------------------------------

CTE_TA_LandDetails AS (
  --Change land model id for current year
    SELECT
  lh.RevObjId,
  lh.TotalMktValue
  --Land Header
  FROM LandHeader AS lh
  /*
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND lh.PostingSource=ld.PostingSource
    AND ld.PostingSource='A'
    AND ld.LandModelId='702023'
  
  --Land Types
  LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type
  */
  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'
    AND lh.LandModelId='702023'
    --Looking for:
  -- AND lh.RevObjId = '1702' --< Used as a test case
)