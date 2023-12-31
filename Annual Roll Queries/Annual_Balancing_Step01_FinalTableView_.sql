
SELECT
*



FROM cadroll cr
	JOIN cadlevel cl ON cr.id=cl.cadrollid AND cl.rolllevel =
		(SELECT MAX(cl_sub.rolllevel) FROM cadlevel cl_sub
			WHERE cl.cadrollid=cl_sub.cadrollid)

JOIN cadinv ci ON ci.cadlevelid=cl.id and ci.effstatus='A' AND ci.valchangereason IN (0,2000015)



JOIN valuetypeamount vta ON vta.headertype=100153 AND vta.headerid=ci.id
		AND vta.addlobjectid NOT IN (--1200355,
		1200391--,1200392)


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
		
		
		
		
		------------------------------------------------------------------



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
	
	
	
	
	
	