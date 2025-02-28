-- !preview conn=conn



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
  and ta.Descr = '242-HAUSER FIRE'
  and f.Descr = 'HAUSER LAKE FIRE DIST' 
  --495,069,528 net taxable value

