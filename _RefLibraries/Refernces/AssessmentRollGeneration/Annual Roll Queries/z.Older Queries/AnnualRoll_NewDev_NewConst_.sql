/*
AsTxDBProd
GRM_Main

Permits-Prod
iMS

*/

-- YOU HAVE TO JOIN EXTENSIONS BETRWEEN PARCEL AND IMPROVEMENTS TO FILTER OUT VOIDED SKETCHES UGH 


----------------------------
--New Construction Roll Query - Step One, Find Parcels to Review
----------------------------

SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
--MemoID
m.memo_id AS [MemoId],
m.memo_text AS [2023NewConstruction],
--Improvements
i.year_built,
i.year_remodeled,
i.improvement_id,
e.extension,
i.imp_type,
i.true_tax_value3,
i.pct_complete,
i.rem_value3,
i.rcnld_value1,
i.rcnld_value3,
--AdditionalPropertyInfo
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
LTRIM(RTRIM(parcel.TAG)) AS [TAG],
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity]


FROM KCv_PARCELMASTER1 AS parcel
--JOIN Improvements, change to current year 2022, 2023
JOIN extensions AS e ON parcel.lrsn=e.lrsn AND parcel.EffStatus=e.status AND e.status='A' AND e.extension NOT LIKE 'L%'
--JOIN extensions between parcel and improvements to filter out voided records
JOIN improvements AS i ON e.lrsn=i.lrsn 
AND e.extension=i.extension 
AND i.status='A' 
AND (
  	   (i.improvement_id IN ('D','M') AND i.year_built = '2022')
	OR (i.improvement_id IN ('C') AND (i.year_built = '2022' OR i.year_remodeled = '2022'))
	
       )
--JOIN Memos, change to current year NC22, NC23
LEFT JOIN memos AS m ON parcel.lrsn=m.lrsn AND m.memo_id='NC22' AND m.memo_line_number='1'


WHERE parcel.EffStatus= 'A'
AND i.true_tax_value3 <> '0'

ORDER BY parcel.neighborhood, parcel.pin;

--End Step One



----------------------------
--Land Change HB519 -- REVIEW Version
----------------------------

SELECT 
--Account Details
parcel.lrsn AS [LRSN],
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
--Values
v23.land_market_val AS [CertLand2023],
v23.imp_val AS [CertImp2023],
(v23.imp_val + v23.land_market_val) AS [CertTotalValue2023],
mhoed.Total_HO_Exemption AS [HomeOwnerDollar],
--Allocations table
al23.extension AS [Ex23],
al23.group_code AS [GC23],
--Aumentum Modifier
murd.ModifierDescr AS [63-602W_HB519],
murd.ExpirationYear AS [ExYear]

FROM KCv_PARCELMASTER1 AS parcel
--Mod
JOIN TSBv_MODIFIERS AS murd ON parcel.lrsn=murd.lrsn 
	AND murd.ModifierStatus='A' AND murd.ModifierDescr LIKE '%602W%' AND murd.ExpirationYear = '2022'
--Value 2023
LEFT JOIN valuation AS v23 ON parcel.lrsn = v23.lrsn 
	AND v23.status = 'A' AND v23.eff_year BETWEEN 20230101 AND 20231231 AND v23.imp_val<>'0'
--Home Owner $$$
LEFT JOIN TSBv_Homeowners AS mhoed ON LTRIM(RTRIM(parcel.pin))=LTRIM(RTRIM(mhoed.pin))
--mhoed (dollar)
--allocations
LEFT JOIN allocations AS al23 ON parcel.lrsn=al23.lrsn 
  AND al23.status='A'
  AND al23.extension LIKE 'L%'

WHERE parcel.EffStatus= 'A'

ORDER BY parcel.neighborhood, parcel.pin;


----------------------------
--Land Change HB519 -- SEND Version
----------------------------
SELECT 
--Account Details
parcel.lrsn AS [LRSN],
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
--Values
v23.land_market_val AS [Cert_Land_2023],
v23.imp_val AS [Cert_Imp_2023],
(v23.imp_val + v23.land_market_val) AS [Cert_Total_2023],
mhoed.Total_HO_Exemption AS [HomeOwner_Exemption],
--Allocations table
al23.group_code AS [GroupCode],
--Aumentum Modifier
murd.ModifierDescr AS [63-602W_HB519],
murd.ExpirationYear AS [ExYear]

FROM KCv_PARCELMASTER1 AS parcel
--Mod
JOIN TSBv_MODIFIERS AS murd ON parcel.lrsn=murd.lrsn 
	AND murd.ModifierStatus='A' AND murd.ModifierDescr LIKE '%602W%' AND murd.ExpirationYear = '2022'
--Value 2023
LEFT JOIN valuation AS v23 ON parcel.lrsn = v23.lrsn 
	AND v23.status = 'A' AND v23.eff_year BETWEEN 20230101 AND 20231231 AND v23.imp_val<>'0'
--Home Owner $$$
LEFT JOIN TSBv_Homeowners AS mhoed ON LTRIM(RTRIM(parcel.pin))=LTRIM(RTRIM(mhoed.pin))
--mhoed (dollar)
--allocations
LEFT JOIN allocations AS al23 ON parcel.lrsn=al23.lrsn 
  AND al23.status='A'
  AND al23.extension LIKE 'L%'

WHERE parcel.EffStatus= 'A'

ORDER BY parcel.neighborhood, parcel.pin;




----------------------------
--New Construction Roll Query - Step Two
--Will pull all properties, sort for Commer vs Res
----------------------------

/*
AsTxDBProd
GRM_Main
*/

WITH CTE_NewDevRollQuery AS (

SELECT DISTINCT
    parcel.lrsn AS [LRSN],
    LTRIM(RTRIM(parcel.pin)) AS [PIN], 
    LTRIM(RTRIM(parcel.ain)) AS [AIN], 
	LTRIM(RTRIM(TIF.Id)) AS [TifId],
	LTRIM(RTRIM(TIF.Descr)) AS [TIF_Name],
	murd.OverrideAmount AS [URD_BASE_$],
	LTRIM(RTRIM(parcel.TAG)) AS [TAG], 
    v22.imp_val AS [CertImpValue_2022],
    v23.imp_val AS [CertImpValue_2023],
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
	AND v23.status = 'A' AND v23.eff_year BETWEEN 20230101 AND 20231231 AND v23.imp_val<>'0'
--Values Previous Year
LEFT JOIN valuation AS v22 ON parcel.lrsn = v22.lrsn 
	AND v22.status = 'A' AND v22.eff_year BETWEEN 20220101 AND 20221231 AND v22.imp_val<>'0'
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








---------------------------------------------------------------
--Everything below this line is saved for future rereference, pulled from various sources.
---------------------------------------------------------------

---Unclear if this is what I need?? 

DECLARE @EffYear INT;
SET @EffYear = 2022; -- CURRENT YEAR
select * from KCfx_NewConstBuild(@EffYear) order by pin


/*
DISREGARD but save in case we want this later...

--Land Change
SELECT 
--Account Details
parcel.lrsn,
LTRIM(RTRIM(parcel.ain)) AS [AIN], 
LTRIM(RTRIM(parcel.pin)) AS [PIN], 
parcel.neighborhood AS [GEO],
LTRIM(RTRIM(parcel.ClassCD)) AS [ClassCD], 
murd.ModifierDescr AS [63-602W_HB519],
murd.ExpirationYear AS [ExYear],
al22.extension AS [Ex22],
al22.group_code AS [GC22],
al22.eff_year AS [Yr22],
al23.extension AS [Ex23],
al23.group_code AS [GC23],
al23.eff_year AS [Yr23],
mNC.memo_text AS [2023NewConstruction],
mB519.memo_text AS [HB519_OldHeader],
m6023.memo_text AS [63-602W3 New Const HB475],
m602W.memo_text AS [63-602W4 Dev Land Ex HB519],
--Demographics
LTRIM(RTRIM(parcel.DisplayName)) AS [Owner], 
LTRIM(RTRIM(parcel.SitusAddress)) AS [SitusAddress],
LTRIM(RTRIM(parcel.SitusCity)) AS [SitusCity],
--Acres
parcel.Acres,
--Other
LTRIM(RTRIM(parcel.TAG)) AS [TAG], 
LTRIM(RTRIM(parcel.DisplayDescr)) AS [LegalDescription],
LTRIM(RTRIM(parcel.SecTwnRng)) AS [SecTwnRng]

FROM KCv_PARCELMASTER1 AS parcel
JOIN allocations AS al22 ON parcel.lrsn=al22.lrsn 
  AND al22.status='A'
  AND al22.extension LIKE 'L%'
--JOIN allocations
JOIN allocations AS al23 ON parcel.lrsn=al23.lrsn 
  AND al23.status='A'
  AND al23.extension LIKE 'L%'
  
--JOIN Memos, change to current year NC22, NC23
LEFT JOIN memos AS mNC ON parcel.lrsn=mNC.lrsn AND mNC.memo_id='NC22' AND mNC.memo_line_number='1'

--JOIN Memos, change to current year B519
LEFT JOIN memos AS mB519 ON parcel.lrsn=mB519.lrsn AND mB519.memo_id='B519' AND mB519.memo_line_number='1'

--JOIN Memos, change to current year 6023
LEFT JOIN memos AS m6023 ON parcel.lrsn=m6023.lrsn AND m6023.memo_id='6023' AND m6023.memo_line_number='1'

--JOIN Memos, change to current year 602W
LEFT JOIN memos AS m602W ON parcel.lrsn=m602W.lrsn AND m602W.memo_id='602W' AND m602W.memo_line_number='1'
--Mod
JOIN TSBv_MODIFIERS AS murd ON parcel.lrsn=murd.lrsn 
	AND murd.ModifierStatus='A' AND murd.ModifierDescr LIKE '%602W%' AND murd.ExpirationYear = '2022'

WHERE parcel.EffStatus= 'A'
AND (al22.group_code<>al23.group_code)


ORDER BY parcel.neighborhood, parcel.pin;
*/




---CHECK THIS OUT







-- New Development Procedure 05-25-21.docx

/*
Phase 1: Prepare Annexation Worktable
Step 7.	Run the following SQL to make sure that the PINs given in the spreadsheets from Betty are the same as the PINs that the database thinks are correct (differences could be from the time that the spreadsheets were made and when we are running the code):
a. Modify the PINs as needed to align with the database.  This could involve directly changing the PINs if the error is obvious (ie. missing digits, duplicates,…) or sending the list of non-matches back to Betty
*/

select 
c.*, 
pm.lrsn, 
pm.pin, 
pm.ain, 
pm.displayname as Owner 
from bkp_(<tab specific>)annexationlist_t c
join kcv_parcelmaster_short pm on pm.ain=c.ain
where c.lrsn <> pm.lrsn or c.pin <> pm.pin
order by c.pin

/*
Phase 2: Prepare Land Use (New Sub) Worktable
*/

select 
c.PIN, 
c.AIN, 
c.RevObjId, 
pm.displayname as Owner, 
pm.TAG, isnull(tr.tifid,0) as tifid,	
c.group_code, SUM(c.newsubamt), 
'' as CatBaseValue, 
isnull(v.valueamount,0) as HOExemption  

from A_TAGTANSList_V c
left outer join kcv_parcelmaster_short pm on pm.lrsn=c.revobjid	
left outer join KCv_RPAnnualCadExport21c v on v.revobjid=c.revobjid 	
	and ltrim(rtrim(v.AddlObjectShortDescr))=ltrim(rtrim(c.group_code))
	and v.valuetypeid=472
left outer join kcv_tifrole1a tr on tr.objectid=c.revobjid	

group by c.pin, c.ain, c.revobjid, pm.displayname, pm.tag, tr.tifid, c.group_code, v.valueamount	
order by c.pin, c.group_code



/*
--------------------------------------------------------
Various notes and codes found in the SQL tabs of previous year's reports.
--------------------------------------------------------

DECLARE @EffYear INT;
SET @EffYear = 2022; -- CURRENT YEAR
select * from KCfx_NewConstBuild(@EffYear) order by pin



select c.*, pm.lrsn, pm.pin, pm.ain, pm.displayname as Owner from bkp_(<tab specific>)annexationlist_t c
join kcv_parcelmaster_short pm on pm.ain=c.ain
where c.lrsn <> pm.lrsn or c.pin <> pm.pin
order by c.pin



--start by pasting the New Construction tab from the Final New Development spreadsheet through the Taxable Value column
--next run the following query and paste the results into the spreadsheet in cell G2

select distinct 
  c.*, 
  v.valueamount as OwnerOcc,
  case 
  when 
  c.category in ('35','39','42','43','51') then taxablevalue else 0 end as CommValue
      --sum(case when v.ain is not null then c.taxablevalue else 0 end) as OwnerOccupiedTaxable,
      --sum(case when v.ain is null then c.taxablevalue else 0 end) as NonOwnerOccupiedTaxable

from bkp_newconstvalues_t c
left outer join kcv_rpannualcadexport18a v on v.ain=c.ain and v.valuetypeid=305
where c.taxablevalue > 0
order by c.ain

--check the PIN check column to unsure everything lines up
--Values requested are the totals for columns Q, R, & S


select 
c.pin, 
ta.Id as TaxAuthorityId, 
ta.descr as TaxAuthority, 
sum(nonresval) as LandUseTaxableValue 

from bkp_newsub_t c
join kcv_parcelmaster_short pm on pm.pin=c.pin
join kcv_tagrole1a tr on tr.objectid=pm.lrsn
join kcv_tagtaxauthority19a tta on tta.tagid=tr.tagid and tta.effstatus='A'
join kcv_taxauthority19a ta on ta.id=tta.taxauthorityid and ta.effstatus='A' and ta.id in (1,1054,1034,1046,1026,1040,1016)
left outer join kcv_tifrole1a tifr on tifr.objectid=pm.lrsn
left outer join bkp_annexation_t a on a.lrsn=pm.lrsn and a.taxauthorityid=ta.id

where a.lrsn is null and (tifr.id is null or tifr.effstatus='I')
group by c.pin, ta.id, ta.descr
order by c.pin, ta.descr

--New SQL
--HB475
select * 
from bkp_HB475Values_t c
join bkp_annexation_t a on a.lrsn=c.revobjid and a.category=c.category and a.taxauthorityid in (1054,1046)

--New Construction 
select * 
from bkp_NewConstValues_t c
join bkp_annexation_t a on a.lrsn=c.revobjid and a.category=c.category and a.taxauthorityid in (1054,1046)

-- exec BKP_HB475_T_Build

select * 
from BKP_HB475_T c
left outer join KCv_RPOccCadExport18c v1 on v1.revobjid=c.lrsn and v1.valuetypeid=760
left outer join KCv_RPOccCadExport18c v2 on v2.revobjid=c.lrsn and v2.valuetypeid=472 and v2.addlobjectid=v1.addlobjectid
order by c.lrsn, v1.valuetype, v1.addlobjectid

select 
c.revobjid as RevObjId, 
pm.PIN, 
pm.AIN, 
pm.displayname as Owner, 
--Missing primary join
left outer join kcv_parcelmaster_short pm on pm.lrsn=c.revobjid
order by pm.pin

select 
c.* 
from bkp_newconstvalues_t c
join KC_2019_NewDevelopment_PostBOECheck v on v.ain=c.ain
order by c.pin, c.category

select 
c.* 
from bkp_newsubs_t c
join KC_2019_NewDevelopment_PostBOECheck v on v.ain=c.ain
order by c.pin, c.category

select c.* 
from bkp_nonres_t c
join KC_2019_NewDevelopment_PostBOECheck v on v.ain=c.ain
order by c.pin, c.category

select c.* 
from bkp_newdevcomm_t c
join KC_2019_NewDevelopment_PostBOECheck v on v.ain=c.ain
order by c.pin, c.category

select c.* 
from bkp_hb475values_t c
join KC_2019_NewDevelopment_PostBOECheck v on v.ain=c.ain
order by c.pin, c.category

select c.* 
from bkp_annexation_t c
join KC_2019_NewDevelopment_PostBOECheck v on v.pin=c.pin
order by c.pin, c.category

select c.* 
from bkp_deannexation_t c
join KC_2019_NewDevelopment_PostBOECheck v on v.pin=c.pin
order by c.pin, c.category
*/