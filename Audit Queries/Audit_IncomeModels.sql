/*
AsTxDBProd
GRM_Main

SQL from Tony Magnelli to check for income models
Tony: I can send you a query I made for Spokane that helps you identify income parcels and their current costing details if you like.  
They use it to build input files for batch pricing income parcels by income year.

*/


select distinct
p.lrsn
,p.parcel_id
,p.property_class
,c.tbl_element_desc as 'pccdescr'
,mc.mkt_area
,mc.mkt_area_name
,ms.submkt_area
,ms.submkt_area_name
,p.neighborhood
,nc.neigh_name
, 'currentvaluemethod' = --RECONCILIATION METHOD UTILIZED
				CASE WHEN r.method = 'M' THEN 'Market Model'
					 WHEN r.method = 'S' THEN 'Comparable Sales'
					 WHEN r.method = 'I' THEN 'Income Approach'
					 WHEN r.method = 'T' THEN 'Trended'
					 WHEN r.method = 'R' THEN 'User Override'
					 WHEN r.method = 'O' THEN 'Override'
					 WHEN r.method = 'A' THEN 'Calculation Model'
					 WHEN r.method = 'B' THEN 'Spatial'
					 WHEN r.method = 'G' THEN 'Regression (MRA)'
					 WHEN r.method = 'F' THEN 'Feedback'
					 WHEN r.method = 'P' THEN 'Personal Property'
					 WHEN r.method = 'C' THEN 'Cost Models' 
					 ELSE '' 
					 END

,'datepriced' = --DATE RECONCILIATION IMPROVEMENT RECORD WAS PRICED	 
				CASE WHEN r.method = 'M' THEN CASE WHEN r.market_price_date = 0		THEN 0 ELSE CONVERT(Varchar,r.market_price_date)		 END
					 WHEN r.method = 'S' THEN CASE WHEN r.comp_price_date = 0		THEN 0 ELSE CONVERT(Varchar,r.comp_price_date)			 END
					 WHEN r.method = 'I' THEN CASE WHEN r.income_price_date = 0		THEN 0 ELSE CONVERT(Varchar,r.income_price_date)		 END
					 WHEN r.method = 'T' THEN CASE WHEN r.trend_price_date = 0		THEN 0 ELSE CONVERT(Varchar,r.trend_price_date)			 END
					 WHEN r.method = 'R' THEN CASE WHEN r.recon_price_date = 0		THEN 0 ELSE CONVERT(Varchar,r.recon_price_date)			 END
					 WHEN r.method = 'O' THEN CASE WHEN r.recon_price_date = 0		THEN 0 ELSE CONVERT(Varchar,r.recon_price_date)			 END
					 WHEN r.method = 'A' THEN CASE WHEN r.recon_price_date = 0		THEN 0 ELSE CONVERT(Varchar,r.recon_price_date)			 END
					 WHEN r.method = 'B' THEN CASE WHEN r.spatial_price_date = 0	THEN 0 ELSE CONVERT(Varchar,r.spatial_price_date)		 END
					 WHEN r.method = 'G' THEN CASE WHEN r.regression_price_date = 0 THEN 0 ELSE CONVERT(Varchar,r.regression_price_date)	 END
					 WHEN r.method = 'F' THEN CASE WHEN r.feedback_price_date = 0	THEN 0 ELSE CONVERT(Varchar,r.feedback_price_date)		 END
					 WHEN r.method = 'P' THEN CASE WHEN r.recon_price_date = 0		THEN 0 ELSE CONVERT(Varchar,r.recon_price_date)			 END
					 WHEN r.method = 'C' THEN CASE WHEN r.cost_price_date = 0		THEN 0 ELSE CONVERT(Varchar,r.cost_price_date)			 END 
					 ELSE '' 
					 END
,UserID = e.UserId
,'Imp_Model_Used'=				--IMPROVEMENT MODEL UTILIZED
				CASE WHEN r.method = 'M' THEN r.market_model
					 WHEN r.method = 'S' THEN r.comp_model
					 WHEN r.method = 'I' THEN r.income_model
					 WHEN r.method = 'T' THEN r.trend_model
					 WHEN r.method = 'R' THEN 0
					 WHEN r.method = 'O' THEN 0
					 WHEN r.method = 'A' THEN 0
					 WHEN r.method = 'B' THEN r.spatial_model 
					 WHEN r.method = 'G' THEN r.regression_model
					 WHEN r.method = 'F' THEN r.feedback_model
					 WHEN r.method = 'P' THEN 0
					 WHEN r.method = 'C' THEN r.cost_model 
					 ELSE 0  
					 END 
					
,i.income_year
,'Land_Value' =				--RECONCILIATION LAND VALUE	 
				CASE WHEN r.method = 'M' THEN r.land_mkt_val_mkt
					 WHEN r.method = 'S' THEN r.land_mkt_val_comp
					 WHEN r.method = 'I' THEN r.land_mkt_val_inc
					 WHEN r.method = 'T' THEN r.land_mkt_val_trend
					 WHEN r.method = 'R' THEN r.land_mkt_val_ov
					 WHEN r.method = 'O' THEN r.land_mkt_val_ov
					 WHEN r.method = 'A' THEN r.land_mkt_val_ov
					 WHEN r.method = 'B' THEN r.land_mkt_val_sptl
					 WHEN r.method = 'G' THEN r.land_mkt_val_regression
					 WHEN r.method = 'F' THEN r.land_mkt_val_feedback
					 WHEN r.method = 'P' THEN 0
					 WHEN r.method = 'C' THEN r.land_mkt_val_cost ELSE 0 END 


				--RECONCILIATION IMPROVEMENT VALUE
,'Imp_Value'=	CASE WHEN r.method = 'M' THEN r.market_value - r.land_mkt_val_mkt
					 WHEN r.method = 'S' THEN r.comp_value - r.land_mkt_val_comp
					 WHEN r.method = 'I' THEN r.income_value - r.land_mkt_val_inc
					 WHEN r.method = 'T' THEN r.trend_value - r.land_mkt_val_trend
					 WHEN r.method = 'R' THEN r.recon_value - r.land_mkt_val_ov
					 WHEN r.method = 'O' THEN r.recon_value - r.land_mkt_val_ov
					 WHEN r.method = 'A' THEN r.recon_value - r.land_mkt_val_ov
					 WHEN r.method = 'B' THEN r.spatial_value - r.land_mkt_val_sptl
					 WHEN r.method = 'G' THEN r.regression_value - r.land_mkt_val_regression
					 WHEN r.method = 'F' THEN r.feedback_value - r.land_mkt_val_feedback
					 WHEN r.method = 'P' THEN r.recon_value
					 WHEN r.method = 'C' THEN r.cost_value ELSE 0 END 


,'Total_Value'=				--RECONCILIATION TOTAL VALUE
				CASE WHEN r.method = 'M' THEN r.market_value
					 WHEN r.method = 'S' THEN r.comp_value
					 WHEN r.method = 'I' THEN r.income_value
					 WHEN r.method = 'T' THEN r.trend_value
					 WHEN r.method = 'R' THEN r.recon_value 
					 WHEN r.method = 'O' THEN r.recon_value
					 WHEN r.method = 'A' THEN r.recon_value
					 WHEN r.method = 'B' THEN r.spatial_value 
					 WHEN r.method = 'G' THEN r.regression_value
					 WHEN r.method = 'F' THEN r.feedback_value
					 WHEN r.method = 'P' THEN r.recon_value
					 WHEN r.method = 'C' THEN r.cost_value + r.land_mkt_val_cost ELSE 0 END 


from igroups i 
inner join parcel_base p
	on p.lrsn = i.lrsn
	and i.income_year = (select max(income_year) from igroups isub
				 where isub.lrsn = i.lrsn 
				 and i.status = 'a'
				 )

inner join reconciliation r
	on r.lrsn = i.lrsn 
	and r.status = 'w'

inner join extensions e
on e.lrsn = p.lrsn 

inner join codes_table c
	on c.CodesToSysType = p.property_class
	and c.tbl_type_code = 'PCC'
	and c.code_status = 'a'

inner join neigh_control nc
	on nc.neighborhood = p.neighborhood
	and nc.inactivate_date = 99991231

inner join MktSubAreaCtrl ms
	on ms.submkt_area = nc.SubMktArea
	and ms.inactivate_date = 99991231

inner join MktAreaCtrl mc
	on mc.mkt_area = ms.mkt_area
	and mc.inactivate_date = 99991231
where
p.status = 'a' and
i.status = 'a' and 
e.status = 'a'
--and p.property_class >= 403 and p.property_class <= 421  
--and i.lrsn = 273912
--select * from igroups where lrsn = 273912
--select * from income_computation where lrsn = 273912
--select * from reconciliation where lrsn = 273912 and status = 'w'










