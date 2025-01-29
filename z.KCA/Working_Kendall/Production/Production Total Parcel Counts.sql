-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT
  DISTINCT(p.neighborhood),
  p.NeighborHoodName,
  COUNT(DISTINCT p.AIN) 

FROM TSBv_PARCELMASTER as p
  JOIN neigh_control AS nc ON nc.neighborhood = p.neighborhood
    AND nc.inactivate_date = '99991231'

WHERE p.EffStatus = 'A'
  AND p.neighborhood < '999'
  OR p.neighborhood = '1000'
  OR p.neighborhood = '1020'
  OR p.neighborhood = '5000'
  OR p.neighborhood = '5002'
  OR p.neighborhood = '6000'
  OR p.neighborhood = '6002'
  OR p.neighborhood > '9000'

GROUP BY p.neighborhood,
         p.NeighborHoodName

ORDER BY p.neighborhood ASC
;