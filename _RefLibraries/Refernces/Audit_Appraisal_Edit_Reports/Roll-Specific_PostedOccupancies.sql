DECLARE @CURRENTYEAR AS int = CONCAT((YEAR(GETDATE())),'0101')
;

SELECT 
    TRIM(p.pin) AS PIN,
    TRIM(p.AIN) AS AIN,
    p.neighborhood AS GEO,
    RIGHT(m.memo_text,10) AS OCCUPANCY_DATE,
    CAST(v.last_update AS DATE) AS POSTED_DATE
    

FROM TSBv_PARCELMASTER AS p 
    JOIN valuation AS v ON p.lrsn = v.lrsn
        AND v.eff_year > @CURRENTYEAR
    JOIN memos AS m ON p.lrsn = m.lrsn
        AND m.memo_id = 'NC24'
        AND m.memo_line_number = '2'

WHERE p.EffStatus = 'A'
    AND v.status = 'A'

ORDER BY POSTED_DATE