-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/

WITH
CTE_HOEX AS (
Select
lrsn
,ModifierPercent
--Add Mofiers with and without HOEX
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