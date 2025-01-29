select  v.lrsn, pm.pin, pm.ain, pm.neighborhood, pm.displayname as Owner, v.last_update,v.change_reason, v.valuation_comment from valuation v 
join kcv_parcelmaster_short pm on pm.lrsn = v.lrsn and pm.neighborhood > 3999 and pm.neighborhood < 5000 -- 9100 to 9699
where v.eff_year < '20200101' order by pin
