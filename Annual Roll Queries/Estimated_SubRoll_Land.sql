/*
AsTxDBProd
GRM_Main
*/

-----------------------
--Estimated SubRoll
-----------------------

WITH

  CTE_Memo AS (
      SELECT
          CASE WHEN PATINDEX('%[0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', memo_text) > 0
               THEN SUBSTRING(memo_text, PATINDEX('%[0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]%', memo_text), 10)
               ELSE NULL
          END AS extracted_date,
          lrsn, memo_id, memo_line_number, memo_text
      FROM
          memos
      WHERE
          memo_id = 'NC23'
          AND memo_line_number = '2'
          AND memo_text LIKE '%Prepped%'
  ),

  CTE_TAGTIF AS (
    --TAGs with TIF IDs Only
    Select
    tag.Id AS TagId,
    tag.ShortDescr AS TAG,
    MAX(tag.BegEffYear) AS Year,
    tagtif.TIFId
    
    From TAG
    LEFT OUTER JOIN TAGTIF ON TAG.Id=TAGTIF.TAGId 
      AND TAGTIF.EffStatus = 'A'
    LEFT OUTER JOIN TIF ON TAGTIF.TIFId=TIF.Id 
      AND TIF.EffStatus  = 'A'
    
    Where TAG.EffStatus  = 'A'
    
    Group By
    tag.Id,
    tag.ShortDescr,
    tagtif.TIFId
),

  CTE_TotalAssessed AS (
      Select
      cv.RevObjId,
      SUM (cv.ValueAmount) AS [TotalAssessedByCat],
      cv.AddlAttribute,
      cv.ValueTypeShortDescr,
      cv.ValueTypeDescr
      FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
  
      WHERE cv.AssessmentYear IN ('2023')
      AND cv.ValueTypeShortDescr = 'AssessedByCat'
      
      GROUP BY
      cv.RevObjId,
      cv.AddlAttribute,
      cv.ValueTypeShortDescr,
      cv.ValueTypeDescr
  ),
  
  CTE_RealRoll AS (
      Select
      cv.RevObjId,
      cv.PIN,
      cv.AIN,
      LTRIM(RTRIM(LEFT (cv.AddlAttribute,3))) AS [GroupCode],
      cv.TAGShortDescr,
      cv.ValueAmount AS [RealRollTaxable],
      cv.AddlAttribute
        
      FROM CadValueTypeAmount_V AS cv -- ON pm.lrsn = cv.RevObjId
      WHERE cv.AssessmentYear IN ('2023')
      AND cv.ValueTypeShortDescr = 'AssessedByCat'
  
  ),
  
  CTE_URDBase AS (
      Select Distinct
      tsbm.lrsn,
      tsbm.OverrideAmount AS [URDBase],
      tsbm.ModifierId,
      tsbm.ModifierShortDescr,
      tsbm.ModifierDescr
      
      FROM TSBv_MODIFIERS AS tsbm --ON tsbm.lrsn=pm.lrsn
        WHERE tsbm.PINStatus='A'
        And tsbm.ModifierStatus = 'A'
        And tsbm.ExpirationYear >= 2023 -- Update each year
        And tsbm.ModifierId IN ('53') 
        
        -- Three HOEX Modifiers, see Modifier root table for reference
        /*
        Id	ShortDescr	Descr
        53 URDBaseModifier Total URD Base
        */
  ),
  
  CTE_HOEX AS (
    Select
      tsbm.lrsn,
    --Calculated Column
        CASE
          WHEN tsbm.ModifierId IS NULL or tsbm.ModifierId = '' THEN 'No'
          ELSE 'Yes'
        END AS [HomeOwners_Exemption]
    
    FROM TSBv_MODIFIERS AS tsbm --ON tsbm.lrsn=pm.lrsn
      WHERE tsbm.PINStatus='A'
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
  

    Select
    rr.RevObjId AS [LRSN],
    rr.PIN,
    rr.AIN,
    rr.[GroupCode],
    rr.TAGShortDescr,
    tf.TIFId,
    urd.[URDBase],
    rr.[RealRollTaxable],
    ta.[TotalAssessedByCat],
    ho.[HomeOwners_Exemption],
        rr.AddlAttribute,
    m.memo_id, m.memo_line_number, m.memo_text, m.extracted_date

    FROM CTE_Memo AS m

    JOIN CTE_RealRoll AS rr ON m.lrsn = rr.RevObjId

    JOIN CTE_TotalAssessed AS ta ON ta.RevObjId = rr.RevObjId
      AND rr.AddlAttribute = ta.AddlAttribute

    JOIN CTE_TAGTIF AS tf ON  tf.TAG = rr.TAGShortDescr

    LEFT JOIN CTE_HOEX AS ho ON m.lrsn=ho.lrsn

    LEFT JOIN CTE_URDBase AS urd ON m.lrsn=urd.lrsn


--T.pin, T.AIN, T.TAG, T.neighborhood,

--END


