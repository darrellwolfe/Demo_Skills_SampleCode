


Declare @TaxYear int = 2024;

SELECT DISTINCT 
tag.Id --AS TAGId
,tag.BegEffYear
,TRIM(tag.Descr) AS TAG
,CONCAT(LEFT(TRIM(tag.Descr),3),'-',RIGHT(TRIM(tag.Descr),3)) AS TAGFormatted
,tta.Id
,tta.TAGId
,tta.TaxAuthorityId
,ta.Id AS TaxAuthId 
,TRIM(ta.Descr) AS TaxAuthority

--TAG Table
FROM TAG AS tag

--TAGTaxAuthority Key
LEFT JOIN TAGTaxAuthority AS tta
    ON tag.Id=tta.TAGId 
    And tta.EffStatus = 'A'
    And tta.BegEffYear = (select max(BegEffYear) from TAGTaxAuthority AS ttasub where ttasub.id = tta.id and ttasub.BegEffYear <= @TaxYear)

--TaxAuthority Table
LEFT JOIN TaxAuthority AS ta 
    ON tta.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
    And ta.BegEffYear = (select max(BegEffYear) from TaxAuthority AS tasub where tasub.id = ta.id and tasub.BegEffYear <= @TaxYear)





WHERE tag.EffStatus = 'A'
And tag.BegEffYear = (select max(BegEffYear) from TAG AS tagsub where tagsub.id = tag.id and tagsub.BegEffYear <= @TaxYear)


ORDER BY TAGId, TaxAuthId


















/*



inner join TaxAuthority ta
  on ta.id = tta.TaxAuthorityId
  and ta.EffStatus = 'A'
  and ta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority tasub where tasub.id = ta.id and tasub.BegEffYear <= @TaxYear)

inner join Taf
  on taf.TaxAuthorityId = ta.id
  and taf.EffStatus = 'A'
  and taf.BegEffYear = (select max(BegEffYear) from Taf tafsub where tafsub.id = taf.id and tafsub.BegEffYear <= @TaxYear)

inner join Fund f
  on f.id = taf.fundId
  and f.EffStatus = 'A'
  and f.BegEffYear = (select max(BegEffYear) from Fund fsub where fsub.id = f.id and fsub.BegEffYear <= @TaxYear)

inner join TafRate tr
  on tr.tafid = taf.id
  and tr.RateValueType = c.ValueType --value type multiplied by the levy to get the gross tax charge
  and tr.TaxYear = @TaxYear
  and tr.ChrgSubCd = 290093 --Gross Tax Charge

where c.taxyear = @TaxYear






--TOTAL NET TAXABLE
Declare @TaxYear int = 2023

select sum(ValueAmount) 

from tsbv_cadastre c 
inner join TagTaxAuthority tta
  on tta.tagid = c.tagid
  and tta.EffStatus = 'A'
  and tta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority ttasub where ttasub.id = tta.id and ttasub.BegEffYear <= @TaxYear)

inner join TaxAuthority ta
  on ta.id = tta.TaxAuthorityId
  and ta.EffStatus = 'A'
  and ta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority tasub where tasub.id = ta.id and tasub.BegEffYear <= @TaxYear)

inner join Taf
  on taf.TaxAuthorityId = ta.id
  and taf.EffStatus = 'A'
  and taf.BegEffYear = (select max(BegEffYear) from Taf tafsub where tafsub.id = taf.id and tafsub.BegEffYear <= @TaxYear)

inner join Fund f
  on f.id = taf.fundId
  and f.EffStatus = 'A'
  and f.BegEffYear = (select max(BegEffYear) from Fund fsub where fsub.id = f.id and fsub.BegEffYear <= @TaxYear)

inner join TafRate tr
  on tr.tafid = taf.id
  and tr.RateValueType = c.ValueType --value type multiplied by the levy to get the gross tax charge
  and tr.TaxYear = @TaxYear
  and tr.ChrgSubCd = 290093 --Gross Tax Charge

where c.taxyear = @TaxYear




--  and ta.Descr = '242-HAUSER FIRE'
--  and f.Descr = 'HAUSER LAKE FIRE DIST' 
  --495,069,528 net taxable value



AsTxDBProd
GRM_Main

---------
--Select All
---------
Select Distinct *
From TSBv_PARCELMASTER AS pm
Where pm.EffStatus = 'A'

TAFRate is the table where yearly Tax Rates are stored:
TAFRate.TaxYear
TAFRate.TAFId

Are the key fields

TAF is linking between TaxAuthority and Fund 
TAGTaxAuthority is the linking between TaxAuthority and TAG

Select Distinct
*

taf.TaxYear
,taf.TAFId
,taf.TaxRate

From TAFRate AS taf

Where taf.TaxYear = '2023'

Order by taf.TaxYear, taf.TAFId;

Select * From TAF


SELECT *
--FROM KCv_TAGLevyRate23a
FROM KCv_TAGLevyRate24a


Select Distinct *
--taf.TaxYear,taf.TAFId,taf.TaxRate
From TAFRate AS taf
Where taf.TaxYear = '2023'
Order by taf.TaxYear, taf.TAFId;
*/