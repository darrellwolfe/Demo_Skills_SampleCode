--------------------------------------------
/*
AsTxDBProd
GRM_Main


Various TAG,TIF, TaxAuthority, combinations

--Tables
KCv_AumentumEasy_TagTaxAuthorities
TAG
TIF
TAGTIF
TAGTaxAuthority

*/

--Single Table Lookups

Select *
From TAG

Select *
From TAGTIF

Select *
From TIF

Select *
From TAGTaxAuthority

SELECT *
FROM TaxAuthority

SELECT *
FROM Tafrate

SELECT *
FROM tsbv_cadastre

SELECT *
FROM tsbv_cadastre
WHERE taxyear = '2023' AND AIN = '107763'

Select *
From tsbv_tagtaxauthority
Where tag = 










-- Begin CTE Key
CTE_TAG_TA_TIF_Key AS (

  SELECT DISTINCT 
  tag.Id AS TAGId,
  TRIM(tag.Descr) AS TAG,
  tif.Id AS TIFId,
  TRIM(tif.Descr) AS TIF,
  ta.Id AS TaxAuthId,
  TRIM(ta.Descr) AS TaxAuthority
  
  --TAG Table
  FROM TAG AS tag
  --TAGTIF Key
  LEFT JOIN TAGTIF 
    ON TAG.Id=TAGTIF.TAGId 
    AND TAGTIF.EffStatus = 'A'
  --TIF Table
  LEFT JOIN TIF AS tif 
    ON TAGTIF.TIFId=TIF.Id 
    AND TIF.EffStatus  = 'A'
  --TAGTaxAuthority Key
  LEFT JOIN TAGTaxAuthority 
    ON TAG.Id=TAGTaxAuthority.TAGId 
    AND TAGTaxAuthority.EffStatus = 'A'
  --TaxAuthority Table
  LEFT JOIN TaxAuthority AS ta 
    ON TAGTaxAuthority.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
  --CTE_ JOIN, only want TAGs in this TaxAuth
  
  WHERE tag.EffStatus = 'A'

) 
-- End CTE Key













--TAG_TIF_TaxAuth Combined
Select
TAGTIF.Id AS [TAGTIFId],
--New Group
'' AS [TAG_Info_>],
TAG.Id AS [TagId],
TAG.BegEffYear AS [TagEffYr],
TAG.EffStatus AS [TagStatus],
TAG.TranId AS [TagTranId],
TAG.TAGType AS [TagType],
TAG.Descr AS [TAG],
--New Group
'' AS [TIF_Info_>],
TIF.Id AS [TifId],
TIF.BegEffYear AS [TifEffYr],
TIF.EffStatus AS [TiffStatus],
TIF.TranId AS [TifTranId],
TIF.Descr AS [TIF_Name],
TIF.ShortDescr AS [TIF_Num],
TIF.StartYear,
TIF.EndYear,
TIF.BaseValueYear,
TIF.PlanDate,
TIF.CertDate,
TIF.ExpirationDate,
TIF.DecertificationDate,
--New Group
'' AS [TAGTaxAuthority_Info_>],
TAGTaxAuthority.Id AS [TAGTaxAuthorityId],
--New Group
'' AS [TaxAuthority_Info_>],
TaxAuthority.BegEffYear AS [TaxAuth_BegEffYear],
TaxAuthority.TranId AS [TaxAuth_TranId],
TaxAuthority.ShortDescr AS [TaxAuth#],
TaxAuthority.Descr AS [TaxAuthority_Name],
TaxAuthority.TAType AS [TaxAuthority_Type]

From TAG
LEFT OUTER JOIN TAGTIF ON TAG.Id=TAGTIF.TAGId AND TAGTIF.EffStatus = 'A'
LEFT OUTER JOIN TIF ON TAGTIF.TIFId=TIF.Id AND TIF.EffStatus  = 'A'
LEFT OUTER JOIN TAGTaxAuthority ON TAG.Id=TAGTaxAuthority.TAGId AND TAGTaxAuthority.EffStatus = 'A'
LEFT OUTER JOIN TaxAuthority ON TAGTaxAuthority.TaxAuthorityId=TaxAuthority.Id AND TaxAuthority.EffStatus = 'A'

WHERE TAG.EffStatus = 'A'

ORDER BY TAG.Id 


---TAGs with TIFs
Select
tag.Id AS TagId,
tag.ShortDescr AS TAG,
MAX(tag.BegEffYear),
tagtif.TIFId,
tif.ShortDescr,
tif.Descr

From TAG
LEFT OUTER JOIN TAGTIF ON TAG.Id=TAGTIF.TAGId 
  AND TAGTIF.EffStatus = 'A'
LEFT OUTER JOIN TIF ON TAGTIF.TIFId=TIF.Id 
  AND TIF.EffStatus  = 'A'

Where TAG.EffStatus  = 'A'

Group By
tag.Id,
tag.ShortDescr,
tagtif.TIFId,
tif.ShortDescr,
tif.Descr

--TAGs with TIF IDs Only
Select
tag.Id AS TagId,
tag.ShortDescr AS TAG,
MAX(tag.BegEffYear),
tagtif.TIFId

From TAG
LEFT OUTER JOIN TAGTIF ON TAG.Id=TAGTIF.TAGId 
  AND TAGTIF.EffStatus = 'A'
LEFT OUTER JOIN TIF ON TAGTIF.TIFId=TIF.Id 
  AND TIF.EffStatus  = 'A'

Where TAG.EffStatus  = 'A'

Group By
tag.Id,
tag.ShortDescr,
tagtif.TIFId
