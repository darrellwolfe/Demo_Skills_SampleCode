-- !preview conn=conn
/*
AsTxDBProd
GRM_Main

SELECT * FROM information_schema.columns 
WHERE table_name LIKE '%Status%'
AND TABLE_NAME NOT LIKE 'KCv%'

Order By TABLE_NAME

SELECT * FROM information_schema.columns 
WHERE table_name LIKE 'TIF%';

--Find a table with a Column Name like...
SELECT * FROM information_schema.columns 
WHERE column_name LIKE 'TaxCalcDetail%';

SELECT * FROM information_schema.columns 
WHERE column_name LIKE 'ChangeDate%';

  a.lrsn
, a.group_code
, impgroup.tbl_element_desc AS Imp_GroupCode_Desc

*/

WITH

CTE_HOEX AS (
Select Distinct
  tsbm.lrsn
  ,CASE
     WHEN tsbm.ModifierId IS NULL or tsbm.ModifierId = '' THEN 'No_HOEX'
     ELSE 'HomeOwners_Exemption'
   END AS [HomeOwners_Exemption]

From TSBv_MODIFIERS AS tsbm 
  --ON tsbm.lrsn=pm.lrsn

Where tsbm.PINStatus='A'
  And tsbm.ModifierStatus = 'A'
  And tsbm.ExpirationYear >= 2023 -- Update each year
  And tsbm.ModifierId IN ('7','41','42') 
  -- Three HOEX Modifiers, see Modifier root table for reference
  /*
  Id	ShortDescr	Descr
  7	_HOEXCap	602G Residential Improvements - Homeowners
  41	_HOEXCapCalc	Homeowner Calc Cap Override
  42	_HOEXCapManual	Homeowner Manual Cap Override
  */
)


Select *
From CTE_HOEX


  
  
  
  