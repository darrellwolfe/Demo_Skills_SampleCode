/*
DESCRIPTION: Lists all 81s allocations within ProVal; 
at this time, there are 3 reasons an 81 should be applied:
1. HB519 (Land Developer's Credit)
2. Statute-Exempt Property
3. HB475 (Exempt until improvement is finished) (OLD Historical method)
Any other reason should have a different allocation applied.
*/
SELECT DISTINCT
  CASE
    WHEN p.neighborhood >= 9000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 6003 THEN 'District_6'
    WHEN p.neighborhood = 6002 THEN 'Manufactured_Homes'
    WHEN p.neighborhood = 6001 THEN 'District_6'
    WHEN p.neighborhood = 6000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 5003 THEN 'District_5'
    WHEN p.neighborhood = 5002 THEN 'Manufactured_Homes'
    WHEN p.neighborhood = 5001 THEN 'District_5'
    WHEN p.neighborhood = 5000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 4000 THEN 'District_4'
    WHEN p.neighborhood >= 3000 THEN 'District_3'
    WHEN p.neighborhood >= 2000 THEN 'District_2'
    WHEN p.neighborhood >= 1021 THEN 'District_1'
    WHEN p.neighborhood = 1020 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 1001 THEN 'District_1'
    WHEN p.neighborhood = 1000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 451 THEN 'Commercial'
    WHEN p.neighborhood = 450 THEN 'Specialized_Cell_Towers'
    WHEN p.neighborhood >= 1 THEN 'Commercial'
    WHEN p.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS [District],
    p.neighborhood AS [GEO],
    TRIM(p.pin) AS [PIN],
    TRIM(p.AIN) AS [AIN],
    a.group_code AS [GC],
    p.ClassCd AS [PCC],
    p.DisplayName,
    m1.memo_text AS HB519Memo,
    m2.memo_text AS [81ExemptMemo],
    m3.memo_text AS HB475Memo

FROM TSBv_PARCELMASTER AS p
  JOIN allocations AS a ON p.lrsn = a.lrsn
    AND a.status = 'A'
    AND a.group_code IN ('81','81L')
  LEFT JOIN memos AS m1 ON p.lrsn = m1.lrsn
    AND m1.memo_id = '602W'
    AND m1.memo_line_number = '2'
  LEFT JOIN memos AS m2 ON p.lrsn = m2.lrsn
    AND m2.memo_id = 'EX81'
    AND m2.memo_line_number = '2'
  LEFT JOIN memos AS m3 ON p.lrsn = m3.lrsn
    AND m3.memo_id = '6023'
    AND m3.memo_line_number = '2'

WHERE p.EffStatus = 'A'
  AND p.neighborhood > '0'
  AND p.ClassCd <> '681'

ORDER BY DisplayName, AIN