-- !preview conn=con

SELECT
    e.lrsn,
    -- e.extension,
    pm.ain,
    pm.neighborhood,
    e.data_source_code,
    e.data_collector,
    e.collection_date
    -- pm.EffStatus

FROM extensions AS e

JOIN TSBv_PARCELMASTER AS pm
  ON e.lrsn = pm.lrsn
  AND pm.EffStatus = 'A'
  
WHERE e.extension = 'L00'
    AND (e.collection_date >= {ts '2022-01-01 00:00:00'}
    AND e.collection_date < {ts '2023-12-31 00:00:01'})

ORDER BY e.data_collector,
         pm.neighborhood,
         e.data_source_code,
         e.lrsn,
         e.extension