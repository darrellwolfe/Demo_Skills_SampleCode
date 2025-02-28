/*

--GRM Database
AsTxDBProd
GRM_Main

--iMS Database, County Permits
Permits-Prod
iMS

--In iMS, their version of a codes_table is called: vw_BaseCustomFields

PROJECT VALUATION
PROJECT SQ FT

*/




SELECT 
b.IssueDt AS [IssueDtOrder],
--Property Data
LTRIM(RTRIM(vwb.ParcelNo)) AS [PIN],
--Permit Data, from Vw_Base_KC (vwb) or Base (b)
--Permit Data, from Vvw_BaseCustomFields
LTRIM(RTRIM(vwb.BaseNo)) AS [REFERENCE #],
bcfval.cMoney AS [COST ESTIMATE],
bcfsf.cDbl AS [ESTIMATED SF],
CONVERT(varchar, b.IssueDt, 101) AS [FILING DATE],
'' AS [CALLBACK DATE],
'' AS [inactivedate],
'' AS [DATE CERT FOR OCC],
LTRIM(RTRIM(vwb.FullDescription)) AS [DESCRIPTION],
'' AS [PERMIT TYPE - Placeholder], --To be replaced in Power Query
'CNTY' AS [PERMIT SOURCE],
'' AS [PHONE NUMBER], -- But I would like to find this when we can
'' AS [permit_char3],
'A' AS [status_code],
'' AS [permit_char20b],
'0' AS [permit_int2],
'0' AS [permit_int3],
'0' AS [permit_int4],
'' AS [PERMANENT SERVICE DATE],
'' AS [PERMIT FEE],
--For matching the PermitType key, then delete in Power Query
LTRIM(RTRIM(vwb.RcSubtype)) AS [RcSubType]


FROM Vw_Base_KC AS vwb 
JOIN Base AS b ON vwb.ID=b.ID
LEFT JOIN vw_BaseCustomFields AS bcfval ON vwb.ID=bcfval.BaseID AND bcfval.fieldname='PROJECT VALUATION'
LEFT JOIN vw_BaseCustomFields AS bcfsf ON vwb.ID=bcfsf.BaseID AND bcfsf.fieldname='PROJECT SQ FT'


WHERE (b.IssueDt IS NOT NULL AND b.IssueDt <> '1900-01-01')
  AND vwb.Milestone <> 'CANCELLED'
  AND vwb.Milestone <> 'WITHDRAWN'
  AND vwb.BaseNo NOT LIKE 'SDP%'
  AND vwb.FullDescription NOT LIKE '%LINE%'

ORDER BY [IssueDtOrder] DESC;

