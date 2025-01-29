-- !preview conn=conn

SELECT DISTINCT
  tag.Descr AS TAG,
  ta.Descr AS Tax_Authorities

FROM TAG AS tag
  JOIN TAGTaxAuthority AS tta ON tag.Id = tta.TAGId
  JOIN TaxAuthority AS ta ON tta.TaxAuthorityId = ta.Id
  
WHERE tag.EffStatus = 'A'
  AND tta.EffStatus = 'A'
  AND ta.EffStatus = 'A'
/*
  AND (ta.Descr = '1-KOOTENAI CO'
        OR ta.Descr = '210-CITY POST FALLS'
        OR ta.Descr = '232-SCHOOL DIST #273-BOND'
        OR ta.Descr = '232-SCHOOL DIST #273-SUPP'
        OR ta.Descr = '232-SCHOOL DIST#273-OTHER'
        OR ta.Descr = '255 - KC FIRE AND RESCUE BOND'
        OR ta.Descr = '255-KC FIRE & RESCUE'
        OR ta.Descr = '271-COMM LIBRARY NET J' 
        OR ta.Descr = '351-N ID COLLEGE'
        OR ta.Descr = '354-KOOTENAI-EMS')  
*/

ORDER BY
  tag.Descr