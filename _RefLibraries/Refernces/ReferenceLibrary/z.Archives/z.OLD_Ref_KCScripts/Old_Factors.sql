-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/




Select *
From income_factors
Where neighborhood = 4999
And table_type LIKE 'RENT%'