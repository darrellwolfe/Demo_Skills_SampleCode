
--Declare @Year int = 2024; -- Input THIS year here
DECLARE @TaxYear INT;
SET @TaxYear = YEAR(GETDATE());
--PreviousYear
Declare @YearPrev int = @TaxYear - 1; -- Input the year here
--VARCHAR String with the two letters plus last two of year, allows for NC Memos in this case
Declare @LandModelYear varchar(6) = '70' + Cast(@TaxYear as varchar); -- This will create 'NC24'
Declare @LandModelYearPrevious varchar(6) = '70' + Cast(@YearPrev as varchar); -- This will create 'NC24'
  --AND lh.LandModelId='702023'
  --AND ld.LandModelId='702023'
  --AND lh.LandModelId= @LandModelYear
  --AND ld.LandModelId= @LandModelYear

SELECT
lh.RevObjId,
lh.TotalMktValue,
ld.lcm,
lcm.tbl_element_desc AS LCM_CodeDescription,
ld.LandType,
lt.land_type_desc AS Land_Type,
--STRING_AGG(lt.land_type_desc, ', ') AS AggregatedLandTypes,
ld.LandDetailType,
ld.SiteRating,
sr.tbl_element_desc AS Legend,
ld.BaseRate,
ld.SoilIdent,
ld.LDAcres,
ld.ActualFrontage,
ld.DepthFactor,
ld.SoilProdFactor,
ld.SmallAcreFactor

--Land Header
FROM LandHeader AS lh
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND lh.PostingSource=ld.PostingSource
--Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

LEFT JOIN codes_table AS lcm ON CAST(lcm.tbl_element AS INT) = ld.lcm
  AND lcm.code_status= 'A' 
  AND lcm.tbl_type_code= 'lcmshortdesc'
  --'lcmshortdesc' (aka Land Types)

LEFT JOIN codes_table AS sr ON sr.tbl_element = ld.SiteRating
  AND sr.code_status= 'A' 
  AND sr.tbl_type_code= 'siterating'
  --'siterating' (aka Legends)

WHERE lh.EffStatus= 'A' 
  AND lh.PostingSource='A'
  AND ld.PostingSource='A'
--Change land model id for current year
  --AND lh.LandModelId='702023'
  --AND ld.LandModelId='702023'
  AND lh.LandModelId= @LandModelYear
  AND ld.LandModelId= @LandModelYear
--Looking for:
  --AND ld.LandType IN ('82')
/*
GROUP BY
lh.RevObjId,
lh.TotalMktValue,
ld.lcm,
lcm.tbl_element_desc,
ld.LandType,
lt.land_type_desc,
ld.LandDetailType,
ld.SiteRating,
sr.tbl_element_desc,
ld.BaseRate,
ld.SoilIdent,
ld.LDAcres,
ld.ActualFrontage,
ld.DepthFactor,
ld.SoilProdFactor,
ld.SmallAcreFactor
*/