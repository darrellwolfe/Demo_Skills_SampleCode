
-- !preview conn=conn




SELECT *
FROM memos AS m
---ON parcel.lrsn=m2.lrsn 

WHERE m.memo_id IN ('RY23','RY24','RY25','RY26','RY27' )
--AND m.memo_line_number = '2'
