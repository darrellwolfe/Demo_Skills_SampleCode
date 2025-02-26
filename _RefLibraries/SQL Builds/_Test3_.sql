Select Distinct
*

/*
e.lrsn,
e.extension,
e.ext_description,
i.imp_type,
i.year_built
*/
--Extensions always comes first
FROM extensions AS e -- ON e.lrsn --lrsn link if joining this to another query
  -- AND e.status = 'A' -- Filter if joining this to another query
JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M','C','D')
--Conditions
WHERE e.status = 'A'
AND i.year_built = 2023
--AND i.year_built = @TaxYear-1