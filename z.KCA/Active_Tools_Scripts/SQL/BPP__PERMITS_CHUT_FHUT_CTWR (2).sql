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
  UPPER(LTRIM(RTRIM(p.permit_ref))) AS [REFERENCE_Num],
  UPPER(LTRIM(RTRIM(p.permit_desc))) AS [DESCRIPTION],
  LTRIM(RTRIM(c.tbl_element_desc)) AS [PERMIT_TYPE],
  p.callback AS [CALLBACK_DATE],
  f.field_in AS [WORK_DUE_DATE],
  p.cert_for_occ AS [DATE_CERT_FOR_OCC],
  f.need_to_visit AS [NEED_TO_VISIT], 
  LTRIM(RTRIM(f.field_person)) AS [APPRAISER],
  f.date_completed AS [COMPLETED_DATE],
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
  -- Permit Types
  LEFT JOIN codes_table AS c ON c.tbl_element=p.permit_type AND c.tbl_type_code= 'permits'
    AND c.code_status= 'A'
  --Where conditions for P
  WHERE p.status= 'A' 

  AND NOT (f.need_to_visit='N'
  AND f.field_person IS NOT NULL
  AND f.date_completed IS NOT NULL
      )
  AND (p.permit_desc LIKE '%CHUT%'
      OR p.permit_desc LIKE '%FHUT%'
      OR p.permit_desc LIKE '%CTWR%')
    
),

CTE_Memos AS (
Select Distinct
m.lrsn
,m.memo_id AS PERM_Memos_ID
--,m.memo_text AS RY_Memo
,STRING_AGG(CAST(mtext.memo_text AS VARCHAR(MAX)), ', ') AS Perm_Memos

FROM memos AS m
LEFT JOIN memos AS mtext
  On m.lrsn=mtext.lrsn
  And mtext.status = 'A'
  And mtext.memo_line_number <> '1'
  And mtext.memo_id = 'PERM'

--WHERE m.memo_id = @MemoIDYear1
WHERE m.memo_id = 'PERM'

--WHERE m.memo_id='RY24'
AND m.status = 'A'

GROUP BY
m.lrsn
,m.memo_id
)




SELECT DISTINCT
  ppp.lrsn
  ,pm.PIN
  ,pm.AIN
  ,pm.GEO
  ,pm.GEO_Name
  ,ppp.REFERENCE_Num
  ,ppp.DESCRIPTION
  ,ppp.PERMIT_TYPE

  ,ppp.PERMIT_SOURCE
  ,ppp.NEED_TO_VISIT
  ,ppp.APPRAISER
  ,ppp.COMPLETED_DATE
  ,ppp.FILING_DATE
  ,ppp.DATE_CERT_FOR_OCC

  ,ppp.CALLBACK_DATE
  ,ppp.WORK_DUE_DATE
  ,ppp.PERMANENT_SERVICE_DATE
  ,ppp.WORK_ASSIGNED_DATE
  
  ,ppp.COST_ESTIMATE
  ,ppp.ESTIMATED_SF
  ,pm.ClassCD
  ,pm.TAG
  ,pm.Owner
  ,pm.SitusAddress
  ,pm.SitusCity
  ,memos.Perm_Memos

FROM CTE_PP_Permits as ppp
JOIN CTE_ParcelMaster AS pm ON pm.lrsn=ppp.lrsn

LEFT JOIN CTE_Memos AS memos ON memos.lrsn = ppp.lrsn

WHERE (ppp.DESCRIPTION LIKE '%CHUT%'
  OR  ppp.DESCRIPTION LIKE '%FHUT%'
  OR  ppp.DESCRIPTION LIKE '%CTWR%')

AND (ppp.DESCRIPTION NOT LIKE '%not-ctwr%'
  AND ppp.DESCRIPTION NOT LIKE '%non-ctwr%'
  
  AND ppp.DESCRIPTION NOT LIKE '%not-chut%'
  AND ppp.DESCRIPTION NOT LIKE '%non-chut%'

  AND ppp.DESCRIPTION NOT LIKE '%not-fhut%'
  AND ppp.DESCRIPTION NOT LIKE '%non-fhut%')

ORDER BY DESCRIPTION, PIN;

















