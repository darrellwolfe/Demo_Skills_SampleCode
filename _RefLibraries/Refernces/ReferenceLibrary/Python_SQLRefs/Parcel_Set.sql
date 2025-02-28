

SELECT DISTINCT 
ps.lrsn,
TRIM(pm.AIN) AS AIN,
TRIM(pm.PIN) AS PIN,
TRIM(ps.set_id) AS set_id

FROM Parcel_set AS ps
JOIN TSBv_Parcelmaster AS pm
    ON ps.lrsn = pm.lrsn

WHERE ps.set_id = 'PLAT_HL890'




SELECT DISTINCT TRIM(pm.AIN) AS AIN,TRIM(ps.set_id) AS set_id FROM Parcel_set AS ps JOIN TSBv_Parcelmaster AS pm ON ps.lrsn = pm.lrsn WHERE ps.set_id = 'PLAT_HL890'