-- !preview conn=con
/*
AsTxDBProd
GRM_Main
LTRIM(RTRIM())
*/

WITH 
CTE_Memo_Filter AS (
  SELECT DISTINCT
    LTRIM(RTRIM(parcel.lrsn)) AS [LRSN],
    LTRIM(RTRIM(parcel.AIN)) AS [AIN],
    m.memo_id AS [Memo ID],
    m.memo_text
  
  FROM TSBv_PARCELMASTER AS parcel
    JOIN memos AS m ON parcel.lrsn = m.lrsn
    
  WHERE parcel.EffStatus = 'A'
    AND m.memo_id IN ('AR','T','Z')
    AND m.memo_text LIKE 'CS-%/23%'
    OR m.memo_text LIKE 'PF-%/23%'

  GROUP BY
    parcel.LRSN,
    parcel.AIN,
    m.memo_id,
    m.memo_text  

--  ORDER BY AIN ASC -- IF YOU ARE RUNNING THIS BY ITSELF
)

SELECT
  mf.AIN,
  CASE
    WHEN mf.memo_text LIKE 'CS-%/23H%' THEN 'Habitat'
    WHEN mf.memo_text LIKE 'CS-%/23I%' THEN 'Index'
    WHEN mf.memo_text LIKE 'CS-%/23TA%'
      OR mf.memo_text LIKE 'PF-%/23TAG%'
      OR mf.memo_text LIKE 'PF-%/23TA%' THEN 'Mixed Timber/Ag'
    WHEN mf.memo_text LIKE 'CS-%/23T%'
      OR mf.memo_text LIKE 'PF-%/23T%' THEN 'Timber'
    WHEN mf.memo_text LIKE 'CS-%/23A%'
      OR mf.memo_text LIKE 'CS-%/23AG%'
      OR mf.memo_text LIKE 'PF-%/23A%'
      OR mf.memo_text LIKE 'PF-%/23AG%' THEN 'Ag'
    WHEN mf.memo_text LIKE 'CS-%/23S%' THEN 'Mapping'
    WHEN mf.memo_text LIKE 'PF-%/23C%' THEN 'Compliance'
    WHEN mf.memo_text LIKE 'PF-%/23DQ%'
      OR mf.memo_text LIKE 'PF-%/23D%' THEN 'Deferred Quote'
    WHEN mf.memo_text LIKE 'PF-%/23Y%' THEN 'Yield'
    WHEN mf.memo_text LIKE 'PF-%/23TP%' THEN 'Timber Plan'
    WHEN mf.memo_text LIKE 'PF-%/23AGDEC%' THEN 'Ag Declaration'
    ELSE 'Misc.'
    END AS [Memo Category],
  CASE
    WHEN LEFT(mf.memo_text,2) = 'PF' THEN 'Pat Fitzwater'
    WHEN LEFT(mf.memo_text,2) = 'CS' THEN 'Colton Smith'
    ELSE 'Review'
    END AS [User],
  mf.memo_text,
  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LEFT(mf.memo_text,5),'/',''),'-0',''),'PF',''),'CS-',''),'CS',''),'-','') AS [Month]
  
  
FROM CTE_Memo_Filter AS mf

;

