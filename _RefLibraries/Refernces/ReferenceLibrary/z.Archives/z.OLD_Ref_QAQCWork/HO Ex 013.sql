--EX013

--LIST PARCELS WHERE THE MODIFIER PERCENT IS GREATER THAN 100%
select Distinct 
  p.pin as 'PIN'
, p.DisplayName as 'Display Name'
, '1' as EditType
, 'HO Override ' + rtrim(cast(cast(rsm.ModifierPercent as int)as char))+ '% > 100%' as Issue
from tsbv_parcelmasterLimited p
inner join RevObjSiteModifier rsm
on rsm.RevObjSiteId = p.RevobjSiteId
and rsm.EffStatus = 'A'
and rsm.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rrsub where rrsub.id = rsm.id) 
--and rsm.modifierid = 7
and rsm.modifierPercent > 100
and rsm.ExpirationYear >= ltrim(str(datepart(year,getdate()))) 
inner join Modifier m
on m.id = rsm.modifierId
and m.ShortDescr in ('_HOEXCap')
and m.EffStatus = 'A'
and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id)
where p.EffStatus = 'A' --1 sec

union all

--LIST PARCELS WHERE IS AN ACTIVE LAND EXTENSION BUT NONE OF THEM HAVE A 'H'
select distinct 
  p.pin
, p.displayname
, '2' as EditType
, 'PIN has a HO and an active land record but no H cat'  as Issue 
from tsbv_parcelmasterLimited p
inner join RevObjSiteModifier rsm
on rsm.RevObjSiteId = p.RevobjSiteId
and rsm.EffStatus = 'A'
and rsm.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rrsub where rrsub.id = rsm.id) 
--and rsm.modifierid in (7,8,9)
and rsm.ExpirationYear >= ltrim(str(datepart(year,getdate()))) 
inner join Modifier m
on m.id = rsm.modifierId
and m.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
and m.EffStatus = 'A'
and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id)
where p.lrsn not in (select lrsn from allocations where group_code like '%H' and status = 'A') 
and p.effstatus = 'A'
and p.lrsn in (select lrsn from allocations where extension = 'L00' and status = 'A') 
and P.EffStatus = 'A' --2 sec

union all



--LIST PARCELS WHERE IS AN ACTIVE IMP EXTENSION BUT NONE OF THEM HAVE A 'H'
select distinct
   p.pin
 , p.displayname
 , '2' as EditType
 , case when i.lrsn is not null then 'PIN has a HO and an active imp record but no H cat'  
        when i.lrsn is null then 'PIN has a HO, is not related to another PIN, and does not have an active IMP' 
   else ''
   end as Issue 
from Modifier m
inner join RevObjSiteModifier rsm
on rsm.modifierid = m.id
and rsm.EffStatus = 'A'
and rsm.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rrsub where rrsub.id = rsm.id) 
--and rsm.modifierid in (7,8,9)
and rsm.ExpirationYear >= ltrim(str(datepart(year,getdate())))  
inner join tsbv_parcelmasterLimited p
on p.revobjsiteId = rsm.RevObjSiteId 
and p.lrsn not in (select lrsn 
					 from allocations a
					 where --extension like 'R0%' 
					 group_code like '%H' 
					 and a.[status] = 'A'
					 )
AND p.effstatus = 'A'
--AND p.lrsn in (select lrsn from allocations where extension between 'R01' and 'R37' and status = 'A')--4 sec 
LEFT OUTER JOIN Improvements i
ON i.lrsn = p.lrsn
AND i.[status] = 'A'
AND i.imp_type in ('DWELL','MHOME')
where m.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')

and m.EffStatus = 'A'
and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id)--4 sec 
and p.lrsn not in     (select revobj1id --primary's where the secondary has a ho and a dwelling
					   from RelRevObj rro
					   inner join tsbv_Modifiers m2
					   on m2.lrsn = rro.revobj2id
					   and m2.ModifierShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
					   and m2.PINStatus = 'A'
					   and m2.ModifierStatus = 'A'
					   inner join Improvements i2
					   ON i2.lrsn = rro.revobj2id
					   AND i2.[status] = 'A'
					   AND i2.imp_type in ('DWELL','MHOME')
					   where rro.BegEffDate = (select max(BegEffDate) from RelRevObj rrosub where rrosub.id = rro.id)
					   and rro.EffStatus = 'A'
					   )
and p.lrsn not in     (select revobj2id --primary's where the secondary has a ho and a dwelling
					   from RelRevObj rro
					   inner join tsbv_Modifiers m2
					   on m2.lrsn = rro.revobj1id
					   and m2.ModifierShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
					   and m2.PINStatus = 'A'
					   and m2.ModifierStatus = 'A'
					   inner join Improvements i2
					   ON i2.lrsn = rro.revobj1id
					   AND i2.[status] = 'A'
					   AND i2.imp_type in ('DWELL','MHOME')
					   where rro.BegEffDate = (select max(BegEffDate) from RelRevObj rrosub where rrosub.id = rro.id)
					   and rro.EffStatus = 'A'
					   )

union all

--LIST PARCELS WHERE PRIMARY PIN AND RELATED SECONDARY PIN HAVE A HO MODIFIER BUT NO HO IMP CAT ON EITHER ONE
select distinct 
p.pin
, p.displayname
, '3' as EditType
, 'PIN and Related PIN have HO, but no HO imp cat. RELATED PIN: ' + rtrim(r2.pin) as Issue 
from tsbv_parcelmasterLimited p
inner join RevObjSiteModifier rsm
on rsm.RevObjSiteId = p.RevobjSiteId
and rsm.EffStatus = 'A'
and rsm.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rrsub where rrsub.id = rsm.id) 
--and rsm.modifierid in (7,8,9)
and rsm.ExpirationYear >= ltrim(str(datepart(year,getdate()))) 
INNER JOIN Modifier m
on m.id = rsm.modifierId
and m.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
and m.EffStatus = 'A'
and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id)
INNER JOIN relrevobj rr
on rr.revobj1id = p.lrsn
and rr.effstatus = 'A'
and rr.begeffdate = (select max(begeffdate) from relrevobj rrsub where rrsub.id = rr.id)
INNER JOIN revobj r2
on r2.id = rr.revobj2id
and r2.BegEffDate = (select max(BegEffDate) from Revobj r2sub where r2sub.id = r2.id) 
where p.lrsn not in (select lrsn from allocations where status = 'A' and extension <> 'L00') 
and p.effstatus = 'A'
and r2.id not in (select lrsn from allocations where status = 'A' and extension <> 'L00') 
and  P.EffStatus = 'A' --2 sec

union all

--TOTAL ELIGIBLE ACRES ARE GREATER THAN 1.000
select  
p.pin
, p.displayname
, '4' as EditType
,'HO acres '+ rtrim(cast(sum(ld.ldacres)as char))  +'  > 1' + '  LandType: ' + LD.landtype + '   Method: ' + cast(LD.lcm as char) as 'Issue'
from tsbv_parcelmasterLimited p
inner join RevObjSiteModifier rsm
on rsm.RevObjSiteId = p.RevobjSiteId
and rsm.EffStatus = 'A'
and rsm.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rrsub where rrsub.id = rsm.id) 
--and rsm.modifierid in (7,8,9)
and rsm.ExpirationYear >= ltrim(str(datepart(year,getdate()))) 
INNER JOIN Modifier m
on m.id = rsm.modifierId
and m.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
and m.EffStatus = 'A'
and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id)
inner join LandHeader LH
on lh.revobjid = p.lrsn  
AND LH.EffStatus = 'A'
AND LH.PostingSource = 'A'                                                                 
inner join LandDetail LD
on LH.ID = LD.LandHeaderId
AND LD.EffStatus = 'A'
AND LD.postingsource = 'A'
AND LD.lcm in (select tbl_element from codes_table where tbl_type_code = 'lcmshortdesc' and tbl_element_desc not like '%SQFT%' and code_status = 'a')
where p.lrsn in (select LH.revobjid 
                        from LandHeader LH
                        inner join LandDetail LD
                        on LH.ID = LD.LandHeaderId
                        AND LD.EffStatus = 'A'
                        AND LD.postingsource = 'A'
                        inner join Allocations a
                        ON LH.RevObjID = a.lrsn
                        AND LD.LandLineNumber = a.land_line_number
                        AND a.Status = 'A'
                        AND a.extension like  'L00'
                        AND a.group_code like '%H'
                        where lh.revobjid = p.lrsn  
                        AND LH.EffStatus = 'A'
                        AND LH.PostingSource = 'A'
                        group by LH.revobjid, a.cost_alloc_pct, ld.ldAcres
                        having a.cost_alloc_pct * .000001 * ld.ldAcres > 1 )  
and  P.EffStatus='A'
group by p.pin, p.displayname, ld.landtype, ld.lcm  --2 sec

union all

--TOTAL ELIGIBLE SQUARE FEET ARE GREATER THAN 43,560
select  
p.pin
, p.displayname
, '5' as EditType
,'HO square feet  '+ rtrim(cast(sum(ld.sqrfeet)as char))  +'  > 43,560' + '  LandType: ' + LD.landtype + '   Method: ' + cast(LD.lcm as char) as 'Issue'
from tsbv_parcelmasterLimited p
inner join RevObjSiteModifier rsm
on rsm.RevObjSiteId = p.RevobjSiteId
and rsm.EffStatus = 'A'
and rsm.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rrsub where rrsub.id = rsm.id) 
--and rsm.modifierid in (7,8,9)
and rsm.ExpirationYear >= ltrim(str(datepart(year,getdate()))) 
INNER JOIN Modifier m
on m.id = rsm.modifierId
and m.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
and m.EffStatus = 'A'
and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id)
inner join LandHeader LH
on lh.revobjid = p.lrsn  
AND LH.EffStatus = 'A'
AND LH.PostingSource = 'A'                                                                 
inner join LandDetail LD
on LH.ID = LD.LandHeaderId
AND LD.EffStatus = 'A'
AND LD.postingsource = 'A'
AND LD.lcm in (select tbl_element from codes_table where tbl_type_code = 'lcmshortdesc' and tbl_element_desc like '%SQFT%' and code_status = 'a')
where p.lrsn in    (select LH.revobjid 
                    from LandHeader LH
                    inner join LandDetail LD
                    on LH.ID = LD.LandHeaderId
                    AND LD.EffStatus = 'A'
                    AND LD.postingsource = 'A'
                    inner join Allocations a
                    ON LH.RevObjID = a.lrsn
                    AND LD.LandLineNumber = a.land_line_number
                    AND a.Status = 'A'
                    AND a.extension like  'L00'
                    AND a.group_code like '%H'
                    where lh.revobjid = p.lrsn  
                    AND LH.EffStatus = 'A'
                    AND LH.PostingSource = 'A'
                    group by LH.revobjid, a.cost_alloc_pct, ld.sqrfeet
                    having a.cost_alloc_pct * .000001 * ld.sqrfeet > 43560 )  
and  P.EffStatus = 'A'
group by p.pin, p.displayname, ld.landtype, ld.lcm --2 sec

union all

--PRIMARY PIN HAS A HO BUT SECONDARY RELATED PIN DOES NOT HAVE A HO EXEMPTION
select distinct 
p1.pin
, p1.displayname
, '6' as EditType
, 'Related PIN does not have a HO: ' + rtrim(p2.pin) + '    TYPE: ' + s.shortDescr + '  RELATED OWNER: ' + rtrim(p2.displayname) 
from tsbv_parcelmasterLimited p1
inner join RevObjSiteModifier rsm
on rsm.RevObjSiteId = p1.RevobjSiteId
and rsm.EffStatus = 'A'
and rsm.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rrsub where rrsub.id = rsm.id) 
--and rsm.modifierid in (7,8,9)
and rsm.ExpirationYear >= ltrim(str(datepart(year,getdate())))
INNER JOIN Modifier m
on m.id = rsm.modifierId
and m.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
and m.EffStatus = 'A'
and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id) 
inner join relrevobj rr
on rr.revobj1id = p1.lrsn --first pin
and rr.begeffdate = (select max(begeffdate) from relrevobj rsub where rsub.id = rr.id)
and rr.effstatus = 'A'
and rr.revobj2id not in  (select ros.revobjid 
                          from RevObjSite ros
                          inner join RevObjSiteModifier rsm2
                          on rsm2.RevObjSiteId = ros.id
                          and rsm2.EffStatus = 'A'
                          and rsm2.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rr2sub where rr2sub.id = rsm2.id) 
                          --and rsm.modifierid in (7,8,9)
                          and rsm2.ExpirationYear >= ltrim(str(datepart(year,getdate()))) 
                          INNER JOIN Modifier m1
						  on m1.id = rsm2.modifierId
						  and m1.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
						  and m1.EffStatus = 'A'
						  and m1.BegTaxYear = (select max(BegTaxYear) from Modifier m1sub where m1sub.id = m1.id) 
                          where ros.EffStatus = 'A'
                          and ros.begeffdate = (select max(begeffdate) from RevObjSite rrsub where rrsub.id = ros.id)
                          )
inner join systype s
on s.id = rr.rrotype
and s.effStatus = 'A'
and s.begeffdate = (select max(begeffdate) from systype ssub where ssub.id = s.id)
and s.systypecatid = 7330
and s.shortDescr not in ('MHToLease', 'PersonalToParcel', 'PersonalToMH', 'InfoOnly','PersonalToPers')
inner join tsbv_parcelmasterLimited p2
on p2.lrsn = revobj2id
and p2.effStatus = 'A'
where p1.effstatus = 'A' --2 sec

union all 

--PRIMARY PIN HAS A HO BUT SECONDARY RELATED PIN DOES NOT HAVE A HO EXEMPTION
select distinct 
p2.pin
, p2.displayname
, '6' as EditType
, 'Related PIN does not have a HO: ' + rtrim(p1.pin) + '    TYPE: ' + s.shortDescr + '  RELATED OWNER: ' + rtrim(p1.displayname) 
from tsbv_parcelmasterLimited p2
inner join RevObjSiteModifier rsm
on rsm.RevObjSiteId = p2.RevobjSiteId
and rsm.EffStatus = 'A'
and rsm.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rrsub where rrsub.id = rsm.id) 
--and rsm.modifierid in (7,8,9)
and rsm.ExpirationYear >= ltrim(str(datepart(year,getdate()))) 
INNER JOIN Modifier m
on m.id = rsm.modifierId
and m.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
and m.EffStatus = 'A'
and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id) 
inner join relrevobj rr
on rr.revobj2id = p2.lrsn --first pin
and rr.begeffdate = (select max(begeffdate) from relrevobj rsub where rsub.id = rr.id)
and rr.effstatus = 'A'
and rr.revobj1id not in  (select ros.revobjid 
                          from RevObjSite ros
                          inner join RevObjSiteModifier rsm2
                          on rsm2.RevObjSiteId = ros.id
                          and rsm2.EffStatus = 'A'
                          and rsm2.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rr2sub where rr2sub.id = rsm2.id) 
                          --and rsm.modifierid in (7,8,9)
                          INNER JOIN Modifier m2
						  on m2.id = rsm2.modifierId
						  and m2.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
						  and m2.EffStatus = 'A'
						  and m2.BegTaxYear = (select max(BegTaxYear) from Modifier m2sub where m2sub.id = m2.id) 
                          and rsm2.ExpirationYear >= ltrim(str(datepart(year,getdate()))) 
                          where ros.EffStatus = 'A'
                          and ros.begeffdate = (select max(begeffdate) from RevObjSite rrsub where rrsub.id = ros.id)
                          )
inner join systype s
on s.id = rr.rrotype
and s.effStatus = 'A'
and s.begeffdate = (select max(begeffdate) from systype ssub where ssub.id = s.id)
and s.systypecatid = 7330
and s.shortDescr not in ('MHToLease', 'PersonalToParcel', 'PersonalToMH', 'InfoOnly','PersonalToPers')
inner join tsbv_parcelmasterLimited p1
on p1.lrsn = revobj1id
and p1.effStatus = 'A'
where p2.effstatus = 'A' --3 sec

union all

--PARCEL HAS MORE THAN ONE ACTIVE HO EXEMPTION
select 
p.pin
, p.displayname
, '7' as EditType
, 'PIN cannot have more than one active HO Exemption'
from Modifier m
inner join RevObjSiteModifier rsm
on rsm.ModifierId = m.id
and rsm.EffStatus = 'A'
and rsm.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rrsub where rrsub.id = rsm.id ) 
--and rsm.modifierid in (7,8,9)
and left(rsm.BegTaxYear,4) <= year(getdate())
and rsm.ExpirationYear >= ltrim(str(datepart(year,getdate()))) 
INNER JOIN tsbv_parcelmasterLimited p
on p.RevobjSiteId = rsm.RevObjSiteId
and P.EffStatus = 'A'
where m.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
and m.EffStatus = 'A'
and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id) 
group by p.pin, p.displayname
having count(p.pin) > 1 --3 sec

union all

--MANUAL OVERRIDE CAP IS GREATER THAN STANDARD HO CAP
select      
  p.pin
, p.DisplayName
, '8' as EditType
, 'NOTE:  HO Manual Cap Override ' + ltrim(str(rsv.ValueAmount)) + ' > Standard HO cap' 
from tsbv_parcelmasterLimited p
INNER JOIN RevObjSiteModifier rsm
on rsm.RevObjSiteId = p.RevobjSiteId
and rsm.EffStatus = 'A'
and rsm.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rrsub where rrsub.id = rsm.id) 
--and rsm.modifierid in (9)
and rsm.ExpirationYear >= ltrim(str(datepart(year,getdate()))) 
INNER JOIN Modifier m
on m.id = rsm.modifierId
and m.ShortDescr in ('_HOEXCapManual')
and m.EffStatus = 'A'
and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id) 
INNER JOIN RevObjSiteModifierValue rsv
on rsv.RevObjSiteModifierId = rsm.id
and rsv.ValueTypeId = 303
and rsv.EffStatus = 'A'
and rsv.begTaxYear = (select max(begTaxYear) from RevObjSiteModifierValue rrsub where rrsub.id = rsv.id) 
and  P.EffStatus='A'
group by p.pin, p.DisplayName, rsv.ValueAmount
having rsv.ValueAmount > (select mo.ValueAmount 
						  from modifierOutput mo
						  INNER JOIN Modifier m2
						  on m2.id = mo.modifierId
						  and m2.ShortDescr in ('_HOEXCap')
						  and m2.EffStatus = 'A'
						  and m2.BegTaxYear = (select max(BegTaxYear) from Modifier m2sub where m2sub.id = m2.id) 
						  where --ModifierId = 7 and 
						  left(mo.BegTaxYear,4) = ltrim(str(datepart(year,getdate()))) ) --1 sec

union all

--PARCEL HAS EFFECTIVE YEAR > APPLY DATE
select 
  m.pin
, m.displayname
, '9' as EditType
, 'PIN has an EffectiveYear > ApplyDate. See Edit Checklist to Fix.'
from tsbv_Modifiers m
where m.ModifierStatus = 'A'
and m.PinStatus = 'A'
and m.begTaxYear > year(m.ApplicationDate)
and m.ModifierShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
and m.ExpirationYear >= year(getdate()) 
and m.BegTaxYear > year(getdate())--4 sec 

union all

--PARCEL HAS A HOMEOWNERS AND ALSO HAS A 'PERSONAL TO PERSONAL' RELATIONSHIP TO ANOTHER PARCEL
select distinct 
  p.pin
, p.displayname
, '10' as EditType
, 'Pin has a homeowners exemption AND a "Personal to Personal" relationship to another parcel; change relationship type' 
from tsbv_parcelmasterLimited p
inner join RevObjSiteModifier rsm
on rsm.RevObjSiteId = p.RevobjSiteId
and rsm.EffStatus = 'A'
and rsm.begTaxYear = (select max(begTaxYear) from RevObjSiteModifier rrsub where rrsub.id = rsm.id) 
--and rsm.modifierid in (7,8,9)
and rsm.ExpirationYear >= ltrim(str(datepart(year,getdate()))) 
INNER JOIN Modifier m
on m.id = rsm.modifierId
and m.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
and m.EffStatus = 'A'
and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id) 
inner join relrevobj rr
on rr.revobj1id = p.lrsn --first pin
and rr.begeffdate = (select max(begeffdate) from relrevobj rsub where rsub.id = rr.id)
and rr.effstatus = 'A'
inner join systype s
on s.id = rr.rrotype
and s.effStatus = 'A'
and s.begeffdate = (select max(begeffdate) from systype ssub where ssub.id = s.id)
and s.systypecatid = 7330
and s.shortDescr in ('PersonalToPers')
where p.effstatus = 'A'--1 sec

order by 1,3  


