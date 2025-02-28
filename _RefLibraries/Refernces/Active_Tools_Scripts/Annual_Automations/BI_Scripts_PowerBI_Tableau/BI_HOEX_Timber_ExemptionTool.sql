Select Distinct
  --ParcelMaster
  TRIM(CONVERT(VARCHAR, pm.lrsn)) AS [LRSN],
  TRIM(pm.pin) AS [PIN],
  TRIM(CONVERT(VARCHAR, pm.AIN)) AS [AIN],
  TRIM(CONVERT(VARCHAR, pm.neighborhood)) AS [GEO],
  TRIM(pm.NeighborHoodName) AS [NeighborHoodName],
  TRIM(CONVERT(VARCHAR, pm.TAG)) AS [TAG],
  TRIM(pm.DisplayName) AS [OwnerName],
  TRIM(pm.SitusAddress) AS [SitusAddress],
  TRIM(pm.SitusCity) AS [SitusCity],

  --Modifiers HOEX
  tsbm.ModifierShortDescr AS [Homeowner Exemption_Short],
  tsbm.ModifierDescr AS [Homeowner Exemption_Long],

  --Modifiers Timber Ag
  tsta.ModifierShortDescr AS [Timber/Ag Exemption_Short],
  tsta.ModifierDescr AS [Timber/Ag Exemption_Long],

  --Calculated Column
  CASE
    WHEN tsbm.ModifierId IS NULL OR tsbm.ModifierId = '' THEN 'No'
    ELSE 'Yes'
  END AS [HomeOwners_Exemption],

  --Calculated Column
  CASE
    WHEN tsta.ModifierId IS NULL OR tsta.ModifierId = '' THEN 'No'
    ELSE 'Yes'
  END AS [Timber_Ag_Exemption]

From TSBv_PARCELMASTER AS pm
--Using LEFT JOIN removes Confidential Owners from the dataset here and Where statement
Left Join memos AS m ON m.lrsn=pm.lrsn
  AND m.memo_id = 'ACC' 
  --memo_text LIKE '%Confidential%'
  And m.status='A'
  And m.memo_line_number = '1'

--Add Modifiers with and without HOEX
Left Join TSBv_MODIFIERS AS tsbm ON tsbm.lrsn=pm.lrsn
  AND tsbm.PINStatus='A'
  And tsbm.ModifierStatus = 'A'
  And tsbm.ExpirationYear >= YEAR(GETDATE())
  And tsbm.ModifierId IN ('7', '41', '42')

--Add Modifiers with and without Timber/Ag
Left Join TSBv_MODIFIERS AS tsta ON tsta.lrsn=pm.lrsn
  AND tsta.PINStatus='A'
  And tsta.ModifierStatus = 'A'
  And tsta.ExpirationYear >= YEAR(GETDATE())
  And tsta.ModifierId IN ('26', '9', '27')

Where pm.EffStatus = 'A'
 AND m.lrsn IS NULL 
