-- !preview conn=conn

-------------------------------------
--CTE_MarketAdjustmentNotes 
-- Using the memos table with SA and SAMH memo_id
--NOTES, CONCAT allows one line of notes instead of duplicate rows, TRIM removes spaces from boths ides
-------------------------------------
/*
CTE_NotesSalesAnalysis AS (
  Select Distinct
    m1.lrsn,
    LTRIM(RTRIM(CONCAT(
    m2.memo_text,
    '.', 
    m3.memo_text,
    '.', 
    m4.memo_text,
    '.', 
    m5.memo_text,
    '.', 
    m6.memo_text,
    '.', 
    m7.memo_text
    ))) AS [NotesSalesAnalysis]

  From memos AS m1
  LEFT JOIN memos AS m2 ON m1.lrsn=m2.lrsn AND m2.memo_line_number = '2'
    AND m2.status = 'A'
    AND m2.memo_id IN ('SA','SAMH')
  LEFT JOIN memos AS m3 ON m1.lrsn=m3.lrsn AND m3.memo_line_number = '3'
    AND m3.status = 'A'
    AND m3.memo_id IN ('SA','SAMH')
  LEFT JOIN memos AS m4 ON m1.lrsn=m4.lrsn AND m4.memo_line_number = '4'
    AND m4.status = 'A'
    AND m4.memo_id IN ('SA','SAMH')
  LEFT JOIN memos AS m5 ON m1.lrsn=m2.lrsn AND m2.memo_line_number = '5'
    AND m5.status = 'A'
    AND m5.memo_id IN ('SA','SAMH')
  LEFT JOIN memos AS m6 ON m1.lrsn=m3.lrsn AND m3.memo_line_number = '6'
    AND m6.status = 'A'
    AND m6.memo_id IN ('SA','SAMH')
  LEFT JOIN memos AS m7 ON m1.lrsn=m4.lrsn AND m4.memo_line_number = '7'
    AND m7.status = 'A'
    AND m7.memo_id IN ('SA','SAMH')
  --------------------------
  -- SA Sales Analysis, SAMH Sales Analyis MH (Mobile Home) are seperate Memo Headers in ProVal
  --------------------------
  Where m1.memo_id IN ('SA','SAMH')
  AND m1.status = 'A'

),





WITH FilteredMemos AS (
    SELECT
        lrsn,
        memo_text,
        CONCAT(memo_line_number, '.') AS line_number
    FROM
        memos
    WHERE
        status = 'A'
        AND memo_id IN ('SA', 'SAMH')
)

SELECT
    lrsn,
    STRING_AGG(memo_text, '.') WITHIN GROUP (ORDER BY line_number) AS NotesSalesAnalysis
FROM
    FilteredMemos
GROUP BY
    lrsn


Declare @MemoLastUpdatedNoEarlierThan DATE = '2022-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022


SELECT
  lrsn,
  STRING_AGG(memo_text, '.') AS SalesMemos

FROM (SELECT
        lrsn,
        memo_text
      FROM memos
    
    WHERE status = 'A'
    AND memo_id IN ('SA', 'SAMH')
    AND memo_line_number > 1
    AND last_update >= @MemoLastUpdatedNoEarlierThan
    ) AS Subquery
  GROUP BY lrsn
  
  

*/

Declare @MemoLastUpdatedNoEarlierThan DATE = '2022-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022


--CTE_SalesMemos AS (
SELECT
  lrsn,
  STRING_AGG(memo_text, ' | ') AS Sales_Notes
FROM memos

WHERE status = 'A'
AND memo_id IN ('SA', 'SAMH')
AND memo_line_number <> '1'
AND last_update >= @MemoLastUpdatedNoEarlierThan

/*
AND (memo_text LIKE '%/23 %'
    OR memo_text LIKE '%/2023 %'
    OR memo_text LIKE '%/24 %'
    OR memo_text LIKE '%/2024 %')
*/
GROUP BY lrsn
--)

