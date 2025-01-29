-- !preview conn=con

SELECT *
FROM
(SELECT DISTINCT
  p.DisplayName,
  p.SitusAddress,
  p.SitusCity,
  p.SitusState,
  p.SitusZip,
  p.pin,
  p.AIN,
  (v.land_assess+v.imp_assess) AS [Assessed Value],
--  m.ModifierShortDescr,
--  m.ModifierPercent,
  v.eff_year
  
FROM TSBv_PARCELMASTER AS p
  JOIN valuation AS v ON p.lrsn=v.lrsn
--  JOIN TSBv_MODIFIERS AS m ON p.lrsn=m.lrsn
  
WHERE p.EffStatus='A'
--  AND m.ModifierShortDescr='_HOEXCap'
--  AND m.ExpirationYear='9999'
--  AND m.ModifierStatus='A'
  AND v.eff_year > '20230101'
  
ORDER BY
  v.eff_year,
  p.DisplayName,
  p.SitusAddress,
  p.SitusCity,
  p.SitusState,
  p.SitusZip,
  p.pin,
  p.AIN
) AS sb