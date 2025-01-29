CTE_ResBldgSF AS (
  SELECT
    lrsn,
    SUM(finish_living_area) AS ResBldg_SF
  FROM res_floor
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_ManBldgSF AS (
  SELECT
    e.lrsn,
    SUM(i.imp_size) AS MH_SF
  FROM extensions AS e --ON kcv.lrsn=e.lrsn
  --AND e.status = 'A'
    JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      AND i.improvement_id IN ('M')
      --('M','','')
  WHERE e.status = 'A'
  GROUP BY e.lrsn
),

CTE_CommBldgSF AS (
  SELECT
    lrsn,
    SUM(area) AS CommSF
  FROM comm_uses
  WHERE status = 'A'
  GROUP BY lrsn
),

CTE_YearBuilt AS (
  SELECT
    e.lrsn,
    MAX(i.year_built) AS YearBuilt,
    MAX(i.eff_year_built) AS EffYear,
    MAX(i.year_remodeled) AS RemodelYear
  
  FROM extensions AS e --ON kcv.lrsn=e.lrsn
  --AND e.status = 'A'
  JOIN improvements AS i ON e.lrsn=i.lrsn 
      AND e.extension=i.extension
      AND i.status='A'
      --AND i.improvement_id IN ('M','','')  
    WHERE e.status = 'A'
  GROUP BY e.lrsn
),