--PM255

Declare @TaxYear int = {?TaxYear}

	--NEW CONSTRUCTION CURRENT YEAR VALUES	
	SELECT DISTINCT
	        m.lrsn
		  ,	p.pin
		  , p.EffStatus 
		  , m.Memo_Id as Memo
		  , s.ShortDescr as 'Group Code'
		  , 1 as GroupCodeYear  
		  , 0 as PriorTotalValue
		  , 0 as PriorExemption
		  , 0 as PriorNet	 		
		  , vta.valueamount  as 'Total Value'	
		  , isnull(vta2.valueamount,0) as 'Homeowners Exemption'	
		  , vta.valueamount - isnull(vta2.valueamount,0) as 'Net'	  	  
		  , isnull(vta1.ValueAmount,0) as 'New Const/Change of Use'
		  , cast(cr.AssessmentYear as char(4)) as AssessmentYear
		  , left(Memo_Id,2) as Indicator
		  , case when tr.id is not null then 1
		    else 0 end as Tif
		  , case when vta1.ValueAmount <> vta1.CalculatedAmount then 1
		    else 0 end as ValOverride 
		  , 0 as PriorCatCount  
		  , (select count(ObjectId) from ValueTypeAmount vta1
			 where vta1.ObjectId = vta.ObjectId
			 and vta1.HeaderId = vta.HeaderId
			 and vta1.ValueTypeId = vta.ValueTypeId			 
			 and vta1.AddlObjectId in (select CodesToSysType from Codes_Table where tbl_type_code = 'impgroup' and field_2 = '2-Imp')
			 ) as CurrentCatCount	
		  , case when vta.valueamount - isnull(vta2.valueamount,0) < isnull(vta1.ValueAmount,0) then 'Net < NC Value'
		    else ''
		    end as Issue	 	
      FROM Memos m
INNER JOIN tsbv_parcelMasterLimited p
        ON p.lrsn = m.lrsn
LEFT OUTER JOIN CadInv ci
	    ON ci.RevObjId = p.lrsn 
       AND ci.RollCaste = 16001	    
	   AND year(ci.InvEffDate) = @TaxYear 
	   AND ci.EffStatus = 'A'
LEFT OUTER JOIN ValueTypeAmount vta --assessed by group code
        ON vta.HeaderId = ci.id
       AND vta.ValueTypeId = 470  
LEFT OUTER JOIN ValueTypeAmount vta1 --new construction by group code
        ON vta1.HeaderId = ci.id
       AND vta1.ValueTypeId in (651) 
       AND vta1.AddlObjectId = vta.AddlObjectId
LEFT OUTER JOIN ValueTypeAmount vta2 --hoex by group code
        ON vta2.HeaderId = ci.id
       AND vta2.ValueTypeId = 472  
       AND vta2.AddlObjectId = vta.AddlObjectId      
LEFT OUTER JOIN CadLevel cl
        ON cl.id = ci.CadLevelId
LEFT OUTER JOIN CadRoll cr
        ON cr.id = cl.CadRollId 
       AND cr.AssessmentYear = @TaxYear
LEFT OUTER JOIN systype s
        ON s.id = vta.AddlObjectId
       AND s.systypecatid = 10340
       AND s.BegEffDate = (select max(BegEffDate) from systype ssub where ssub.id = s.id)
       AND s.EffStatus = 'A'  
LEFT OUTER JOIN tifRole tr
        ON tr.objectid = m.lrsn
       AND tr.BegEffDate = (select max(BegEffDate) from TifRole trsub where trsub.id = tr.id) 
       AND tr.EffStatus = 'A'                 
     WHERE (m.memo_id = 'NC' + right(cast(@TaxYear as char(4)),2)  )
       AND m.Status = 'A'
       AND vta.AddlObjectId in (select CodesToSysType from Codes_Table where tbl_type_code = 'impgroup' and field_2 = '2-Imp')
	   AND m.Memo_Line_Number = (select max(memo_Line_Number) from Memos msub where msub.lrsn = m.lrsn and msub.memo_id = m.memo_id)
	   --AND P.PIN = 'RP08S24E0100B2'

UNION

--NEW CONSTRUCTION PRIOR YEAR VALUES
	SELECT DISTINCT
	        m.lrsn
		  ,	p.pin
		  , p.EffStatus 
		  , m.Memo_Id as Memo
		  , c.FullGroupCode as 'Group Code'
		  , 2 as GroupCodeYear       
          , c.valueamount as PriorTotalValue
		  , isnull(vta2.valueamount,0) as PriorExemption
		  , c.valueamount - isnull(vta2.valueamount,0) as PriorNet	 		  
		  , 0 as 'Total Value'
		  , 0 as 'Homeowners Exemption'	
		  , 0 as 'Net'	  	  
		  , 0 as 'New Const/Change of Use'
		  , cast(@TaxYear as char(4)) as AssessmentYear
		  , left(Memo_Id,2)  as Indicator
		  , case when tr.id is not null then 1
		    else 0 end as Tif
		  , 0 as ValOverride 
		  , 0 as PriorCatCount
		  , 0 as CurrentCatCount	
		  , '' as Issue	 		  			  
      FROM Memos m
INNER JOIN tsbv_parcelMasterLimited p
        ON p.lrsn = m.lrsn
INNER JOIN tsbv_Cadastre c
		ON c.lrsn = m.lrsn
	   AND c.TaxYear = @TaxYear -1	
       AND c.RollCaste = 16001	    
       AND c.ValueType = 470 --assessed by group code 
LEFT OUTER JOIN ValueTypeAmount vta2 --hoex by group code
        ON vta2.HeaderId = c.cadinvid
       AND vta2.ValueTypeId = 472  
       AND vta2.AddlObjectId = c.GroupCodeSysType 
LEFT OUTER JOIN tifRole tr
        ON tr.objectid = m.lrsn
       AND tr.BegEffDate = (select max(BegEffDate) from TifRole trsub where trsub.id = tr.id) 
       AND tr.EffStatus = 'A'                 
     WHERE (m.memo_id = 'NC' + right(cast(@TaxYear as char(4)),2) )
       AND m.Status = 'A'
       AND c.GroupCodeSysType in (select CodesToSysType from Codes_Table where tbl_type_code = 'impgroup' and field_2 = '2-Imp')
	   AND m.Memo_Line_Number = (select max(memo_Line_Number) from Memos msub where msub.lrsn = m.lrsn and msub.memo_id = m.memo_id)
	   --AND P.PIN = 'RP08S24E0100B2'
	   
ORDER BY 2,1
