-- !preview conn=con
/*
AsTxDBProd
GRM_Main
LTRIM(RTRIM())
*/
--WITH CTE_Memo_Filter AS (
  SELECT DISTINCT
    LTRIM(RTRIM(parcel.lrsn)) AS [LRSN],
    LTRIM(RTRIM(parcel.AIN)) AS [AIN],
    m.memo_id AS [Memo ID],
    m.memo_text AS [Memo Text]
  
  FROM TSBv_PARCELMASTER AS parcel
    JOIN memos AS m ON parcel.lrsn = m.lrsn
    
  WHERE parcel.EffStatus = 'A'
    AND m.memo_id IN ('AR','T','Z')
    AND m.memo_text LIKE 'CS-%/23%'

  GROUP BY
    parcel.LRSN,
    parcel.AIN,
    m.memo_id,
    m.memo_text  

--  ORDER BY AIN ASC -- IF YOU ARE RUNNING THIS BY ITSELF
--)
