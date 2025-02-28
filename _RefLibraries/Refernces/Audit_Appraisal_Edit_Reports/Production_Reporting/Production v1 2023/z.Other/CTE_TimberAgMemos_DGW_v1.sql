-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/


DECLARE @yearSuffix VARCHAR(10) = '24';
--SET @yearSuffix = '23';
--SET @yearSuffix = '24';

WITH 
CTE_Memo_Filter AS (
  SELECT DISTINCT
  parcel.lrsn AS LRSN
  ,TRIM(parcel.AIN) AS AIN
  ,m.memo_id
  ,m.memo_text
  
  FROM TSBv_PARCELMASTER AS parcel
  JOIN memos AS m ON parcel.lrsn = m.lrsn
  
  WHERE parcel.EffStatus = 'A'
  AND m.memo_id IN ('AR','T','Z')
  AND (m.memo_text LIKE 'CS-%/' + @yearSuffix + '%'
       OR m.memo_text LIKE 'PF-%/' + @yearSuffix + '%')
  
  GROUP BY
  parcel.LRSN
  ,parcel.AIN
  ,m.memo_id
  ,m.memo_text  
)

SELECT
  mf.AIN
  ,CASE
    WHEN mf.memo_text LIKE 'CS-%/' + @yearSuffix + 'H%' THEN 'Habitat'
    WHEN mf.memo_text LIKE 'CS-%/' + @yearSuffix + 'I%' THEN 'Index'
    WHEN mf.memo_text LIKE 'CS-%/' + @yearSuffix + 'TA%'
      OR mf.memo_text LIKE 'PF-%/' + @yearSuffix + 'TAG%'
      OR mf.memo_text LIKE 'PF-%/' + @yearSuffix + 'TA%' THEN 'Mixed Timber/Ag'
    WHEN mf.memo_text LIKE 'CS-%/' + @yearSuffix + 'T%'
      OR mf.memo_text LIKE 'PF-%/' + @yearSuffix + 'T%' THEN 'Timber'
    WHEN mf.memo_text LIKE 'CS-%/' + @yearSuffix + 'A%'
      OR mf.memo_text LIKE 'CS-%/' + @yearSuffix + 'AG%'
      OR mf.memo_text LIKE 'PF-%/' + @yearSuffix + 'A%'
      OR mf.memo_text LIKE 'PF-%/' + @yearSuffix + 'AG%' THEN 'Ag'
    WHEN mf.memo_text LIKE 'CS-%/' + @yearSuffix + 'S%' THEN 'Mapping'
    WHEN mf.memo_text LIKE 'PF-%/' + @yearSuffix + 'C%' THEN 'Compliance'
    WHEN mf.memo_text LIKE 'PF-%/' + @yearSuffix + 'DQ%'
      OR mf.memo_text LIKE 'PF-%/' + @yearSuffix + 'D%' THEN 'Deferred Quote'
    WHEN mf.memo_text LIKE 'PF-%/' + @yearSuffix + 'Y%' THEN 'Yield'
    WHEN mf.memo_text LIKE 'PF-%/' + @yearSuffix + 'TP%' THEN 'Timber Plan'
    WHEN mf.memo_text LIKE 'PF-%/' + @yearSuffix + 'AGDEC%' THEN 'Ag Declaration'
    ELSE 'Misc.'
    END AS [Memo Category]
  ,CASE
    WHEN LEFT(mf.memo_text,2) = 'PF' THEN 'Pat Fitzwater'
    WHEN LEFT(mf.memo_text,2) = 'CS' THEN 'Colton Smith'
    ELSE 'Review'
    END AS [User]
  ,mf.memo_text
  ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LEFT(mf.memo_text,5),'/',''),'-0',''),'PF',''),'CS-',''),'CS',''),'-','') AS [Month]
FROM CTE_Memo_Filter AS mf;























