select * from igroups where lrsn in (select lrsn  from parcel_base where neighborhood = 1998)

select * from neigh_control where neighborhood = 1998
update neigh_control set activate_date = 20080101 where neighborhood = 1998
update neigh_land set activate_date = 20080101 where neighborhood = 1998
update neigh_res_impr set activate_date = 20080101 where neighborhood = 1998
update neigh_com_impr set activate_date = 20080101 where neighborhood = 1998
