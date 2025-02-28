WITH CTE_Aum_Detail AS (
SELECT 
  r.Id AS [Aum_LRSN],
  r.PIN AS [Aum_PIN],
  r.AIN AS [Aum_AIN],
  r.GeoCd AS [Aum_GEO],
  dh.DisplayDescr AS [Aum_Legal_Descr],
  MAX(r.BegEffDate) AS [Newest]
FROM RevObj AS r
  JOIN DescrHeader AS dh ON r.Id = dh.RevObjId
WHERE r.EffStatus = 'A'
  AND dh.EffStatus = 'A'
GROUP BY 
  r.Id,
  r.PIN,
  r.AIN,
  r.GeoCd,
  dh.DisplayDescr,
  r.BegEffDate
)

SELECT
cad.Newest,
cad.Aum_LRSN,
cad.Aum_PIN,
cad.Aum_AIN,
cad.Aum_GEO,
cad.Aum_Legal_Descr,
TRIM(p.pin) AS [PV_PIN],
TRIM(p.AIN) AS [PV_AIN],
p.DisplayDescr AS [PV_Legal_Descr],
TRIM(p.ClassCd) AS [PV_PCC],
p.DisplayName

FROM TSBv_PARCELMASTER AS p
  inner JOIN CTE_Aum_Detail AS cad ON p.lrsn = cad.Aum_LRSN

WHERE p.EffStatus = 'A'
  AND p.neighborhood = '33'
  
ORDER BY p.pin ASC