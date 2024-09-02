/*


SELECT * FROM information_schema.columns 
WHERE table_name LIKE 'CAD%'
OR table_name LIKE 'Value%'


SELECT * FROM information_schema.columns 
WHERE table_name LIKE 'TIF%';

SELECT * FROM information_schema.columns 
WHERE column_name LIKE 'TaxCalcDetail%';


--SELECT * FROM information_schema.columns 
--WHERE column_name LIKE '%Due%';


SELECT
    tc.table_name AS foreign_table,
    kcu.column_name AS foreign_column,
    ccu.table_name AS primary_table,
    ccu.column_name AS primary_column
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
WHERE
    tc.constraint_type = 'FOREIGN KEY'
    AND kcu.table_name = 'YourTableName'
    AND kcu.column_name = 'YourIDColumnName';


*/



Select *
From Appeals