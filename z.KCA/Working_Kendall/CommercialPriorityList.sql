DECLARE @CURRENTYEAR AS date = CONCAT((YEAR(GETDATE())),'0101')
;

SELECT 
    TRIM(p.AIN) AS [AIN],
    TRIM(p.pin) AS [PIN],
    p.neighborhood AS [GEO],
    TRIM(pe.permit_ref) [PERMIT_NO.],
    FORMAT(pe.cert_for_occ,'MM/dd/yyyy') AS [CO_DATE],
    m.memo_text

FROM TSBv_PARCELMASTER AS p
    JOIN permits AS pe ON p.lrsn = pe.lrsn
        AND pe.status = 'A'
        AND pe.cert_for_occ > @CURRENTYEAR
        AND pe.permit_type NOT IN ('3','9')
    LEFT JOIN memos AS m ON p.lrsn = m.lrsn
        AND m.memo_id = 'NC24'
        AND m.memo_line_number = '2'

WHERE p.EffStatus = 'A'
    AND p.neighborhood < '1000'

ORDER BY 
    GEO,
    AIN,
    [PERMIT_NO.]