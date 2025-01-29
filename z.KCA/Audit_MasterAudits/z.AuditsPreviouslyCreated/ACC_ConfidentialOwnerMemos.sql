/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/


-----------------------------
--Memos
----------------------------

Select 
m.lrsn,
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
m.memo_id,
m.memo_text

From memos AS m
Join TSBv_PARCELMASTER AS pm ON m.lrsn=pm.lrsn

Where m.memo_id = 'ACC' 
--memo_text LIKE '%Confidential%'
And m.status='A'
And m.memo_line_number = '1'

Order By [Owner];