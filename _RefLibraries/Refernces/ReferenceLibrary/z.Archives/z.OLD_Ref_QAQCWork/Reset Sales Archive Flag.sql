update transfer set mkt_post_flag = '' 
	where mkt_post_flag = 'Y' and status = 'A' 
		and pxfer_date >= '01-01-2009'

