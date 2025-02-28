-------------------------------------------
--Special Query - Find Exemptions Yes/No
-------------------------------------------

DECLARE @TaxYear = YEAR(GETDATE());

Select Distinct
--ParcelMaster
  TRIM(pm.lrsn) AS [LRSN],
  TRIM(pm.pin) AS [PIN],
  TRIM(pm.AIN) AS [AIN],
  TRIM(pm.neighborhood) AS [GEO],
  TRIM(pm.NeighborHoodName) AS [NeighborHoodName],
  TRIM(pm.TAG) AS [TAG],
  TRIM(pm.DisplayName) AS [OwnerName],
  TRIM(pm.SitusAddress) AS [SitusAddress],
  TRIM(pm.SitusCity) AS [SitusCity],

--Mofifiers HOEX
  tsbm.ModifierShortDescr AS [Homeowner Exemption_Short],
  tsbm.ModifierDescr AS [Homeowner Exemption_Long],

--Mofifiers Timber Ag
  tsta.ModifierShortDescr AS [Timber/Ag Exemption_Short],
  tsta.ModifierDescr AS [Timber/Ag Exemption_Long],


--Calculated Column
    CASE
      WHEN tsbm.ModifierId IS NULL or tsbm.ModifierId = '' THEN 'No'
      ELSE 'Yes'
    END AS [HomeOwners_Exemption],

--Calculated Column
    CASE
      WHEN tsta.ModifierId IS NULL or tsbm.ModifierId = '' THEN 'No'
      ELSE 'Yes'
    END AS [Timber_Ag_Exemption]

From TSBv_PARCELMASTER AS pm
--Using LEFT JOIN removes Confidential Owners from the dataset here and Where statement
Left Join memos AS m ON m.lrsn=pm.lrsn
  AND m.memo_id = 'ACC' 
  --memo_text LIKE '%Confidential%'
  And m.status='A'
  And m.memo_line_number = '1'

----UPDATE YEAR

--Add Mofiers with and without HOEX
Left Join TSBv_MODIFIERS AS tsbm ON tsbm.lrsn=pm.lrsn
  AND tsbm.PINStatus='A'
  And tsbm.ModifierStatus = 'A'
  --And tsbm.ExpirationYear >= 2023 -- Update each year
  And tsbm.ExpirationYear >= @TaxYear -- Update each year
  And tsbm.ModifierId IN ('7','41','42') 
  -- Three HOEX Modifiers, see Modifier root table for reference
  /*
  Id	ShortDescr	Descr
  7	_HOEXCap	602G Residential Improvements - Homeowners
  41	_HOEXCapCalc	Homeowner Calc Cap Override
  42	_HOEXCapManual	Homeowner Manual Cap Override
  */

----UPDATE YEAR

--Add Mofiers with and without Timber/Ag
Left Join TSBv_MODIFIERS AS tsta ON tsta.lrsn=pm.lrsn
  AND tsta.PINStatus='A'
  And tsta.ModifierStatus = 'A'
  --And tsta.ExpirationYear >= 2023 -- Update each year
  And tsta.ExpirationYear >= @TaxYear -- Update each year
  And tsta.ModifierId IN ('26','9','27') 
  -- Three Timber & Ag Modifiers, see Modifier root table for reference
  /*
  Id	ShortDescr	Descr
  26	LandUse	Land Use Program
  9	SpecLand	602K Speculative Value of Ag Land
  27	Timber	Timber Program
  */

Where pm.EffStatus = 'A'
--Using LEFT JOIN removes Confidential Owners from the dataset here and Where statement
 AND m.lrsn IS NULL 
-- OR m.lrsn <> '')

Group By
--ParcelMaster
pm.lrsn,
pm.pin,
pm.AIN,
pm.neighborhood,
pm.NeighborHoodName,
pm.TAG,
pm.DisplayName,
pm.SitusAddress,
pm.SitusCity,
--Modifier Wheres
tsbm.PINStatus,
tsbm.ModifierStatus,
tsbm.ExpirationYear,
tsbm.ModifierId,
--Modifier Wheres
tsta.PINStatus,
tsta.ModifierStatus,
tsta.ExpirationYear,
tsta.ModifierId,
--Modifier
tsbm.ModifierShortDescr,
tsbm.ModifierDescr,
tsta.ModifierShortDescr,
tsta.ModifierDescr


Order By [GEO],[PIN];
