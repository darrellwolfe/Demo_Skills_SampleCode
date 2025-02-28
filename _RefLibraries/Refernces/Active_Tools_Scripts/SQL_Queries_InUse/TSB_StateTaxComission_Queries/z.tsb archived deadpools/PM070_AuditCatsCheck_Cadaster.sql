-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

Select *
From Allocations

Where status = 'H'
And eff_year = '20230101'
And group_code IN ('01','02','03','04','05')


*/

DECLARE @TaxYear INT = '2023';
DECLARE @ValueType INT = '471';

Select 
c.Group_Code
,Count(c.LRSN)
/*
c.LRSN
,c.PIN
,c.AIN
,c.Group_Code
,c.ValueAmount
,c.TaxYear
,c.ValueType
,c.TypeCode
*/
From tsbv_cadastre AS c

Join ValueTypeAmount AS v
  On v.HeaderId = c.CadInvId 
  And v.ValueTypeId = @ValueType
  And v.AddlObjectId IN ('1200300','1200301','1200302','1200303','1200304')
  --HeaderId = c.CadInvId 

Where c.TaxYear = @TaxYear
  --AND c.ValueType = 101 -- LandMarket
  --AND c.ValueType = 112 -- PABLYV
  --AND c.ValueType = 471 -- AcresByCat
  --AND c.ValueType = 470 -- AssessedByCat
  AND c.ValueType = @ValueType -- Variable
  AND c.RollCaste = 16001
  And c.Group_Code IN ('01','02','03','04','05')

Group By c.Group_Code
