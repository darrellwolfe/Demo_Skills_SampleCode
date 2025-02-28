-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

SELECT * FROM information_schema.columns 
WHERE table_name LIKE '%CadValue%'
AND table_name NOT LIKE 'KCv%'
ORDER BY table_name;



/*

Select *
From A_CVTAG_view
Where AIN = 121631
And valuetype = 455
---Does not run, binding error
-- invalid object name dbo.CadValue

SELECT * FROM information_schema.columns 
WHERE table_name LIKE '%CVTAG%'
AND table_name NOT LIKE 'KCv%'
ORDER BY table_name;

But this says the table exists?

SELECT * FROM information_schema.columns 
WHERE table_name LIKE '%CadValue%'
AND table_name NOT LIKE 'KCv%'
ORDER BY table_name;

This agrees there is no dbo.CadValue table
*/

