/*
Darrell,

I know nothing about nothing … just like “John Snow” … if you are a GoT fan?! 

TAFRate is the table where yearly Tax Rates are stored:
TAFRate.TaxYear
TAFRate.TAFId

Are the key fields

TAF is linking between TaxAuthority and Fund 
TAGTaxAuthority is the linking between TaxAuthority and TAG

Hopefully this helps

Mike “John Snow” Dunn

SELECT * FROM information_schema.columns 
WHERE column_name LIKE 'levy%'
AND table_name NOT LIKE 'KCv%'
ORDER BY table_name;


Select *
From TAFRate AS tr
Where tr.TaxYear = 2023
--And TAFRate.TAFId = 

Select *
From TAF AS taf

*/

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @CurrentDate DATE = GETDATE();

DECLARE @LastYear INT = @CurrentYear - 1;

SELECT DISTINCT 
tag.Id AS TAGId
,TRIM(tag.Descr) AS TAG
,MAX(tag.BegEffYear) AS TAG_MaxBegEffYear

,ta.Id AS TaxAuthId
,TRIM(ta.Descr) AS TaxAuthority  
,MAX(ta.BegEffYear) AS TaxAuthority_MaxBegEffYear



--  ,tif.Id AS TIFId
--  ,TRIM(tif.Descr) AS TIF
--,SUM(tafrate.TaxRate) AS TaxRate
--,tafrate.TaxRate

--TAG Table
    FROM TAG AS tag

--TAGTaxAuthority Key
--TAGTaxAuthority is the linking between TaxAuthority and TAG
    JOIN TAGTaxAuthority 
        ON TAG.Id=TAGTaxAuthority.TAGId 
        AND TAGTaxAuthority.EffStatus = 'A'

--TaxAuthority Table
    JOIN TaxAuthority AS ta 
        ON TAGTaxAuthority.TaxAuthorityId=ta.Id 
        AND ta.EffStatus = 'A'



WHERE tag.EffStatus = 'A'
AND tag.ShortDescr = '001000'

GROUP BY tag.Id,tag.Descr, ta.Id

ORDER BY TaxAuthId