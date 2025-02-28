Select 
--	SysType.shortdescr As TaxType, 
--	ta.id As TAXAuthorityId, ta.descr as TAXAuthority,
	IsNull(t.descr, 'Non-TIF') as TIF, 
	RO.RO_ID AS LRSN, RO.RO_PIN AS PIN, RO.RO_AIN AS AIN,
	Sum (Case When ValueType = 939 Then ValueAmount else 0 End) As SupTax939,
	Sum (Case When ValueType = 940 Then ValueAmount else 0 End) As FireTax940,
	Sum (Case When ValueType = 597 Then ValueAmount else 0 End) As URDBase597,
	Sum (Case When ValueType = 599 Then ValueAmount else 0 End) As URDIncr599,
	Sum (Case When ValueType = 937 Then ValueAmount else 0 End) As PSupVal937,
	Sum (Case When ValueType = 938 Then ValueAmount else 0 End) As TotHmEx938
--	,
--	Sum (Case When ValueType = 455 Then ValueAmount else 0 End) as NetTax455,
--	Sum (Case when (t.id <> 0 and valuetype = 597) 
--		or (t.id = 0 and valuetype = 455) then valueamount else 0 End) as DistTaxable,
--	Sum (Case when (t.id <> 0 and valuetype = 599) then valueamount else 0 End) as URDTaxable,
--	Sum (Case when ValueType > 37 and valuetype < 48 then valuetype - 37 else 0 End) As AVMURD
	   From (select distinct ci.revobjid, ci.tagid, ci.taxtype, cv.valuetype, cv.valueamount
		from cadinv ci
	join cadvalue cv on ci.id = cv.cadinvid
					where ci.cadinvctrlid in (476) AND cv.versionnumber = 
0
--AND CI.REVOBJID=86514
--(select max(cv_sub.versionnumber) from cadvalue cv_sub where cv.cadinvid = cv_sub.cadinvid)
) As Result
	JOIN REVOBJKC_V RO ON RESULT.REVOBJID = RO.RO_ID
	INNER JOIN TAGTaxAuthority TTA ON TTA.TAGId = result.tagId 
		AND TTA.TAXAUTHORITYID IN (208) --change this
       		AND TTA.BegTaxYear = (SELECT MAX(subtta.BegTaxYear) 
		FROM TAGTaxAuthority subtta WHERE subtta.ID = TTA.ID)AND TTA.EffStatus = 'A'
	left outer join tifrole tr on tr.objectid = result.revobjid and tr.effstatus = 'A' 
	and tr.begtaxyear =
		(select max(tr_sub.begtaxyear) from tifrole tr_sub where tr_sub.id = tr.id
--	and tr_sub.effstatus = 'A'
	and tr_sub.begtaxyear <= 201399999)
	left outer join tif t on tr.tifid = t.id and t.effstatus = 'A' and t.begtaxyear =
		(select max(t_sub.begtaxyear) from tif t_sub where t_sub.id = t.id 
--	and t_sub.effstatus = 'A'
	and t_sub.begtaxyear <= 201399999)
	  Group By 
--		SysType.shortdescr, 
--		ta.id, 
--		ta.descr,
		t.descr
		,
		RO.RO_ID,
		RO.RO_PIN,
		RO.RO_AIN



GO


