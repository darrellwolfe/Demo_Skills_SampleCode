
DECLARE @CurrentYear INT = YEAR(GETDATE());


--Looking to see what PP accounts have a URD Modifier, to be compared with URD in the legal descriptions
CTE_ModURD AS (
SELECT
    lrsn,
    TRIM(ModifierDescr) AS URD,
    ModifierPercent AS URDPerc,
    OverrideAmount AS URD_Amount,
    ExpirationYear

FROM TSBv_MODIFIERS
WHERE ModifierStatus='A'
AND ModifierDescr LIKE '%URD%'
AND PINStatus='A'
--AND ExpirationYear > '2024'
AND ExpirationYear > @CurrentYear


),


-- Very Important Audits
,pmd.TAG
--,ttt.TIF
,CASE
  When ttt.TIF IS NULL Then 'Non_TIF'
  When ttt.TIF IS NOT NULL Then ttt.TIF
  Else ttt.TIF
 END AS TIF
,mURD.URD_Amount
, CASE
    When ttt.TIF IS NULL Then 'Non_TIF'
    
    When ttt.TIF IS NOT NULL 
      And mURD.URD_Amount IS NULL
      Then 'Missing_URD_Modifier'

    WHEN (mppv.mAppraisedValue-kk602.PPExemption602KK) < mURD.URD_Amount THEN 'Check_URD_Base'
    
    ELSE 'URD_Base_OK'
  END AS URDvNetTaxableCheck

LEFT JOIN CTE_ModURD AS mURD 
  ON pmd.lrsn=mURD.lrsn