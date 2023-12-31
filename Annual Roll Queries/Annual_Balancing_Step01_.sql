/*
AsTxDBProd
GRM_Main

Permits-Prod
iMS

*/


SELECT 
	* 
FROM KCfx_Balance_CadCheck_AN_CatTaxableChk_TA(
	@EffYear,
	@CadRollId,
	@CadLevelId
) a
ORDER BY taxauthority



----------------------------
--- START FX 1  CatDistTaxable, CatNetTax, CatURDIncr
----------------------------


KCfx_Balance_CadCheck_AN_CatTaxableChk_TA:
(
	@EffYear int,
	--@TaxAuthority int,
	@CadRollId int,
	@CadLevelId int
	--@transient BIT,
	--@personalProperty2 BIT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT ct.TaxAuthority, ct.TaxAuthorityId, ct.DistTaxable, ct.NetTax, 
		ct.URDBase, ct.URDIncr,
		
		SUM(cc.disttaxable) AS CatDistTaxable,
		
		SUM(cc.disttaxable + cc.urdincrvalue) AS CatNetTax,
		
		SUM(cc.urdincrvalue) AS CatURDIncr
		
		
		
	FROM KCfx_Balance_CadCheck_AN_Taxable_TA(@EffYear, @CadRollId, @CadLevelId) ct
	LEFT OUTER JOIN KCfx_Balance_CadCheck_AN_Cat_TA(@EffYear, @CadRollId, @CadLevelId) cc 
	ON cc.taxauthorityid=ct.taxauthorityid
	GROUP BY ct.TaxAuthority, ct.TaxAuthorityId, ct.DistTaxable, ct.NetTax, 
		ct.URDBase, ct.URDIncr
)
GO

----------------------------
--- GO STATEMENT
----------------------------


----------------------------
--- START FX 2
/*

TaxAuthority
TaxAuthorityid
DistTaxable
NetTax
URDBase
URDIncr

*/
----------------------------


KCfx_Balance_CadCheck_AN_Taxable_TA:
  (
  	@EffYear int,
  	--@TaxAuthority int,
  	@CadRollId int,
  	@CadLevelId int
  	--@transient BIT,
  	--@personalProperty2 BIT
  )
  RETURNS TABLE 
  AS
  RETURN 
  (
  	SELECT 
  	  ta.descr AS TaxAuthority, 
  	  ta.id AS TaxAuthorityid, 
	  
          /*
          
          FROM KCfx_Balance_CadCheck_AN_Taxable_TAG(@EffYear, @CadRollId, @CadLevelId) 
          
              AS cv
          
          ChatGPT
          The SUM(CASE ... END) AS segments are performing conditional aggregations on the data. 
          
          The conditions are based on whether the id of the ta (probably "tax authority") is either 250 or 251:
          
          DistTaxable: 
          If ta.id is 250 or 251, 
            the firedisttaxable value from cv (presumably a view or table) is summed; 
            otherwise, disttaxable is summed.
          
          NetTax: If ta.id is 250 or 251, 
            the ntmtbr460 value from cv is summed; 
            otherwise, NetTax455 is summed.
          
          URDBase: If ta.id is 250 or 251, 
            the NTmTBRBase621 value from cv is summed; 
            otherwise, URDBase501 is summed.
          
          URDIncr: If ta.id is 250 or 251, 
            the NTmTBRIncr622 value from cv is summed; 
            otherwise, urdincr601 is summed.
          
          */

		SUM(CASE 
		      WHEN ta.id IN (250,251) 
		        THEN cv.firedisttaxable
			    ELSE cv.disttaxable END) 
			              AS DistTaxable,
		
		
		SUM(CASE 
		      WHEN ta.id IN (250,251) 
		        THEN cv.ntmtbr460
			    ELSE NetTax455 END) 
			              AS NetTax,
		
		
		SUM(CASE 
		      WHEN ta.id IN (250,251) 
		        THEN cv.NTmTBRBase621
			   ELSE cv.URDBase501 END) 
			               AS URDBase,
		
		
		SUM(CASE 
		      WHEN ta.id IN (250,251) 
		        THEN cv.NTmTBRIncr622
			   ELSE cv.urdincr601 END) 
			                AS URDIncr 
  	
  -------------------------------------------
  -- All these functions pull in the tag, tagtaxauthority, and taxauthority tables. 
  --    Against the CadRoll/CadLevel tables
  -- 	    GROUP BY ta.descr, ta.id
  -------------------------------------------
  		
  		FROM KCfx_Balance_CadCheck_AN_Taxable_TAG(@EffYear, @CadRollId, @CadLevelId) cv
  	
  	JOIN tag tag ON tag.shortdescr=cv.tag AND tag.effstatus='A'
  		AND tag.begeffyear=(SELECT MAX(tag_sub.begeffyear) FROM tag tag_sub
  			WHERE tag.id=tag_sub.id)
  	
  	JOIN tagtaxauthority tta ON tta.tagid=tag.id AND tta.effstatus='A'
  		AND tta.begeffyear=(SELECT MAX(tta_sub.begeffyear) FROM tagtaxauthority tta_sub
  			WHERE tta.id=tta_sub.id)
  	
  	JOIN taxauthority ta ON ta.id=tta.taxauthorityid AND ta.effstatus='A'
  	--	and ta.id=1
  		AND ta.id NOT IN (1096,1098) AND ta.begeffyear=
  			(SELECT MAX(ta_sub.begeffyear) FROM taxauthority ta_sub
  			WHERE ta.id=ta_sub.id)
  	
  	
  	GROUP BY ta.descr, ta.id
  )
  GO

----------------------------
--- GO STATEMENT
----------------------------



----------------------------
--- START FX 3
/*
TaxAuthority
TaxAuthorityId
Category

CatAcres
FullMktValue
SpecLandExValue
HomeOwnerExValue
PersPropExValue
URDIncrValue
OtherExValue
Cat81ExValue
URDBaseValue
DistTaxable

*/
----------------------------


KCfx_Balance_CadCheck_AN_Cat_TA:
(
	@EffYear int,
	--@TaxAuthority int,
	@CadRollId int,
	@CadLevelId int
	--@transient BIT,
	--@personalProperty2 BIT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT ta.descr AS TaxAuthority, ta.id AS TaxAuthorityId, cv.Category,

		SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
			THEN 0 ELSE cv.catacres END) AS CatAcres, 

		SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
			THEN 0 ELSE cv.fullmktvalue END) AS FullMktValue, 

		SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
			THEN 0 ELSE cv.SpecLandExValue END) AS SpecLandExValue, 

		SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
			THEN 0 ELSE cv.HomeOwnerExValue END) AS HomeOwnerExValue, 

		SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
			THEN 0 ELSE PersPropExValue END) AS PersPropExValue, 

		SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
			THEN 0 ELSE cv.URDIncrValue END) AS URDIncrValue,

		SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
			THEN 0 ELSE cv.OtherExValue END) AS OtherExValue,

		SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
			THEN 0 ELSE cv.Cat81ExValue END) AS Cat81ExValue,

		SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
			THEN 0 ELSE cv.urdbasevalue END) AS URDBaseValue,

		SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
			THEN 0 ELSE cv.fullmktvalue - 
			(cv.speclandexvalue + cv.HomeOwnerExValue + cv.PersPropExValue + cv.urdincrvalue +
				cv.otherexvalue + cv.Cat81ExValue) END) AS DistTaxable

		FROM KCfx_Balance_CadCheck_AN_Cat_TAG(@EffYear, @CadRollId, @CadLevelId) cv
	JOIN tag tag ON tag.shortdescr=cv.tag AND tag.effstatus='A'
		AND tag.begeffyear=(SELECT MAX(tag_sub.begeffyear) FROM tag tag_sub
			WHERE tag.id=tag_sub.id)
	JOIN tagtaxauthority tta ON tta.tagid=tag.id AND tta.effstatus='A'
		AND tta.begeffyear=(SELECT MAX(tta_sub.begeffyear) FROM tagtaxauthority tta_sub
			WHERE tta.id=tta_sub.id)
	JOIN taxauthority ta ON ta.id=tta.taxauthorityid AND ta.effstatus='A'
	--	and ta.id=1
		AND ta.id NOT IN (1096,1098) AND ta.begeffyear=
			(SELECT MAX(ta_sub.begeffyear) FROM taxauthority ta_sub
			WHERE ta.id=ta_sub.id)
	GROUP BY ta.descr, ta.id, cv.category
)
GO

----------------------------
--- GO STATEMENT
----------------------------


----------------------------
--- START FX 4 
/*
TIF
tag
DistTaxable
FireDistTaxable

NetTax455
URDBase501
URDIncr601
NTmTBR460
NTmTBRBase621
NTmTBRIncr622
HOExcemptValue


*/
----------------------------


KCfx_Balance_CadCheck_AN_Taxable_TAG:
(
	@EffYear int,
	--@TaxAuthority int,
	@CadRollId int,
	@CadLevelId int
	--@transient BIT,
	--@personalProperty2 BIT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT vr.TIF, vr.tag,
		SUM (CASE WHEN vr.tif= 'Non-TIF' THEN vr.nettaxable455 ELSE vr.urdbase501 END) 
			AS DistTaxable,
		SUM (CASE WHEN vr.tif= 'Non-TIF' THEN vr.ntmtbr460 ELSE vr.ntmtbrbase621 END) 
			AS FireDistTaxable,
		SUM(vr.NetTaxable455) AS NetTax455, 
		SUM(vr.URDBase501) AS URDBase501, 
		SUM(vr.URDIncr601) AS URDIncr601,
		SUM(vr.ntmtbr460) AS NTmTBR460,
		SUM(vr.ntmtbrbase621) AS NTmTBRBase621,
		SUM(vr.ntmtbrincr622) AS NTmTBRIncr622,
		SUM(vr.HOExcemptValue) AS HOExcemptValue
	
	
	
FROM KCfx_Balance_CadCheck_AN_Raw(@EffYear, @CadRollId, @CadLevelId) vr
	--join KC_Abstract_Cat_descr_t cv on cv.categoryno=vr.catdescr
	--WHERE vr.category = ''
	GROUP BY vr.tif, vr.tag
	--order by vr.tif;
)
GO


----------------------------
--- GO STATEMENT
----------------------------



----------------------------
--- START FX 5
----------------------------

KCfx_Balance_CadCheck_AN_Cat_TAG:
(
	@EffYear int,
	--@TaxAuthority int,
	@CadRollId int,
	@CadLevelId int
	--@transient BIT,
	--@personalProperty2 BIT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT vr.tag, cv.Category, 
		SUM(vr.CatAcres) AS CatAcres,
		SUM(vr.Fullmktvalue) AS FullMktValue, 
		SUM(vr.SpecLandExValue) AS SpecLandExValue, 
		SUM(vr.HOExValue) AS HomeOwnerExValue, 
		SUM(vr.PPExValue) AS PersPropExValue, 
		SUM(vr.URDIncrValue) AS URDIncrValue,
		SUM(vr.OtherExValue) AS OtherExValue,
		SUM(vr.cat81value) AS Cat81ExValue,
		SUM(vr.urdbasevalue) AS URDBaseValue
		FROM KCfx_Balance_CadCheck_AN_Raw(@EffYear, @CadRollId, @CadLevelId) vr
	JOIN KC_Abstract_Cat_descr_t cv on cv.categoryno=vr.catdescr
	WHERE vr.category <> ''
	GROUP BY vr.tag, cv.category
)
GO

----------------------------
--- GO STATEMENT
----------------------------


----------------------------
--- START FX 6
----------------------------

KCfx_Balance_CadCheck_AN_Raw:
(
	@EffYear int,
	--@TaxAuthority int,
	@CadRollId int,
	@CadLevelId int
	--@transient BIT,
	--@personalProperty2 BIT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT ci.RevObjId, ro.PIN, ro.AIN, --tr.id as TIFRoleId, tif.id as TIFId, 
		isnull(tif.descr,'Non-TIF') AS TIF, tif.id AS TIFId,--ci.tagid, tgr.id as TAGRoleId, tag.id as TAGId,
		tag.descr AS TAG, 
			dbo.stdescr('01-01-' + CAST(@EffYear AS VARCHAR(4)),vta.addlobjectid) AS Category, dbo.stshortdescr(vta.addlobjectid) AS CatDescr,
		SUM (CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'AssessedByCat' OR dbo.vtshortdescr(vta.valuetypeid) = 'SpecLandDeferred' 
			Then vta.ValueAmount ELSE 0 END) AS FullMktValue,
		SUM (CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'SpecLandDeferred' THEN vta.ValueAmount ELSE 0 END) AS SpecLandExValue,
		SUM (CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'HOEX_ByCat' THEN vta.ValueAmount ELSE 0 END) AS HOExValue,
		SUM (CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'HOEX_Exemption' THEN vta.ValueAmount ELSE 0 END) AS HOExcemptValue,
		SUM (CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'PPExemptionByCat' THEN vta.ValueAmount ELSE 0 END) AS PPExValue,
		SUM (CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'UR_IncrByCat' THEN vta.ValueAmount ELSE 0 END) AS URDIncrValue,
		SUM (CASE WHEN vta.valuetypeid in (431,432,433,434,435,436,464,465,466,467,468,469,488,489,490,491,
			492,493,494,495,496,497) THEN vta.ValueAmount ELSE 0 END) AS OtherExValue,
		SUM (CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'AssessedByCat' AND vta.addlobjectid IN (1200415,1200416) 
			THEN vta.ValueAmount ELSE 0 END) AS Cat81Value,
		SUM (CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'UR_BaseByCat' THEN vta.Valueamount ELSE 0 END) AS URDBaseValue,
		SUM (CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'AcresByCat' THEN vta.valueamount ELSE 0 END) AS CatAcres,
		SUM (CASE WHEN vta.ValueTypeId = 455 THEN ValueAmount ELSE 0 END) AS NetTaxable455,
		SUM (CASE WHEN vta.ValueTypeId = 501 Then ValueAmount ELSE 0 END) AS URDBase501,
		SUM (CASE WHEN vta.ValueTypeId = 601 THEN ValueAmount ELSE 0 END) AS URDIncr601,
		SUM (CASE WHEN vta.valuetypeid = 460 THEN valueamount ELSE 0 END) AS NTmTBR460,
		SUM (CASE WHEN vta.valuetypeid = 621 THEN valueamount ELSE 0 END) AS NTmTBRBase621,
		SUM (CASE WHEN vta.valuetypeid = 622 THEN valueamount ELSE 0 END) AS NTmTBRIncr622
		FROM cadroll cr
	JOIN cadlevel cl ON cr.id=cl.cadrollid AND cl.rolllevel =
		(SELECT MAX(cl_sub.rolllevel) FROM cadlevel cl_sub
			WHERE cl.cadrollid=cl_sub.cadrollid)
	JOIN cadinv ci ON ci.cadlevelid=cl.id and ci.effstatus='A' AND ci.valchangereason IN (0,2000015)
	JOIN valuetypeamount vta ON vta.headertype=100153 AND vta.headerid=ci.id
		AND vta.addlobjectid NOT IN (--1200355,
		1200391--,1200392
		)
	JOIN revobj ro ON ro.id=ci.revobjid AND ro.classcd <> 1306493
	--	and ro.classcd in (1200251) --Transient
		AND 
		((@CadRollId IN (SELECT CadRollId FROM KCv_RollID WHERE AssessmentYear = @EffYear AND Roll != 'PP2'))
		OR
		((@CadRollId IN (SELECT CadRollId FROM KCv_RollID WHERE AssessmentYear = @EffYear AND Roll = 'PP2'))
		AND (ro.classcd NOT IN (1200251)))) --(2000074,2000077,2000075,2000076) --Personal Property 2
	--	and ro.id not in (80291,41270,30143,26238,26680,534023,5129,80702,544941,40911,
	--		31992,32143,78726,548079,166,48964,535976)
	--AND ((@transient=1 AND @personalProperty2=1 AND ro.classcd in (SELECT DISTINCT classcd FROM revobj))
	--OR (@transient=1 AND @personalProperty2=0 AND ro.classcd in (1200251))
	--OR (@transient=0 AND @personalProperty2=1 AND ro.classcd in (SELECT DISTINCT classcd FROM revobj WHERE classcd <>1200251))
	--OR (@transient=0 AND @personalProperty2=0 AND ro.classcd in (SELECT DISTINCT classcd FROM revobj)))
		AND ro.begeffdate=
		(SELECT MAX(ro_sub.begeffdate) FROM revobj ro_sub WHERE ro.id=ro_sub.id)
	JOIN tagrole tgr ON tgr.id=ci.tagroleid AND tgr.begeffdate=ci.tagroledate
	JOIN tag ON tag.id=ci.tagid AND tag.begeffyear=ci.tagyear
	LEFT OUTER JOIN tifrole tr ON tr.objectid=ci.revobjid AND tr.objecttype=100002 
		AND tr.effstatus='A' AND tr.begeffdate=
		(SELECT MAX(tr_sub.begeffdate) FROM tifrole tr_sub WHERE tr_sub.id=tr.id
			 AND tr_sub.begeffdate < '01-02-' + CAST(@EffYear AS VARCHAR(4)))
	LEFT OUTER JOIN tif ON tif.id=tr.tifid AND tif.effstatus='A' AND tif.begeffyear=
		(SELECT MAX(tif_sub.begeffyear) FROM tif tif_sub WHERE tif.id=tif_sub.id)
	--where cr.id in (551,550) and cl.id in (825,824) --Real & Personal
	WHERE cr.id IN (@CadRollId) AND cl.id IN (@CadLevelId) --Real
	--where cr.id in (550) and cl.id in (824) --Personal
	--where cr.id in (552) and cl.id in (826) -- Operating
	--where cr.id in (553) and cl.id in (827) -- Transient Personal/ Personal 2
	--and ro.ain=345397
	GROUP BY ci.RevObjId, ro.PIN, ro.AIN,
	 --	tr.id as TIFRoleId, tif.id as TIFId,
		isnull(tif.descr,'Non-TIF'), tif.id,
	--	tgr.id as TAGRoleId, tag.id as TAGId,
		tag.descr,
		dbo.stdescr('01-01-' + CAST(@EffYear AS VARCHAR(4)),vta.addlobjectid),
		dbo.stshortdescr(vta.addlobjectid)
	--order by 2,6;
)
GO


----------------------------
--- GO STATEMENT
----------------------------



















-------------------------------------------------------
--WHAT IF POWER QUERY M
----------------------------------------------------------








/*

  EffYear = 2023,
  CadRollId = 559,560
  CadLevelId = 834, 835


What this would look like as a Power Query M

let
  EffYear = 2023,
  CadRollId = 559,560 -- Replace with the actual CadRollId value
  CadLevelId = 834, 835 -- Replace with the actual CadLevelId value

  KCfx_Balance_CadCheck_AN_CatTaxableChk_TA = () =>
    let
      Source = Sql.Database("server", "database"),
      Query = "SELECT ct.TaxAuthority, ct.TaxAuthorityId, ct.DistTaxable, ct.NetTax,
        ct.URDBase, ct.URDIncr,
        SUM(cc.disttaxable) AS CatDistTaxable,
        SUM(cc.disttaxable + cc.urdincrvalue) AS CatNetTax,
        SUM(cc.urdincrvalue) AS CatURDIncr
        FROM KCfx_Balance_CadCheck_AN_Taxable_TA(" & Text.From(EffYear) & ", " & Text.From(CadRollId) & ", " & Text.From(CadLevelId) & ") ct
        LEFT OUTER JOIN KCfx_Balance_CadCheck_AN_Cat_TA(" & Text.From(EffYear) & ", " & Text.From(CadRollId) & ", " & Text.From(CadLevelId) & ") cc
        ON cc.taxauthorityid=ct.taxauthorityid
        GROUP BY ct.TaxAuthority, ct.TaxAuthorityId, ct.DistTaxable, ct.NetTax,
        ct.URDBase, ct.URDIncr",
      Result = Source{[Schema="dbo", Item="YourTable"]}[Data]
    in
      Result,

  KCfx_Balance_CadCheck_AN_Taxable_TA = () =>
    let
      Source = Sql.Database("server", "database"),
      Query = "SELECT ta.descr AS TaxAuthority, ta.id AS TaxAuthorityid,
        SUM(CASE WHEN ta.id IN (250,251) THEN cv.firedisttaxable
          ELSE cv.disttaxable END) AS DistTaxable,
        SUM(CASE WHEN ta.id IN (250,251) THEN cv.ntmtbr460
          ELSE NetTax455 END) AS NetTax,
        SUM(CASE WHEN ta.id IN (250,251) THEN cv.NTmTBRBase621
          ELSE cv.URDBase501 END) AS URDBase,
        SUM(CASE WHEN ta.id IN (250,251) THEN cv.NTmTBRIncr622
          ELSE cv.urdincr601 END) AS URDIncr
        FROM KCfx_Balance_CadCheck_AN_Taxable_TAG(" & Text.From(EffYear) & ", " & Text.From(CadRollId) & ", " & Text.From(CadLevelId) & ") cv
        JOIN tag tag ON tag.shortdescr=cv.tag AND tag.effstatus='A'
          AND tag.begeffyear=(SELECT MAX(tag_sub.begeffyear) FROM tag tag_sub
            WHERE tag.id=tag_sub.id)
        JOIN tagtaxauthority tta ON tta.tagid=tag.id AND tta.effstatus='A'
          AND tta.begeffyear=(SELECT MAX(tta_sub.begeffyear) FROM tagtaxauthority tta_sub
            WHERE tta.id=tta_sub.id)
        JOIN taxauthority ta ON ta.id=tta.taxauthorityid AND ta.effstatus='A'
          AND ta.id NOT IN (1096,1098) AND ta.begeffyear=
            (SELECT MAX(ta_sub.begeffyear) FROM taxauthority ta_sub
            WHERE ta.id=ta_sub.id)
        GROUP BY ta.descr, ta.id",
      Result = Source{[Schema="dbo", Item="YourTable"]}[Data]
    in
      Result,

  KCfx_Balance_CadCheck_AN_Cat_TA = () =>
    let
      Source = Sql.Database("server", "database"),
      Query = "SELECT ta.descr AS TaxAuthority, ta.id AS TaxAuthorityId, cv.Category,
        SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
          THEN 0 ELSE cv.catacres END) AS CatAcres,
        SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
          THEN 0 ELSE cv.fullmktvalue END) AS FullMktValue,
        SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
          THEN 0 ELSE cv.SpecLandExValue END) AS SpecLandExValue,
        SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
          THEN 0 ELSE cv.HomeOwnerExValue END) AS HomeOwnerExValue,
        SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
          THEN 0 ELSE PersPropExValue END) AS PersPropExValue,
        SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
          THEN 0 ELSE cv.URDIncrValue END) AS URDIncrValue,
        SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
          THEN 0 ELSE cv.OtherExValue END) AS OtherExValue,
        SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
          THEN 0 ELSE cv.Cat81ExValue END) AS Cat81ExValue,
        SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
          THEN 0 ELSE cv.urdbasevalue END) AS URDBaseValue,
        SUM(CASE WHEN (ta.id IN (250,251) AND LEFT(cv.category,2) IN ('06','07'))
          THEN 0 ELSE cv.fullmktvalue -
          (cv.speclandexvalue + cv.HomeOwnerExValue + cv.PersPropExValue + cv.urdincrvalue +
            cv.otherexvalue + cv.Cat81ExValue) END) AS DistTaxable
        FROM KCfx_Balance_CadCheck_AN_Cat_TAG(" & Text.From(EffYear) & ", " & Text.From(CadRollId) & ", " & Text.From(CadLevelId) & ") cv
        JOIN tag tag ON tag.shortdescr=cv.tag AND tag.effstatus='A'
          AND tag.begeffyear=(SELECT MAX(tag_sub.begeffyear) FROM tag tag_sub
            WHERE tag.id=tag_sub.id)
        JOIN tagtaxauthority tta ON tta.tagid=tag.id AND tta.effstatus='A'
          AND tta.begeffyear=(SELECT MAX(tta_sub.begeffyear) FROM tagtaxauthority tta_sub
            WHERE tta.id=tta_sub.id)
        JOIN taxauthority ta ON ta.id=tta.taxauthorityid AND ta.effstatus='A'
          AND ta.id NOT IN (1096,1098) AND ta.begeffyear=
            (SELECT MAX(ta_sub.begeffyear) FROM taxauthority ta_sub
            WHERE ta.id=ta_sub.id)
        GROUP BY ta.descr, ta.id, cv.category",
      Result = Source{[Schema="dbo", Item="YourTable"]}[Data]
    in
      Result,

  KCfx_Balance_CadCheck_AN_Taxable_TAG = () =>
    let
      Source = Sql.Database("server", "database"),
      Query = "SELECT vr.TIF, vr.tag,
        SUM (CASE WHEN vr.tif= 'Non-TIF' THEN vr.nettaxable455 ELSE vr.urdbase501 END)
          AS DistTaxable,
        SUM (CASE WHEN vr.tif= 'Non-TIF' THEN vr.ntmtbr460 ELSE vr.ntmtbrbase621 END)
          AS FireDistTaxable,
        SUM(vr.NetTaxable455) AS NetTax455,
        SUM(vr.URDBase501) AS URDBase501,
        SUM(vr.URDIncr601) AS URDIncr601,
        SUM(vr.ntmtbr460) AS NTmTBR460,
        SUM(vr.ntmtbrbase621) AS NTmTBRBase621,
        SUM(vr.ntmtbrincr622) AS NTmTBRIncr622,
        SUM(vr.HOExcemptValue) AS HOExcemptValue
        FROM KCfx_Balance_CadCheck_AN_Raw(" & Text.From(EffYear) & ", " & Text.From(CadRollId) & ", " & Text.From(CadLevelId) & ") vr
        GROUP BY vr.tif, vr.tag",
      Result = Source{[Schema="dbo", Item="YourTable"]}[Data]
    in
      Result,

  KCfx_Balance_CadCheck_AN_Cat_TAG = () =>
    let
      Source = Sql.Database("server", "database"),
      Query = "SELECT vr.tag, cv.Category,
        SUM(vr.CatAcres) AS CatAcres,
        SUM(vr.Fullmktvalue) AS FullMktValue,
        SUM(vr.SpecLandExValue) AS SpecLandExValue,
        SUM(vr.HOExValue) AS HomeOwnerExValue,
        SUM(vr.PPExValue) AS PersPropExValue,
        SUM(vr.URDIncrValue) AS URDIncrValue,
        SUM(vr.OtherExValue) AS OtherExValue,
        SUM(vr.cat81value) AS Cat81ExValue,
        SUM(vr.urdbasevalue) AS URDBaseValue
        FROM KCfx_Balance_CadCheck_AN_Raw(" & Text.From(EffYear) & ", " & Text.From(CadRollId) & ", " & Text.From(CadLevelId) & ") vr
        JOIN KC_Abstract_Cat_descr_t cv ON cv.categoryno=vr.catdescr
        WHERE vr.category <> ''
        GROUP BY vr.tag, cv.category",
      Result = Source{[Schema="dbo", Item="YourTable"]}[Data]
    in
      Result,

  KCfx_Balance_CadCheck_AN_Raw = () =>
    let
      Source = Sql.Database("server", "database"),
      Query = "SELECT ci.RevObjId, ro.PIN, ro.AIN,
        ISNULL(tif.descr,'Non-TIF') AS TIF, tif.id AS TIFId,
        tag.descr AS TAG,
        dbo.stdescr('01-01-' + Text.From(EffYear), vta.addlobjectid) AS Category,
        dbo.stshortdescr(vta.addlobjectid) AS CatDescr,
        SUM(CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'AssessedByCat' OR dbo.vtshortdescr(vta.valuetypeid) = 'SpecLandDeferred'
          THEN vta.ValueAmount ELSE 0 END) AS FullMktValue,
        SUM(CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'SpecLandDeferred' THEN vta.ValueAmount ELSE 0 END) AS SpecLandExValue,
        SUM(CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'HOEX_ByCat' THEN vta.ValueAmount ELSE 0 END) AS HOExValue,
        SUM(CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'HOEX_Exemption' THEN vta.ValueAmount ELSE 0 END) AS HOExcemptValue,
        SUM(CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'PPExemptionByCat' THEN vta.ValueAmount ELSE 0 END) AS PPExValue,
        SUM(CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'UR_IncrByCat' THEN vta.ValueAmount ELSE 0 END) AS URDIncrValue,
        SUM(CASE WHEN vta.valuetypeid IN (431,432,433,434,435,436,464,465,466,467,468,469,488,489,490,491,
          492,493,494,495,496,497) THEN vta.ValueAmount ELSE 0 END) AS OtherExValue,
        SUM(CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'AssessedByCat' AND vta.addlobjectid IN (1200415,1200416)
          THEN vta.ValueAmount ELSE 0 END) AS Cat81Value,
        SUM(CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'UR_BaseByCat' THEN vta.ValueAmount ELSE 0 END) AS URDBaseValue,
        SUM(CASE WHEN dbo.vtshortdescr(vta.valuetypeid) = 'AcresByCat' THEN vta.ValueAmount ELSE 0 END) AS CatAcres,
        SUM(CASE WHEN vta.ValueTypeId = 455 THEN ValueAmount ELSE 0 END) AS NetTaxable455,
        SUM(CASE WHEN vta.ValueTypeId = 501 THEN ValueAmount ELSE 0 END) AS URDBase501,
        SUM(CASE WHEN vta.ValueTypeId = 601 THEN ValueAmount ELSE 0 END) AS URDIncr601,
        SUM(CASE WHEN vta.ValueTypeId = 460 THEN ValueAmount ELSE 0 END) AS NTmTBR460,
        SUM(CASE WHEN vta.ValueTypeId = 621 THEN ValueAmount ELSE 0 END) AS NTmTBRBase621,
        SUM(CASE WHEN vta.ValueTypeId = 622 THEN ValueAmount ELSE 0 END) AS NTmTBRIncr622
        FROM cadroll cr
        JOIN cadlevel cl ON cr.id=cl.cadrollid AND cl.rolllevel =
          (SELECT MAX(cl_sub.rolllevel) FROM cadlevel cl_sub
            WHERE cl.cadrollid=cl_sub.cadrollid)
        JOIN cadinv ci ON ci.cadlevelid=cl.id and ci.effstatus='A' AND ci.valchangereason IN (0,2000015)
        JOIN valuetypeamount vta ON vta.headertype=100153 AND vta.headerid=ci.id
          AND vta.addlobjectid NOT IN (1200391)
        JOIN revobj ro ON ro.id=ci.revobjid AND ro.classcd <> 1306493
        AND ((CadRollId IN (SELECT CadRollId FROM KCv_RollID WHERE AssessmentYear = EffYear AND Roll != 'PP2'))
          OR ((CadRollId IN (SELECT CadRollId FROM KCv_RollID WHERE AssessmentYear = EffYear AND Roll = 'PP2'))
          AND (ro.classcd NOT IN (1200251))))
        AND ro.begeffdate =
          (SELECT MAX(ro_sub.begeffdate) FROM revobj ro_sub WHERE ro.id=ro_sub.id)
        JOIN tagrole tgr ON tgr.id=ci.tagroleid AND tgr.begeffdate=ci.tagroledate
        JOIN tag ON tag.id=ci.tagid AND tag.begeffyear=ci.tagyear
        LEFT OUTER JOIN tifrole tr ON tr.objectid=ci.revobjid AND tr.objecttype=100002
          AND tr.effstatus='A' AND tr.begeffdate=
          (SELECT MAX(tr_sub.begeffdate) FROM tifrole tr_sub WHERE tr_sub.id=tr.id
           AND tr_sub.begeffdate < '01-02-' + Text.From(EffYear))
        LEFT OUTER JOIN tif ON tif.id=tr.tifid AND tif.effstatus='A' AND tif.begeffyear=
          (SELECT MAX(tif_sub.begeffyear) FROM tif tif_sub WHERE tif.id=tif_sub.id)
        WHERE cr.id IN (CadRollId) AND cl.id IN (CadLevelId)
        GROUP BY ci.RevObjId, ro.PIN, ro.AIN,
          ISNULL(tif.descr,'Non-TIF'), tif.id,
          tag.descr,
          dbo.stdescr('01-01-' + Text.From(EffYear), vta.addlobjectid),
          dbo.stshortdescr(vta.addlobjectid)",
      Result = Source{[Schema="dbo", Item="YourTable"]}[Data]
    in
      Result,

  KCfx_Balance_CadCheck_AN_CatTaxableChk_TA(),
  KCfx_Balance_CadCheck_AN_Taxable_TA(),
  KCfx_Balance_CadCheck_AN_Cat_TA(),
  KCfx_Balance_CadCheck_AN_Taxable_TAG(),
  KCfx_Balance_CadCheck_AN_Cat_TAG(),
  KCfx_Balance_CadCheck_AN_Raw()
in
  KCfx_Balance_CadCheck_AN_CatTaxableChk_TA

*/

