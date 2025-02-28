


--Looking to see what PP accounts have a URD Modifier, to be compared with URD in the legal descriptions
CTE_ModURD (lrsn, [URD], [URD%], [URD$]) AS (
SELECT
lrsn,
BegTaxYear,
ExpirationYear,
TRIM(ModifierDescr) AS URDDescr,
ModifierPercent AS URDPerc,
OverrideAmount AS URDBase

FROM TSBv_MODIFIERS
WHERE ModifierStatus='A'
AND ModifierDescr LIKE '%URD%'
AND PINStatus='A'
AND ExpirationYear > 2024

),

,mURD.BegTaxYear
,mURD.ExpirationYear
,mURD.URDDescr
,mURD.URDPerc
,mURD.URDBase


LEFT JOIN CTE_ModURD AS mURD 
  ON pmd.lrsn=mURD.lrsn
  
  
  
  