SELECT DISTINCT
    p.lrsn AS LRSN,
    TRIM(p.pin) AS PIN,
    TRIM(p.AIN) AS AIN,
    TRIM(m.memo_id) AS MEMO_ID

FROM TSBv_PARCELMASTER AS p
    JOIN memos AS m ON p.lrsn = m.lrsn
        AND m.memo_id LIKE 'RY%'
        AND (RIGHT(m.memo_id,2) >= RIGHT((YEAR(CURRENT_TIMESTAMP)-1),2) OR RIGHT(m.memo_id,2) >= RIGHT((YEAR(CURRENT_TIMESTAMP)+1),2))

WHERE p.EffStatus = 'A'