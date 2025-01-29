-- !preview conn=con

SELECT 
  p.pin,
  p.ain,
  p.neighborhood,
  m.memo_text

FROM TSBv_PARCELMASTER AS p
  JOIN memos AS m ON p.lrsn = m.lrsn
  
WHERE m.memo_id = '602W'
  AND m.memo_line_number = '2'
  AND p.EffStatus = 'A'
  
ORDER BY p.neighborhood ASC