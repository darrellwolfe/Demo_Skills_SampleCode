SELECT 
    TRIM(p.AIN) AS [AIN],
    TRIM(p.pin) AS [PIN],
    p.neighborhood AS [GEO],
    m.memo_text,
    m2.memo_text,
    m3.memo_text
FROM TSBv_PARCELMASTER AS p
    JOIN memos AS m ON m.lrsn = p.lrsn
        AND m.memo_id = 'IMP'
        AND m.memo_line_number > '1'
        AND (m.memo_text LIKE '%24%HB475%'
            OR m.memo_text LIKE '%24%occ%')
    LEFT JOIN memos AS m2 ON m2.lrsn = p.lrsn
        AND m2.memo_id = 'NC24'
        AND m2.memo_line_number = '2'
    LEFT JOIN memos AS m3 ON m3.lrsn = p.lrsn
        AND m3.memo_id = '6023'
        AND m3.memo_line_number = '2'

WHERE p.EffStatus = 'A'
    AND m2.memo_text IS NULL
    AND m3.memo_text IS NULL

ORDER BY GEO