select * from improvements 
where left(imp_type,2)='DW' and right(left(imp_type,3),1)<> 'E'

/*
update improvements set imp_type='DWELL'
where left(imp_type,2)='DW' and right(left(imp_type,3),1)<> 'E'
*/