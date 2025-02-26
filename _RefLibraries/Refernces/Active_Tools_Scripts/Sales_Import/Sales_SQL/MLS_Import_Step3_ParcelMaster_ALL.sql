--Use PM to ensure MLS data matches a valid parcel
WITH CTE_ParcelMaster AS (
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
  WHEN pm.neighborhood = 0 THEN 'Other (PP, OP, NA, Error)'
  ELSE NULL
END AS District
,pm.neighborhood AS GEO
,TRIM(pm.NeighborHoodName) AS GEO_Name
,pm.lrsn
,UPPER(TRIM(pm.pin)) AS PIN
,UPPER(TRIM(pm.AIN)) AS AIN
,UPPER(TRIM(pm.DisplayName)) AS Owner
,UPPER(TRIM(pm.DisplayDescr)) AS LegalDescription
,UPPER(TRIM(pm.SitusAddress)) AS SitusAddress
,UPPER(TRIM(pm.SitusCity)) AS SitusCity
,UPPER(TRIM(pm.SitusZip)) AS SitusZip
,pm.EffStatus
From TSBv_PARCELMASTER AS pm
Where pm.pin NOT LIKE 'E%'
And pm.pin NOT LIKE 'G%'
And pm.pin NOT LIKE 'U%'
AND pm.ClassCD NOT LIKE '070%'
)
SELECT
pmd.District
,pmd.GEO
,pmd.GEO_Name
,pmd.lrsn
,pmd.PIN
,pmd.AIN
,pmd.Owner
,pmd.SitusAddress
,pmd.SitusCity
,pmd.SitusZip
,pmd.LegalDescription
,pmd.EffStatus
FROM CTE_ParcelMaster AS pmd