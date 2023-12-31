-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/
-- Parcel Master with Tax Authorities
SELECT 
t.TaxAuthorityDescr,
p.TAG, p.lrsn, p.pin, p.ain, p.ClassCD, p.DisplayName, p.SitusAddress, p.SitusCity, p.neighborhood, p.Acres, p.DisplayDescr, p.EffStatus,
t.TagId, t.TagDescr, t.TaxAuthorityId

FROM KCv_PARCELMASTER1 p
INNER JOIN KCv_AumentumEasy_TagTaxAuthorities t
ON p.TAG = t.TagId


WHERE p.EffStatus = 'A'
AND (t.TaxAuthorityDescr LIKE '345%' OR t.TaxAuthorityDescr LIKE '301%')
--AND p.pin LIKE 'U%'


ORDER BY p.ClassCD, p.TAG, t.TaxAuthorityDescr, p.DisplayDescr ASC;



