-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT DISTINCT
  p.neighborhood,
  CASE
    WHEN p.neighborhood IN ('9201', '9202', '9203', '9205', '9208', '9209', '9210', '9214', '9217', '9219', '9104', '9111', '9115', '9119', '1000', '1020', '5000', '5002', '6000', '6002', '9100') THEN '2023'
    WHEN p.neighborhood IN ('9107', '9109', '9110', '9113', '9117', '9204', '9207', '9212', '9213', '9216', '9218', '9220', '9221', '9222', '9223') THEN '2024'
    WHEN p.neighborhood IN ('9102', '9103', '9112', '9118', '9105', '9106', '9120', '9108', '9314', '9305', '9306', '9312', '9601') THEN '2025'
    WHEN p.neighborhood IN ('9302', '9303', '9304', '9307', '9308', '9309', '9310', '9311', '9315', '9404', '9403', '9412', '9414', '9407', '9501', '9503') THEN '2026'
    WHEN p.neighborhood IN ('9401', '9405', '9406', '9409', '9418', '9411', '9413', '9417', '9415', '9416') THEN '2027'
    ELSE 'Review'
    END AS [Reval Year],
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  e.extension,
  e.data_collector,
  e.collection_date

FROM TSBv_PARCELMASTER AS p 
  JOIN extensions AS e ON e.lrsn = p.lrsn
    AND e.collection_date >= '2022-04-16'
    AND e.collection_date <= '2027-04-15'
    AND e.extension = 'L00'
    AND e.status = 'A'

WHERE p.EffStatus = 'A'
  AND p.neighborhood = '1000'
  OR p.neighborhood = '1020'
  OR p.neighborhood = '5000'
  OR p.neighborhood = '5002'
  OR p.neighborhood = '6000'
  OR p.neighborhood = '6002'
  OR p.neighborhood >= '9000'
;