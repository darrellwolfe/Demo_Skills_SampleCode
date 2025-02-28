-- !preview conn=con

SELECT 
  TRIM(p.pin) AS [PIN], 
  TRIM(p.ain) AS [AIN], 
  p.neighborhood AS [GEO],
  a.group_code AS [GroupCode],
  a.property_class AS [ClassCode],
  a.extension AS [Record],
  a.improvement_id AS [ImpId]

FROM KCv_PARCELMASTER1 AS p
JOIN allocations AS a ON p.lrsn = a.lrsn
WHERE p.EffStatus = 'A'
  AND a.status = 'A'
  AND (p.pin LIKE '0%'
        OR p.pin LIKE '47%'
        OR p.pin LIKE '48%'
        OR p.pin LIKE '49%'
        OR p.pin LIKE '50%'
        OR p.pin LIKE '51%'
        OR p.pin LIKE '52%'
        OR p.pin LIKE '53%'
        OR p.pin LIKE '54%')
  AND a.group_code IN ('20','21','22','30','41','42','43')
  AND p.neighborhood <> 0

ORDER BY [GEO], [PIN];