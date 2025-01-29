select lrsn, pin, ain, displayname, displaydescr from kcv_parcelmaster_short where effstatus = 'A' 
	and (displaydescr like '%DELETED%' or displaydescr like '%Delete%' or displaydescr like '%delete%')
