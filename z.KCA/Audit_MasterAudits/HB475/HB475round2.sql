SELECT 
    p.lrsn AS [LRSN],
    TRIM(p.pin) AS [PIN],
    TRIM(p.ain) AS [AIN], 
    p.neighborhood AS [GEO], 
    P.DisplayName AS [OWNER_NAME],
    FORMAT(t.pxfer_date, 'yyyy-MM-dd') AS [TRANSFER_DATE],
    t.GrantorName AS [TRANSFERRED_TO],
    pe.permit_ref AS [PERMIT_NO.],
    m.memo_text AS [NC_MEMO_TEXT]


FROM TSBv_PARCELMASTER AS p
    LEFT JOIN memos AS m ON p.lrsn = m.lrsn
        AND m.memo_id= 'NC24'
        AND m.memo_line_number = '2'
    RIGHT JOIN permits AS pe ON p.lrsn = pe.lrsn
        AND pe.status='A'
        AND (pe.permit_desc LIKE 'HB475%'
        OR pe.permit_desc LIKE '%HB475%'
        OR pe.permit_desc LIKE '%HB475')
    JOIN field_visit AS fv ON pe.lrsn=fv.lrsn AND pe.field_number=fv.field_number
        AND fv.date_completed IS NOT NULL
        AND fv.need_to_visit='N'
    LEFT JOIN transfer AS t ON p.lrsn = t.lrsn
        AND t.status = 'A'
        AND t.pxfer_date > '20231201'

WHERE p.EffStatus= 'A'
;