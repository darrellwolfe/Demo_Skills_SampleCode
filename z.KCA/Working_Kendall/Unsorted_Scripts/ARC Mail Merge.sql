-- !preview conn=conn

SELECT
  TRIM(p.pin) AS [PIN],
  TRIM(p.AIN) AS [AIN],
  p.DisplayName,
  p.MailingAddress,
  TRIM(p.MailingCityStZip) AS [Mailing_City_St_ZIP],
  TRIM(p.SitusAddress) AS [Situs_Address]

FROM TSBv_PARCELMASTER as p

WHERE p.EffStatus = 'A'
