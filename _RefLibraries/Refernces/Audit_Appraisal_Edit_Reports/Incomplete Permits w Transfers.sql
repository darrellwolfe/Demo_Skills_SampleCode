WITH CTE_IncPermits AS (
SELECT
TRIM(p.pin) AS [PIN],
TRIM(p.AIN) AS [AIN],
  CASE
    WHEN p.neighborhood >= 9000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 6003 THEN 'District_6'
    WHEN p.neighborhood = 6002 THEN 'Manufactured_Homes'
    WHEN p.neighborhood = 6001 THEN 'District_6'
    WHEN p.neighborhood = 6000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 5003 THEN 'District_5'
    WHEN p.neighborhood = 5002 THEN 'Manufactured_Homes'
    WHEN p.neighborhood = 5001 THEN 'District_5'
    WHEN p.neighborhood = 5000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 4000 THEN 'District_4'
    WHEN p.neighborhood >= 3000 THEN 'District_3'
    WHEN p.neighborhood >= 2000 THEN 'District_2'
    WHEN p.neighborhood >= 1021 THEN 'District_1'
    WHEN p.neighborhood = 1020 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 1001 THEN 'District_1'
    WHEN p.neighborhood = 1000 THEN 'Manufactured_Homes'
    WHEN p.neighborhood >= 451 THEN 'Commercial'
    WHEN p.neighborhood = 450 THEN 'Specialized_Cell_Towers'
    WHEN p.neighborhood >= 1 THEN 'Commercial'
    WHEN p.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS District,
p.neighborhood AS [GEO],
pe.permit_ref AS [Permit #],
pe.permit_desc,
pe.permit_type,
pe.cert_for_occ,
pe.permservice,
pe.filing_date

FROM TSBv_PARCELMASTER AS p
JOIN permits as pe ON p.lrsn=pe.lrsn
WHERE p.EffStatus = 'A'
AND pe.status = 'A'
AND pe.permit_desc LIKE '%INC%'
),

CTE_NCMemoHeader AS (
SELECT
TRIM(p.pin) AS [PIN],
TRIM(p.AIN) AS [AIN],
p.neighborhood AS [GEO],
m.memo_text

FROM TSBv_PARCELMASTER AS p
JOIN memos AS m ON p.lrsn=m.lrsn
WHERE p.EffStatus = 'A'
AND m.memo_id = 'NC24'
AND m.memo_line_number = '2'
),

CTE_Transfers AS (
SELECT
TRIM(p.pin) AS [PIN],
TRIM(p.AIN) AS [AIN],
p.neighborhood AS [GEO],
t.pxfer_date,
t.GrantorName,
t.GranteeName

FROM TSBv_PARCELMASTER AS p
JOIN transfer AS t ON p.lrsn = t.lrsn
)

SELECT DISTINCT
  cip.PIN,
  cip.AIN,
  cip.District,
  cip.GEO,
  cip.permservice,
  cip.cert_for_occ,
  cip.permit_desc,
  cip.[Permit #],
  cip.filing_date,
  cmh.memo_text,
  ct.pxfer_date,
  ct.GrantorName,
  ct.GranteeName

FROM CTE_IncPermits AS cip
FULL JOIN CTE_NCMemoHeader AS cmh ON cip.PIN = cmh.PIN
JOIN CTE_Transfers AS ct ON cip.PIN = ct.PIN

WHERE ct.pxfer_date > cip.filing_date
 AND ct.pxfer_date > '2023-01-01'
 
ORDER BY cip.AIN







