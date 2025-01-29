-- !preview conn=con

/*
AsTxDBProd
GRM_Main
*/

DECLARE @Year INT = 2023;  -- Change this value to 2022 or 2024 as desired

SELECT 
      v.lrsn,
    LTRIM(RTRIM(pm.pin)) AS [PIN], 
    LTRIM(RTRIM(pm.ain)) AS [AIN], 
    pm.neighborhood AS [GEO],
      TRIM(pm.TAG) AS TAG,
      --Assessed Values
      v.land_assess AS [Assessed Land],
      v.imp_assess AS [Assessed Imp],
      (v.imp_assess + v.land_assess) AS [Assessed Total Value],
      v.eff_year AS [Tax Year],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
FROM valuation AS v
JOIN TSBv_PARCELMASTER AS pm ON pm.lrsn=v.lrsn
WHERE v.eff_year BETWEEN (@Year * 10000 + 101) AND (@Year * 10000 + 1231)  -- Calculating start and end dates of the year
AND v.status = 'A';