select pm.lrsn, pm.pin, pm.ain, pm.displayname as Owner, pm.neighborhood, 
--	i.*, ig.*
	i.extension, i.dwelling_number, 
	i.imp_line_number, i.eff_year_built as Improvement_Eff_Year_Built, ig.eff_year_built as IGroups_Eff_Year_Buil
	from kcv_parcelmaster_short pm
join improvements i on i.lrsn=pm.lrsn and i.status='A' and i.imp_type='DWELL'	
join igroups ig on ig.lrsn=pm.lrsn and ig.status='A' and ig.income_year='2018' and ig.eff_year_built <> i.eff_year_built	
where pm.effstatus='A' and pm.neighborhood='2999'
	and pm.neighborhood between 1000 and 6999
--	and pm.lrsn=86320
order by pm.neighborhood, pm.pin
