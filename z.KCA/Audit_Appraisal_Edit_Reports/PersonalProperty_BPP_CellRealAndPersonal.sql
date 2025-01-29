WITH

CTE_BPP_PINS AS (
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

),

CTE_CELL_PINS AS (
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
And pm.PIN LIKE '%CELL%'


)



SELECT DISTINCT
bpp.EffStatus
,bpp.lrsn
,bpp.PIN
,bpp.AIN
,bpp.ClassCD
,bpp.Property_Class_Description
,bpp.TAG
,bpp.Owner
,bpp.LegalDescription
,bpp.SitusAIN
,bpp.SitusAddress
,bpp.SitusCity
,'>>>' AS CellData
,cell.PIN AS CELLPIN
,cell.AIN AS CELLAIN
,cell.LegalDescription AS CELLLEGAL
,cell.SitusAIN AS CELLSITUSAIN
,cell.SitusAddress AS CELLSITUSADDRESS


FROM CTE_BPP_PINS AS bpp

--LEFT JOIN CTE_CELL_PINS AS cell ON cell.SitusAIN = bpp.SitusAIN

FULL OUTER JOIN CTE_CELL_PINS AS cell ON cell.SitusAIN = bpp.SitusAIN

WHERE (bpp.Owner LIKE 'AT&T MOB%'
    OR cell.Owner LIKE 'AT&T MOB%')

AND (bpp.EffStatus = 'A'
    OR cell.EffStatus = 'A')