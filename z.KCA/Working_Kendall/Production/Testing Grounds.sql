-- !preview conn=con

WITH CTE_CommercialField AS (
SELECT DISTINCT
  p.neighborhood,
  CASE
    WHEN p.neighborhood IN ('1', '2', '15', '16', '17', '33', '42', '9204', '9212', '9213', '9216', '9218', '9207', '9220', '9221', '9223', '9107', '9109', '9110', '9113', '9222', '9117') THEN '2024'    
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
    AND e.collection_date >= '2023-04-16'
    AND e.collection_date <= '2024-04-15'
    AND e.extension = 'L00'
    AND e.status = 'A'

WHERE p.EffStatus = 'A'
  AND (p.neighborhood <= '999'
  OR p.neighborhood = '1000'
  OR p.neighborhood = '1020'
  OR p.neighborhood = '5000'
  OR p.neighborhood = '5002'
  OR p.neighborhood = '6000'
  OR p.neighborhood = '6002'
  OR p.neighborhood >= '9000')
),

CTE_CommercialCompleted AS (
SELECT DISTINCT
  p.neighborhood,
  CASE
    WHEN p.neighborhood IN ('1', '2', '15', '16', '17', '33', '42', '9204', '9212', '9213', '9216', '9218', '9207', '9220', '9221', '9223', '9107', '9109', '9110', '9113', '9222', '9117') THEN '2024'
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
    AND e.appraisal_date >= '2023-04-16'
    AND e.appraisal_date <= '2024-04-15'
    AND e.extension = 'L00'
    AND e.status = 'A'

WHERE p.EffStatus = 'A'
  AND (p.neighborhood <= '999'
  OR p.neighborhood = '1000'
  OR p.neighborhood = '1020'
  OR p.neighborhood = '5000'
  OR p.neighborhood = '5002'
  OR p.neighborhood = '6000'
  OR p.neighborhood = '6002'
  OR p.neighborhood >= '9000')
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
  AND (p.neighborhood <= '999'
  OR p.neighborhood = '1000'
  OR p.neighborhood = '1020'
  OR p.neighborhood = '5000'
  OR p.neighborhood = '5002'
  OR p.neighborhood = '6000'
  OR p.neighborhood = '6002'
  OR p.neighborhood >= '9000')

GROUP BY p.neighborhood,
         p.NeighborHoodName
),

CTE_RYMemo AS (
SELECT DISTINCT
  p.lrsn,
  p.neighborhood,
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  m.memo_text,
  REPLACE(LEFT(m.memo_text,4),'-','') AS [Appraiser Initials]

FROM TSBv_PARCELMASTER as p
  JOIN memos AS m ON p.lrsn = m.lrsn
    AND m.memo_id = 'RY24'
    AND m.memo_line_number = '2'

WHERE p.EffStatus = 'A'
  AND (p.neighborhood <= '999'
  OR p.neighborhood = '1000'
  OR p.neighborhood = '1020'
  OR p.neighborhood = '5000'
  OR p.neighborhood = '5002'
  OR p.neighborhood = '6000'
  OR p.neighborhood = '6002'
  OR p.neighborhood >= '9000')
)

SELECT
  tc.neighborhood,
  cf.AIN,
  cf.data_collector,
  cc.appraiser,
  ry.[Appraiser Initials]
  
FROM 
  CTE_CommercialField AS cf
FULL JOIN
  CTE_CommercialCompleted AS cc ON cf.lrsn = cc.lrsn
FULL JOIN
  CTE_TotalCommerical AS tc ON tc.neighborhood = cf.neighborhood
FULL JOIN
  CTE_RYMemo AS ry ON cf.lrsn = ry.lrsn
  
WHERE tc.neighborhood IN ('1', '2', '15', '16', '17', '33', '42', '9204', '9212', '9213', '9216', '9218', '9207', '9220', '9221', '9223', '9107', '9109', '9110', '9113', '9222', '9117')

;