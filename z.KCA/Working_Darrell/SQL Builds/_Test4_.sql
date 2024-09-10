-- !preview conn=conn

/*
AsTxDBProd
GRM_Main
*/


Select *
FROM memos

WHERE status = 'A'
AND memo_id IN ('NOTE')
AND memo_line_number <> '1'