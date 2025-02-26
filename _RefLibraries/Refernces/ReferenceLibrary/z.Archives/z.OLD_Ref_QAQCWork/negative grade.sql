select distinct pm.lrsn, pm.pin, pm.ain
--, pm.classcd, pm.neighborhood, i.extension, 
--	i.dwelling_number, improvement_id,imp_type 
from improvements i
join kcv_parcelmaster_short pm on pm.lrsn=i.lrsn and pm.pin not like 'KC%' 
	and pm.neighborhood > 999
where i.grade in ('22','32','42','52','62','72')
order by 
--pm.neighborhood, 
pm.pin
