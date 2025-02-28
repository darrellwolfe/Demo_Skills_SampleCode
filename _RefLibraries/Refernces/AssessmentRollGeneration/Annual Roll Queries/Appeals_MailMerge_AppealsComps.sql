WITH
--Begin CTEs
CTE_ResBldgSF AS (
  SELECT
    lrsn,
    SUM(finish_living_area) AS [ResBldg_SF]
  FROM res_floor
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_ManBldgSF AS (
  SELECT
    lrsn,
    SUM(imp_size) AS [MH_SF]
  FROM improvements
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_CommBldgSF AS (
  SELECT
    lrsn,
    SUM(area) AS [CommSF]
  FROM comm_uses
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_YearBuilt AS (
  SELECT
    lrsn,
    MAX(year_built) AS [YearBuilt],
    MAX(eff_year_built) AS [EffYear],
    MAX(year_remodeled) AS [RemodelYear]
  FROM improvements
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_SalePrice AS (
  SELECT
    lrsn,
    pxfer_date,
    AdjustedSalePrice,
    ROW_NUMBER() OVER (PARTITION BY lrsn ORDER BY pxfer_date DESC) AS RowNum
  FROM transfer
  WHERE AdjustedSalePrice <> '0'
  GROUP BY lrsn, AdjustedSalePrice, pxfer_date
)

--End CTEs, Start Primary Query

SELECT
  pm.lrsn,
  LTRIM(RTRIM(pm.pin)) AS [PIN],
  LTRIM(RTRIM(pm.AIN)) AS [AIN],
  LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
  LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
  LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD],
  LTRIM(RTRIM(pm.TAG)) AS [TAG],
  LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
  LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
  LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
  pm.LegalAcres,
  pm.TotalAcres,
  pm.Improvement_Status,
  pm.WorkValue_Land,
  pm.WorkValue_Impv,
  pm.WorkValue_Total,
  pm.CostingMethod,
  --CTEs
  rsf.[ResBldg_SF],
  msf.[MH_SF],
  csf.[CommSF],
  yb.[YearBuilt],
  sp.AdjustedSalePrice


FROM TSBv_PARCELMASTER AS pm
--CTEs
LEFT JOIN CTE_ResBldgSF AS rsf ON pm.lrsn = rsf.lrsn
LEFT JOIN CTE_ManBldgSF AS msf ON pm.lrsn = msf.lrsn
LEFT JOIN CTE_CommBldgSF AS csf ON pm.lrsn = csf.lrsn
LEFT JOIN CTE_YearBuilt AS yb ON pm.lrsn = yb.lrsn
LEFT JOIN CTE_SalePrice AS sp ON pm.lrsn = sp.lrsn


WHERE pm.EffStatus = 'A'
  AND pm.ClassCD NOT LIKE '070%'


ORDER BY GEO, PIN;
