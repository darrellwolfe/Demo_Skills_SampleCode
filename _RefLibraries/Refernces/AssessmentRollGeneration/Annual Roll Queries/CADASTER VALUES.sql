-- !preview conn=conn


--TOTAL ASSESSED
 Declare @CadasterYear int = 2024

 Select Distinct
c.TaxYear
,c.CadRollId
,r.Descr AS AssessmentType
,c.TAG
,c.LRSN AS CadValue_LRSN
,c.PIN
,c.ValueAmount  AS Cadaster_Value

 From tsbv_cadastre AS c 
 
   Join TagTaxAuthority AS tta
   On tta.tagid = c.tagid
   And tta.EffStatus = 'A'
   And tta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority ttasub where ttasub.id = tta.id and ttasub.BegEffYear <= @CadasterYear)
 
 
 Join TaxAuthority AS ta
   On ta.id = tta.TaxAuthorityId
   And ta.EffStatus = 'A'
   And ta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority tasub where tasub.id = ta.id and tasub.BegEffYear <= @CadasterYear)
 
 
 Join Taf AS taf
   On taf.TaxAuthorityId = ta.id
   And taf.EffStatus = 'A'
   And taf.BegEffYear = (select max(BegEffYear) from Taf tafsub where tafsub.id = taf.id and tafsub.BegEffYear <= @CadasterYear)
 
 
 Join Fund AS f
   On f.id = taf.fundId
   And f.EffStatus = 'A'
   And f.BegEffYear = (select max(BegEffYear) from Fund fsub where fsub.id = f.id and fsub.BegEffYear <= @CadasterYear)
 
 Join ValueType AS vt
   On vt.id = c.ValueType
   And vt.ShortDescr = 'Total Value'
 Join CadRoll AS r
   On c.CadRollId = r.Id
   --And r.Id = '563' -- 2023 PERSONAL PROPERTY 2


 Where c.taxyear = @CadasterYear
-- and ta.Descr = '242-HAUSER FIRE'
-- and f.Descr = 'HAUSER LAKE FIRE DIST' 
   --594,858,771 total value (This is the total assessed value)

