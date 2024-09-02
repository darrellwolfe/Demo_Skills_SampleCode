-- !preview conn=conn

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
--Property Data
LTRIM(RTRIM(vwb.ParcelNo)) AS [PIN],
LTRIM(RTRIM(vwb.BaseNo)) AS [REFERENCE_#],
bcfval.cMoney AS [ProjectCost],
bcfsf.cDbl AS [ProjectSF],
CONVERT(varchar, b.IssueDt, 101) AS [IssueDt],
'' AS callback,
'' AS inactivedate,
'' AS cert_for_occ,
LTRIM(RTRIM(vwb.FullDescription)) AS [PermitDesc],
LTRIM(RTRIM(vwb.RcType)) AS [RcType],
LTRIM(RTRIM(vwb.RcSubtype)) AS [RcSubType],
'REPLACE_WITH_KEY_#' AS permit_type,
'iMS' AS permit_source,
'' AS phone_number,
'' AS permit_char3,
'A' AS status_code,
'' AS permit_char20b,
'0' AS permit_int2,
'0' AS permit_int3,
'0' AS permit_int4,
'' AS permservice,
'' AS permit_fee,
'>' AS AdditionalData,
LTRIM(RTRIM(vwb.AIN)) AS [AIN],
LTRIM(RTRIM(vwb.Address1)) AS [Address1],
LTRIM(RTRIM(vwb.Address2)) AS [Address2],
LTRIM(RTRIM(vwb.City)) AS [City],
LTRIM(RTRIM(vwb.Variant)) AS [Variant],
LTRIM(RTRIM(vwb.Milestone)) AS [ViewMilestone],
b.MilestoneID,
LTRIM(RTRIM(b.Milestone)) AS [BaseMilestone],
CONVERT(varchar, b.ExpireDt, 101) AS [ExpireDt],
CONVERT(varchar, b.FinalDt, 101) AS [FinalDt],
CONVERT(varchar, b.UpdateDt, 101) AS [UpdateDt],
b.Progress,
--Employee?
vwb.FullName,
vwb.CreateBy,
--Owner Contact
vwb.Owner,
vwb.Applicant,
vwb.Contractor,
--Lat-Long
vwb.Longitude,
vwb.Latitude

FROM Vw_Base_KC AS vwb 
JOIN Base AS b ON vwb.ID=b.ID
  AND b.IssueDt > '2023-01-01'
LEFT JOIN vw_BaseCustomFields AS bcfval ON vwb.ID=bcfval.BaseID AND bcfval.fieldname='PROJECT VALUATION'
LEFT JOIN vw_BaseCustomFields AS bcfsf ON vwb.ID=bcfsf.BaseID AND bcfsf.fieldname='PROJECT SQ FT'


WHERE (b.IssueDt IS NOT NULL AND b.IssueDt <> '1900-01-01')
AND vwb.Milestone <> 'CANCELLED'
AND vwb.Milestone <> 'WITHDRAWN'
AND vwb.BaseNo NOT LIKE 'SDP%'
AND vwb.FullDescription NOT LIKE '%LINE%'
AND vwb.RcType IS NOT NULL
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


ORDER BY [IssueDt] DESC, [City], [RcType];
