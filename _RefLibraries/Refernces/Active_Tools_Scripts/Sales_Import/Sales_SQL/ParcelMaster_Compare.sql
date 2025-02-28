Select Distinct
  pm.lrsn
,  TRIM(pm.pin) AS [PIN]
,  TRIM(pm.AIN) AS [AIN]
,  pm.neighborhood AS [GEO]
,  TRIM(pm.NeighborHoodName) AS [GEO_Name]
,  TRIM(pm.PropClassDescr) AS [ClassCD]
,  TRIM(pm.TAG) AS [TAG]
,  TRIM(pm.DisplayName) AS [Owner]
,  TRIM(pm.SitusAddress) AS [SitusAddress]
,  TRIM(pm.SitusCity) AS [SitusCity]
,  pm.LegalAcres
,  pm.TotalAcres
,  pm.Improvement_Status
,  pm.WorkValue_Land
,  pm.WorkValue_Impv
,  pm.WorkValue_Total
,  pm.CostingMethod
  
  From TSBv_PARCELMASTER AS pm
  
  Where pm.EffStatus = 'A'
    AND pm.ClassCD NOT LIKE '070%'
    AND pm.ClassCD NOT LIKE '060%'
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