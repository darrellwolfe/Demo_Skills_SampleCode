WITH

CTE_ParcelMaster AS (
--------------------------------
--ParcelMaster
--------------------------------
Select Distinct
CASE
  WHEN pm.neighborhood >= 9000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 6003 THEN 'District_6'
  WHEN pm.neighborhood = 6002 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood = 6001 THEN 'District_6'
  WHEN pm.neighborhood = 6000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 5003 THEN 'District_5'
  WHEN pm.neighborhood = 5002 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood = 5001 THEN 'District_5'
  WHEN pm.neighborhood = 5000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 4000 THEN 'District_4'
  WHEN pm.neighborhood >= 3000 THEN 'District_3'
  WHEN pm.neighborhood >= 2000 THEN 'District_2'
  WHEN pm.neighborhood >= 1021 THEN 'District_1'
  WHEN pm.neighborhood = 1020 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 1001 THEN 'District_1'
  WHEN pm.neighborhood = 1000 THEN 'Manufactured_Homes'
  WHEN pm.neighborhood >= 451 THEN 'Commercial'
  WHEN pm.neighborhood = 450 THEN 'Specialized_Cell_Towers'
  WHEN pm.neighborhood >= 1 THEN 'Commercial'
  WHEN pm.neighborhood = 0 THEN 'N/A_or_Error'
  ELSE NULL
END AS District

-- # District SubClass
,pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,pm.EffStatus
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
,pm.LegalAcres
,pm.Improvement_Status 


From TSBv_PARCELMASTER AS pm


),


MemoSearch AS (
Select
m.lrsn
,m.memo_id AS LAND
,m.memo_text AS MemoTexts
FROM memos AS m

WHERE m.memo_id  = 'LAND'
And m.memo_line_number = '2'
AND m.status = 'A'
)




SELECT DISTINCT
pmd.lrsn
,pmd.PIN
,pmd.AIN
,m.MemoTexts
,pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.EffStatus
FROM CTE_ParcelMaster AS pmd

LEFT JOIN MemoSearch AS m
  ON m.lrsn = pmd.lrsn

--Where pmd.AIN IN (351039,351040,351041,351042,351044,351045,351046,351047,351048,351049,351050,351051,351052,351053,351054,351055,351056,351081,351082,351083,351084,351085,351086,351087,351088,351089,351090,351091,351092,351093,351094,351095,351096,351097,351098,351101,351102,351103,351104,351105,351106,351132,351133,351134,351135,351136,351137,351140,351141,351142,351143,351144,351145,351209,351219,351226)
Where pmd.EffStatus = 'A'
And pmd.PIN LIKE 'HL890%'

Order by District,GEO,PIN;