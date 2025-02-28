-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

WITH

CTE_Permit AS (
-----Permit Metric
SELECT
p.permit_type
, YEAR(f.field_in) AS Year
--, f.field_person
, COUNT(p.lrsn) AS Permit_Parcels
, CASE
    WHEN p.permit_type IN ('1','2','PO') THEN 10
    WHEN p.permit_type IN ('3','4','12','13','14','99') THEN 5
    WHEN p.permit_type IN ('5','6','10','11','15') THEN 3
    WHEN p.permit_type IN ('9') THEN 1
    ELSE NULL
  END AS Point_Key
, CASE
    WHEN p.permit_type IN ('1','2','PO') THEN (COUNT(p.lrsn)*10)
    WHEN p.permit_type IN ('3','4','12','13','14','99') THEN (COUNT(p.lrsn)*5)
    WHEN p.permit_type IN ('5','6','10','11','15') THEN (COUNT(p.lrsn)*3)
    WHEN p.permit_type IN ('9') THEN (COUNT(p.lrsn)*1)
    ELSE NULL
  END AS Points

FROM permits AS p
LEFT JOIN field_visit AS f ON p.field_number=f.field_number

WHERE f.field_in IS NOT NULL
AND f.field_in > '2012-12-31'

GROUP BY
p.permit_type
, YEAR(f.field_in)

),


CTE_RYMemos AS (
SELECT
m.memo_id
, CAST(YEAR(CONCAT('01/01/20',RIGHT(m.memo_id, 2))) AS INT) AS Year
--, m.memo_line_number
, COUNT(m.lrsn) AS RY_Parcels
, (COUNT(m.lrsn)*7) AS Points

--, m.memo_text

FROM memos AS m
WHERE m.memo_id LIKE '%RY%'
AND m.memo_line_number = 2
AND TRIM(m.memo_text) IS NOT NULL

GROUP BY
m.memo_id
--, m.memo_line_number
--, m.memo_text
),

CTE_Sales AS(
SELECT
YEAR(t.pxfer_date) AS Year
--, t.AdjustedSalePrice
, COUNT(t.lrsn) AS Sale_Parcels
, (COUNT(t.lrsn)*7) AS Points

FROM transfer AS t
WHERE t.AdjustedSalePrice IS NOT NULL
AND t.AdjustedSalePrice > 0
AND t.pxfer_date > '2013-01-01'


GROUP BY
YEAR(t.pxfer_date)
--, t.AdjustedSalePrice
)
-------------------How would we join that??
SELECT
sale.Year
,sale.Sale_Parcels
,sale.Points
,ry.RY_Parcels
,ry.Points
,permit.Permit_Parcels
,permit.Point_Key
,permit.Points

FROM CTE_Sales AS sale

JOIN CTE_RYMemos AS ry ON sale.year=ry.year

JOIN CTE_Permit AS permit ON sale.year=permit.year