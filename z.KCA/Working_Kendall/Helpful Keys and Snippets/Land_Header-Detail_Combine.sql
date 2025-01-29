--CTE_LandTables AS(
SELECT
    *

FROM LandHeader AS lh
    JOIN LandDetail AS ld ON lh.Id = ld.LandHeaderId
--)
