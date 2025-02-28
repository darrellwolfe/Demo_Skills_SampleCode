-- !preview conn=con

CTE_Memos_CHUT AS (
----------------------------------------
-- Instead of Concat, use STRING_AGG to keep all memos on one row
----------------------------------------
SELECT DISTINCT
    m1.lrsn,
    STRING_AGG(CAST(m1.memo_text AS VARCHAR(MAX)), ', ') AS [MemoText_ImpLand]
FROM memos AS m1

--WHERE m1.memo_id IN ('CELL') 
WHERE m1.memo_id IN ('CHUT') 
AND m1.memo_line_number <> 1

GROUP BY m1.lrsn

),