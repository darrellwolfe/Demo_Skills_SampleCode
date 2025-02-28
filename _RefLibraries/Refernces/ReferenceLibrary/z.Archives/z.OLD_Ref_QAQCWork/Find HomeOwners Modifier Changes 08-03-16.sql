-- Find Homeowners Modifier changes 08-03-16 SCB
--
select ros.RevObjId, pm.PIN, pm.AIN, ros.begeffdate as ROS_BegEffDate, ros.Descr as ROS_Descr,
	 dbo.stdescr('01-01-2016',ros.valchangereason) as ROS_ValChangeReason,
	 m.descr as Modifier, rosm.BegTaxYear, rosm.ApplyDate, rosm.ExpirationYear, rosm.ModifierPercent,
	 isnull(rosmv.valueamount,0) as OverrideAmount,
	 isnull(th.ChangeTimeStamp,' ') as ROS_ChangeTimeStamp, isnull(up.UserLogin,' ') as ROS_UserLogin,
	 isnull(th1.changetimestamp,' ') as ROSM_ChangeTimeStamp, isnull(up1.userlogin,' ') as ROSM_UserLogin,
	 dbo.stdescr('01-01-2016',rosm.valchangereason) as ROSM_ValChangeReason
	 from revobjsite ros
join kcv_parcelmaster_short pm on pm.lrsn=ros.revobjid and pm.effstatus='A'
	and pm.ain=249408
--	and pm.pin='P57150020160'
join revobjsitemodifier rosm on rosm.revobjsiteid=ros.id and rosm.modifierid in (7,41,42)
join modifier m on m.id=rosm.modifierid
join tranheader th on th.tranid=ros.tranid
left outer join tranheader th1 on th1.tranid=rosm.tranid
join userprofile up on up.id=th.userprofileid
left outer join userprofile up1 on up1.id=th1.userprofileid
left outer join revobjmodifiervalue rosmv on rosmv.revobjmodifierid=rosm.id
where ros.sitetype=15905
order by pm.pin, rosm.begtaxyear, rosm.applydate
