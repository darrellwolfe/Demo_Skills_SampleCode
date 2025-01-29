SELECT Distinct pm.LRSN, pm.PIN, pm.AIN, pm.NEIGHBORHOOD, m.memo_id, a.group_code
FROM TSBV_PARCELMASTER AS pm
LEFT JOIN memos AS m ON pm.LRSN = m.LRSN
Left Join allocations as a on pm.lrsn = a.lrsn
Where m.memo_id = 'NC22' AND a.group_code = '81' AND a.status = 'A'
