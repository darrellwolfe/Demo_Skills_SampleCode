
Declare @TaxYear int;


--LevyRates will change every 11/15
-- Dynamically set the TaxYear based on the current date
If GetDate() < DateFromParts(Year(GetDate()), 1, 5)
    Set @TaxYear = Year(GetDate()) - 1; -- Last year until November 15
Else
    Set @TaxYear = Year(GetDate()); -- Current year after November 15


-- Declare @LandModelYear dynamically
Declare @LandModelYear int;
--DECLARE @LandModelYear INT = '702024';

-- NOTE --- IF repriced before the date, this needs to change to the date of reprice to work
-- Dynamically set the @LandModelYear based on the current date 
If GetDate() < DateFromParts(Year(GetDate()), 1, 5)
    --Set @LandModelYear = 700000 + Year(GetDate()) - 1; -- Last year's value until April 1
    Set @LandModelYear = CONCAT('70', (Year(GetDate())-1)); -- Current year's value after April 1
Else
    --Set @LandModelYear = 700000 + Year(GetDate()); -- Current year's value after April 1
    Set @LandModelYear = CONCAT('70', Year(GetDate())); -- Current year's value after April 1

WITH

-------------------------------------
-- CTE_Cat19Waste
-------------------------------------

CTE_Cat19Waste AS (
SELECT
lh.RevObjId,
ld.LandDetailType,
ld.LandType,
lt.land_type_desc,
ld.SoilIdent,
ld.LDAcres AS [Cat19Waste]

--Land Header
FROM LandHeader AS lh
--Land Detail
JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
  AND ld.EffStatus='A' 
  AND lh.PostingSource=ld.PostingSource
--Land Types
LEFT JOIN land_types AS lt ON ld.LandType=lt.land_type

WHERE lh.EffStatus= 'A' 
  AND lh.PostingSource='A'
  AND ld.PostingSource='A'
--Change land model id for current year
--  AND lh.LandModelId='702023'
--  AND ld.LandModelId='702023'
  AND lh.LandModelId=@LandModelYear
  AND ld.LandModelId=@LandModelYear


--Looking for:
  AND ld.LandType IN ('82')
  
)