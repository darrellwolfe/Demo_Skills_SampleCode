-- !preview conn=con
WITH cte_memo AS (
    SELECT
        CASE WHEN PATINDEX('%[0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', memo_text) > 0
             THEN SUBSTRING(memo_text, PATINDEX('%[0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', memo_text), 10)
             ELSE NULL
        END AS extracted_date,
        lrsn, memo_id, memo_line_number, memo_text
    FROM
        memos
    WHERE
        memo_id = 'NC23'
        AND memo_line_number = '2'
        AND memo_text LIKE '%Prepped%'
),

cte_allocations AS (
    SELECT A.lrsn, SUM(A.cost_value) AS total_cost
    FROM ALLOCATIONS AS A
    WHERE status = 'A' AND A.group_code = '81'
    GROUP BY A.lrsn
)

SELECT DISTINCT
   cte_memo.lrsn, T.pin, T.AIN, T.TAG, T.neighborhood, cte_memo.memo_id, cte_memo.memo_line_number, cte_memo.memo_text, cte_memo.extracted_date, A.total_cost
FROM
    cte_memo
LEFT JOIN TSBV_PARCELMASTER AS T ON cte_memo.lrsn = T.lrsn
LEFT JOIN cte_allocations AS A ON A.lrsn = cte_memo.lrsn;
