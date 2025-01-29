







Declare @TaxYear int;


--LevyRates will change every 11/15
-- Dynamically set the TaxYear based on the current date
If GetDate() < DateFromParts(Year(GetDate()), 11, 15)
    Set @TaxYear = Year(GetDate()) - 1; -- Last year until November 15
Else
    Set @TaxYear = Year(GetDate()); -- Current year after November 15


-- Declare @LandModelYear dynamically
Declare @LandModelYear VARCHAR(6);
--DECLARE @LandModelYear INT = '702024';

-- Dynamically set the @LandModelYear based on the current date 
-- Land Model will change every 04/01

If GetDate() < DateFromParts(Year(GetDate()), 1, 10)
    --Set @LandModelYear = 700000 + Year(GetDate()) - 1; -- Last year's value until April 1
    Set @LandModelYear = CONCAT('70', (Year(GetDate())-1)); -- Current year's value after April 1
Else
    --Set @LandModelYear = 700000 + Year(GetDate()); -- Current year's value after April 1
    Set @LandModelYear = CONCAT('70', Year(GetDate())); -- Current year's value after April 1


  --Change land model id for current year
  SELECT
  lh.RevObjId,
  lh.TotalMktValue
  --Land Header
  FROM LandHeader AS lh
  --Land Detail
  JOIN LandDetail AS ld ON lh.id=ld.LandHeaderId 
    AND ld.EffStatus='A' 
    AND ld.PostingSource='A'
    AND ld.LandModelId=@LandModelYear

  WHERE lh.EffStatus= 'A' 
    AND lh.PostingSource='A'
  --Change land model id for current year
    --AND lh.LandModelId='702023'
    --AND ld.LandModelId='702023'
    AND lh.LandModelId=@LandModelYear
    AND ld.SoilIdent IN ('Y1','Y2','Y3','Y4')
    --AND ld.SoilIdent IN ('Y1','Y2','Y3','Y4','T1','T2','T3','T4')
    AND ld.LandType IN ('61')
    --AND ld.LandType IN ('9','31','32')
    --AND lh.RevObjId=30296
  
  --GROUP BY lh.RevObjId
  --ld.SoilIdent,
  --ld.LDAcres