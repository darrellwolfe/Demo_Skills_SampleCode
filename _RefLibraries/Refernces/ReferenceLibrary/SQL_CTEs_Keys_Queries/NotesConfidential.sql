-- !preview conn=conn


Declare @MemoLastUpdatedNoEarlierThan DATE = '2022-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022

-------------------------------------
--CTE_MarketAdjustmentNotes 
-- Using the memos table with SA and SAMH memo_id
--NOTES, CONCAT allows one line of notes instead of duplicate rows, TRIM removes spaces from boths ides
-------------------------------------

--CTE_NotesConfidential AS (
SELECT
  lrsn,
  STRING_AGG(memo_text, ' | ') AS Sales_Notes
FROM memos

WHERE status = 'A'
AND memo_id IN ('NOTE')
AND memo_line_number <> '1'
AND last_update >= @MemoLastUpdatedNoEarlierThan

/*
AND (memo_text LIKE '%/23 %'
    OR memo_text LIKE '%/2023 %'
    OR memo_text LIKE '%/24 %'
    OR memo_text LIKE '%/2024 %')
*/
GROUP BY lrsn
--),
