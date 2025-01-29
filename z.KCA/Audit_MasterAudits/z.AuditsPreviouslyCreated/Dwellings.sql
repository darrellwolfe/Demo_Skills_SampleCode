-- !preview conn=conn

SELECT DISTINCT *

FROM extensions AS e 

JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id = 'D'
      
WHERE e.status = 'A'
