DECLARE @CurrentDate DATE = GETDATE();

DECLARE @CurrentYear INT = YEAR(GETDATE());

DECLARE @Year INT;
--Declare @Year int = 2025; -- Input THIS year here
--DECLARE @TaxYear INT;
--SET @TaxYear = YEAR(GETDATE());

IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 5, 1) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 15) --01/01/20xx
--IF @CurrentDate > DATEFROMPARTS(@CurrentYear, 1, 31) --01/01/20xx

SET @Year = @CurrentYear; -- After January 15, set @Year to the current year
ELSE
SET @Year = @CurrentYear - 1; -- Before or on January 15, set @Year to the previous year

Declare @YearPrev int = @Year - 1; -- Input the year here
Declare @YearPrevPrev int = @Year - 2; -- Input the year here


Declare @MemoLastUpdatedNoEarlierThan date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @MemoLastUpdatedNoEarlierThan DATE = '2024-01-01';
--1/1 of the earliest year requested. 
-- If you need sales back to 10/01/2022, use 01/01/2022

Declare @PrimaryTransferDateFROM date = CAST(CAST(@Year as varchar) + '-01-01' AS DATE); -- Generates '2023-01-01' for the current year
Declare @PrimaryTransferDateTO date = CAST(CAST(@Year as varchar) + '-12-31' AS DATE); -- Generates '2023-01-01' for the current year
--Declare @PrimaryTransferDateFROM DATE = '2024-01-01';
--Declare @PrimaryTransferDateTO DATE = '2024-12-31';
--pxfer_date
--AND tr.pxfer_date BETWEEN '2023-01-01' AND '2023-12-31'

Declare @CertValueDateFROM varchar(8) = Cast(@Year as varchar) + '0101'; -- Generates '20230101' for the previous year
Declare @CertValueDateTO varchar(8) = Cast(@Year as varchar) + '1231'; -- Generates '20230101' for the previous year
--Declare @CertValueDateFROM INT = '20240101';
--Declare @CertValueDateTO INT = '20241231';
--v.eff_year
---WHERE v.eff_year BETWEEN 20230101 AND 20231231


Declare @LandModelId varchar(6) = '70' + Cast(@Year+1 as varchar); -- Generates '702023' for the previous year


Declare @MemoText1 varchar(6) = '%/' + Cast(@Year as varchar) + ' %'; -- Generates '702023' for the previous year
Declare @MemoText2 varchar(6) = '%/' + RIGHT(@Year,2) + ' %'; -- Generates '702023' for the previous year




SELECT
--lh.LastUpdate,
--lh.*
ld.*
--ld.LandLineNumber

--lt.*
--li.*

/*
lh.RevObjId AS [lrsn],
ld.LandDetailType,
ld.lcm,
ld.LandType,
lt.land_type_desc,
ld.SoilIdent,
ld.LDAcres,
ld.ActualFrontage,
ld.DepthFactor,
ld.SoilProdFactor,
ld.SmallAcreFactor,
ld.SiteRating,
TRIM (sr.tbl_element_desc) AS [Legend],
li.InfluenceCode,
li.InfluenceAmount,
li.InfluenceAmount,
CASE
WHEN li.InfluenceType = 1 THEN '1-Pct'
ELSE '2-Val'
END AS [InfluenceType],
li.PriceAdjustment
*/


--Land Header
FROM LandHeader AS lh
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
AND ld.EffStatus='A' 
AND ld.PostingSource='A'
AND lh.PostingSource=ld.PostingSource
LEFT JOIN codes_table AS sr ON ld.SiteRating = sr.tbl_element
AND sr.tbl_type_code='siterating  '

--Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

--Land Influence
LEFT JOIN LandInfluence AS li ON li.ObjectId = ld.Id
AND li.EffStatus='A' 
AND li.PostingSource='A'


WHERE lh.EffStatus= 'A' 
AND lh.PostingSource='A'

--Change land model id for current year
AND lh.LandModelId= @LandModelId
AND ld.LandModelId= @LandModelId 
AND ld.LandType IN ('9','31','32','11')
