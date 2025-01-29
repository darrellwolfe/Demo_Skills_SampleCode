-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/
WITH CTE_CommercialField AS (
SELECT DISTINCT
  p.neighborhood,
  CASE
    WHEN p.neighborhood IN ('35', '36', '37', '38', '39', '47', '95', '27', '101', '102', '103', '104', '106', '108', '109', '110', '42', '828', '9201', '9202', '9203', '9205', '9208', '9209', '9210', '9214', '9217', '9219', '9104', '9111', '9115', '9119', '1000', '1020', '5000', '5002', '6000', '6002', '9100', '450') THEN '2023'
    ELSE 'Review'
    END AS [Reval Year],
  p.lrsn,
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  e.extension,
  e.data_collector,
  e.collection_date

FROM TSBv_PARCELMASTER AS p 
  JOIN extensions AS e ON e.lrsn = p.lrsn
    AND e.collection_date >= '2022-04-16'
    AND e.collection_date <= '2023-04-15'
    AND e.extension = 'L00'
    AND e.status = 'A'

WHERE p.EffStatus = 'A'
  AND p.neighborhood <= '999'
  OR p.neighborhood = '1000'
  OR p.neighborhood = '1020'
  OR p.neighborhood = '5000'
  OR p.neighborhood = '5002'
  OR p.neighborhood = '6000'
  OR p.neighborhood = '6002'
  OR p.neighborhood >= '9000'
),

CTE_CommercialCompleted AS (
SELECT DISTINCT
  p.neighborhood,
  CASE
    WHEN p.neighborhood IN ('35', '36', '37', '38', '39', '47', '95', '27', '101', '102', '103', '104', '106', '108', '109', '110', '42', '828', '9201', '9202', '9203', '9205', '9208', '9209', '9210', '9214', '9217', '9219', '9104', '9111', '9115', '9119', '1000', '1020', '5000', '5002', '6000', '6002', '9100', '450') THEN '2023'
    ELSE 'Review'
    END AS [Reval Year],
  p.lrsn,
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  e.extension,
  e.appraiser,
  e.appraisal_date

FROM TSBv_PARCELMASTER AS p 
  JOIN extensions AS e ON e.lrsn = p.lrsn
    AND e.appraisal_date >= '2022-04-16'
    AND e.appraisal_date <= '2023-04-15'
    AND e.extension = 'L00'
    AND e.status = 'A'

WHERE p.EffStatus = 'A'
  AND p.neighborhood <= '999'
  OR p.neighborhood = '1000'
  OR p.neighborhood = '1020'
  OR p.neighborhood = '5000'
  OR p.neighborhood = '5002'
  OR p.neighborhood = '6000'
  OR p.neighborhood = '6002'
  OR p.neighborhood >= '9000'
),

CTE_TotalCommerical AS (
SELECT
  DISTINCT(p.neighborhood),
  p.NeighborHoodName,
  COUNT(DISTINCT p.AIN) AS [Total Parcel Count] 

FROM TSBv_PARCELMASTER as p
  JOIN neigh_control AS nc ON nc.neighborhood = p.neighborhood
    AND nc.inactivate_date = '99991231'

WHERE p.EffStatus = 'A'
  AND (p.neighborhood > '0'
  OR p.neighborhood <= '999'
  OR p.neighborhood = '1000'
  OR p.neighborhood = '1020'
  OR p.neighborhood = '5000'
  OR p.neighborhood = '5002'
  OR p.neighborhood = '6000'
  OR p.neighborhood = '6002'
  OR p.neighborhood >= '9000')

GROUP BY p.neighborhood,
         p.NeighborHoodName
)

SELECT
  cf.neighborhood,
  COUNT(cf.neighborhood) AS [Fielded Count],
  COUNT(cc.neighborhood) AS [Appraised Count],
  tc.[Total Parcel Count]
  
FROM 
  CTE_CommercialField AS cf
JOIN
  CTE_CommercialCompleted AS cc ON cf.lrsn = cc.lrsn
left JOIN
  CTE_TotalCommerical AS tc ON tc.neighborhood = cf.neighborhood

WHERE 
  cf.[Reval Year] = '2023'
  AND cc.[Reval Year] = '2023'
  
GROUP BY
  cf.neighborhood,
  tc.[Total Parcel Count]
  
ORDER BY
  cf.neighborhood
;