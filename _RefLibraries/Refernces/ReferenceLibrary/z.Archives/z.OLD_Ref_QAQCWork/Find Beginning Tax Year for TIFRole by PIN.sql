Declare @find_pins varchar(50)
Set @find_pins = 'pk313%'
-- You can also enter portions of a PIN (Starts with)if you put an % at the end

Select r.RO_PIN as PIN, r.RO_AIN as AIN, TR.objectid as LRSN, tr.id as 'TR Id',tr.begtaxyear, tr.effstatus, 
	t.descr as 'TIF Descr' from RevObjSCB_v r
	join tifrole tr on tr.objectid = r.ro_id
	join tif t on t.id = tr.tifid and t.begtaxyear = 
		(select max(t_sub.begtaxyear) from tif t_sub where t.id = t_sub.id)
where r.ro_pin like @find_pins

order by r.ro_pin, tr.id, tr.begtaxyear

