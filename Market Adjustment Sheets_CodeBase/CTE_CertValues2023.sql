


-------------------------------------
--CTE_CertValues2023
-------------------------------------

  CTE_Cert2023 AS (
    SELECT 
      lrsn,
      --Certified Values
      v.land_market_val AS [Cert_Land_2023],
      v.imp_val AS [Cert_Imp_2023],
      (v.imp_val + v.land_market_val) AS [Cert_Total_2023],
      v.eff_year AS [Tax_Year_2023],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    FROM valuation AS v
    WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
      AND v.status = 'A'
  )

