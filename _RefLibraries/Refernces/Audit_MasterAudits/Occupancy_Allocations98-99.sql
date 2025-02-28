DECLARE @CURRENTYEAR AS int = CONCAT((YEAR(GETDATE())),'0101')
;

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
    a.group_code,
    v.eff_year

FROM TSBv_PARCELMASTER AS p
    JOIN allocations AS a ON p.lrsn = a.lrsn
        AND a.group_code IN ('98','99')
        AND a.status = 'A'
    JOIN valuation AS v ON p.lrsn = v.lrsn
      AND v.eff_year > @CURRENTYEAR
      AND v.status = 'A'