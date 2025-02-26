--File Name: CPCertCat1Thru5
--Despription: Value and acres spread for cat 1-5 for cur and prev years
--Author: Sandy Bowens
--Date created: 10/24/2017
--Last Modified: 05/01/2020

--    Modification History
--    sab 10/24/2017 WO17656 - 1.)List PIN, CAT, Acres and Value for 2016 and 2017 for comparison of categories 1,2,3,4,5. 
--    sab 05/01/2020 WO20226 - 1.)Report should on bring in annual values, not supplemental.


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.TSBsp_tsb_CPCertCat1Thru5') 
AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TSBsp_tsb_CPCertCat1Thru5
go

CREATE PROCEDURE dbo.TSBsp_tsb_CPCertCat1Thru5

(
  @p_TaxYear smallint
)

AS
  SET NOCOUNT ON
 
--set @p_TaxYear = 2017 
  
  
BEGIN
                                     
		With Temp_Current(LRSN,PIN,AIN,TAG,CurrStatus,CurrYear,CurrTotal,cat01c,Acres01c,				  
						  cat02c,Acres02c,cat03c,Acres03c,cat04c,Acres04c,cat05c,Acres05c
		                  )	
		                  
		As (                 
		                  
			SELECT DISTINCT
			c.LRSN,
			c.PIN,
			c.AIN,	
			c.Tag,							
			(select EffStatus from RevObj r where r.id = c.lrsn and r.BegEffDate = (select max(BegEffDate) from RevObj rsub where rsub.id = r.id)) as CurrStatus,
			CurrYear = @p_TaxYear,
			CurrTotal = 0,
			Cat01c = isnull((select ValueAmount from ValueTypeAmount where HeaderId = c.CadInvId and ValueTypeId = 470 and AddlObjectId = 1200300),0),
			Acres01c = isnull((select ValueAmount from ValueTypeAmount where HeaderId = c.CadInvId and ValueTypeId = 471 and AddlObjectId = 1200300),0),
			Cat02c = isnull((select ValueAmount from ValueTypeAmount where HeaderId = c.CadInvId and ValueTypeId = 470 and AddlObjectId = 1200301),0),
			Acres02c = isnull((select ValueAmount from ValueTypeAmount where HeaderId = c.CadInvId and ValueTypeId = 471 and AddlObjectId = 1200301),0),
			Cat03c = isnull((select ValueAmount from ValueTypeAmount where HeaderId = c.CadInvId and ValueTypeId = 470 and AddlObjectId = 1200302),0),
			Acres03c = isnull((select ValueAmount from ValueTypeAmount where HeaderId = c.CadInvId and ValueTypeId = 471 and AddlObjectId = 1200302),0),
			Cat04c = isnull((select ValueAmount from ValueTypeAmount where HeaderId = c.CadInvId and ValueTypeId = 470 and AddlObjectId = 1200303),0),
			Acres04c = isnull((select ValueAmount from ValueTypeAmount where HeaderId = c.CadInvId and ValueTypeId = 471 and AddlObjectId = 1200303),0),
			Cat05c = isnull((select ValueAmount from ValueTypeAmount where HeaderId = c.CadInvId and ValueTypeId = 470 and AddlObjectId = 1200304),0),
			Acres05c = isnull((select ValueAmount from ValueTypeAmount where HeaderId = c.CadInvId and ValueTypeId = 471 and AddlObjectId = 1200304),0)
			FROM tsbv_cadastre c
			WHERE c.TaxYear = @p_TaxYear
			AND c.ValueType = 112
			AND c.RollCaste = 16001
		)			
			
	,		
			Temp_Prior(LRSN,PriorYear,PriorTotal,cat01p,Acres01p,cat02p,Acres02p,
			           cat03p,Acres03p,cat04p,Acres04p,cat05p,Acres05p
		               )	
		                  
		As (                 
		                  
			SELECT DISTINCT
			p.LRSN as PriorLRSN,
			PriorYear = @p_TaxYear - 1,
			PriorTotal = 0,
			Cat01p = isnull((select ValueAmount from ValueTypeAmount where HeaderId = p.CadInvId and ValueTypeId = 470 and AddlObjectId = 1200300),0),
			Acres01p = isnull((select ValueAmount from ValueTypeAmount where HeaderId = p.CadInvId and ValueTypeId = 471 and AddlObjectId = 1200300),0),
			Cat02p = isnull((select ValueAmount from ValueTypeAmount where HeaderId = p.CadInvId and ValueTypeId = 470 and AddlObjectId = 1200301),0),
			Acres02p = isnull((select ValueAmount from ValueTypeAmount where HeaderId = p.CadInvId and ValueTypeId = 471 and AddlObjectId = 1200301),0),
			Cat03p = isnull((select ValueAmount from ValueTypeAmount where HeaderId = p.CadInvId and ValueTypeId = 470 and AddlObjectId = 1200302),0),
			Acres03p = isnull((select ValueAmount from ValueTypeAmount where HeaderId = p.CadInvId and ValueTypeId = 471 and AddlObjectId = 1200302),0),
			Cat04p = isnull((select ValueAmount from ValueTypeAmount where HeaderId = p.CadInvId and ValueTypeId = 470 and AddlObjectId = 1200303),0),
			Acres04p = isnull((select ValueAmount from ValueTypeAmount where HeaderId = p.CadInvId and ValueTypeId = 471 and AddlObjectId = 1200303),0),
			Cat05p = isnull((select ValueAmount from ValueTypeAmount where HeaderId = p.CadInvId and ValueTypeId = 470 and AddlObjectId = 1200304),0),
			Acres05p = isnull((select ValueAmount from ValueTypeAmount where HeaderId = p.CadInvId and ValueTypeId = 471 and AddlObjectId = 1200304),0)
			FROM tsbv_cadastre p
			WHERE p.TaxYear = @p_TaxYear - 1
			AND p.ValueType = 112
			AND p.RollCaste = 16001
		)					
			
				                  					  				    
		select *			
		from Temp_Current c
		inner join Temp_Prior p
		ON c.lrsn = p.lrsn
		order by 2
 

END










