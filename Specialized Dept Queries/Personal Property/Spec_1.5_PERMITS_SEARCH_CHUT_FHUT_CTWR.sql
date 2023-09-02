-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/

WITH 

CTE_ParcelMaster AS (
  --------------------------------
  --ParcelMaster
  --------------------------------
  Select Distinct
  pm.lrsn
,  LTRIM(RTRIM(pm.pin)) AS [PIN]
,  LTRIM(RTRIM(pm.AIN)) AS [AIN]
,  pm.neighborhood AS [GEO]
,  LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name]
,  LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD]
,  LTRIM(RTRIM(pm.TAG)) AS [TAG]
,  LTRIM(RTRIM(pm.DisplayName)) AS [Owner]
,  LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress]
,  LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity]
,  pm.LegalAcres
,  pm.TotalAcres
,  pm.Improvement_Status
,  pm.WorkValue_Land
,  pm.WorkValue_Impv
,  pm.WorkValue_Total
,  pm.CostingMethod
  
  From TSBv_PARCELMASTER AS pm
  
  Where pm.EffStatus = 'A'
    --AND pm.ClassCD NOT LIKE '070%'
    
  Group By
  pm.lrsn,
  pm.pin,
  pm.AIN,
  pm.PropClassDescr,
  pm.neighborhood,
  pm.NeighborHoodName,
  pm.TAG,
  pm.DisplayName,
  pm.SitusAddress,
  pm.SitusCity,
  pm.LegalAcres,
  pm.TotalAcres,
  pm.Improvement_Status,
  pm.WorkValue_Land,
  pm.WorkValue_Impv,
  pm.WorkValue_Total,
  pm.CostingMethod

),

CTE_PP_Permits AS (
  SELECT 
  p.lrsn,
  LTRIM(RTRIM(p.permit_ref)) AS [REFERENCE_Num],
  LTRIM(RTRIM(p.permit_desc)) AS [DESCRIPTION],
  LTRIM(RTRIM(c.tbl_element_desc)) AS [PERMIT_TYPE],
  p.callback AS [CALLBACK_DATE],
  f.field_in AS [WORK_DUE_DATE],
  p.cert_for_occ AS [DATE_CERT_FOR_OCC],
  f.need_to_visit AS [NEED_TO_VISIT], 
  LTRIM(RTRIM(f.field_person)) AS [APPRAISER],
  f.date_completed AS [COMPLETED_DATE],
  --NOTES, CONCAT allows one line of notes instead of duplicate rows
  m2.memo_id AS [MEMO_ID],
  LTRIM(RTRIM(CONCAT(m2.memo_text, '.', m3.memo_text,'.', m4.memo_text,'.', 
    m5.memo_text,'.', m6.memo_text,'.', m7.memo_text))) AS [MemoText],
  --Additional Data
  p.cost_estimate AS [COST_ESTIMATE],
  p.sq_ft AS [ESTIMATED_SF],
  --Other Dates
  LTRIM(RTRIM(p.permit_source)) AS [PERMIT_SOURCE],
  p.filing_date AS [FILING_DATE],
  p.permservice AS [PERMANENT_SERVICE_DATE],
  f.field_out AS [WORK_ASSIGNED_DATE]

  FROM permits AS p 
  -- Field Visits
  LEFT JOIN field_visit AS f ON p.field_number=f.field_number
    AND f.status='A'
  --Memos concated to pull all rows of memors for an lrsn into one column/row. 
    LEFT JOIN memos AS m2 ON p.lrsn=m2.lrsn AND m2.memo_id = 'PERM' AND m2.memo_line_number = '2'
    LEFT JOIN memos AS m3 ON p.lrsn=m3.lrsn AND m3.memo_id = 'PERM' AND m3.memo_line_number = '3'
    LEFT JOIN memos AS m4 ON p.lrsn=m4.lrsn AND m4.memo_id = 'PERM' AND m4.memo_line_number = '4'
    LEFT JOIN memos AS m5 ON p.lrsn=m2.lrsn AND m5.memo_id = 'PERM' AND m5.memo_line_number = '5'
    LEFT JOIN memos AS m6 ON p.lrsn=m3.lrsn AND m6.memo_id = 'PERM' AND m6.memo_line_number = '6'
    LEFT JOIN memos AS m7 ON p.lrsn=m4.lrsn AND m7.memo_id = 'PERM' AND m7.memo_line_number = '7'
  -- Permit Types
  LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type AND c.tbl_type_code= 'permits'
    AND c.code_status= 'A'
  --Where conditions for P
  WHERE p.status= 'A' 
  AND NOT (f.need_to_visit='N'
  AND f.field_person IS NOT NULL
  AND f.date_completed IS NOT NULL
      )
)



SELECT 
  ppp.lrsn
  ,pm.PIN
  ,pm.AIN
  ,pm.GEO
  ,pm.GEO_Name
  ,ppp.REFERENCE_Num
  ,ppp.DESCRIPTION
  ,ppp.PERMIT_TYPE
  ,ppp.CALLBACK_DATE
  ,ppp.WORK_DUE_DATE
  ,ppp.DATE_CERT_FOR_OCC
  ,ppp.NEED_TO_VISIT
  ,ppp.APPRAISER
  ,ppp.COMPLETED_DATE
  ,ppp.MEMO_ID
  ,ppp.MemoText
  ,ppp.COST_ESTIMATE
  ,ppp.ESTIMATED_SF
  ,ppp.PERMIT_SOURCE
  ,ppp.FILING_DATE
  ,ppp.PERMANENT_SERVICE_DATE
  ,ppp.WORK_ASSIGNED_DATE
  ,pm.ClassCD
  ,pm.TAG
  ,pm.Owner
  ,pm.SitusAddress
  ,pm.SitusCity

FROM CTE_PP_Permits as ppp
JOIN CTE_ParcelMaster AS pm ON pm.lrsn=ppp.lrsn


WHERE (ppp.DESCRIPTION LIKE '%CHUT%'
      OR ppp.DESCRIPTION LIKE '%FHUT%'
      OR ppp.DESCRIPTION LIKE '%COFFEE%'
      OR ppp.DESCRIPTION LIKE '%Tower%'
      OR ppp.DESCRIPTION LIKE '%Cell%'
      OR ppp.DESCRIPTION LIKE '%HUT%'
      )
AND NOT (ppp.DESCRIPTION LIKE '%CANCEL%'
      OR ppp.DESCRIPTION LIKE '%MISCELL%'
      OR ppp.DESCRIPTION LIKE '%QUANSET%'
      OR ppp.DESCRIPTION LIKE '%PIZZA%'
      )

