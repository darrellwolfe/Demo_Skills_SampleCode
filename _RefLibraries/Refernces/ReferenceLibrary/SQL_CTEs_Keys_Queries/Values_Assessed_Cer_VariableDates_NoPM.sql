-- !preview conn=con

/*
AsTxDBProd
GRM_Main
*/

DECLARE @Year INT = 2023;  -- Change this value to 2022 or 2024 as desired

SELECT 
    v.lrsn,
    --Assessed Values
    v.land_assess AS [Assessed_Land],
    v.imp_assess AS [Assessed_Imp],
    (v.imp_assess + v.land_assess) AS [Assessed_Total_Value],
    v.eff_year AS [Tax_Year],
    v.land_market_val AS [Cert_Land],
    v.imp_val AS [Cert_Imp],
    (v.imp_val + v.land_market_val) AS [Cert_Total_Value],
    v.valuation_comment AS [Val_Comment],
    ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    
FROM valuation AS v
WHERE v.eff_year BETWEEN (@Year * 10000 + 101) AND (@Year * 10000 + 1231)  -- Calculating start and end dates of the year
AND v.status = 'A';







