select pm.lrsn, t.ain, pm.pin, r.cost_value from deenawork_t t
join kcv_parcelmaster1 pm on pm.ain=t.ain
join reconciliation r on r.lrsn=pm.lrsn and r.status='W'
