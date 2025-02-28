

-------------------------------------
-- CTE_MultiSaleSums
-------------------------------------
-- Common Table Expression (CTE) to calculate the sums for Multi-Sale cases
MultiSaleSums AS (
  SELECT
    t.DocNum,
    SUM(cv23.Cert_Total_2023) AS TotalCertValue
    
    --bring in this table
    
  FROM
    transfer AS t -- ON t.lrsn for joins
    
  JOIN CTE_CertValues2023 AS cv23 ON t.lrsn=cv23.lrsn

  WHERE
    t.TfrType = 'M' -- Filter only Multi-Sale cases
  GROUP BY
    t.DocNum
),


/*
In final SELECT, use:
>>>>>>>>>    
COALESCE(msv.[MultiSaleSums], 0) AS [MultiSaleSums],

*/