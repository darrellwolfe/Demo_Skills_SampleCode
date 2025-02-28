-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

select * from val_element_table where val_year = 2023
and val_element like 'MHOME%'
order by 1,2


