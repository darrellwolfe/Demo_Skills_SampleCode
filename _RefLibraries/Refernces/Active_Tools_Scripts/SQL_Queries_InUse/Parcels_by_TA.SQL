-- !preview conn=conn

SELECT DISTINCT
-- TAG.Descr AS [TAG],
TaxAuthority.Descr AS [TaxAuthority_Name],
Count (DISTINCT pm.LRSN)

FROM TAG
LEFT JOIN TSBv_PARCELMASTER AS pm ON Tag.Descr = pm.TAG
LEFT JOIN TAGTIF ON TAG.Id=TAGTIF.TAGId 
  AND TAGTIF.EffStatus = 'A'
LEFT JOIN TIF ON TAGTIF.TIFId=TIF.Id 
  AND TIF.EffStatus  = 'A'
LEFT JOIN TAGTaxAuthority ON TAG.Id=TAGTaxAuthority.TAGId 
  AND TAGTaxAuthority.EffStatus = 'A'
LEFT JOIN TaxAuthority ON TAGTaxAuthority.TaxAuthorityId=TaxAuthority.Id 
  AND TaxAuthority.EffStatus = 'A'

WHERE TAG.EffStatus = 'A'
--AND TaxAuthority.Descr LIKE '203%'

GROUP BY
TaxAuthority.Descr 
