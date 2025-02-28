
Declare @TaxYear int = 2024;


WITH
-- Begin CTE Key
CTE_TAG_TA_TIF_Key AS (

SELECT DISTINCT 
tag.Id AS TAGId
,tag.BegEffYear
,TRIM(tag.Descr) AS TAG
,CONCAT(LEFT(TRIM(tag.Descr),3),'-',RIGHT(TRIM(tag.Descr),3)) AS TAGFormatted
--,tta.Id
--,tta.TAGId
--,tta.TaxAuthorityId
,ta.Id AS TaxAuthId 
,TRIM(ta.Descr) AS TaxAuthority

,tif.Id AS TIFId
,TRIM(tif.Descr) AS TIF


--TAG Table
FROM TAG AS tag

--TAGTaxAuthority Key joins TAGs to TaxAuthorities
JOIN TAGTaxAuthority AS tta
    ON tag.Id=tta.TAGId 
    And tta.EffStatus = 'A'
    And tta.BegEffYear = (select max(BegEffYear) from TAGTaxAuthority AS ttasub where ttasub.id = tta.id and ttasub.BegEffYear <= @TaxYear)

--TaxAuthority Table
JOIN TaxAuthority AS ta 
    ON tta.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
    And ta.BegEffYear = (select max(BegEffYear) from TaxAuthority AS tasub where tasub.id = ta.id and tasub.BegEffYear <= @TaxYear)

-- TAGTIF Key Joins TAGs to TIFs
  LEFT JOIN TAGTIF 
    ON TAG.Id=TAGTIF.TAGId 
    AND TAGTIF.EffStatus = 'A'
    And TAGTIF.BegEffYear = (select max(BegEffYear) from TAGTIF AS TAGTIFsub where TAGTIFsub.id = TAGTIF.id and TAGTIFsub.BegEffYear <= @TaxYear)

  --TIF Table
  LEFT JOIN TIF AS tif 
    ON TAGTIF.TIFId=tif.Id 
    AND tif.EffStatus  = 'A'
    And tif.BegEffYear = (select max(BegEffYear) from TIF AS tifsub where tifsub.id = tif.id and tifsub.BegEffYear <= @TaxYear)


WHERE tag.EffStatus = 'A'
And tag.BegEffYear = (select max(BegEffYear) from TAG AS tagsub where tagsub.id = tag.id and tagsub.BegEffYear <= @TaxYear)


)

SELECT * FROM CTE_TAG_TA_TIF_Key




