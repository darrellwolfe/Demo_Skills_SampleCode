
DECLARE @CurrentYear INT = YEAR(GETDATE());

WITH 

TimberAg AS (
SELECT
lrsn,
TRIM(ModifierDescr) AS ModifierDescr,
ModifierPercent,
--CAST(OverrideAmount AS BIGINT) AS PPExemption602KK,
--TRY_CAST(ISNUMERIC(OverrideAmount) AS BIGINT) AS PPExemption602KK,
--CAST(OverrideAmount AS VARCHAR) AS PPExemption602KK,
CAST(OverrideAmount AS INT) AS ModifierAmount,
ExpirationYear
FROM TSBv_MODIFIERS
WHERE ModifierStatus='A'
--AND ModifierDescr LIKE '%Ag%'
AND PINStatus='A'
AND ExpirationYear > @CurrentYear
AND (ModifierDescr LIKE '%Ag Land%'
OR ModifierDescr LIKE '%Tim%')
)


Select Distinct *
From TimberAg

