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




SELECT DISTINCT
  LTRIM(RTRIM(vwb.RcType)) AS [RcType]
,  LTRIM(RTRIM(vwb.RcSubtype)) AS [RcSubType]
-- ,  LTRIM(RTRIM(vwb.FullDescription)) AS [PermitDesc]

FROM Vw_Base_KC AS vwb 
JOIN Base AS b ON vwb.ID=b.ID
LEFT JOIN vw_BaseCustomFields AS bcfval ON vwb.ID=bcfval.BaseID AND bcfval.fieldname='PROJECT VALUATION'
LEFT JOIN vw_BaseCustomFields AS bcfsf ON vwb.ID=bcfsf.BaseID AND bcfsf.fieldname='PROJECT SQ FT'


WHERE vwb.RcType IS NOT NULL
AND vwb.RcType <> 'SIGN'
AND vwb.RcType <> 'SITE DISTURBANCE'
AND vwb.RcType <> 'FENCE'
AND vwb.RcType <> 'APPEAL'
AND vwb.RcType <> 'COMPREHENSIVE%'
AND vwb.RcType <> 'FLOOD DEV%'
AND vwb.RcType <> 'OFFICE FEES'
AND vwb.RcSubtype <> 'CHANGE OF USE'
AND vwb.RcType <> 'LOCATION'
AND vwb.RcType <> 'RETAINING WALL'



AND vwb.Milestone <> 'CANCELLED'
AND vwb.Milestone <> 'WITHDRAWN'
AND vwb.BaseNo NOT LIKE 'SDP%'
AND vwb.FullDescription NOT LIKE '%LINE%'
AND (b.IssueDt IS NOT NULL AND b.IssueDt <> '1900-01-01')

ORDER BY [RcType];

