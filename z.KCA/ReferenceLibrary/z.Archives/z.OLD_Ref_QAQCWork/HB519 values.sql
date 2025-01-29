
Notice the CadInvCtrlId and the CadValueCtrlId on the Balance spreadsheet tabs for each roll.

alter view KCv_B519_1a
as
select pm.lrsn, pm.pin, pm.ain, m.memo_id, ci.id as CadInvId,
sum(cv1.valueamount) as TaxableValue
--, sum(cv2.valueamount) as ExemptValue
 from memos m
join kcv_parcelmaster_short pm on pm.lrsn=m.lrsn
left outer join cadinv ci on ci.revobjid=m.lrsn and ci.cadinvctrlid=481
left outer join cadvalue cv1 on cv1.cadinvid=ci.id and cv1.cadvaluectrlid=740
	and cv1.valuetype in ('123','219','124','125','128','220','129','130')
--left outer join cadvalue cv2 on cv2.cadinvid=ci.id and cv2.cadvaluectrlid=740
--	and cv2.valuetype in ('135')
where m.memo_id='B519' and m.memo_line_number=1
group by pm.lrsn, pm.pin, pm.ain, m.memo_id, ci.id
--order by pm.pin

alter view KCv_B519_1b
as
select pm.lrsn, pm.pin, pm.ain, m.memo_id, ci.id as CadInvId,
--sum(cv1.valueamount) as TaxableValue,
sum(cv2.valueamount) as ExemptValue
 from memos m
join kcv_parcelmaster_short pm on pm.lrsn=m.lrsn
left outer join cadinv ci on ci.revobjid=m.lrsn and ci.cadinvctrlid=481
--left outer join cadvalue cv1 on cv1.cadinvid=ci.id and cv1.cadvaluectrlid=740
--	and cv1.valuetype in ('123','219','124','125','128','220','129','130')
left outer join cadvalue cv2 on cv2.cadinvid=ci.id and cv2.cadvaluectrlid=740
	and cv2.valuetype in ('135')
where m.memo_id='B519' and m.memo_line_number=1
group by pm.lrsn, pm.pin, pm.ain, m.memo_id, ci.id
--order by pm.pin

Change number highlighted in Yellow to the current CadInvCtrlID
Change number highlighted in Red to the current CadValueCtrlID

Then Execute the Alter (Click the Execute) in SQL windows after making the changes.

Then run the follow SQL:

select a.*, b.ExemptValue from KCv_B519_1a a
left outer join KCv_B519_1b b on a.lrsn=b.lrsn
order by a.pin







