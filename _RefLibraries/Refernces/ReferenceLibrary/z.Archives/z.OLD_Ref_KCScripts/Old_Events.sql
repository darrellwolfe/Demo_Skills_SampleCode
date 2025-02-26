-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

Select *
From events AS e
Where e.EffDate >= '2024-01-01'
--And e.event = 1
And e.lrsn = 2
Order by e.lrsn


/*
Select *
From neigh_res_impr AS n
Where n.last_update_long > 20230101

Select *
From events AS e
Where e.lrsn = 46210
And e.EffDate >= '2023-01-01'


*/