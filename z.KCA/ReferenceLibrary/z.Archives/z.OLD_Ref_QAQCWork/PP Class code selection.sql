select * from kcv_parcelmaster_pp where effstatus='A' 
and left(classcd,3) in ('020','021',
--'022',
'030'
--'031',
--'060',
--'070'
)
order by pin
--classcd
