/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())

Used for tax cancellation forms and other uses
Distinct created a query that takes too long to run and crash on our current outdated systems. 
Removed Distinct and it runs. This works for now.

*/


Select
  LTRIM(RTRIM(pm.pin)) AS [PIN],
  LTRIM(RTRIM(pm.AIN)) AS [AIN],
--Cadaster Values
  '' AS [Cadaster_Value_>>],
cv.ValueTypeShortDescr,
cv.ValueTypeDescr,
cv.ValueAmount,
cv.CalculatedAmount,
cv.FormattedValueAmount,
  '' AS [Worksheet_Value_>>],
  pm.WorkValue_Land,
  pm.WorkValue_Impv,
  pm.WorkValue_Total,
--Cadaster Info
cv.AssessmentYear,
CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate],
cv.CadRollDescr,
cv.CadRollId,
cv.CadLevelId,
cv.CadInvId,
cv.RollLevel,
-- Parcel Info from Cad Viewer
cv.RevObjId AS [LRSN],
cv.PIN,
-- Parcel Info from Parcel Master
  '' AS [Worksheet_Info_>>],
  LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
  LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD],
  pm.Improvement_Status,
  pm.CostingMethod,
  pm.LegalAcres,
  pm.TotalAcres,
  LTRIM(RTRIM(pm.TAG)) AS [TAG],
  LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
  LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
  LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
  LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
  LTRIM(RTRIM(pm.AttentionLine)) As [AttentionLine],
  LTRIM(RTRIM(pm.MailingAddress)) As [MailingAddress],
  LTRIM(RTRIM(pm.AddlAddrLine)) As [AddlAddrLine],
  LTRIM(RTRIM(pm.MailingCity)) As [MailingCity],
  LTRIM(RTRIM(pm.MailingState)) As [MailingState],
  LTRIM(RTRIM(pm.MailingZip)) As [MailingZip],
  LTRIM(RTRIM(pm.MailingCountry)) As [MailingCountry],
  LTRIM(RTRIM(pm.PINforGIS)) As [PINforGIS]


FROM CadValueTypeAmount_V AS cv
JOIN TSBv_PARCELMASTER AS pm ON pm.lrsn = cv.RevObjId
  AND pm.EffStatus = 'A'
  AND pm.PropClassDescr NOT LIKE '%070%'

WHERE cv.AssessmentYear IN ('2023')
  --,'2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
  AND cv.ValueTypeShortDescr IN ('Net Tax Value', 'Total Value', 'Total Exemptions')

Order By cv.AssessmentYear DESC, pm.neighborhood, pm.pin;







/*/*/*

FAILED OPTION SAVING FOR REFERENCE

--------------------------------
--ParcelMaster
--------------------------------

Select -- Distinct
  pm.lrsn,
  LTRIM(RTRIM(pm.pin)) AS [PIN],
  LTRIM(RTRIM(pm.AIN)) AS [AIN],
  LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
  LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD],

-- Cadaster Values needed for Tax Cancellation Forms
cvt.AssessmentYear,
CONCAT ('01/01/',cvt.AssessmentYear) AS [AssessmentDate],
cvt.ValueAmount AS [Total Assessed Value],
cvex.ValueAmount AS [Total Exemptions],
cvnet.ValueAmount AS [Net Taxable Value],
/*
--Other values included for reference and calculations
--Valuation Table - Cert Values
  '' AS [Certified_Info_>>],
  v.last_update AS [Last_Updated],
  (v.imp_val + v.land_market_val) AS [NEW Cert Total Value],
  v.land_market_val AS [Cert Land],
  v.imp_val AS [Cert Imp],
  v.valuation_comment AS [Val Comment],
  v.eff_year AS [Tax Year],
-- This ParcelMaster already has worksheet values
*/
  '' AS [Worksheet_Info_>>],
  pm.Improvement_Status,
  pm.WorkValue_Land,
  pm.WorkValue_Impv,
  pm.WorkValue_Total,
  pm.CostingMethod,
  pm.LegalAcres,
  pm.TotalAcres,
  LTRIM(RTRIM(pm.TAG)) AS [TAG],
  LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
  LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
  LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
  LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
  LTRIM(RTRIM(pm.AttentionLine)) As [AttentionLine],
  LTRIM(RTRIM(pm.MailingAddress)) As [MailingAddress],
  LTRIM(RTRIM(pm.AddlAddrLine)) As [AddlAddrLine],
  LTRIM(RTRIM(pm.MailingCity)) As [MailingCity],
  LTRIM(RTRIM(pm.MailingState)) As [MailingState],
  LTRIM(RTRIM(pm.MailingZip)) As [MailingZip],
  LTRIM(RTRIM(pm.MailingCountry)) As [MailingCountry],
  LTRIM(RTRIM(pm.PINforGIS)) As [PINforGIS]


From TSBv_PARCELMASTER AS pm
/*
--Cert Values
JOin valuation AS v ON pm.lrsn = v.lrsn
  AND v.status = 'A'
  AND v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired/current year 20230101 > 20240101, etc.
*/
--Net Tax Value
Join CadValueTypeAmount_V AS cvnet ON pm.lrsn = cvnet.RevObjId
  AND cvnet.AssessmentYear IN ('2023')
  --'2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
  AND cvnet.ValueTypeShortDescr = 'Net Tax Value'

--Total Value
Join CadValueTypeAmount_V AS cvt ON pm.lrsn = cvt.RevObjId
  AND cvt.AssessmentYear IN ('2023')
  --'2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
  AND cvt.ValueTypeShortDescr = 'Total Value'

--Total Exemptions
Join CadValueTypeAmount_V AS cvex ON pm.lrsn = cvex.RevObjId
  AND cvex.AssessmentYear IN ('2023')
  --'2022','2021','2020','2019','2018','2017','2016','2015','2014','2013')
  AND cvex.ValueTypeShortDescr = 'Total Exemptions'

--xxx.ValueTypeShortDescr IN ('Net Tax Value', 'Total Value', 'Total Exemptions')



Where pm.EffStatus = 'A'
  AND pm.ClassCD NOT LIKE '070%'


Group By
  pm.lrsn,
  pm.pin,
  pm.AIN,
cvt.AssessmentYear,
cvt.ValueAmount,
cvex.ValueAmount,
cvnet.ValueAmount,
  pm.PropClassDescr,
  pm.neighborhood,
  pm.NeighborHoodName,
  pm.TAG,
  pm.DisplayName,
  pm.SitusAddress,
  pm.SitusCity,
  pm.AttentionLine,
  pm.MailingAddress,
  pm.AddlAddrLine,
  pm.MailingCity,
  pm.MailingState,
  pm.MailingZip,
  pm.MailingCountry,
  pm.PINforGIS,
  pm.LegalAcres,
  pm.TotalAcres,
  pm.Improvement_Status,
  pm.WorkValue_Land,
  pm.WorkValue_Impv,
  pm.WorkValue_Total,
  pm.CostingMethod
  --
  v.land_market_val,
  v.imp_val,
  v.valuation_comment,
  v.eff_year,
  v.last_update


Order By GEO, PIN;

*/*/*/

