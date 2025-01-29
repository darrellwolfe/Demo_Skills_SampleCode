
-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

, cal.group_code
, cal.market_value
, cal.cost_value


*/

SELECT DISTINCT
  YEAR(t.pxfer_date) AS Year_Key,
  FORMAT(CONVERT(DATETIME, CONCAT(YEAR(t.pxfer_date), '-01-01')), 'MM/dd/yyyy') AS Year_Date
FROM transfer AS t
WHERE t.AdjustedSalePrice IS NOT NULL
  AND t.AdjustedSalePrice > 0
  AND t.pxfer_date > '2012-12-31'
