--CHANGE RPANNUALCADEXPORT NAME BEFORE RUNNING; SELECTS 05 ACRES FOR IDAHO RANGELAND RESOURCE COMMISSION
select pm.LRSN, pm.PIN, pm.AIN, c.valueamount as LDAcres, c.Owner,
pm.MailingAddress, pm.MailingCity, pm.MailingState, pm.MailingZip from kcv_rpannualcadexport18a c
join kcv_parcelmaster1c pm on pm.lrsn=c.revobjid
where c.valuetypeid=471 and c.addlobjectid=1200304 --and revobjid=546479
order by c.owner


