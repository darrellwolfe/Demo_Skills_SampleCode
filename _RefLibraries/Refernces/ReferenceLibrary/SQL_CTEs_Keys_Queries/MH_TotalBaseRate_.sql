-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/











CTE_MH_TotalBaseRate AS (
Select
lrsn
,mh_length
,mh_width
,total_base_price1
,subtot2_1
,subtot3_1
,subtot4_1
,reproduction_cost1

From dwellings AS i
Where status = 'A'
--And improvement_id = 'M'
--Group By lrsn
--And lrsn = 562833
)