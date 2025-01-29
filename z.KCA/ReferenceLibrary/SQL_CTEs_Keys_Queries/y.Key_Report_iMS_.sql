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
--Permit Data, from Vw_Base_KC
vwb.BaseNo
vwb.FullDescription
vwb.RcType
vwb.RcSubtype
vwb.Variant
vwb.Milestone
--Permit Data, from Base
b.IssueDt
b.ExpireDt
b.FinalDt
b.Progress
b.UpdateDt
b.MilestoneID
b.Milestone
--Permit Data, from Vvw_BaseCustomFields
bcfval.cMoney
bcfsf.cDbl

--Property Data
vwb.ParcelNo
vwb.AIN
vwb.Address1
vwb.Address2
vwb.City




--Employee?
vwb.FullName
vwb.CreateBy
--Owner Contact
vwb.Owner
vwb.Applicant
vwb.Contractor

--Lat-Long
vwb.Longitude
vwb.Latitude



FROM Base AS b
LEFT JOIN Vw_Base_KC AS vwb ON b.ID=vwb.ID
LEFT JOIN vw_BaseCustomFields AS bcfval ON vwb.ID=bcfval.BaseID AND bcfval.fieldname='PROJECT VALUATION'
LEFT JOIN vw_BaseCustomFields AS bcfsf ON vwb.ID=bcfsf.BaseID AND bcfsf.fieldname='PROJECT SQ FT'


WHERE (b.IssueDt IS NOT NULL AND b.IssueDt <> '1900-01-01')
AND vwb.Milestone <> 'CANCELLED'
AND vwb.Milestone <> 'WITHDRAWN'
