-- !preview conn=con

SELECT
TRIM(p.pin) AS [PIN],
TRIM(p.AIN) AS [AIN],
p.neighborhood AS [GEO],
m.memo_text


FROM TSBv_PARCELMASTER AS p
JOIN memos AS m ON p.lrsn=m.lrsn
WHERE p.EffStatus = 'A'
AND m.memo_id = 'NC24'
AND m.memo_line_number = '2'