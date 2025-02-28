-- !preview conn=conn


SELECT * FROM information_schema.columns 
WHERE column_name LIKE 'set%' --OR column_name LIKE '%parcel%'
AND table_name NOT LIKE 'KCv%'
ORDER BY table_name;





/*
SELECT * FROM information_schema.columns 
WHERE table_name LIKE 'TSBsp%'

SELECT * FROM information_schema.columns 
WHERE column_name LIKE 'Change%'
AND table_name NOT LIKE 'KCv%'
ORDER BY table_name;

--AND column_name LIKE 'Cha%';


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


tsbv_TAFRateMirror
tsbv_TIFMirror

tsbv_MktImprHistory

DECLARE @SearchTerm NVARCHAR(100) = '%search_term%';

-- Example dynamic SQL for searching a specific column in a specific table
DECLARE @SQL NVARCHAR(MAX) = 'SELECT * FROM [YourTableName] WHERE [YourColumnName] LIKE ' + QUOTENAME(@SearchTerm, '''') + ';';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;



*/


