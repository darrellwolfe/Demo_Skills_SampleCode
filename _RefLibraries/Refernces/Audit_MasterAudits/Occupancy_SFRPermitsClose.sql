DECLARE @CURRENTYEAR AS int = CONCAT((YEAR(GETDATE())),'0101')
;

SELECT DISTINCT
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
    TRIM(p.pin) AS [PIN],
    TRIM(p.AIN) AS [AIN],
    TRIM(pe.permit_ref) AS [PERMIT_NO.],
    pe.permit_desc AS [PERMIT_DESCRIPTION],
    CAST(fv.date_completed AS DATE) AS [DATE_COMPLETED]
    

FROM TSBv_PARCELMASTER AS p
    JOIN permits AS pe ON p.lrsn = pe.lrsn
        AND pe.permit_type = '1'
        AND pe.status = 'A'
    JOIN field_visit AS fv ON pe.field_number = fv.field_number
        AND fv.status = 'A'
        AND fv.date_completed IS NOT NULL
    JOIN valuation AS v ON p.lrsn = v.lrsn
      AND v.eff_year > @CURRENTYEAR
      AND v.status = 'A'