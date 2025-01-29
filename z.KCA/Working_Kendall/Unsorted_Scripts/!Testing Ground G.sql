-- !preview conn=conn
-- FREE TO USE --

SELECT *

from TSBv_MODIFIERS as m

WHERE m.ModifierShortDescr NOT IN (
'Timber',
'PTR',
'LandUse',
'_HOEXCap',
'PTRImp',
'PTRLand',
'SpecLand',
'_HOEXCapManual',
'PPExemption',
'_HOEXCapCalc',
'URDBaseModifier',
'Government'
)