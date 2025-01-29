-- !preview conn=con

/*
AsTxDBProd
GRM_Main
*/

/*
SELECT * FROM information_schema.columns 
WHERE table_name LIKE '%Set';

Select *
From AsmtEventWorkingSet

*/

WITH 

CTE_Values AS (

    SELECT 
      v.lrsn,
    --Assessed Values
      v.land_assess AS [Assessed Land],
      v.imp_assess AS [Assessed Imp],
      (v.imp_assess + v.land_assess) AS [Assessed Total Value],
      v.eff_year AS [Tax Year],
      ROW_NUMBER() OVER (PARTITION BY v.lrsn ORDER BY v.last_update DESC) AS RowNumber
      
    FROM valuation AS v
    WHERE v.eff_year BETWEEN 20230101 AND 20231231
--Change to desired year
      AND v.status = 'A'
)

--CTE_ParcelTAGS AS ( ) -- <-In Case you re-use this as a base for something else.
    
    SELECT
    TRIM(pm.TAG) AS TAG,
    SUM(CAST(ctev.[Assessed Total Value] AS bigint)) AS ValueTest

    FROM TSBv_PARCELMASTER AS pm 
    JOIN CTE_Values AS ctev 
      ON pm.lrsn=ctev.lrsn
      AND ctev.RowNumber = '1'
      
    WHERE pm.EffStatus='A'
    
    GROUP BY pm.TAG