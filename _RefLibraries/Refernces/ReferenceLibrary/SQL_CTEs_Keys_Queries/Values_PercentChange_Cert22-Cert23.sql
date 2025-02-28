-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/


----------------------
--Values Combined --Change to desired year in CTE Statements
----------------------


WITH 
  CTE_Cert2022 AS (
    SELECT 
      lrsn,
      --Certified Values
      v.land_market_val AS [Cert_Land_2022],
      v.imp_val AS [Cert_Imp_2022],
      (v.imp_val + v.land_market_val) AS [Cert_Total_2022],
      v.eff_year AS [Tax_Year_2022],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
    FROM valuation AS v
    WHERE v.eff_year BETWEEN 20220101 AND 20221231
--Change to desired year
      AND v.status = 'A'
  ),

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

SELECT 
  parcel.lrsn,
  LTRIM(RTRIM(parcel.pin)) AS [PIN], 
  LTRIM(RTRIM(parcel.ain)) AS [AIN], 
  parcel.neighborhood AS [GEO],
  parcel.Acres,
  parcel.ClassCD,
  
--Certified Values2022
  crt22.[Cert_Land_2022],
  crt22.[Cert_Imp_2022],
  crt22.[Cert_Total_2022],
  crt22.[Tax_Year_2022],

--Certified Values2023
  crt23.[Cert_Land_2023],
  crt23.[Cert_Imp_2023],
  crt23.[Cert_Total_2023],
  crt23.[Tax_Year_2023],

--Difference in Dollars
  crt23.[Cert_Land_2023] - crt22.[Cert_Land_2022] AS [LandDifference$],
  crt23.[Cert_Imp_2023] - crt22.[Cert_Imp_2022] AS [ImpDifference$],
  crt23.[Cert_Total_2023] - crt22.[Cert_Total_2022] AS [TotalDifference$],

--Land Percent Change  
CASE
  WHEN crt22.[Cert_Land_2022] = 0 AND crt23.[Cert_Land_2023] <> 0 THEN 1
  WHEN crt22.[Cert_Land_2022] <> 0 THEN (crt23.[Cert_Land_2023] - crt22.[Cert_Land_2022]) / ABS(crt22.[Cert_Land_2022])
  ELSE 0
END AS [LandChange%],

--Imp Percent Change  
CASE
  WHEN crt22.[Cert_Imp_2022] = 0 AND crt23.[Cert_Imp_2023] <> 0 THEN 1
  WHEN crt22.[Cert_Imp_2022] <> 0 THEN (crt23.[Cert_Imp_2023] - crt22.[Cert_Imp_2022]) / ABS(crt22.[Cert_Imp_2022])
  ELSE 0
END AS [ImpChange%],

--Total Percent Change  
CASE
  WHEN crt22.[Cert_Total_2022] = 0 AND crt23.[Cert_Total_2023] <> 0 THEN 1
  WHEN crt22.[Cert_Total_2022] <> 0 THEN (crt23.[Cert_Total_2023] - crt22.[Cert_Total_2022]) / ABS(crt22.[Cert_Total_2022])
  ELSE 0
END AS [TotalChange%]


FROM KCv_PARCELMASTER1 AS parcel
LEFT JOIN CTE_Cert2022 AS crt22 ON parcel.lrsn = crt22.lrsn
  AND crt22.RowNumber=1
LEFT JOIN CTE_Cert2023 AS crt23 ON parcel.lrsn = crt23.lrsn
  AND crt23.RowNumber=1

WHERE parcel.EffStatus = 'A'
  AND parcel.ClassCD <> '070 Commercial - Late'
  AND parcel.ClassCD <> '090 Exempt PPV'

ORDER BY [GEO], [PIN];