-- !preview conn=conn

/*
AsTxDBProd
GRM_Main


SELECT * FROM information_schema.columns 
WHERE column_name LIKE 'Change%'
AND table_name NOT LIKE 'KCv%'
ORDER BY table_name;

*/

















