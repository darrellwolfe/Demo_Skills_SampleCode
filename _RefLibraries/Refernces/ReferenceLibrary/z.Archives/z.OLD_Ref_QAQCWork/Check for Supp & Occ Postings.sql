select  v.lrsn, pm.pin, pm.ain, pm.neighborhood, pm.displayname as Owner, v.last_update,v.change_reason, v.valuation_comment from valuation v 
join kcv_parcelmaster_short pm on pm.lrsn = v.lrsn
where v.eff_year > '20200101' ORDER BY 3
	--and v.last_update > '2016-01-22' order by pin
--	and v.last_update between '2015-06-03' and '2015-06-08' order by pin
