-- !preview conn=con
SELECT DISTINCT
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
LTRIM(RTRIM(pm.MailingAddress)) AS [Mailing Address],
LTRIM(RTRIM(pm.MailingCityStZip)) AS [CityStZip]

FROM TSBv_PARCELMASTER AS pm

WHERE pm.EffStatus = 'A'

GROUP BY
pm.pin,
pm.AIN,
pm.DisplayName,
pm.SitusAddress,
pm.MailingAddress,
pm.MailingCityStZip