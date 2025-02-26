
DECLARE @CurrentYear INT = YEAR(GETDATE());


--Looking for the Personal Property 63-602KK $250,000 exemption from Aumentum Modifiers, paying special attention to the shared exemptions
--CTE_63602KK AS (
SELECT
lrsn,
TRIM(ModifierDescr) AS ModifierDescr,
ModifierPercent,
--CAST(OverrideAmount AS BIGINT) AS PPExemption602KK,
--TRY_CAST(ISNUMERIC(OverrideAmount) AS BIGINT) AS PPExemption602KK,
--CAST(OverrideAmount AS VARCHAR) AS PPExemption602KK,
CAST(OverrideAmount AS INT) AS PPExemption602KK,
ExpirationYear


FROM TSBv_MODIFIERS
WHERE ModifierStatus='A'
AND ModifierDescr LIKE '%602KK%'
AND PINStatus='A'
AND ExpirationYear > @CurrentYear

--),

/*
-- Imperitive Values
,mppv.mAcquisitionValue
,mppv.mAppraisedValue
--,kk602.PPExemption602KK
, CASE
    WHEN kk602.PPExemption602KK IS NULL THEN 'MISSING_PPEX_MODIFER'
    ELSE kk602.PPExemption602KK
  END AS PPExemption602KK
,(mppv.mAppraisedValue-kk602.PPExemption602KK) AS NetTaxable

LEFT JOIN CTE_63602KK AS kk602
  ON pmd.lrsn=kk602.lrsn
*/