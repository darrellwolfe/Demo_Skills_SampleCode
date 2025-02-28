SELECT 
  p.AIN,
  SUM(a.cost_value) AS Cost,
  SUM(a.income_value) AS Income

FROM TSBv_PARCELMASTER AS p
  JOIN allocations AS a on p.lrsn = a.lrsn

WHERE p.EffStatus = 'A'
  AND a.group_code = '19'
  AND a.status = 'A'
  AND (a.cost_value <> '0' OR a.income_value <> '0')

GROUP BY
  p.ain,
  a.income_value,
  a.cost_value