


Declare @TaxYear int = 2024;


SELECT DISTINCT 
tag.Id --AS TAGId
,tag.BegEffYear
,TRIM(tag.Descr) AS TAG
--,SUM(tr.TaxRate) AS TaxRateMaybe
,CONCAT(LEFT(TRIM(tag.Descr),3),'-',RIGHT(TRIM(tag.Descr),3)) AS TAGFormatted
,tta.Id
,tta.TAGId
,tta.TaxAuthorityId
,ta.Id AS TaxAuthId 
,TRIM(ta.Descr) AS TaxAuthority
,tr.RateValueType
,tr.TaxRate

--TAG Table
FROM TAG AS tag

--TAGTaxAuthority Key 
JOIN TAGTaxAuthority AS tta
    ON tag.Id=tta.TAGId 
    AND tta.EffStatus = 'A'
    AND tta.BegEffYear = (select max(BegEffYear) from TAGTaxAuthority AS ttasub where ttasub.id = tta.id AND ttasub.BegEffYear <= @TaxYear)

--TaxAuthority Table
JOIN TaxAuthority AS ta 
    ON tta.TaxAuthorityId=ta.Id 
    AND ta.EffStatus = 'A'
    AND ta.BegEffYear = (select max(BegEffYear) from TaxAuthority AS tasub where tasub.id = ta.id AND tasub.BegEffYear <= @TaxYear)

--Taf key connects TaxAuthority and Fund and TafRate connects to Taf
JOIN Taf AS taf
  ON taf.TaxAuthorityId = ta.id
  AND taf.EffStatus = 'A'
  AND taf.BegEffYear = (select max(BegEffYear) from Taf tafsub where tafsub.id = taf.id AND tafsub.BegEffYear <= @TaxYear)

--TafRate connects to Taf
JOIN TafRate tr
  ON tr.tafid = taf.id
  AND tr.TaxYear = @TaxYear
  AND tr.RateValueType IN (455, 456, 459, 460)
    --Levy on all values - Net Taxable Values
    --Levy on all values except OPT = vt456
    --Levy on all values except OPT, AG, and TIMBER = vt459
    --Levy on all values except OPT, and TIMBER = vt460
  --AND tr.ChrgSubCd = 290093 --Gross Tax Charge


WHERE tag.EffStatus = 'A'
AND tag.BegEffYear = (select max(BegEffYear) from TAG AS tagsub where tagsub.id = tag.id AND tagsub.BegEffYear <= @TaxYear)
--AND TRIM(tag.Descr) = 001000 --CORRECT
--AND TRIM(tag.Descr) = 261000 --CORRECT
--AND TRIM(tag.Descr) = 261000 --CORRECT
--AND TRIM(tag.Descr) = 261000 --CORRECT
--AND TRIM(tag.Descr) = 261000 --CORRECT
--AND TRIM(tag.Descr) = 013004 --CORRECT

--GROUP BY tag.Id, tag.Descr

ORDER BY TAGId, TaxAuthId


















/*



inner JOIN TaxAuthority ta
  ON ta.id = tta.TaxAuthorityId
  AND ta.EffStatus = 'A'
  AND ta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority tasub where tasub.id = ta.id AND tasub.BegEffYear <= @TaxYear)

inner JOIN Taf
  ON taf.TaxAuthorityId = ta.id
  AND taf.EffStatus = 'A'
  AND taf.BegEffYear = (select max(BegEffYear) from Taf tafsub where tafsub.id = taf.id AND tafsub.BegEffYear <= @TaxYear)

inner JOIN Fund f
  ON f.id = taf.fundId
  AND f.EffStatus = 'A'
  AND f.BegEffYear = (select max(BegEffYear) from Fund fsub where fsub.id = f.id AND fsub.BegEffYear <= @TaxYear)

inner JOIN TafRate tr
  ON tr.tafid = taf.id
  AND tr.RateValueType = c.ValueType --value type multiplied by the levy to get the gross tax charge
  AND tr.TaxYear = @TaxYear
  AND tr.ChrgSubCd = 290093 --Gross Tax Charge

where c.taxyear = @TaxYear






--TOTAL NET TAXABLE
Declare @TaxYear int = 2023

select sum(ValueAmount) 

from tsbv_cadastre c 
inner JOIN TagTaxAuthority tta
  ON tta.tagid = c.tagid
  AND tta.EffStatus = 'A'
  AND tta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority ttasub where ttasub.id = tta.id AND ttasub.BegEffYear <= @TaxYear)

inner JOIN TaxAuthority ta
  ON ta.id = tta.TaxAuthorityId
  AND ta.EffStatus = 'A'
  AND ta.BegEffYear = (select max(BegEffYear) from TagTaxAuthority tasub where tasub.id = ta.id AND tasub.BegEffYear <= @TaxYear)

inner JOIN Taf
  ON taf.TaxAuthorityId = ta.id
  AND taf.EffStatus = 'A'
  AND taf.BegEffYear = (select max(BegEffYear) from Taf tafsub where tafsub.id = taf.id AND tafsub.BegEffYear <= @TaxYear)

inner JOIN Fund f
  ON f.id = taf.fundId
  AND f.EffStatus = 'A'
  AND f.BegEffYear = (select max(BegEffYear) from Fund fsub where fsub.id = f.id AND fsub.BegEffYear <= @TaxYear)

inner JOIN TafRate tr
  ON tr.tafid = taf.id
  AND tr.RateValueType = c.ValueType --value type multiplied by the levy to get the gross tax charge
  AND tr.TaxYear = @TaxYear
  AND tr.ChrgSubCd = 290093 --Gross Tax Charge

where c.taxyear = @TaxYear




--  AND ta.Descr = '242-HAUSER FIRE'
--  AND f.Descr = 'HAUSER LAKE FIRE DIST' 
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

TAF is linking between TaxAuthority AND Fund 
TAGTaxAuthority is the linking between TaxAuthority AND TAG

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