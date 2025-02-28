/*
AsTxDBProd
GRM_Main


In the context of sales, specifically in real estate transactions, "GrantorName" and "GranteeName" refer to the parties involved in the transfer of property ownership.

GrantorName: The Grantor is the party who is transferring or "granting" their ownership rights in a property to another party. The GrantorName refers to the name of the individual, group, or organization that is giving up their ownership interest in the property. Typically, the Grantor is the seller in a real estate transaction.

GranteeName: The Grantee is the party who is receiving or "being granted" the ownership rights in a property from the Grantor. The GranteeName refers to the name of the individual, group, or organization that is acquiring the ownership interest in the property. Typically, the Grantee is the buyer in a real estate transaction.
*/

SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
--Sales Transfer Table from GRM Main
t.pxfer_date AS [TransferDate],
t.AdjustedSalePrice AS [SalesPrice_ProVal],
t.DocNum,
t.ConvForm,
t.SaleDesc,
t.TfrType,
t.GrantorName AS [Grantor_Seller],
t.GranteeName AS [Grantee_Buyer],
t.last_update AS [LastUpdated],
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [ProValOwner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
--Acres
parcel.Acres,
--Other
LTRIM(RTRIM(parcel.TAG)) AS [TAG], 
LTRIM(RTRIM(parcel.DisplayDescr)) AS [LegalDescription]


FROM KCv_PARCELMASTER1 AS parcel
JOIN transfer AS t ON parcel.lrsn=t.lrsn


WHERE parcel.EffStatus = 'A'
AND t.status = 'A'
AND t.pxfer_date > '2023-01-01'

ORDER BY [GEO],[PIN];






