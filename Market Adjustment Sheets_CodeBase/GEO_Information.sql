/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/


--------------------------------
--GEO Counts, GEO Names for Market Adjustments
--------------------------------
Select Distinct
pm.neighborhood AS [GEO],
LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
COUNT(pm.lrsn) AS [Count_of_PINs]

From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
AND pm.neighborhood IS NOT NULL

GROUP BY pm.neighborhood, pm.NeighborHoodName

ORDER BY [GEO]


