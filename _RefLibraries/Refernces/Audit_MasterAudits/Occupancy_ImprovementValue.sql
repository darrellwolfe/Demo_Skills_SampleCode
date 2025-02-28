DECLARE @CURRENTYEAR AS int = CONCAT((YEAR(GETDATE())),'0101')
;

WITH CTE_OccValue AS (
SELECT 
    p.lrsn,
    p.AIN,
    v.eff_year,
    v.land_market_val,
    v.imp_val
FROM TSBv_PARCELMASTER AS p
    JOIN valuation AS v ON p.lrsn = v.lrsn
        AND v.eff_year > @CURRENTYEAR
        AND v.status = 'A'
WHERE p.EffStatus = 'A'
)

SELECT 
    CASE
        WHEN p.neighborhood >= 9000 THEN 'Manufactured_Homes'
        WHEN p.neighborhood >= 6003 THEN 'District_6'
        WHEN p.neighborhood = 6002 THEN 'Manufactured_Homes'
        WHEN p.neighborhood = 6001 THEN 'District_6'
        WHEN p.neighborhood = 6000 THEN 'Manufactured_Homes'
        WHEN p.neighborhood >= 5003 THEN 'District_5'
        WHEN p.neighborhood = 5002 THEN 'Manufactured_Homes'
        WHEN p.neighborhood = 5001 THEN 'District_5'
        WHEN p.neighborhood = 5000 THEN 'Manufactured_Homes'
        WHEN p.neighborhood >= 4000 THEN 'District_4'
        WHEN p.neighborhood >= 3000 THEN 'District_3'
        WHEN p.neighborhood >= 2000 THEN 'District_2'
        WHEN p.neighborhood >= 1021 THEN 'District_1'
        WHEN p.neighborhood = 1020 THEN 'Manufactured_Homes'
        WHEN p.neighborhood >= 1001 THEN 'District_1'
        WHEN p.neighborhood = 1000 THEN 'Manufactured_Homes'
        WHEN p.neighborhood >= 451 THEN 'Commercial'
        WHEN p.neighborhood = 450 THEN 'Specialized_Cell_Towers'
        WHEN p.neighborhood >= 1 THEN 'Commercial'
        WHEN p.neighborhood = 0 THEN 'N/A_or_Error'
        ELSE NULL
    END AS [District], 
    p.neighborhood AS [GEO],
    TRIM(p.AIN) AS [AIN],
    TRIM(p.pin) AS [PIN],
    cov.eff_year AS [OCC_POSTED_DATE],
    p.CostingMethod AS [COST_METHOD],
    (cov.imp_val - v.imp_val) AS [OCCUPANCY_VALUE],
    v.imp_val AS [1_1_IMP_VALUE],
    cov.imp_val AS [OCC_IMP_VALUE]

FROM TSBv_PARCELMASTER AS p
    JOIN CTE_OccValue AS cov ON p.lrsn = cov.lrsn
    JOIN valuation AS v ON p.lrsn = v.lrsn
      AND v.eff_year = @CURRENTYEAR
      AND v.status = 'A'

WHERE p.EffStatus = 'A'

ORDER BY OCCUPANCY_VALUE ASC
;