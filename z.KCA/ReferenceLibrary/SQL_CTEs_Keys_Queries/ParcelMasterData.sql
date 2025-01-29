


--------------------------------
--CTE_ParcelMasterData
--------------------------------
CTE_ParcelMasterData AS (
Select Distinct
pm.lrsn,
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
LTRIM(RTRIM(pm.PropClassDescr)) AS [PCC_ClassCD],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
pm.LegalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total

From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

)



