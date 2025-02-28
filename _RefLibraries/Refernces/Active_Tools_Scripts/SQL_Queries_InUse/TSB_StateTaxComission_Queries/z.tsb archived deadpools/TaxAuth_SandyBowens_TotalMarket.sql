-- !preview conn=conn


--TOTAL MARKET
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
inner join ValueType vt
  on vt.id = c.ValueType
  and vt.ShortDescr IN ('LandMarket', 'Imp Assessed')

where c.taxyear = @TaxYear
  and ta.Descr = '242-HAUSER FIRE'
  and f.Descr = 'HAUSER LAKE FIRE DIST' 
  --594,858,771 total value (This is the total of the land market value which will be higher than the assessed land on ag and timber group codes; plus the improvement market; remember that you calculate your values for parcels with site improvement exemptions differently and those values may not be included in the total above.  You’ll want to find a parcels with a site improvement exemption and see how you’re handling the values for those parcels. )


