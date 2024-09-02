-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

    SELECT 
      lrsn,
      --Assessed_Values
      v.land_assess AS [Assessed_Land],
      v.imp_assess AS [Assessed_Imp],
      (v.imp_assess + v.land_assess) AS [Assessed_Total_Value],
      LEFT(CONVERT(VARCHAR, v.eff_year), 4) AS [Assessed_Tax_Year],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    FROM valuation AS v
    WHERE v.eff_year BETWEEN 20130101 AND 20231231
--Change to desired year
      AND v.status = 'A'