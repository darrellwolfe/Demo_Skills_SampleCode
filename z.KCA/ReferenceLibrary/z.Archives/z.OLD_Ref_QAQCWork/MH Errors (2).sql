select * from improvements 
where left(imp_type,2)='MH' 
and (right(left(imp_type,3),1)<> 'O' 
	and right(left(imp_type,3),1)<> 'P' 
	and right(left(imp_type,3),1)<> 'C'
	and right(left(imp_type,3),1)<> 'H'
)
/*
update improvements set imp_type='MHOME'
where left(imp_type,2)='MH' 
and (right(left(imp_type,3),1)<> 'O' 
	and right(left(imp_type,3),1)<> 'P' 
	and right(left(imp_type,3),1)<> 'C'
	and right(left(imp_type,3),1)<> 'H')
*/
