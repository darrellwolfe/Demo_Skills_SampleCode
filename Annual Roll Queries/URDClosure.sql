






---------
--DistFnclTotal
---------

Select
--Dist
dft.TaxYear,
SUM(dft.Amount) AS [Amount],
SUM(dft.TotalNetDist) AS [TotalNetDist],
dft.TIFId,
--TIF
tif.Descr AS [TIF_Name]

From DistFnclTotal AS dft
Join TIF AS tif ON dft.TIFid=tif.id

Where dft.TaxYear IN ('2006','2022')
And tif.Descr LIKE ('%URD%')

Group By 
dft.TaxYear,
dft.TIFId,
tif.Descr

Order By
tif.Descr

---------
--Cad Viewer
---------


Select
cv.AssessmentYear,
CONCAT ('01/01/',cv.AssessmentYear) AS [AssessmentDate],
cv.CadRollDescr,
cv.CadRollId,
cv.CadLevelId,
cv.CadInvId,
cv.RollLevel,
cv.RevObjId,
cv.PIN,
cv.AIN,
cv.TAGShortDescr,
cv.ValueAmount AS [NetTaxableValue],
cv.CalculatedAmount,
cv.FormattedValueAmount,
cv.ValueTypeShortDescr,
cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
WHERE cv.AssessmentYear IN ('2022','2006')
--For URDs opened before 2006, we use the 2006 values
--For URDs opened after 2006, we use the year-opened values

Order By cv.CadRollId;



---------
--Select Lite
---------

Select
LTRIM(RTRIM(pm.lrsn)) AS [LRSN],
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.PropClassDescr)) AS [PCC],
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(pm.TAG)) AS [TAG],
LTRIM(RTRIM(pm.DisplayName)) AS [OwnerName],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity]

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'


-------------------
-- Tag-Tif-TaxAuth Filtered for URD
------------------

--TAG_TIF_TaxAuth Combined
Select Distinct
TAGTIF.Id AS [TAGTIFId],
--New Group
'' AS [TAG_Info_>],
TAG.Id AS [TagId],
TAG.BegEffYear AS [TagEffYr],
TAG.Descr AS [TAG],
--New Group
'' AS [TIF_Info_>],
TIF.Id AS [TifId],
TIF.BegEffYear AS [TifEffYr],
TIF.Descr AS [TIF_Name],
TIF.ShortDescr AS [TIF_Num],
TIF.StartYear,
TIF.EndYear,
TIF.BaseValueYear,
TIF.PlanDate,
TIF.CertDate,
TIF.ExpirationDate,
TIF.DecertificationDate,
--New Group
'' AS [TAGTaxAuthority_Info_>],
TAGTaxAuthority.Id AS [TAGTaxAuthorityId],
--New Group
'' AS [TaxAuthority_Info_>],
TaxAuthority.Descr AS [TaxAuthority_Name]

From TAG
LEFT OUTER JOIN TAGTIF ON TAG.Id=TAGTIF.TAGId AND TAGTIF.EffStatus = 'A'
LEFT OUTER JOIN TIF ON TAGTIF.TIFId=TIF.Id AND TIF.EffStatus  = 'A'
LEFT OUTER JOIN TAGTaxAuthority ON TAG.Id=TAGTaxAuthority.TAGId AND TAGTaxAuthority.EffStatus = 'A'
LEFT OUTER JOIN TaxAuthority ON TAGTaxAuthority.TaxAuthorityId=TaxAuthority.Id AND TaxAuthority.EffStatus = 'A'

WHERE TAG.EffStatus = 'A'
AND TIF.Descr LIKE '%URD%'

Group By
TAGTIF.Id,
TAG.Id,
TAG.BegEffYear,
TAG.Descr,
TIF.Id,
TIF.BegEffYear,
TIF.Descr,
TIF.ShortDescr,
TIF.StartYear,
TIF.EndYear,
TIF.BaseValueYear,
TIF.PlanDate,
TIF.CertDate,
TIF.ExpirationDate,
TIF.DecertificationDate,
TAGTaxAuthority.Id,
TaxAuthority.Descr


ORDER BY [TIF_Num],[TAG],[TaxAuthority_Name];
