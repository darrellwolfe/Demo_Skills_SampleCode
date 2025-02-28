ALTER view [dbo].[KCv_Modifiers15a]
as
select pm.lrsn, pm.pin, pm.ain, pm.displayname as Owner, ros.id as RevObjSiteId, ros.begeffdate as ROS_BegEffDate, 
	rosm.id as RevObjSiteModifierId, rosm.begtaxyear as ROSM_BegTaxYear, rosm.ApplyDate, rosm.ExpirationYear, 
	m.id as ModifierId, m.descr as Modifier, isnull(rosmv.id,0) as RevObjSiteModifierValueId, 
	isnull(rosmv.begtaxyear,' ') as ROSMV_BegTaxYear, isnull(rosmv.ValueTypeId,0) as ValueTypeId, 
	isnull(vt.descr,' ') as ValueType, isnull(rosmv.ValueAmount,0) as ValueAmount 
		from kcv_parcelmaster_short pm
join revobjsite ros on ros.revobjid=pm.lrsn and ros.effstatus='A'
	and ros.valchangereason in (0,2000015) and ros.sitetype=15905 and ros.begeffdate=
		(select max(ros_sub.begeffdate) from revobjsite ros_sub where ros.id=ros_sub.id)
join revobjsitemodifier rosm on rosm.revobjsiteid=ros.id and rosm.effstatus='A'
	and rosm.valchangereason in (0,2000015) and rosm.expirationyear > 2014 and rosm.begtaxyear=
		(select max(rosm_sub.begtaxyear) from revobjsitemodifier rosm_sub where rosm.id=rosm_sub.id)
join modifier m on m.id=rosm.modifierid and m.effstatus='A' and m.begtaxyear=
	(select max(m_sub.begtaxyear) from modifier m_sub where m.id=m_sub.id)
left outer join revobjsitemodifiervalue rosmv on rosmv.revobjsitemodifierid=rosm.id and rosmv.effstatus='A'
	and rosmv.begtaxyear=(select max(rosmv_sub.begtaxyear) from revobjsitemodifiervalue rosmv_sub
		where rosmv.id=rosmv_sub.id)
left outer join valuetype vt on vt.id=rosmv.valuetypeid
where pm.effstatus='A'


select * from KCv_Modifiers15a order by pin, modifier  -- for 2015

--To make for 2016:

create view [dbo].[KCv_Modifiers16a]
as
select pm.lrsn, pm.pin, pm.ain, pm.displayname as Owner, ros.id as RevObjSiteId, ros.begeffdate as ROS_BegEffDate, 
	rosm.id as RevObjSiteModifierId, rosm.begtaxyear as ROSM_BegTaxYear, rosm.ApplyDate, rosm.ExpirationYear, 
	m.id as ModifierId, m.descr as Modifier, isnull(rosmv.id,0) as RevObjSiteModifierValueId, 
	isnull(rosmv.begtaxyear,' ') as ROSMV_BegTaxYear, isnull(rosmv.ValueTypeId,0) as ValueTypeId, 
	isnull(vt.descr,' ') as ValueType, isnull(rosmv.ValueAmount,0) as ValueAmount 
		from kcv_parcelmaster_short pm
join revobjsite ros on ros.revobjid=pm.lrsn and ros.effstatus='A'
	and ros.valchangereason in (0,2000015) and ros.sitetype=15905 and ros.begeffdate=
		(select max(ros_sub.begeffdate) from revobjsite ros_sub where ros.id=ros_sub.id)
join revobjsitemodifier rosm on rosm.revobjsiteid=ros.id and rosm.effstatus='A'
	and rosm.valchangereason in (0,2000015) and rosm.expirationyear > 2015 and rosm.begtaxyear=
		(select max(rosm_sub.begtaxyear) from revobjsitemodifier rosm_sub where rosm.id=rosm_sub.id)
join modifier m on m.id=rosm.modifierid and m.effstatus='A' and m.begtaxyear=
	(select max(m_sub.begtaxyear) from modifier m_sub where m.id=m_sub.id)
left outer join revobjsitemodifiervalue rosmv on rosmv.revobjsitemodifierid=rosm.id and rosmv.effstatus='A'
	and rosmv.begtaxyear=(select max(rosmv_sub.begtaxyear) from revobjsitemodifiervalue rosmv_sub
		where rosmv.id=rosmv_sub.id)
left outer join valuetype vt on vt.id=rosmv.valuetypeid
where pm.effstatus='A'

select * from KCv_Modifiers16a order by pin, modifier  -- for 2016




