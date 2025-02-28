/*
AsTxDBProd
GRM_Main

Multiple Queries, check them all before selecting

Timber AG Only:   
AND ld.LandType IN ('4','41','45','52','6','61','62','73','75','8')



*/


----------
--Land Header + Land Detail + Land Types Key
----------

SELECT
lh.RevObjId,
ld.LandDetailType,
ld.LandType,
lt.land_type_desc,
ld.SoilIdent

--Land Header
FROM LandHeader AS lh
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND lh.PostingSource=ld.PostingSource
--Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

WHERE lh.EffStatus= 'A' 
  AND lh.LandModelId='702023'
  AND ld.LandModelId='702023'
  AND lh.PostingSource='A'
  AND ld.PostingSource='A'

----------
--Land Types Key
----------
SELECT
land_type,
land_type_desc

FROM land_types