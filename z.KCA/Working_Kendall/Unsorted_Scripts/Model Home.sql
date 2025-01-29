-- !preview conn=conn

SELECT
  p.pin,
  p.AIN,
  p.DisplayName,
  m.memo_line_number,
  m.memo_text

FROM TSBv_PARCELMASTER AS p
  JOIN memos AS m ON p.lrsn = m.lrsn
    AND m.status = 'A'
    AND m.memo_id = '6023'
    AND m.memo_text LIKE '%MODEL HOME%'
    
where p.EffStatus = 'A'