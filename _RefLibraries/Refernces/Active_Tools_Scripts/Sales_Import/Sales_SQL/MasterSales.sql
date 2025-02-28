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
END AS District,
pm.neighborhood AS [GEO],
TRIM(pm.NeighborHoodName) AS [GEO_Name],
TRIM(pm.PropClassDescr) AS [ClassCD],
TRIM(pm.TAG) AS [TAG],
pm.lrsn,
TRIM(pm.pin) AS [PIN],
TRIM(pm.AIN) AS [AIN],
TRIM(pm.DisplayName) AS [Owner],
TRIM(pm.SitusAddress) AS [SitusAddress],
TRIM(pm.SitusCity) AS [SitusCity],
pm.LegalAcres,
pm.TotalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total,
pm.CostingMethod,
--SALES
--t.lrsn,
t.pxfer_date AS [Sale_Date],
t.AdjustedSalePrice AS [Sale_Price],
t.DocNum,
t.ConvForm,
t.SaleDesc,
t.TfrType,
t.GrantorName AS [Grantor_Seller],
t.GranteeName AS [Grantee_Buyer],
t.last_update AS [LastUpdated],
t.sxfer_date AS [Secondary_Transfer_Date],
--VALUES
--Certified Values
--i.RevObjId AS lrsn,
c.ValueAmount AS Cadaster_Assesed_Value,

--(c.ValueAmount / t.AdjustedSalePrice) AS SalesRatio
CASE 
    WHEN t.AdjustedSalePrice = 0 OR t.AdjustedSalePrice IS NULL THEN NULL 
    ELSE c.ValueAmount / t.AdjustedSalePrice 
END AS SalesRatio


FROM TSBv_PARCELMASTER AS pm

INNER JOIN transfer AS t
    ON pm.lrsn = t.lrsn
    AND t.pxfer_date BETWEEN '2024-01-01' AND '2024-12-31'
    AND t.AdjustedSalePrice > 0
    AND t.TfrType = 'S'

INNER JOIN tsbv_cadastre AS c 
    ON c.lrsn = pm.lrsn
    AND c.lrsn = t.lrsn
    And c.ValueType = 109
    --Declare @ValueTypetotal INT = 109;
    JOIN CadRoll r On c.CadRollId = r.Id
        AND r.AssessmentYear = 2024
    JOIN CadLevel l ON r.Id = l.CadRollId
    JOIN CadInv i ON l.Id = i.CadLevelId
        And CAST(i.ValEffDate AS DATE) = '2024-01-01'
        And c.CadInvId = i.Id

Where pm.EffStatus = 'A'
AND pm.ClassCD NOT LIKE '070%'
AND pm.ClassCD NOT LIKE '060%'
AND pm.ClassCD NOT LIKE '090%'



