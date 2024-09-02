-- !preview conn=con
/*
AsTxDBProd
GRM_Main
*/
  --------------------------------
  --ParcelMaster
  --------------------------------
  Select Distinct
  pm.lrsn
,  LTRIM(RTRIM(pm.pin)) AS [PIN]
,  LTRIM(RTRIM(pm.AIN)) AS [AIN]
,  pm.neighborhood AS [GEO]
,  LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name]
,  LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD]
,  LTRIM(RTRIM(pm.TAG)) AS [TAG]
,  LTRIM(RTRIM(pm.DisplayName)) AS [Owner]
,  LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress]
,  LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity]
,  pm.LegalAcres
,  pm.TotalAcres
,  pm.Improvement_Status
,  pm.WorkValue_Land
,  pm.WorkValue_Impv
,  pm.WorkValue_Total
,  pm.CostingMethod
  
  From TSBv_PARCELMASTER AS pm
  
  Where pm.EffStatus = 'A'
    AND pm.ClassCD NOT LIKE '010%'
    AND pm.ClassCD NOT LIKE '020%'
    AND pm.ClassCD NOT LIKE '021%'
    AND pm.ClassCD NOT LIKE '022%'
    AND pm.ClassCD NOT LIKE '030%'
    AND pm.ClassCD NOT LIKE '031%'
    AND pm.ClassCD NOT LIKE '032%'
    AND pm.ClassCD NOT LIKE '060%'
    AND pm.ClassCD NOT LIKE '070%'
    AND pm.ClassCD NOT LIKE '090%'

  Group By
  pm.lrsn,
  pm.pin,
  pm.AIN,
  pm.PropClassDescr,
  pm.neighborhood,
  pm.NeighborHoodName,
  pm.TAG,
  pm.DisplayName,
  pm.SitusAddress,
  pm.SitusCity,
  pm.LegalAcres,
  pm.TotalAcres,
  pm.Improvement_Status,
  pm.WorkValue_Land,
  pm.WorkValue_Impv,
  pm.WorkValue_Total,
  pm.CostingMethod

Order By GEO, PIN;
