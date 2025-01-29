SELECT 
    p.lrsn,
    p.pin, 
    TRIM(p.ain) AS AIN, 
    p.neighborhood,
    m.memo_text,
    p.DisplayName

FROM TSBv_PARCELMASTER AS p
    LEFT JOIN memos AS m ON p.lrsn=m.lrsn

WHERE p.EffStatus= 'A'
    AND m.memo_id= '6023'
    AND m.memo_line_number = '2'
    AND m.memo_text <> p.DisplayName

ORDER BY p.neighborhood, p.pin;