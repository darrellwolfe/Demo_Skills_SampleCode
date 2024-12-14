WITH

CTE_ParcelMaster AS (
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
,TRIM(pm.SitusAddress) AS SitusAddress
,TRIM(pm.SitusCity) AS SitusCity
,TRIM(pm.SitusState) AS SitusState

From TSBv_PARCELMASTER AS pm


)



SELECT DISTINCT
pmd.EffStatus
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.ClassCD
,pmd.Property_Class_Description
,pmd.TAG
,pmd.Owner
,pmd.LegalDescription
,pmd.SitusAddress
,pmd.SitusCity
,pmd.SitusState

FROM CTE_ParcelMaster AS pmd

Where pmd.EffStatus = 'A'
And pmd.PIN LIKE 'E%'
And pmd.ClassCD LIKE '%22%'

Order by Owner, PIN;