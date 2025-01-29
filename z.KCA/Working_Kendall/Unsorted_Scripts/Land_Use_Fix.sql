WITH CTE_LandUse AS (
SELECT 
  m.lrsn,
  m.ain,
  m.PINStatus,
  m.ModifierStatus,
  m.ModifierDescr,
  m.ExpirationYear
FROM TSBv_MODIFIERS AS m
WHERE m.ModifierShortDescr = 'LandUse'
  AND m.PINStatus = 'A'
  AND m.ModifierStatus = 'A'
  AND m.ExpirationYear > '2024'
  AND NOT EXISTS 
    (SELECT 1
    FROM TSBv_MODIFIERS AS m2
    WHERE m2.lrsn = m.lrsn
      AND m2.ModifierShortDescr IN ('Timber','SpecLand')
      AND m2.PINStatus = 'A'
      AND m2.ModifierStatus = 'A'
      AND m2.ExpirationYear > '2024')
),
CTE_LandDetail AS (
SELECT
  lh.RevObjId,
  lh.BegEffDate,
  ld.LandType
FROM LandHeader AS lh
  JOIN LandDetail AS ld ON lh.Id = ld.LandHeaderId
WHERE ld.EffStatus = 'A'
  AND ld.PostingSource = 'A'
  AND ld.LandType IN ('4','52','61')
  AND lh.EffStatus = 'A'
  AND lh.BegEffDate = '20240101'
)

SELECT 
  lu.*,
  cld.LandType

FROM CTE_LandUse AS lu
  LEFT JOIN CTE_LandDetail AS cld ON lu.lrsn = cld.RevObjId

ORDER BY lu.ain