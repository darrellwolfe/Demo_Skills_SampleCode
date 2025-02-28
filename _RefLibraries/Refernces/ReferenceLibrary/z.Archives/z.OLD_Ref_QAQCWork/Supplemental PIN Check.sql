--Supplemental Check
select pm.lrsn, pm.pin, pm.ain, v.last_update, v.update_user_id, v.valuation_comment, v.eff_year,									
	e.trankey, e.effdate, e.updtdate, e.procdate 								
	from valuation v								
join kcv_parcelmaster_short pm on pm.lrsn=v.lrsn 									
	and (pm.pin not like 'E%' and pm.pin not like 'G%' and pm.pin not like 'UP%')								
left outer join events e on e.lrsn=v.lrsn and e.event=7 and e.transtype='VC' 									
	and e.useridn not in ('SCB','MLS') and e.trankey=								
	(select max(e_sub.trankey) from events e_sub where e.lrsn=e_sub.lrsn and e_sub.event=7								
		and e_sub.transtype='VC' and e_sub.useridn not in ('SCB','MLS'))							
where v.last_update > '12-31-2012' 									
	and (v.valuation_comment in ('38- Subsequent Assessment') or v.change_reason in ('38'))								
	and v.status='A' and v.last_update=								
		(select max(v_sub.last_update) from valuation v_sub where v.lrsn=v_sub.lrsn							
		and v_sub.last_update > '12-31-2012')							
order by v.change_reason, v.eff_year									
