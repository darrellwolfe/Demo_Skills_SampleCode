-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/


Select *
From allocations
--Where group_code = '99' and '98'
Where group_code IN ('99', '98')
And status = 'A'
