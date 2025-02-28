
update transfer set mkt_post_flag = '' 
	 where mkt_post_flag = 'Y' and status = 'A' 
		and lrsn = '30382'
			and pxfer_date >= '01-01-2009'
