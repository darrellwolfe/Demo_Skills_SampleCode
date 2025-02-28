-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
lrsn,
SUM(imp_size) AS MH_SF
imp_base_rate1

*/





--CTE_MH_SF AS (
Select
*
From improvements AS i
Where status = 'A'
And improvement_id = 'M'
--Group By lrsn
And lrsn = 562833
--)