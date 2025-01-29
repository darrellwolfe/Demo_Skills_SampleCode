-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

-- Total Value <- Assessed Value

SELECT
cv.AssessmentYear
, cv.CadRollId
, cv.CadRollDescr
, cv.CadInvId
, cv.CadLevelId
, cv.RevObjId
, cv.PIN
, cv.AIN
, cv.ClassCd AS ClassCd_Type
,  LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD_Description]
, cv.TAGId
, TRIM(cv.TAGDescr) AS TAG
,  pm.neighborhood AS [GEO]
,  LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name]
,  LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress]
,  LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity]
,  pm.LegalAcres
,  pm.Improvement_Status
,  pm.WorkValue_Land
,  pm.WorkValue_Impv
,  pm.WorkValue_Total
,  cv.ValueAmount AS [Cadastre_Value]
,  cv.ValueTypeShortDescr
,  cv.ValueTypeDescr

FROM CadValueTypeAmount_V AS cv
JOIN TSBv_PARCELMASTER AS pm ON pm.lrsn=cv.RevObjId
  AND pm.EffStatus = 'A'


WHERE cv.AssessmentYear BETWEEN '2013' AND '2023'
  AND cv.ValueTypeShortDescr = 'Total Value'


