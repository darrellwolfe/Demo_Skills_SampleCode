-- !preview conn=con

SELECT p.AIN,
m.BegTaxYear,
m.ExpirationYear,
m.ApplicationDate,
m.ModifierPercent,
m.StandardCap,
m.OverrideAmount,
m.StartTimeStamp,
m.UserName

FROM TSBv_PARCELMASTER AS p
JOIN TSBv_MODIFIERS AS m ON m.lrsn = p.lrsn
  AND m.ModifierDescr = '602G Residential Improvements - Homeowners'
--  AND m.BegTaxYear = '2023'
  AND m.ExpirationYear > '2024'
  AND m.PINStatus = 'A'
  AND m.ModifierStatus = 'A'
  and p.AIN = '178505'

ORDER BY p.AIN