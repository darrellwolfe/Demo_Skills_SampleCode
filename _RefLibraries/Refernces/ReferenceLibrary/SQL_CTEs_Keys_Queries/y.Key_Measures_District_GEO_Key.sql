-- !preview conn=conn


WITH 

CTE_GEOs AS (

SELECT DISTINCT
pm.neighborhood AS GEO
FROM TSBv_PARCELMASTER AS pm
WHERE pm.EffStatus = 'A'
AND pm.neighborhood <> 0;

)

SELECT
    CASE
        WHEN GEO >= 9000 THEN 'Manufactured Homes'
        WHEN GEO >= 6003 THEN 'District 6'
        WHEN GEO = 6002 THEN 'Manufactured Homes'
        WHEN GEO = 6001 THEN 'District 6'
        WHEN GEO = 6000 THEN 'Manufactured Homes'
        WHEN GEO >= 5003 THEN 'District 5'
        WHEN GEO = 5002 THEN 'Manufactured Homes'
        WHEN GEO = 5001 THEN 'District 5'
        WHEN GEO = 5000 THEN 'Manufactured Homes'
        WHEN GEO >= 4000 THEN 'District 4'
        WHEN GEO >= 3000 THEN 'District 3'
        WHEN GEO >= 2000 THEN 'District 2'
        WHEN GEO >= 1021 THEN 'District 1'
        WHEN GEO = 1020 THEN 'Manufactured Homes'
        WHEN GEO >= 1001 THEN 'District 1'
        WHEN GEO = 1000 THEN 'Manufactured Homes'
        WHEN GEO >= 451 THEN 'Commercial'
        WHEN GEO = 450 THEN 'Personal Property'
        WHEN GEO >= 1 THEN 'Commercial'
        WHEN GEO = 0 THEN 'N/A or Error'
        ELSE NULL
    END AS District,
    GEO
FROM CTE_GEOs
ORDER BY District, GEO