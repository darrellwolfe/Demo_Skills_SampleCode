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
)
SELECT
    extracted_date, lrsn, memo_id, memo_line_number, memo_text
FROM
    cte_memo;
