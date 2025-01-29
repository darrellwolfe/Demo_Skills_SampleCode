-- !preview conn=con

SELECT DISTINCT
TRIM(p.pin) AS [PIN],
TRIM(p.AIN) AS [AIN],
p.neighborhood AS [GEO],
p.PropClassDescr,
m.memo_text
FROM TSBv_PARCELMASTER AS p
JOIN allocations AS a ON p.lrsn = a.lrsn
  AND a.status = 'A'
  AND a.group_code = '81'
  AND a.eff_year = '0'
JOIN memos AS m ON p.lrsn=m.lrsn
  AND (m.memo_id = '602W'
  OR m.memo_id = '6023')
  AND m.memo_line_number = '2'

WHERE p.ClassCd <> '681'

ORDER BY p.neighborhood ASC