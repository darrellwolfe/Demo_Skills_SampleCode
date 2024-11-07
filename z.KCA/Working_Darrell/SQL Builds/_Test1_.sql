Select Distinct
pm.EffStatus
,pm.lrsn
,TRIM(pm.pin) AS PIN
,TRIM(pm.AIN) AS AIN
,pm.ClassCD
,TRIM(pm.PropClassDescr) AS Property_Class_Description
,TRIM(pm.TAG) AS TAG
,TRIM(pm.DisplayName) AS Owner
,TRIM(pm.DisplayDescr) AS LegalDescription

,SUBSTRING(pm.DisplayDescr, PATINDEX('%SITUS#%[0-9][0-9][0-9][0-9][0-9][0-9]%', pm.DisplayDescr) + 6, 6) AS SitusAIN

,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,TRIM(pm.SitusState) AS SitusState

From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'
And pm.PIN LIKE 'E%'
And pm.DisplayName LIKE 'AT&T M%'