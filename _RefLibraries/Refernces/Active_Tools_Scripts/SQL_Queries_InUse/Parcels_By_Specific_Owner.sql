/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/

--------------------------------
--ParcelMaster w/ Mailing
--------------------------------

Select Distinct
pm.lrsn,
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
pm.AttentionLine,
pm.MailingAddress,
pm.AddlAddrLine,
pm.MailingCity,
pm.MailingState,
pm.MailingZip,
pm.MailingCountry,
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD],
LTRIM(RTRIM(pm.TAG)) AS [TAG],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity]

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
  AND pm.ClassCD NOT LIKE '070%'
  AND (pm.DisplayName LIKE '%Avista%'
      OR pm.DisplayName LIKE '%Rathdrum Power%'
      OR pm.DisplayName LIKE '%RathdrumPower%'
      )

Group By
pm.lrsn,
pm.pin,
pm.AIN,
pm.DisplayName,
pm.AttentionLine,
pm.MailingAddress,
pm.AddlAddrLine,
pm.MailingCity,
pm.MailingState,
pm.MailingZip,
pm.MailingCountry,
pm.PropClassDescr,
pm.neighborhood,
pm.TAG,
pm.SitusAddress,
pm.SitusCity

Order By [Owner], [ClassCD], GEO, PIN;