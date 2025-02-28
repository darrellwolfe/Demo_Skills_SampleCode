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
LTRIM(RTRIM(vwb.AIN)) AS [AIN],
LTRIM(RTRIM(vwb.Address1)) AS [Address1],
LTRIM(RTRIM(vwb.Address2)) AS [Address2],
LTRIM(RTRIM(vwb.City)) AS [City],
--Permit Data, from Vw_Base_KC (vwb) or Base (b)
LTRIM(RTRIM(vwb.BaseNo)) AS [Permit#],
LTRIM(RTRIM(vwb.FullDescription)) AS [PermitDesc],
LTRIM(RTRIM(vwb.RcType)) AS [RcType],
LTRIM(RTRIM(vwb.RcSubtype)) AS [RcSubType],
LTRIM(RTRIM(vwb.Variant)) AS [Variant],
LTRIM(RTRIM(vwb.Milestone)) AS [ViewMilestone],
b.MilestoneID,
LTRIM(RTRIM(b.Milestone)) AS [BaseMilestone],
--Dates
CONVERT(varchar, b.IssueDt, 101) AS [IssueDt],
CONVERT(varchar, b.ExpireDt, 101) AS [ExpireDt],
CONVERT(varchar, b.FinalDt, 101) AS [FinalDt],
CONVERT(varchar, b.UpdateDt, 101) AS [UpdateDt],
b.Progress,
--Permit Data, from Vvw_BaseCustomFields
bcfval.cMoney AS [ProjectCost],
bcfsf.cDbl AS [ProjectSF],
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
LEFT JOIN vw_BaseCustomFields AS bcfval ON vwb.ID=bcfval.BaseID AND bcfval.fieldname='PROJECT VALUATION'
LEFT JOIN vw_BaseCustomFields AS bcfsf ON vwb.ID=bcfsf.BaseID AND bcfsf.fieldname='PROJECT SQ FT'


WHERE (b.IssueDt IS NOT NULL AND b.IssueDt <> '1900-01-01')
AND vwb.Milestone <> 'CANCELLED'
AND vwb.Milestone <> 'WITHDRAWN'
AND vwb.BaseNo NOT LIKE 'SDP%'
AND vwb.FullDescription NOT LIKE '%LINE%'

ORDER BY [IssueDtOrder] DESC, [City], [RcType];

