DECLARE @CURRENTYEARDATE AS int = CONCAT((YEAR(GETDATE())),'0101')
DECLARE @CURRENTYEAR AS int = YEAR(GETDATE())
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
    m.BegTaxYear AS [APPLY_YEAR],
    m.ExpirationYear AS [EXPIRE_YEAR],
    v.eff_year

FROM TSBv_PARCELMASTER AS p
    JOIN TSBv_MODIFIERS AS m ON p.lrsn = m.lrsn
        AND m.ModifierShortDescr = 'BusInvExempt'
        AND m.ModifierStatus = 'A'
        AND m.ExpirationYear > @CURRENTYEAR
        AND m.PINStatus = 'A'
    JOIN valuation AS v ON p.lrsn = v.lrsn
        AND v.eff_year > @CURRENTYEARDATE
        AND v.status = 'A'