-- !preview conn=con

--See both for use cases and example below. 

----------------------------------------
-- Instead of Concat, use STRING_AGG to keep all memos on one row
----------------------------------------

SELECT 
    m1.lrsn,
    STRING_AGG(CAST(m.memo_text AS VARCHAR(MAX)), ', ') AS [MemoText]
FROM memos AS m1
LEFT JOIN memos AS m ON m1.lrsn = m.lrsn AND m.memo_id IN ('LAND','IMP')

WHERE m.memo_id IN ('LAND','IMP') AND m1.memo_line_number = '1'
GROUP BY m1.lrsn


--EXAMPLE
CTE_MemosCTWR AS (
----------------------------------------
-- Instead of Concat, use STRING_AGG to keep all memos on one row
----------------------------------------
SELECT DISTINCT
    m1.lrsn,
    STRING_AGG(CAST(m1.memo_text AS VARCHAR(MAX)), ', ') AS [MemoText_CTWR]
FROM memos AS m1

WHERE m1.memo_id IN ('CELL') 
--WHERE m1.memo_id IN ('CELL','LAND','IMP') 

GROUP BY m1.lrsn

),

CTE_Memos_Imp_Land AS (
----------------------------------------
-- Instead of Concat, use STRING_AGG to keep all memos on one row
----------------------------------------
SELECT DISTINCT
    m1.lrsn,
    STRING_AGG(CAST(m1.memo_text AS VARCHAR(MAX)), ', ') AS [MemoText_Imp_Land]
FROM memos AS m1

--WHERE m1.memo_id IN ('CELL') 
WHERE m1.memo_id IN ('LAND','IMP') 

GROUP BY m1.lrsn

),

CTE_Memos_CHUT AS (
----------------------------------------
-- Instead of Concat, use STRING_AGG to keep all memos on one row
----------------------------------------
SELECT DISTINCT
    m1.lrsn,
    STRING_AGG(CAST(m1.memo_text AS VARCHAR(MAX)), ', ') AS [MemoText_CHUT]
FROM memos AS m1

--WHERE m1.memo_id IN ('CELL') 
WHERE m1.memo_id IN ('CHI') 
--AND m1.memo_line_number <> 1

GROUP BY m1.lrsn

),


----------------------------------------
-- CONCAT How we orirginally pulled in multiple memos rows into one row, avoiding duplicates
----------------------------------------


SELECT
m1.lrsn,
m1.memo_text,
LTRIM(RTRIM(CONCAT(m2.memo_text, '.', m3.memo_text,'.', m4.memo_text,'.', 
    m5.memo_text,'.', m6.memo_text,'.', m7.memo_text))) AS [MemoText]

FROM memos AS m1

LEFT JOIN memos AS m2 ON m1.lrsn=m2.lrsn AND m2.memo_id = 'PERM' AND m2.memo_line_number = '2'
LEFT JOIN memos AS m3 ON m1.lrsn=m3.lrsn AND m3.memo_id = 'PERM' AND m3.memo_line_number = '3'
LEFT JOIN memos AS m4 ON m1.lrsn=m4.lrsn AND m4.memo_id = 'PERM' AND m4.memo_line_number = '4'
LEFT JOIN memos AS m5 ON m1.lrsn=m2.lrsn AND m5.memo_id = 'PERM' AND m5.memo_line_number = '5'
LEFT JOIN memos AS m6 ON m1.lrsn=m3.lrsn AND m6.memo_id = 'PERM' AND m6.memo_line_number = '6'
LEFT JOIN memos AS m7 ON m1.lrsn=m4.lrsn AND m7.memo_id = 'PERM' AND m7.memo_line_number = '7'
    
WHERE m1.memo_id = 'PERM' AND m1.memo_line_number = '1'

----------------------------------------
-- CONCAT with CAST
----------------------------------------


SELECT
m1.lrsn,
m1.memo_text,
    LTRIM(RTRIM(CONCAT(
        CAST(m2.memo_text AS VARCHAR(MAX)), '.', 
        CAST(m3.memo_text AS VARCHAR(MAX)), '.', 
        CAST(m4.memo_text AS VARCHAR(MAX)), '.', 
        CAST(m5.memo_text AS VARCHAR(MAX)), '.', 
        CAST(m6.memo_text AS VARCHAR(MAX)), '.', 
        CAST(m7.memo_text AS VARCHAR(MAX))))) AS [MemoText]

FROM memos AS m1

LEFT JOIN memos AS m2 ON m1.lrsn=m2.lrsn AND m2.memo_id = 'PERM' AND m2.memo_line_number = '2'
LEFT JOIN memos AS m3 ON m1.lrsn=m3.lrsn AND m3.memo_id = 'PERM' AND m3.memo_line_number = '3'
LEFT JOIN memos AS m4 ON m1.lrsn=m4.lrsn AND m4.memo_id = 'PERM' AND m4.memo_line_number = '4'
LEFT JOIN memos AS m5 ON m1.lrsn=m2.lrsn AND m5.memo_id = 'PERM' AND m5.memo_line_number = '5'
LEFT JOIN memos AS m6 ON m1.lrsn=m3.lrsn AND m6.memo_id = 'PERM' AND m6.memo_line_number = '6'
LEFT JOIN memos AS m7 ON m1.lrsn=m4.lrsn AND m7.memo_id = 'PERM' AND m7.memo_line_number = '7'
    
WHERE m1.memo_id = 'PERM' AND m1.memo_line_number = '1'

/*
However, you can run into a character limit with STRING_AGG and we don't have write access
to change the data type. You can use the cast or convert if you are still runnning into issues. 

GPT-4:
Certainly, Darrell! Using `CAST` or `CONVERT` to change the data type in your query 
can indeed be a solution when dealing with potential truncation, 
especially if you have read-only access and can't change the underlying table schema.

Here's how you might modify your original query using `CAST`:

```sql
SELECT
    m1.memo_text,
    LTRIM(RTRIM(CONCAT(
        CAST(m2.memo_text AS VARCHAR(MAX)), '.', 
        CAST(m3.memo_text AS VARCHAR(MAX)), '.', 
        CAST(m4.memo_text AS VARCHAR(MAX)), '.', 
        CAST(m5.memo_text AS VARCHAR(MAX)), '.', 
        CAST(m6.memo_text AS VARCHAR(MAX)), '.', 
        CAST(m7.memo_text AS VARCHAR(MAX))))) AS [MemoText]
FROM memos AS m1
...
```

Or you could use `CONVERT`:

```sql
SELECT
    m1.memo_text,
    LTRIM(RTRIM(CONCAT(
        CONVERT(VARCHAR(MAX), m2.memo_text), '.', 
        CONVERT(VARCHAR(MAX), m3.memo_text), '.', 
        CONVERT(VARCHAR(MAX), m4.memo_text), '.', 
        CONVERT(VARCHAR(MAX), m5.memo_text), '.', 
        CONVERT(VARCHAR(MAX), m6.memo_text), '.', 
        CONVERT(VARCHAR(MAX), m7.memo_text)))) AS [MemoText]
FROM memos AS m1
...
```

Either approach should allow for concatenation without truncation, 
provided that the total concatenated length doesn't exceed the maximum length for 
`VARCHAR(MAX)`, which is 2^31-1 characters.

*/

