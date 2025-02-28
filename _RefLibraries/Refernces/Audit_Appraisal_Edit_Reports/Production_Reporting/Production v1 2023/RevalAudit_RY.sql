-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

SELECT * FROM information_schema.columns 
WHERE table_name LIKE 'TIF%';

--Find a table with a Column Name like...
SELECT * FROM information_schema.columns 
WHERE column_name LIKE 'TaxCalcDetail%';
*/

WITH 
CTE_Memo1 AS (
    SELECT *
    FROM memos
    WHERE memo_id = 'RY23'
    AND memo_line_number = '1'
    AND status = 'A'
),

CTE_Memo2 AS (
    SELECT *
    FROM memos
    WHERE memo_id = 'RY23'
    AND memo_line_number = '2'
    AND status = 'A'
)

SELECT DISTINCT
CASE
    WHEN pm.neighborhood >= 9000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 6003 THEN 'District_6'
    WHEN pm.neighborhood = 6002 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood = 6001 THEN 'District_6'
    WHEN pm.neighborhood = 6000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 5003 THEN 'District_5'
    WHEN pm.neighborhood = 5002 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood = 5001 THEN 'District_5'
    WHEN pm.neighborhood = 5000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 4000 THEN 'District_4'
    WHEN pm.neighborhood >= 3000 THEN 'District_3'
    WHEN pm.neighborhood >= 2000 THEN 'District_2'
    WHEN pm.neighborhood >= 1021 THEN 'District_1'
    WHEN pm.neighborhood = 1020 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 1001 THEN 'District_1'
    WHEN pm.neighborhood = 1000 THEN 'Manufactured_Homes'
    WHEN pm.neighborhood >= 451 THEN 'Commercial'
    WHEN pm.neighborhood = 450 THEN 'Specialized_Cell_Towers'
    WHEN pm.neighborhood >= 1 THEN 'Commercial'
    WHEN pm.neighborhood = 0 THEN 'N/A_or_Error'
    ELSE NULL
  END AS District
, pm.neighborhood AS GEO
, TRIM(pm.NeighborHoodName) AS GEO_Name
, TRIM(pm.pin) AS PIN
, TRIM(pm.AIN) AS AIN
, CONCAT(TRIM(pm.AIN),',') AS AIN_LookUp
, m1.*
    
    
FROM CTE_Memo1 AS m1
LEFT JOIN CTE_Memo2 AS m2 ON m1.lrsn = m2.lrsn
LEFT JOIN TSBv_PARCELMASTER AS pm ON m1.lrsn=pm.lrsn



WHERE m2.lrsn IS NULL

ORDER BY District, GEO;