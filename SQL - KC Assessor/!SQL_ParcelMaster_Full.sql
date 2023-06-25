/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/

---------
--Select All
---------
Select Distinct *
From TSBv_PARCELMASTER
Where pm.EffStatus = 'A'


--------------------------------
--ParcelMaster
--------------------------------

Select Distinct
pm.lrsn,
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD],
LTRIM(RTRIM(pm.TAG)) AS [TAG],
LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
pm.LegalAcres,
pm.TotalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total,
pm.CostingMethod

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'
  AND pm.ClassCD NOT LIKE '070%'
  
Group By
pm.lrsn,
pm.pin,
pm.AIN,
pm.PropClassDescr,
pm.neighborhood,
pm.NeighborHoodName,
pm.TAG,
pm.DisplayName,
pm.SitusAddress,
pm.SitusCity,
pm.LegalAcres,
pm.TotalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total,
pm.CostingMethod

Order By GEO, PIN;


---------
--Select Lite
---------

Select
LTRIM(RTRIM(pm.lrsn)) AS [LRSN],
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.PropClassDescr)) AS [PCC],
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(pm.DisplayName)) AS [OwnerName],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity]

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'


---------
--Select Distinct - Key
---------

Select Distinct
LTRIM(RTRIM(pm.lrsn)) AS [LRSN],
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.PropClassDescr)) AS [PCC]

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'

GROUP BY
pm.lrsn,
pm.pin,
pm.AIN,
pm.PropClassDescr,
pm.neighborhood












--------------------------------
--ParcelMaster w/ Mailing
--------------------------------

Select Distinct
pm.lrsn,
LTRIM(RTRIM(pm.pin)) AS [PIN],
LTRIM(RTRIM(pm.AIN)) AS [AIN],
LTRIM(RTRIM(pm.neighborhood)) AS [GEO],
LTRIM(RTRIM(pm.NeighborHoodName)) AS [GEO_Name],
LTRIM(RTRIM(pm.PropClassDescr)) AS [ClassCD],
LTRIM(RTRIM(pm.TAG)) AS [TAG],
LTRIM(RTRIM(pm.DisplayName)) AS [Owner],
LTRIM(RTRIM(pm.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(pm.SitusCity)) AS [SitusCity],
pm.AttentionLine,
pm.MailingAddress,
pm.AddlAddrLine,
pm.MailingCity,
pm.MailingState,
pm.MailingZip,
pm.MailingCountry,
pm.LegalAcres,
pm.TotalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total,
pm.CostingMethod

From TSBv_PARCELMASTER AS pm

Where pm.EffStatus = 'A'

Group By
pm.lrsn,
pm.pin,
pm.AIN,
pm.PropClassDescr,
pm.neighborhood,
pm.NeighborHoodName,
pm.TAG,
pm.DisplayName,
pm.SitusAddress,
pm.SitusCity,
pm.LegalAcres,
pm.TotalAcres,
pm.Improvement_Status,
pm.WorkValue_Land,
pm.WorkValue_Impv,
pm.WorkValue_Total,
pm.CostingMethod,
pm.AttentionLine,
pm.MailingAddress,
pm.AddlAddrLine,
pm.MailingCity,
pm.MailingState,
pm.MailingZip,
pm.MailingCountry

Order By GEO, PIN;




-------
--OLD KCv Version
------

SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
--Mailing
LTRIM(RTRIM(parcel.AttentionLine)) AS [Attn],
LTRIM(RTRIM(parcel.MailingAddress)) AS [MailingAddress],
LTRIM(RTRIM(parcel.MailingCityStZip)) AS [Mailing CSZ],

--Acres
parcel.Acres,
--Other
LTRIM(RTRIM(parcel.TAG)) AS [TAG], 
LTRIM(RTRIM(parcel.DisplayDescr)) AS [LegalDescription],
LTRIM(RTRIM(parcel.SecTwnRng)) AS [SecTwnRng]

FROM KCv_PARCELMASTER1 AS parcel

WHERE parcel.EffStatus= 'A'


ORDER BY parcel.neighborhood, parcel.pin;
