-- !preview conn=conn
/*
AsTxDBProd
GRM_Main
*/

--PM251

Declare @TaxYear int = 2022
--{?TaxYear} --parameter

 		 SELECT 
 				'New Construction' as GroupingName
			  ,	SUM(isnull(c.ValueAmount,0)) as 'Value'
			  , 'NEW CONSTRUCTION OWNER/OCCUPIED' as Indicator
		   FROM tsbv_Cadastre_ver0 c 
	 INNER JOIN ValueTypeAmount vta
			 ON vta.HeaderId = c.CadInvId
			AND vta.ValueTypeId = 305  --homeowners	   
	 INNER JOIN Codes_Table ct
			 ON ct.CodesToSystype = c.GroupCodeSysType
			AND ct.Tbl_Type_Code = 'impgroup'
			AND ct.Field_1 in ('R')  --includes residential cats
		  WHERE c.TaxYear = @TaxYear
			AND c.ValueType = 651 
			AND c.RollCaste = 16001
 
 UNION 
 
 		 SELECT 
 				'New Construction' as GroupingName
			  ,	SUM(isnull(c.ValueAmount,0)) as 'Value'
			  , 'NEW CONSTRUCTION NON/OWNER OCCUPIED' as Indicator
		   FROM tsbv_Cadastre_ver0 c 
   	 INNER JOIN Codes_Table ct
			 ON ct.CodesToSystype = c.GroupCodeSysType
			AND ct.Tbl_Type_Code = 'impgroup'
			AND ct.Field_1 in ('R')  --includes residential cats
LEFT OUTER JOIN ValueTypeAmount vta
			 ON vta.HeaderId = c.CadInvId
			AND vta.ValueTypeId = 305  --homeowners	   
		  WHERE c.TaxYear = @TaxYear
			AND c.ValueType = 651
			AND vta.HeaderId is null  
			AND c.RollCaste = 16001
 
 UNION 
 
 		 SELECT 
 				'New Construction' as GroupingName
			  ,	SUM(isnull(c.ValueAmount,0)) as 'Value'
			  , 'NEW CONSTRUCTION COMMERCIAL' as Indicator
		   FROM tsbv_Cadastre_ver0 c 
   	 INNER JOIN Codes_Table ct
			 ON ct.CodesToSystype = c.GroupCodeSysType
			AND ct.Tbl_Type_Code = 'impgroup'
			AND ct.Field_1 not in ('R')  --includes residential cats
		  WHERE c.TaxYear = @TaxYear
			AND c.ValueType = 651 
			AND c.RollCaste = 16001
       
 
  ORDER BY 1 

