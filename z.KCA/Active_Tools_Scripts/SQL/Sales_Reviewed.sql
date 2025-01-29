-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

*/


WITH

CTE_Sales AS (
SELECT
t.AdjustedSalePrice AS SalePrice
,CAST(t.pxfer_date AS DATE) AS SaleDate
,TRIM(t.SaleDesc) AS SaleDescr
,TRIM(t.TfrType) AS TranxType
,TRIM(t.DocNum) AS DocNum -- Multiples will have the same DocNum

FROM transfer AS t -- ON t.lrsn for joins

WHERE t.status = 'A'
--AND pmd.AIN IN ('142762','135478','249334') -- Use to test cases only
AND t.AdjustedSalePrice <> '0'
AND t.pxfer_date > '2013-01-01'
--BETWEEN '2023-01-01' AND '2023-12-31'
)

SELECT
YEAR(s.SaleDate) AS YearofSale,
COUNT(s.SaleDate) AS CountofSales

FROM CTE_Sales AS s

GROUP BY
YEAR(s.SaleDate)





