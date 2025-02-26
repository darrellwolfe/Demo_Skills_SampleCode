select vs.revobjid, vs.pin, vs.ain, vs.owner, vs.valueamount as OccupancyTotalExemptions, 		
	sum(isnull(va.valueamount,0)) as AnnualTotalExemptions, (vs.valueamount + sum(isnull(va.valueamount,0))) as TotalExemption	
		from kcv_rpocccadexport18a vs
left outer join kcv_rpannualcadexport18a va on va.revobjid=vs.revobjid and va.valuetypeid=305		
where vs.valuetypeid=320		
group by vs.revobjid, vs.pin, vs.ain, vs.owner, vs.valueamount		
order by vs.pin		
