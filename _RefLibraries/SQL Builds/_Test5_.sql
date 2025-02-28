


Select 
ps.lrsn
,TRIM(pm.AIN) AS AIN
FROM parcel_set AS ps
Join TSBv_PARCELMASTER AS pm
    On ps.lrsn = pm.lrsn
Where pm.EffStatus = 'A'
And set_id = 'Dustin1'