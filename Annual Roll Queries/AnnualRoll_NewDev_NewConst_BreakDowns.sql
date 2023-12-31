-- !preview conn=conn

/*
AsTxDBProd
GRM_Main

Permits-Prod
iMS

*/

---------------------------
--New Construction Roll Query - Step Two
--Will pull all properties, sort for Commer vs Res
----------------------------

DECLARE @EffYearStart1 INT;
SET @EffYearStart1 = 20230101; -- CURRENT YEAR

DECLARE @EffYearEnd1 INT;
SET @EffYearEnd1 = 20231231; -- CURRENT YEAR

DECLARE @EffYearStart2 INT;
SET @EffYearStart2 = 20220101; -- LAST YEAR

DECLARE @EffYearEnd2 INT;
SET @EffYearEnd2 = 20221231; -- LAST YEAR


WITH CTE_NewDevRollQuery AS (

SELECT DISTINCT
    parcel.lrsn AS [LRSN],
    LTRIM(RTRIM(parcel.pin)) AS [PIN], 
    LTRIM(RTRIM(parcel.ain)) AS [AIN], 
	LTRIM(RTRIM(TIF.Id)) AS [TifId],
	LTRIM(RTRIM(TIF.Descr)) AS [TIF_Name],
	murd.OverrideAmount AS [URD_BASE_$],
	LTRIM(RTRIM(parcel.TAG)) AS [TAG], 
    v22.imp_val AS [CertImpValue_LASTYEAR],
    v23.imp_val AS [CertImpValue_CURRENTYEAR],
    (v23.imp_val-v22.imp_val) AS [IMP_Difference],
	LTRIM(RTRIM(LEFT(a.group_code,2))) AS [Category],
    parcel.neighborhood AS [GEO],
--Additional Information | Improvements
	'' AS [AdditionalInformation>],
    LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD],
    i.year_built,
	i.year_remodeled,
	i.improvement_id,
	e.extension,
	i.imp_type,
	i.true_tax_value3,
	i.pct_complete,
--Memos related to New Construction
  mNC.memo_text AS [2023NewConstruction],
	mB519.memo_text AS [HB519_OldHeader],
	m6023.memo_text AS [63-602W3 New Const HB475],
	m602W.memo_text AS [63-602W4 Dev Land Ex HB519],
--Add HOEX
mhoed.Total_HO_Exemption AS [HomeOwnerDollar],
	mhoex.ModifierDescr AS [HOEX],
	mhoex.ModifierPercent AS [HOEX_%],
	mhoex.OverrideAmount AS [HOEX_$],
ROW_NUMBER() OVER(PARTITION BY parcel.lrsn ORDER BY v22.last_update DESC, v23.last_update DESC) AS RowNumber
    
FROM KCv_PARCELMASTER1 AS parcel
--Values Current Year
JOIN valuation AS v23 ON parcel.lrsn = v23.lrsn 
	AND v23.status = 'A' AND v23.eff_year BETWEEN @EffYearStart1 AND @EffYearEnd1 AND v23.imp_val<>'0'
--Values Previous Year
LEFT JOIN valuation AS v22 ON parcel.lrsn = v22.lrsn 
	AND v22.status = 'A' AND v22.eff_year BETWEEN @EffYearStart2 AND @EffYearEnd2 AND v22.imp_val<>'0'
--TAG & TIG
LEFT JOIN TAG AS tag ON LTRIM(RTRIM(parcel.TAG))=LTRIM(RTRIM(tag.Descr)) AND tag.EffStatus = 'A'
  LEFT JOIN TAGTIF ON TAG.Id=TAGTIF.TAGId AND TAGTIF.EffStatus = 'A'
  LEFT JOIN TIF ON TAGTIF.TIFId=TIF.Id AND TIF.EffStatus  = 'A'
--modifier URD
LEFT JOIN TSBv_MODIFIERS AS murd ON parcel.lrsn=murd.lrsn 
	AND murd.ModifierStatus='A' AND murd.ModifierDescr LIKE '%URD%' AND murd.ExpirationYear > '2022'
--modifier hoex
LEFT JOIN TSBv_MODIFIERS AS mhoex ON parcel.lrsn=mhoex.lrsn 
	AND mhoex.ModifierStatus='A' AND mhoex.ModifierDescr LIKE '%Homeowner%' AND mhoex.ExpirationYear > '2022'
--Homeowner
--602G Residential Improvements - Homeowners
--Homeowner Calc Cap Override
--Homeowner Manual Cap Override
LEFT JOIN TSBv_Homeowners AS mhoed ON LTRIM(RTRIM(parcel.pin))=LTRIM(RTRIM(mhoed.pin))
--mhoed (dollar)
  
--JOIN Improvements, change to current year 2022, 2023
LEFT JOIN extensions AS e ON parcel.lrsn=e.lrsn 
	AND parcel.EffStatus=e.status AND e.status='A' AND e.extension NOT LIKE 'L%'
--JOIN extensions between parcel and improvements to filter out voided records
JOIN improvements AS i ON e.lrsn=i.lrsn AND e.extension=i.extension 
	AND i.status='A' 
    AND ((i.improvement_id IN ('D','M') AND i.year_built = '2022')
		OR (i.improvement_id IN ('C') AND (i.year_built = '2022' OR i.year_remodeled = '2022'))
         )
--Allocations
JOIN allocations AS a ON parcel.lrsn=a.lrsn
    AND a.status='A' and a.extension NOT LIKE 'L%'
  	AND a.group_code <> '81'

--JOIN Memos, change to current year NC22, NC23
LEFT JOIN memos AS mNC ON parcel.lrsn=mNC.lrsn AND mNC.memo_id='NC22' AND mNC.memo_line_number='1'

--JOIN Memos, change to current year B519
LEFT JOIN memos AS mB519 ON parcel.lrsn=mB519.lrsn AND mB519.memo_id='B519' AND mB519.memo_line_number='1'

--JOIN Memos, change to current year 6023
LEFT JOIN memos AS m6023 ON parcel.lrsn=m6023.lrsn AND m6023.memo_id='6023' AND m6023.memo_line_number='1'

--JOIN Memos, change to current year 602W
LEFT JOIN memos AS m602W ON parcel.lrsn=m602W.lrsn AND m602W.memo_id='602W' AND m602W.memo_line_number='1'

--
  
WHERE parcel.EffStatus = 'A'

)

SELECT *
FROM CTE_NewDevRollQuery
WHERE RowNumber = 1
ORDER BY [GEO],[PIN];
