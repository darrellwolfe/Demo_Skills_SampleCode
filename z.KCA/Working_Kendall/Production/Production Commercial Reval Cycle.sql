-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

SELECT DISTINCT
  p.neighborhood,
  CASE
    WHEN p.neighborhood IN ('35', '36', '37', '38', '39', '47', '95', '27', '101', '102', '103', '104', '106', '108', '109', '110', '42', '9201', '9202', '9203', '9205', '9208', '9209', '9210', '9214', '9217', '9219', '9104', '9111', '9115', '9119', '1000', '1020', '5000', '5002', '6000', '6002', '9100', '450', '828') THEN '2023'
    WHEN p.neighborhood IN ('1', '15', '16', '17', '2', '33', '42', '9107', '9109', '9110', '9113', '9117', '9204', '9207', '9212', '9213', '9216', '9218', '9220', '9221', '9222', '9223') THEN '2024'
    WHEN p.neighborhood IN ('3', '4', '6', '7', '8', '9', '10', '12', '13', '25', '26', '43', '42', '9102', '9103', '9112', '9118', '9105', '9106', '9120', '9108', '9314', '9305', '9306', '9312', '9601', '829') THEN '2025'
    WHEN p.neighborhood IN ('14', '18', '19', '20', '21', '22', '23', '24', '28', '29', '30', '31', '32', '34', '40', '44', '45', '42', '9302', '9303', '9304', '9307', '9308', '9309', '9310', '9311', '9315', '9404', '9403', '9412', '9414', '9407', '9501', '9503') THEN '2026'
    WHEN p.neighborhood IN ('801', '802', '803', '804', '805', '806', '807', '808', '809', '810', '811', '812', '813', '814', '815', '816', '817', '818', '819', '820', '821', '822', '823', '824', '825', '826', '827', '42', '9401', '9405', '9406', '9409', '9418', '9411', '9413', '9417', '9415', '9416') THEN '2027'
    ELSE 'Review'
    END AS [Reval Year],
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  e.extension,
  e.data_collector,
  e.collection_date,
  e.appraiser,
  e.appraisal_date,
  m.memo_id,
  m.memo_text

FROM extensions AS e
  JOIN TSBv_PARCELMASTER AS p ON e.lrsn = p.lrsn
    AND p.EffStatus = 'A'
    AND (p.neighborhood <= '999'
    OR p.neighborhood = '1000'
    OR p.neighborhood = '1020'
    OR p.neighborhood = '5000'
    OR p.neighborhood = '5002'
    OR p.neighborhood = '6000'
    OR p.neighborhood = '6002'
    OR p.neighborhood >= '9000')
  JOIN memos as m ON p.lrsn = m.lrsn
    AND m.memo_id IN ('RY23','RY24','RY25','RY26','RY27')
    and m.memo_line_number = '2'

WHERE e.collection_date >= '2022-04-16'
  AND e.collection_date <= '2027-04-15'
  AND e.extension = 'L00'
  AND e.status = 'A'
;