



SELECT DISTINCT
pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
,pm.neighborhood AS GEO
,TRIM(pm.PropClassDescr) AS PCC_ClassCD
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
FROM TSBv_PARCELMASTER AS pm
WHERE pm.EffStatus = 'A'