-- to find "Exempt by Statute" PINs in the cadastre and then match them to related modifiers		
		
select c.revobjid, c.pin, c.ain, c.owner, c.valuetype, c.valueamount, ros.id as ROS_Id, ros.begeffdate as ROS_BegEffDate,		
	ros.descr as ROS_Descr, rosm.id as ROSM_Id, rosm.begtaxyear as ROSM_BegTaxYear, rosm.ModifierId, 	
		isnull(m.descr,' ') as Modifier, rosm.ExpirationYear, rosm.ApplyDate
	from KCv_RPAnnualCadExport17a c	
left outer join revobjsite ros on ros.revobjid=c.revobjid and ros.sitetype=15905 and ros.effstatus='A'		
	and ros.begeffdate=(select max(ros_sub.begeffdate) from revobjsite ros_sub where ros.id=ros_sub.id)	
left outer join revobjsitemodifier rosm on rosm.revobjsiteid=ros.id and rosm.effstatus='A'		
	and rosm.expirationyear > 2016 	
	and ((rosm.modifierid between 1 and 17 or rosm.modifierid=20 or rosm.modifierid=35) and rosm.modifierid <> 7)	
left outer join modifier m on m.id=rosm.modifierid and m.effstatus='A'		
where c.valuetypeid=642		
order by c.pin		
		
Note - the expiration year needs to be update each year as well as the KCv_RPAnnualCadExport17a view name.		
