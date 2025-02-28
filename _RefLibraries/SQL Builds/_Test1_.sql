



--CTE_Exentions AS (
SELECT DISTINCT
e.*,
lrsn,
ext_id,
extension,
ext_description
--e.*
FROM extensions AS e -- ON e.lrsn 
WHERE e.status='A'
AND e.extension LIKE 'L%'
--)



