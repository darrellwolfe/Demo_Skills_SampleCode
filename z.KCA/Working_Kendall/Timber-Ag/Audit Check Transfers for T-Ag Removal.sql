-- !preview conn=con
/*
AsTxDBProd
GRM_Main

TIMBER-AG PARCELS THAT HAD RECENT TRANSFERS

*/

SELECT DISTINCT
  p.lrsn AS [LRSN],
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  t.pxfer_date AS [Transfer_Date],
  t.GrantorName AS [Grantor],
  t.GranteeName AS [Grantee]

FROM TSBv_PARCELMASTER AS p
  JOIN transfer AS t ON p.lrsn = t.lrsn
    AND t.pxfer_date >= '2023-01-01'
    AND t.GrantorName <> t.GranteeName
  JOIN allocations AS a ON p.lrsn = a.lrsn
    AND a.group_code BETWEEN '01' AND '10'
    AND a.status = 'A'

WHERE p.EffStatus = 'A'

ORDER BY t.pxfer_date