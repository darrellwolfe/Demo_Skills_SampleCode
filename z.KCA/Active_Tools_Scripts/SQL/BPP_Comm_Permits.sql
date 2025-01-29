
CTE_PP_Permits AS (
SELECT 
p.lrsn,
LTRIM(RTRIM(p.permit_ref)) AS [REFERENCE#],
LTRIM(RTRIM(p.permit_desc)) AS [DESCRIPTION],
LTRIM(RTRIM(c.tbl_element_desc)) AS [PERMIT_TYPE],
p.callback AS [CALLBACK DATE],
f.field_in AS [WORK DUE DATE],
p.cert_for_occ AS [DATE CERT FOR OCC],
f.need_to_visit AS [NEED TO VISIT], 
LTRIM(RTRIM(f.field_person)) AS [APPRAISER],
f.date_completed AS [COMPLETED DATE],
--NOTES, CONCAT allows one line of notes instead of duplicate rows
m2.memo_id AS [MEMO ID],
LTRIM(RTRIM(CONCAT(m2.memo_text, '.', m3.memo_text,'.', m4.memo_text,'.', 
  m5.memo_text,'.', m6.memo_text,'.', m7.memo_text))) AS [MemoText],
--Additional Data
p.cost_estimate AS [COST ESTIMATE],
p.sq_ft AS [ESTIMATED SF],
--Other Dates
LTRIM(RTRIM(p.permit_source)) AS [PERMIT SOURCE],
p.filing_date AS [FILING DATE],
p.permservice AS [PERMANENT SERVICE DATE],
f.field_out AS [WORK ASSIGNED DATE]


FROM permits AS p 
-- Field Visits
LEFT JOIN field_visit AS f ON p.field_number=f.field_number
  AND f.status='A'
--Memos concated to pull all rows of memors for an lrsn into one column/row. 
  LEFT JOIN memos AS m2 ON p.lrsn=m2.lrsn AND m2.memo_id = 'PERM' AND m2.memo_line_number = '2'
  LEFT JOIN memos AS m3 ON p.lrsn=m3.lrsn AND m3.memo_id = 'PERM' AND m3.memo_line_number = '3'
  LEFT JOIN memos AS m4 ON p.lrsn=m4.lrsn AND m4.memo_id = 'PERM' AND m4.memo_line_number = '4'
  LEFT JOIN memos AS m5 ON p.lrsn=m2.lrsn AND m2.memo_id = 'PERM' AND m2.memo_line_number = '5'
  LEFT JOIN memos AS m6 ON p.lrsn=m3.lrsn AND m3.memo_id = 'PERM' AND m3.memo_line_number = '6'
  LEFT JOIN memos AS m7 ON p.lrsn=m4.lrsn AND m4.memo_id = 'PERM' AND m4.memo_line_number = '7'
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
    
)