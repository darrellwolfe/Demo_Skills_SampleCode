-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/


DECLARE @TaxYear INT = 2023; 
DECLARE @yearSuffix1 VARCHAR(2) = RIGHT(@TaxYear, 2);      -- Extracts '23' from 2023
DECLARE @yearSuffix2 VARCHAR(2) = RIGHT(@TaxYear + 1, 2);  -- Extracts '24' from 2024
DECLARE @yearSuffix3 VARCHAR(2) = RIGHT(@TaxYear + 2, 2);  -- Extracts '24' from 2024
DECLARE @yearSuffix4 VARCHAR(2) = RIGHT(@TaxYear + 3, 2);  -- Extracts '24' from 2024
DECLARE @yearSuffix5 VARCHAR(2) = RIGHT(@TaxYear + 4, 2);  -- Extracts '24' from 2024

SELECT DISTINCT
  CASE
    WHEN mf.memo_text LIKE '%/%H%' THEN 'Habitat'
    WHEN mf.memo_text LIKE '%/%I%' THEN 'Index'
    WHEN mf.memo_text LIKE '%/%TA%'
      OR mf.memo_text LIKE '%/%TAG%'
      OR mf.memo_text LIKE '%/%TA%' THEN 'Mixed Timber/Ag'
    WHEN mf.memo_text LIKE '%/%T%' THEN 'Timber'
    WHEN mf.memo_text LIKE '%/%A%'
      OR mf.memo_text LIKE '%/%AG%' THEN 'Ag'
    WHEN mf.memo_text LIKE '%/%S%' THEN 'Mapping'
    WHEN mf.memo_text LIKE '%/%C%' THEN 'Compliance'
    WHEN mf.memo_text LIKE '%/%DQ%'
      OR mf.memo_text LIKE '%/%D%' THEN 'Deferred Quote'
    WHEN mf.memo_text LIKE '%/%Y%' THEN 'Yield'
    WHEN mf.memo_text LIKE '%/%TP%' THEN 'Timber Plan'
    WHEN mf.memo_text LIKE '%/%AGDEC%' THEN 'Ag Declaration'
    ELSE 'Misc.'
  END AS [Memo Category]
  ,mf.memo_text
FROM TSBv_PARCELMASTER AS pm
JOIN memos AS mf ON pm.lrsn = mf.lrsn
WHERE pm.EffStatus = 'A'
  AND mf.memo_id IN ('AR','T','Z')
  
  AND (mf.memo_text LIKE 'CS-%' 
    OR mf.memo_text LIKE 'PF-%')
  
  AND (mf.memo_text LIKE '%/' + @yearSuffix1 + '%' 
    OR mf.memo_text LIKE '%/' + @yearSuffix2 + '%'
    OR mf.memo_text LIKE '%/' + @yearSuffix3 + '%'
    OR mf.memo_text LIKE '%/' + @yearSuffix4 + '%'
    OR mf.memo_text LIKE '%/' + @yearSuffix5 + '%')


  

/*
GROUP BY
  parcel.LRSN,
  parcel.AIN,
  m.memo_id,
  m.memo_text  

  AND (mf.memo_text LIKE 'CS-%/' + @yearSuffix + '%'
       OR mf.memo_text LIKE 'PF-%/' + @yearSuffix + '%')

*/