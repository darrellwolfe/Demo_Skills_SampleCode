-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

    SELECT 
      lrsn,
      --Certified_Values
      v.land_market_val AS [Cert_Land],
      v.imp_val AS [Cert_Imp],
      (v.imp_val + v.land_market_val) AS [Cert_Total_Value],
     LEFT(CONVERT(VARCHAR, v.eff_year), 4) AS [Cert_Tax_Year],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    FROM valuation AS v
    WHERE v.eff_year BETWEEN 20130101 AND 20231231
--Change to desired year
      AND v.status = 'A'