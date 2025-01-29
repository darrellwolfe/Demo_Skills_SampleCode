/*
AsTxDBProd
GRM_Main

Every year after Annual Roll, the State wants a report that shows a two-year comparison of all values, with breakdowns by catageory. 
PM049 PM048 is one such report, but in 2023, he asked for it in Excel. When exported, this created a file too large to send in Outlook. 



*/

--------------------------------------------
--1. PINs WITH Group Codes Year over Year with Percent Change
--------------------------------------------

--CTEs

WITH 

  CTE_AllocationGroupCodes2022 AS (
    Select
    a.lrsn,
    LTRIM(RTRIM(a.group_code)) AS [KootenaiGroupCode],
    LEFT(a.group_code,2) AS [StateGroupCode],
    SUM(a.cost_value) AS [CertValue2022],
    MAX(a.last_update) AS [FinalDate]
    --ROW_NUMBER() OVER (PARTITION BY a.lrsn ORDER BY a.last_update DESC) AS RowNum
    --ASC) AS RowNum
    
    From allocations AS a
    Where a.status = 'H'
    And last_update LIKE '%2022%'
    
    Group By a.lrsn, a.group_code, a.last_update
  ),

  CTE_AllocationGroupCodes2023 AS (
    Select
    a.lrsn,
    LTRIM(RTRIM(a.group_code)) AS [KootenaiGroupCode],
    LEFT(a.group_code,2) AS [StateGroupCode],
    SUM(a.cost_value) AS [CertValue2023],
    MAX(a.last_update) AS [FinalDate]
    --ROW_NUMBER() OVER (PARTITION BY a.lrsn ORDER BY a.last_update DESC) AS RowNum
    --ASC) AS RowNum
    
    From allocations AS a
    Where a.status = 'H'
    And last_update LIKE '%2023%'
    
    Group By a.lrsn, a.group_code, a.last_update
  )
  
  
  
--Selects
SELECT 
  parcel.lrsn,
  LTRIM(RTRIM(parcel.pin)) AS [PIN], 
  LTRIM(RTRIM(parcel.ain)) AS [AIN], 
  parcel.neighborhood AS [GEO],
  parcel.Acres,
  parcel.ClassCD,
--Allocation GroupCode Certified Values CTEs
--2022
  agc22.[KootenaiGroupCode],
  agc22.[StateGroupCode],
  agc22.[CertValue2022],
  agc22.[FinalDate],
--2023
  agc23.[KootenaiGroupCode],
  agc23.[StateGroupCode],
  agc23.[CertValue2023],
  agc23.[FinalDate],

--Select Case Statements
--Total Percent Change  
CASE
  WHEN agc22.[CertValue2022] = 0 AND agc23.[CertValue2023] <> 0 THEN 1
  WHEN agc22.[CertValue2022] <> 0 OR agc23.[CertValue2023] <> 0 
    THEN CAST((CAST(agc23.[CertValue2023] AS decimal) / CAST(agc22.[CertValue2022] AS decimal)) AS decimal)
  ELSE 0
END AS [TotalChange%]


---Tables
FROM KCv_PARCELMASTER1 AS parcel

LEFT JOIN CTE_AllocationGroupCodes2022 AS agc22 ON parcel.lrsn=agc22.lrsn

LEFT JOIN CTE_AllocationGroupCodes2023 AS agc23 ON parcel.lrsn=agc23.lrsn
  AND agc23.[KootenaiGroupCode]=agc22.[KootenaiGroupCode]

--Conditions
WHERE parcel.EffStatus = 'A'
  AND parcel.ClassCD <> '070 Commercial - Late'
  AND parcel.ClassCD <> '090 Exempt PPV'
  AND agc23.[CertValue2023] <> '0'

ORDER BY [GEO], [PIN], agc23.[KootenaiGroupCode];







--------------------------------------------
--2. PINs without Group Codes Year over Year with Percent Change
--------------------------------------------


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
AND crt23.[Cert_Total_2023] <> '0'

ORDER BY [GEO], [PIN];


--------------------------------------------
--Allocations ONLY without PINs
--------------------------------------------


CTE_AllocationGroupCodes2022 AS (

Select
a.lrsn,
LTRIM(RTRIM(a.group_code)) AS [KootenaiGroupCode],
LEFT(a.group_code,2) AS [StateGroupCode],
SUM(a.cost_value) AS Cost,
MAX(a.last_update) AS [FinalDate],
--ROW_NUMBER() OVER (PARTITION BY a.lrsn ORDER BY a.last_update DESC) AS RowNum
--ASC) AS RowNum

From allocations AS a
Where a.status = 'H'
And last_update LIKE '%2023%'

Group By a.lrsn, pm.pin, pm.AIN, a.group_code, a.last_update;
)