


Declare @TaxYear int;

-- Dynamically set the TaxYear based on the current date
If GetDate() < DateFromParts(Year(GetDate()), 11, 15)
    Set @TaxYear = Year(GetDate()) - 1; -- Last year until November 15
Else
    Set @TaxYear = Year(GetDate()); -- Current year after November 15

-- Output the TaxYear for verification
--Select @TaxYear as TaxYear;
--Declare @TaxYear int = 2024;


WITH

CTE_LevyRatesByTag AS (
SELECT DISTINCT 
tag.Id AS TAGId
,TRIM(tag.Descr) AS TAG
,CONCAT(LEFT(TRIM(tag.Descr),3),'-',RIGHT(TRIM(tag.Descr),3)) AS TAGFormatted
,SUM(tr.TaxRate) AS LevyRate
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
WHERE tag.EffStatus = 'A'
AND tag.BegEffYear = (select max(BegEffYear) from TAG AS tagsub where tagsub.id = tag.id AND tagsub.BegEffYear <= @TaxYear)
GROUP BY tag.Id, tag.Descr
)


Select *
From CTE_LevyRatesByTag
ORDER BY TAGId, TAG
