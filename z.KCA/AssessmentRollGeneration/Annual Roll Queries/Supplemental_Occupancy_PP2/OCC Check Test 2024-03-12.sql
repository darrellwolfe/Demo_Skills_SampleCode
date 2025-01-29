-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

Select *
From Allocations

Where status = 'H'
And eff_year = '20230101'
And group_code IN ('01','02','03','04','05')

SELECT
lrsn
,last_update
,update_user_id
,imp_val
,imp_assess
,valuation_comment
,eff_year

FROM 
    VALUATION AS V
WHERE 
    V.status = 'A' 
    AND V.eff_year LIKE '2023%' 
  AND last_update > '2024-01-01'
--    AND V.change_reason = '06'
    --OR V.change_reason = '43')
*/





WITH

CTE_AnnualValue AS (
Select Distinct
v.lrsn
,pmd.AIN
,pmd.PIN
--,a.group_code
--,a.improvement_id
--,a.cost_value
--,SUBSTRING(CONVERT(VARCHAR, v.eff_year), 5, 2) AS Month
,CONVERT(VARCHAR, CONVERT(DATE, CONVERT(VARCHAR(8), v.eff_year)), 23) AS PostedAsOf
,v.eff_year
,v.imp_val
,v.imp_assess
,v.update_user_id
,v.last_update AS value_updated
,a.last_update AS allocation_updated
,v.valuation_comment

FROM valuation AS v
Join Allocations AS a
  On a.lrsn = v.lrsn
  And a.status = 'H'
  And a.last_update < '2023-07-01'
Join TSBV_PARCELMASTER AS pmd
  On pmd.lrsn = v.lrsn


WHERE 
    v.status = 'A' 
    AND v.eff_year LIKE '2023%' 
  AND v.last_update < '2023-07-01'
  AND (V.change_reason = '01' OR V.change_reason = '43')

),


CTE_OCCValue AS (
Select Distinct
v.lrsn
,pmd.AIN
,pmd.PIN
--,a.group_code
--,a.improvement_id
--,a.cost_value
--,SUBSTRING(CONVERT(VARCHAR, v.eff_year), 5, 2) AS Month
,CONVERT(VARCHAR, CONVERT(DATE, CONVERT(VARCHAR(8), v.eff_year)), 23) AS PostedAsOf
,v.eff_year
,v.imp_val
,v.imp_assess
,v.update_user_id
,v.last_update AS value_updated
,a.last_update AS allocation_updated
,v.valuation_comment

FROM valuation AS v
Join Allocations AS a
  On a.lrsn = v.lrsn
  And a.status = 'H'
  And a.last_update > '2024-01-01'
Join TSBV_PARCELMASTER AS pmd
  On pmd.lrsn = v.lrsn

WHERE 
    v.status = 'A' 
    AND v.eff_year LIKE '2023%' 
  AND v.last_update > '2024-01-01'
  AND V.change_reason = '06'
    --OR V.change_reason = '43')

),

CTE_MemosNC AS (
Select Distinct
m.lrsn
,m.memo_text
,SUBSTRING(
  m.memo_text,
  PATINDEX('%[0-1][0-9]/[0-3][0-9]/[2][0][0-9][0-9]%', m.memo_text),
  10
  ) AS ExtractedDate
From MEMOS AS M 
--ON M.lrsn = T.lrsn
Where M.memo_id = 'NC23'
AND M.memo_line_number = '2'
AND M.memo_text LIKE '%POSTED%'
),

CTE_HOEX AS (
Select
lrsn
,ModifierDescr
--Add Mofiers with and without HOEX
From TSBv_MODIFIERS AS tsbm 
--From Modifier --root table not lrsn related AS tsbm 
--ON tsbm.lrsn=pm.lrsn

Where tsbm.PINStatus='A'
  And tsbm.ModifierStatus = 'A'
  And (tsbm.ExpirationYear >= 2024 -- Update each year
  Or tsbm.ExpirationYear = 0 -- Update each year
  Or tsbm.ExpirationYear = 9999) -- Update each year
  And tsbm.ModifierId IN ('7','41','42') 
  -- Three HOEX Modifiers, see Modifier root table for reference
  /*
  Id	ShortDescr	Descr
  7	_HOEXCap	602G Residential Improvements - Homeowners
  41	_HOEXCapCalc	Homeowner Calc Cap Override
  42	_HOEXCapManual	Homeowner Manual Cap Override
  */
)





Select Distinct
oc.lrsn
,oc.AIN
,oc.PIN
,oc.PostedAsOf
,oc.eff_year
,oc.imp_assess AS OccTotal
,oc.valuation_comment
,av.imp_assess AS AnnualTotal
,av.valuation_comment
,hoex.ModifierDescr
,CASE
    WHEN hoex.ModifierDescr IS NOT NULL THEN 'Yes'
    ELSE 'No'
  END AS HOEX
,oc.update_user_id
,oc.value_updated
,oc.allocation_updated
,mnc.memo_text
,date.ExtractedDate
,Left(date.ExtractedDate,2) MonthNumber

, CASE
      WHEN DATEDIFF(
          MONTH,
          DATEFROMPARTS(YEAR(CONVERT(DATE, date.ExtractedDate, 101)), 1, 1),
          CONVERT(DATE, date.ExtractedDate, 101)
      ) = 0 THEN 12
      ELSE DATEDIFF(
          MONTH,
          DATEFROMPARTS(YEAR(CONVERT(DATE, date.ExtractedDate, 101)), 1, 1),
          CONVERT(DATE, date.ExtractedDate, 101)
      )
  END AS MonthsSinceStartOfYearOrFullYear


FROM CTE_OCCValue AS oc

Left Join CTE_AnnualValue AS av
  On oc.lrsn = av.lrsn

Left Join CTE_MemosNC AS mnc
  On mnc.lrsn = oc.lrsn
  --And mnc.ExtractedDate NOT LIKE '%P%'

Left Join CTE_MemosNC AS date
  On date.lrsn = oc.lrsn
  And date.ExtractedDate NOT LIKE '%P%'
  
Left Join CTE_HOEX AS hoex
  On hoex.lrsn = oc.lrsn
  


Where oc.AIN = '135595'
