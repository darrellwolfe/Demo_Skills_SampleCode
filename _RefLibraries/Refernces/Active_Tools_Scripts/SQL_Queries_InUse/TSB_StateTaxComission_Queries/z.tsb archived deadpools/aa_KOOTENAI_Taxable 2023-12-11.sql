

/* aa_KOOTENAI_Taxable step  */



--sab 07/24/2023 WO22007  1.) Populate ATR Additional Tax Relief Credit for all six types.
--                        2.) Copy vt455 into vt355 for ATR Credit Value.
--                        3.) Copy vt456 into vt356 for ATR Credit Value.
--                        4.) Copy vt457 into vt357 for ATR Credit Value.
--                        5.) Copy vt458 into vt358 for ATR Credit Value.
--                        6.) Copy vt459 into vt359 for ATR Credit Value.
--                        7.) Copy vt460 into vt360 for ATR Credit Value.
--sab 12/07/2023 WO22254  1.) Modify to accomodate ATR in Supplemental Roll


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE  NAME = 'aa_KOOTENAI_taxable') --WO22007 sab 07/24/2023
	DROP PROCEDURE [dbo].[aa_KOOTENAI_taxable]
GO    

/****** Object:  StoredProcedure [dbo].[aa_kootenai_taxable]    Script Date: 7/24/2023 6:28:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--03/20/2023 XTR MWD - staging for release

CREATE PROCEDURE [dbo].[aa_kootenai_taxable]  
 @p_HeaderType               INT  
 , @p_HeaderId                 INT  
 , @p_ProcessStepTrackingId    INT  
 , @p_BegObjectId              INT  
 , @p_EndObjectId              INT  
 , @p_DebugMode                SMALLINT  
AS  
BEGIN  
  
--version date 12-15-2015  
-- MWD 20230209
--03/20/2023 XTR MWD - staging for release
  
 SET NOCOUNT ON  
  
 DECLARE @v_HeaderType               INT; SELECT @v_HeaderType = @p_HeaderType  
 DECLARE @v_HeaderId                 INT; SELECT @v_HeaderId = @p_HeaderId  
 DECLARE @v_ProcessStepTrackingId    INT; SELECT @v_ProcessStepTrackingId = @p_ProcessStepTrackingId  
 DECLARE @v_BegObjectId              INT; SELECT @v_BegObjectId = @p_BegObjectId  
 DECLARE @v_EndObjectId              INT; SELECT @v_EndObjectId = @p_EndObjectId  
 DECLARE @v_DebugMode           SMALLINT; SELECT @v_DebugMode = @p_DebugMode  
  
 --DECLARE @v_HeaderType               INT; SELECT @v_HeaderType = 100156  
 --DECLARE @v_HeaderId                 INT; SELECT @v_HeaderId = 265  
 --DECLARE @v_ProcessStepTrackingId    INT; SELECT @v_ProcessStepTrackingId = 53  
 --DECLARE @v_BegObjectId              INT; SELECT @v_BegObjectId = 0  
 --DECLARE @v_EndObjectId              INT; SELECT @v_EndObjectId = 99999999  
 --DECLARE @v_DebugMode           SMALLINT; SELECT @v_DebugMode = 0  
  
  
 CREATE TABLE #results  
 (  
  ObjectId                INT  
  , ValueTypeId           INT  
  , HeaderId              INT  
  , AddlObjectId          INT  
  , SecondaryAddlObjectId INT  
  , ValueAmount           DECIMAL(28,10)  
 )   
 CREATE CLUSTERED INDEX #results1 ON #results( ValueTypeId )  
  
 CREATE TABLE #log_results  
 (     
  SourceObjectType        INT   
  , SourceObjectId        INT  
  , LogMessage            VARCHAR(256)  
  , IsError               SMALLINT  
 )   
  
 CREATE TABLE #work (  
   id int  not null  
  ,ObjectId int  
  ,ValueTypeId int  
  ,HeaderId int    
  ,AddlObjectId int  
  ,SecondaryAddlObjectId int  
  ,ValueAmount decimal(28,10)  
  ,flag char(9) null  
  ,ValueAmount2 decimal (28,10) null default 0  
  ,ValueAmount3 decimal (28,10) null default 0  
 )  
 CREATE CLUSTERED INDEX #work1 ON #work( HeaderId )  
   
 CREATE TABLE #TempValueTypeAmount   
 (      
  [Id] [int] NOT NULL,      
  [ObjectId] [int] NOT NULL,      
  [ValueTypeId] [int] NOT NULL,      
  [HeaderType] [int] NOT NULL,      
  [HeaderId] [int] NOT NULL,      
  [AddlObjectId] [int] NOT NULL,      
  [SecondaryAddlObjectId] [int] NOT NULL,      
  [ValueAmount] [decimal](28, 10) NOT NULL,      
  [CalculatedAmount] [decimal](28, 10) NOT NULL,      
  [ProcessStepTrackingId] [int] NOT NULL  
 )      
 CREATE TABLE #workSuppProratedTotalImpOnly (  
   ObjectId int  
  ,ValueTypeId int  
  ,HeaderId int    
  ,AddlObjectId int  
  ,SecondaryAddlObjectId int  
  ,ValueAmount decimal(28,10)  
 )  
  
 CREATE TABLE #workSuppProratedByCat (  
   ObjectId int  
  ,ValueTypeId int  
  ,HeaderId int    
  ,AddlObjectId int  
  ,SecondaryAddlObjectId int  
  ,ValueAmount decimal(28,10)  
 )   
   
 --ASSESSED VALUE BY CAT WORK TABLE  
 CREATE TABLE #WorkAnnualNet (  
   id int  not null  
  ,ObjectId int  
  ,ValueTypeId int  
  ,HeaderId int    
  ,AddlObjectId int  
  ,SecondaryAddlObjectId int  
  ,ValueAmount decimal(28,10)  
  ,flag char(10) null  
 )   

--ASSESSED VALUE BY CAT WORK TABLE  --sab WO22254 12/04/2023
CREATE TABLE #WorkAnnualATR  (
		id int  not null
	,ObjectId int
	,ValueTypeId int
	,HeaderId int		
	,AddlObjectId int
	,SecondaryAddlObjectId int
	,ValueAmount decimal(28,10)
	,flag char(10) null
)	


 BEGIN TRY  
  --Cadastre Sys Types  
  
  DECLARE @stCadLevel INT; EXEC aa_GetSysTypeId 'Object Type', 'CadLevel',@stCadLevel OUTPUT  
  DECLARE @stCadInv   INT; EXEC aa_GetSysTypeId 'Object Type', 'CadInv',  @stCadInv   OUTPUT  
  
  
  --Value Codes (group codes)  
  
  DECLARE @vc01					INT; EXEC aa_GetSysTypeId	'ValCd', '01',			@vc01				OUTPUT --01 Irr Ag  
  DECLARE @vc02					INT; EXEC aa_GetSysTypeId	'ValCd', '02',			@vc02				OUTPUT --02 Irr pasture  
  DECLARE @vc03					INT; EXEC aa_GetSysTypeId	'ValCd', '03',			@vc03				OUTPUT --03 Non-irr Ag  
  DECLARE @vc04					INT; EXEC aa_GetSysTypeId	'ValCd', '04',			@vc04				OUTPUT --04 Meadow  
  DECLARE @vc05					INT; EXEC aa_GetSysTypeId	'ValCd', '05',			@vc05				OUTPUT --05 Dry grazing  
  DECLARE @vc06					INT; EXEC aa_GetSysTypeId	'ValCd', '06',			@vc06				OUTPUT --06 Prod forest  
  DECLARE @vc07					INT; EXEC aa_GetSysTypeId	'ValCd', '07',			@vc07				OUTPUT --07 Bare forest  
  DECLARE @vc26H				INT; EXEC aa_GetSysTypeId	'ValCd', '26H',			@vc26H				OUTPUT --26H Condo/twnhse For HO  
  DECLARE @vc31H				INT; EXEC aa_GetSysTypeId	'ValCd', '31H',			@vc31H				OUTPUT --31H Res imp on 10 for HO  
  DECLARE @vc34H				INT; EXEC aa_GetSysTypeId	'ValCd', '34H',			@vc34H				OUTPUT --34H Res imp on 12 for HO  
  DECLARE @vc37H				INT; EXEC aa_GetSysTypeId	'ValCd', '37H',			@vc37H				OUTPUT --37H Res imp on 15 for HO  
  DECLARE @vc41H				INT; EXEC aa_GetSysTypeId	'ValCd', '41H',			@vc41H				OUTPUT --41H Res imp on 20 for HO  
  DECLARE @vc46H				INT; EXEC aa_GetSysTypeId	'ValCd', '46H',			@vc46H				OUTPUT --46H Mfg housing For HO  
  DECLARE @vc47H				INT; EXEC aa_GetSysTypeId	'ValCd', '47H',			@vc47H				OUTPUT --47H Impr to mfg housing for HO  
  DECLARE @vc48H				INT; EXEC aa_GetSysTypeId	'ValCd', '48H',			@vc48H				OUTPUT --48H Mfg House on Real Prop HO  
  DECLARE @vc49H				INT; EXEC aa_GetSysTypeId	'ValCd', '49H',			@vc49H				OUTPUT --49H Manufactured Housing for HO  
  DECLARE @vc50H				INT; EXEC aa_GetSysTypeId	'ValCd', '50H',			@vc50H				OUTPUT --50H Res imp on Leased Land for HO  
  DECLARE @vc55H				INT; EXEC aa_GetSysTypeId	'ValCd', '55H',			@vc55H				OUTPUT --55H AIRPLANES/BOATS for HO  
  --DECLARE @vc57				INT; EXEC aa_GetSysTypeId	'ValCd', '57',			@vc57				OUTPUT --57 Equities Imp in State Land  
  DECLARE @vc57H				INT; EXEC aa_GetSysTypeId	'ValCd', '57H',			@vc57H				OUTPUT --57H Equities Imp in State Land HO  
  DECLARE @vc65H				INT; EXEC aa_GetSysTypeId	'ValCd', '65H',			@vc65H				OUTPUT --65H Mfg housing pers for HO  
  DECLARE @vc67P				INT; EXEC aa_GetSysTypeId	'ValCd', '67P',			@vc67P				OUTPUT --67P Operating Property by STC  
  DECLARE @vc69H				INT; EXEC aa_GetSysTypeId	'ValCd', '69H',			@vc69H				OUTPUT --69H Recreational Vehicles for HO  
  DECLARE @vc81					INT; EXEC aa_GetSysTypeId	'ValCd', '81',			@vc81				OUTPUT --81 Exempt Improvements  
  
  -- input Value Type  
  
  DECLARE @vtTotalValue			INT; EXEC aa_GetValueTypeId 'Total Value',			@vtTotalValue		OUTPUT --vt112 Total Value  
  DECLARE @vtIA					INT; EXEC aa_GetValueTypeId 'Imp Assessed',			@vtIA				OUTPUT --vt103 Improvement Assessed Value  
  DECLARE @vtHOEX_ByCat			INT; EXEC aa_GetValueTypeId 'HOEX_ByCat',			@vtHOEX_ByCat		OUTPUT --vt472 Homeowner Exemption By Cat  
  DECLARE @vtTotalExemptions	INT; EXEC aa_GetValueTypeId 'Total Exemptions',		@vtTotalExemptions	OUTPUT --vt320 Total Exemptions  
  DECLARE @vtAssessedByCat		INT; EXEC aa_GetValueTypeId 'AssessedByCat',		@vtAssessedByCat	OUTPUT --vt470 AssessedByCat  
  
  DECLARE @vtGovernmentByCat	INT; EXEC aa_GetValueTypeId 'GovernmentByCat',		@vtGovernmentByCat	OUTPUT --vt431  
  DECLARE @vtReligiousByCat		INT; EXEC aa_GetValueTypeId 'ReligiousByCat',		@vtReligiousByCat	OUTPUT --vt432  
  DECLARE @vtFratCharByCat		INT; EXEC aa_GetValueTypeId 'FratCharByCat',		@vtFratCharByCat	OUTPUT --vt433  
  DECLARE @vtHospitalByCat		INT; EXEC aa_GetValueTypeId 'HospitalByCat',		@vtHospitalByCat	OUTPUT --vt434  
  DECLARE @vtSchoolByCat		INT; EXEC aa_GetValueTypeId 'SchoolByCat',			@vtSchoolByCat		OUTPUT --vt435  
  DECLARE @vtCemLibByCat		INT; EXEC aa_GetValueTypeId 'CemLibByCat',			@vtCemLibByCat		OUTPUT --vt435  
  --DECLARE @vtIntangPPropByCat INT; EXEC aa_GetValueTypeId 'IntangPPropByCat',		@vtIntangPPropByCat OUTPUT --vt464  
  --DECLARE @vtMHasCowShpByCat  INT; EXEC aa_GetValueTypeId 'MHasCowShpByCat',		@vtMHasCowShpByCat	OUTPUT --vt465  
  --DECLARE @vtSigCapInvByCat   INT; EXEC aa_GetValueTypeId 'SigCapInvByCat',		@vtSigCapInvByCat	OUTPUT --vt466  
  --DECLARE @vtPlantInvByCat    INT; EXEC aa_GetValueTypeId 'PlantInvByCat',		@vtPlantInvByCat	OUTPUT --vt467  
  --DECLARE @vtWildlifeHabByCat INT; EXEC aa_GetValueTypeId 'WildlifeHabByCat',		@vtWildlifeHabByCat OUTPUT --vt468  
  --DECLARE @vtSmallEmplrByCat  INT; EXEC aa_GetValueTypeId 'SmallEmplrByCat',		@vtSmallEmplrByCat	OUTPUT --vt469  
  DECLARE @vtHardshipByCat		INT; EXEC aa_GetValueTypeId 'HardshipByCat',		 @vtHardshipByCat	OUTPUT --vt490  
  DECLARE @vtCasLossByCat		INT; EXEC aa_GetValueTypeId 'CasLossByCat',			@vtCasLossByCat		OUTPUT --vt491  
  --DECLARE @vtEffChgUseByCat   INT; EXEC aa_GetValueTypeId 'EffChgUseByCat',		@vtEffChgUseByCat	OUTPUT --vt492  
  --DECLARE @vtLowIncHousByCat  INT; EXEC aa_GetValueTypeId 'LowIncHousByCat',		@vtLowIncHousByCat	OUTPUT --vt493  
  --DECLARE @vtPollContrByCat   INT; EXEC aa_GetValueTypeId 'PollContrByCat',		@vtPollContrByCat	OUTPUT --vt494  
  --DECLARE @vtPostConsWstByCat INT; EXEC aa_GetValueTypeId 'PostConsWstByCat',		@vtPostConsWstByCat OUTPUT --vt495  
  --DECLARE @vtQIE_ByCat		INT; EXEC aa_GetValueTypeId 'QIE_ByCat',			@vtQIE_ByCat		OUTPUT --vt496  
  --DECLARE @vtRemedLandByCat   INT; EXEC aa_GetValueTypeId 'RemedLandByCat',		@vtRemedLandByCat	OUTPUT --vt497  
	DECLARE @vtPPExemptionByCat INT; EXEC aa_GetValueTypeId 'PPExemptionByCat',		@vtPPExemptionByCat OUTPUT --vt487  
  
  --DECLARE @vtSpecFactor		INT; EXEC aa_GetValueTypeId 'SpecFactor',			@vtSpecFactor		OUTPUT --vt51  
	DECLARE @vtExemptStatute	INT; EXEC aa_GetValueTypeId 'ExemptStatute',		@vtExemptStatute	OUTPUT --vt642  
  
  -- Output Value Types  
	DECLARE @vtATR_NetTaxable	INT; EXEC aa_GetValueTypeId 'ATR_NetTaxable',		@vtATR_NetTaxable	OUTPUT	--vt355  --WO22007 sab 07/24/2023
	DECLARE @vtATR_FireTax		INT; EXEC aa_GetValueTypeId 'ATR_FireTax',			@vtATR_FireTax		OUTPUT	--vt356  --WO22007 sab 07/24/2023
	DECLARE @vtATR_FloodTax		INT; EXEC aa_GetValueTypeId 'ATR_FloodTax',			@vtATR_FloodTax		OUTPUT	--vt357  --WO22007 sab 07/24/2023
	DECLARE @vtATR_ImpOnly		INT; EXEC aa_GetValueTypeId 'ATR_ImpOnly',			@vtATR_ImpOnly		OUTPUT	--vt358  --WO22007 sab 07/24/2023
	DECLARE @vtATR_LessAgTimber	INT; EXEC aa_GetValueTypeId 'ATR_LessAgTimber',		@vtATR_LessAgTimber	OUTPUT	--vt359  --WO22007 sab 07/24/2023
	DECLARE @vtATR_LessTimber	INT; EXEC aa_GetValueTypeId 'ATR_LessTimber',		@vtATR_LessTimber	OUTPUT	--vt360  --WO22007 sab 07/24/2023

	DECLARE @vtNetTaxValue		INT; EXEC aa_GetValueTypeId 'Net Tax Value',		@vtNetTaxValue		OUTPUT	--vt455 Net Taxable Value  
	DECLARE @vtFireTax			INT; EXEC aa_GetValueTypeId 'Fire Tax',				@vtFireTax			OUTPUT	--vt456 Net Taxable Value Excludes OPT  
	DECLARE @vtFloodTax			INT; EXEC aa_GetValueTypeId 'Flood Tax',			@vtFloodTax			OUTPUT	--vt457 Net Taxable Value Excludes PP and OPT  
	DECLARE @vtNetImpOnly		INT; EXEC aa_GetValueTypeId 'Net Imp Only',			@vtNetImpOnly		OUTPUT	--vt458 Net Taxable Value Imp Only  
	DECLARE @vtNetMinusAgTbr	INT; EXEC aa_GetValueTypeId 'Net Minus Ag/Tbr',		@vtNetMinusAgTbr	OUTPUT	--vt459 Net Taxable Value Excludes Ag/Timber/OPT  
	DECLARE @vtNetMinusTbr		INT; EXEC aa_GetValueTypeId 'Net Minus Tbr',		@vtNetMinusTbr		OUTPUT	--vt460 Net Taxable Value Excludes Timber  
   
	DECLARE @vtSupValCatPro		INT; EXEC aa_GetValueTypeId 'SupValCatPro',			@vtSupValCatPro		OUTPUT	--vt761  
	DECLARE @vtSupHO_ByCat		INT; EXEC aa_GetValueTypeId 'SupHO_ByCat',			@vtSupHO_ByCat		OUTPUT	--vt673 SupHO_ByCat  
		
	DECLARE @vtSUPNetTaxVal		INT; EXEC aa_GetValueTypeId 'SUP Net Tax Val',		@vtSUPNetTaxVal		OUTPUT	--vt740 SUP Net Tax Val  
	DECLARE @vtSUPTaxFire		INT; EXEC aa_GetValueTypeId 'SUPTaxFire',			@vtSUPTaxFire		OUTPUT	--vt741 SUPTaxFire  
	DECLARE @vtSUPTaxFlood		INT; EXEC aa_GetValueTypeId 'SUPTaxFlood',			@vtSUPTaxFlood		OUTPUT	--vt742 SUPTaxFlood  
	DECLARE @vtSUPTaxImpOnly	INT; EXEC aa_GetValueTypeId 'SUPTaxImpOnly',		@vtSUPTaxImpOnly	OUTPUT	--vt743 SUPTaxImpOnly  
	DECLARE @vtSUPTaxExclAgTbr	INT; EXEC aa_GetValueTypeId 'SUPTaxExclAgTbr',		@vtSUPTaxExclAgTbr	OUTPUT	--vt744 SUPTaxExclAgTbr  
	DECLARE @vtSUPTaxExclTbr	INT; EXEC aa_GetValueTypeId 'SUPTaxExclTbr',		@vtSUPTaxExclTbr	OUTPUT	--  SUPTaxExclTbr -- for kootenai 2-25-15  
  
	DECLARE @vtSUP_Annual_Net	INT; EXEC aa_GetValueTypeId 'SUP_Annual_Net',		@vtSUP_Annual_Net	OUTPUT	--vt764 SUP_Annual_Net  
	DECLARE @vtSUP_Annual_Fire	INT; EXEC aa_GetValueTypeId 'SUP_Annual_Fire',		@vtSUP_Annual_Fire	OUTPUT	--vt751 SUP_Annual_Fire  
	DECLARE @vtSUP_Annual_Flood INT; EXEC aa_GetValueTypeId 'SUP_Annual_Flood',		@vtSUP_Annual_Flood OUTPUT	--vt752 SUP_Annual_Flood  
	DECLARE @vtSUP_Annual_Imp	INT; EXEC aa_GetValueTypeId 'SUP_Annual_Imp',		@vtSUP_Annual_Imp	OUTPUT	--vt753 SUP_Annual_Imp  
	DECLARE @vtSUP_Annual_AgTbr INT; EXEC aa_GetValueTypeId 'SUP_Annual_AgTbr',		@vtSUP_Annual_AgTbr OUTPUT	--vt754 SUP_Annual_AgTbr   
	DECLARE @vtSUP_Annual_Tbr	INT; EXEC aa_GetValueTypeId 'SUP_Annual_Tbr',		@vtSUP_Annual_Tbr	OUTPUT	-- for kootenai 2-25-15  
 
   	DECLARE @vtSUP_ANL_NetATR	INT; EXEC aa_GetValueTypeId 'SUP_ANL_NetATR',		@vtSUP_ANL_NetATR	OUTPUT --vt790  --WO22254 sab 12/07/2023
   	DECLARE @vtSUP_ANL_FireATR	INT; EXEC aa_GetValueTypeId 'SUP_ANL_FireATR',		@vtSUP_ANL_FireATR	OUTPUT --vt791  --WO22254 sab 12/07/2023
   	DECLARE @vtSUP_ANL_FloodATR	INT; EXEC aa_GetValueTypeId 'SUP_ANL_FloodATR',		@vtSUP_ANL_FloodATR	OUTPUT --vt792  --WO22254 sab 12/07/2023
   	DECLARE @vtSUP_ANL_ImpATR	INT; EXEC aa_GetValueTypeId 'SUP_ANL_ImpATR',		@vtSUP_ANL_ImpATR	OUTPUT --vt793  --WO22254 sab 12/07/2023
   	DECLARE @vtSUP_ANL_AGTbrATR	INT; EXEC aa_GetValueTypeId 'SUP_ANL_AGTbrATR',		@vtSUP_ANL_AGTbrATR	OUTPUT --vt794  --WO22254 sab 12/07/2023
   	DECLARE @vtSUP_ANL_TbrATR	INT; EXEC aa_GetValueTypeId 'SUP_ANL_TbrATR',		@vtSUP_ANL_TbrATR	OUTPUT --vt795  --WO22254 sab 12/07/2023
		
 
 
 
  
  --DECLARE @vtSpecFactorByCat INT; EXEC aa_GetValueTypeId 'SpecFactorByCat',  @vtSpecFactorByCat OUTPUT --vt650   
  --DECLARE @vtRegReimbursement INT; EXEC aa_GetValueTypeId 'RegReimbursement',  @vtRegReimbursement OUTPUT --vt950 Regular PP Reimbursement   
  
  
-- PROCESS INFO  
  
  DECLARE @v_ProcessStepId INT, @v_ProcessCdTrackingId INT, @v_ProcGrpNumber  INT  
  
  exec dbo.aa_ProcessInformation  
    @p_ProcessStepTrackingId = @v_ProcessStepTrackingId  
     , @p_ProcessStepId         = @v_ProcessStepId OUT  
     , @p_ProcessCdTrackingId   = @v_ProcessCdTrackingId OUT  
     , @p_ProcGrpNumber         = @v_ProcGrpNumber OUT  
           
  IF @v_HeaderType <> @stCadLevel  
   RAISERROR (N'Expecting HeaderType of CadLevel', 11, 1)  
    
-- GET THE ASSESSMENT YEAR AND THE ROLL CASTE
  
  DECLARE @AssessmentYear SMALLINT;   
  DECLARE @RollCaste SMALLINT;			--WO22007 sab 07/24/2023  
  DECLARE @OCC_ChangeReason CHAR(1); 	--WO22254 sab 12/07/2023
      
  SELECT  @AssessmentYear = MAX(cr.AssessmentYear) FROM  CadRoll cr   
  WHERE EXISTS(SELECT * FROM CadLevel cl WHERE cl.Id = @v_HeaderId AND cl.CadRollId = cr.Id)  

  SELECT @RollCaste = max(RollCaste) FROM  dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) 	 --WO22007 sab 07/24/2023  
        
  SELECT @OCC_ChangeReason = (select case when RollCaste = 16001 then 'N'    --WO22254 sab 12/07/2023
											when RollCaste = 16002 and ValChangeReason in (select Id from systype s 
																							where s.SysTypeCatId = 10300 
																							and s.Descr like '%OCC%'
																							and s.EffStatus = 'A' 
																							and s.BegEffDate = (select max(BegEffDate) from SysType ssub where ssub.id = s.id)
																							) 
											then 'Y'																		    
										else 'N' end
								from dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId)
								)        
  
--SCB 08-28-15 START  
   INSERT INTO #TempValueTypeAmount ([Id],[ObjectId],[ValueTypeId],[HeaderType],[HeaderId],[AddlObjectId],  
   [SecondaryAddlObjectId],[ValueAmount],[CalculatedAmount],[ProcessStepTrackingId])      
  SELECT 0 as Id      
     ,vta.Objectid      
     ,vta.ValueTypeId      
     ,vta.HeaderType      
     ,vta.Headerid          
     ,0 as AddlObjectId      
     ,vta.SecondaryAddlObjectid      
     ,sum(vta.ValueAmount) as ValueAmount      
     ,0 as CalculatedAmount      
     ,vta.ProcessStepTrackingId      
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta   
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
  ON vta.Headerid = ci.Id   
  WHERE (vta.ValueTypeId = @vtTotalValue  
  AND ci.RollCaste = 16001)  
  OR ((vta.ValueTypeId = @vtSupValCatPro and vta.valueamount >0)  
  AND ci.RollCaste = 16002)  
  group by ObjectId, ValueTypeId, HeaderType, HeaderId, SecondaryAddlObjectid, vta.ProcessStepTrackingId  
  
  -- MWD 02142023 - added missing INSERT
  Insert into #workSuppProratedTotalImpOnly ([ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],  
  [SecondaryAddlObjectId],[ValueAmount])      
  select vta.Objectid      
     ,0 as ValueTypeId      
     ,vta.Headerid          
     ,0 as AddlObjectId      
     ,0 as SecondaryAddlObjectid      
     ,sum(vta.ValueAmount) as ValueAmount      
  from dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta      
  WHERE vta.ValueTypeId = @vtSupValCatPro  
  and vta.AddlObjectId in (select CodesToSysType from codes_table where tbl_type_code = 'impgroup' and code_status = 'A' and field_2 = '2-Imp' )  
  GROUP BY ObjectId, HeaderId  
     
     
  Insert into #workSuppProratedByCat ([ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],  
  [SecondaryAddlObjectId],[ValueAmount])      
  select vta.Objectid      
     ,vta.ValueTypeId      
     ,vta.Headerid          
     ,vta.AddlObjectId      
     ,vta.SecondaryAddlObjectid      
     ,vta.ValueAmount as ValueAmount      
  from dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta      
  WHERE vta.ValueTypeId = @vtSupValCatPro  
  
  
---- -----------------------------------------------------------------------------------  
---- NET TAXABLE VALUE  
---- -----------------------------------------------------------------------------------  
  
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT   
    vta.Objectid  
   ,@vtNetTaxValue --ValueTypeId  
   ,vta.Headerid  
   ,vta.AddlObjectId  
   ,vta.SecondaryAddlObjectId  
   ,vta.ValueAmount - isnull(vta_exe.ValueAmount,0) -- ValueAmount  
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk( @v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId ) AS vta  --TotalValue rows  
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
  ON ci.Id = vta.Headerid  
  AND ci.RollCaste = 16001  
  LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk( @v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId ) AS vta_exe  
   ON vta_exe.ObjectId = vta.ObjectId  
    AND vta_exe.HeaderId = vta.HeaderId  
    AND vta_exe.ValueTypeId = @vtTotalExemptions  
  WHERE vta.ValueTypeId = @vtTotalValue  
  
  -- add NET TAXABLE to the #Work table so we can use that in a later calc below  
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],  
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])      
  SELECT  
    Headerid  --id  
   ,ObjectId  --ObjectId  
   ,ValueTypeId --ValueTypeId  (vt455 vtNetTaxValue )   
   ,HeaderId  --HeaderId  
   ,AddlObjectId --AddlObjectId  
   ,SecondaryAddlObjectId --Secondardy  
   ,ValueAmount --ValueAmount   
   ,'Net'   --flag   --homeowners percent indicator  
   ,@v_ProcessStepTrackingId  
  FROM #results  --contains the homeowner eligible value  
  WHERE ValueTypeId = @vtNetTaxValue  
  
  
  
---- -----------------------------------------------------------------------------------  
---- NET TAXABLE VALUE EXCLUDES OPT  (Fire Taxable)  
---- -----------------------------------------------------------------------------------  
  
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT   
    w.Objectid  
   ,@vtFireTax --ValueTypeId  
   ,w.Headerid  
   ,w.AddlObjectId  
   ,w.SecondaryAddlObjectId  
   ,case when ci.RollType not in (1200004) then w.ValueAmount     
      when ci.RollType in (1200004) then 0       
      else 0   
    end-- ValueAmount  
  FROM #Work w  --Net Taxable Value rows  
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
  ON ci.Id = w.Headerid  
  AND ci.RollCaste = 16001  
  
  
---- -----------------------------------------------------------------------------------  
---- NET TAXABLE VALUE EXCLUDES PP AND OPT  (Flood Taxable)  
---- -----------------------------------------------------------------------------------  
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT   
    w.Objectid  
   ,@vtFloodTax --ValueTypeId  
   ,w.Headerid  
   ,w.AddlObjectId  
   ,w.SecondaryAddlObjectId  
   ,case when ci.RollType in (1200001,1200003) then w.ValueAmount  --real, mh  
      when ci.RollType in (1200002,1200004, 1200005) then 0     --pp, opt, transient  
      else 0   
    end-- ValueAmount  
  FROM #Work w  --Net Taxable Value rows  
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
  ON ci.Id = w.Headerid  
  AND ci.RollCaste = 16001  
  
  
---- -----------------------------------------------------------------------------------  
---- NET TAXABLE VALUE IMP ONLY    
---- -----------------------------------------------------------------------------------  
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT  
   vta_Imp.Objectid  
   ,@vtNetImpOnly --ValueTypeId  
   ,vta_Imp.Headerid  
   ,vta_Imp.AddlObjectId  
   ,vta_Imp.SecondaryAddlObjectId  
   ,case when vta_Imp.ValueAmount - sum(isnull(vta_ExByCat.ValueAmount,0)) >0   
      then vta_Imp.ValueAmount - sum(isnull(vta_ExByCat.ValueAmount,0))  
      else 0   
      end-- ValueAmount  
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_Imp --Total Imp rows  
  JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
  ON ci.Id = vta_Imp.Headerid  
  AND ci.RollCaste = 16001  
  LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_ExByCat--Ex for Imp rows  
  ON  vta_ExByCat.ObjectId = vta_Imp.ObjectId  
  AND vta_ExByCat.HeaderId = vta_Imp.HeaderId  
  AND vta_ExByCat.ValueTypeId in (@vtHOEX_ByCat, @vtGovernmentByCat, @vtReligiousByCat, @vtFratCharByCat, @vtHospitalByCat,  
          @vtSchoolByCat, @vtCemLibByCat, @vtHardshipByCat,@vtPPExemptionByCat,@vtCasLossByCat)   
  AND vta_ExByCat.AddlObjectId in (@vc26H,@vc31H,@vc34H,@vc37H,@vc41H,@vc46H,@vc47H,  
           @vc48H,@vc49H,@vc50H,@vc55H,@vc57H,@vc65H,@vc69H,@vc81)   
  WHERE vta_Imp.ValueTypeId = @vtIA     
     GROUP BY vta_Imp.Objectid, vta_Imp.Headerid, vta_Imp.AddlObjectId, vta_Imp.SecondaryAddlObjectId,vta_Imp.ValueAmount  
  
  
  
  
  
-- -----------------------------------------------------------------------------------  
-- NET TAXABLE VALUE EXCLUDES AG AND TIMBER --uncommented out 2/25/15 - excludes ag and timber  
-- -----------------------------------------------------------------------------------  
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT   
    vta_TotalVal.Objectid  
   ,@vtNetMinusAgTbr --ValueTypeId  
   ,vta_TotalVal.Headerid  
   ,vta_TotalVal.AddlObjectId  
   ,vta_TotalVal.SecondaryAddlObjectId  
   ,case when vta_TotalVal.ValueAmount - isnull(vta_TotalExe.ValueAmount,0) - sum(isnull(vta_AgTbr.ValueAmount,0)) >0   
      then vta_TotalVal.ValueAmount - isnull(vta_TotalExe.ValueAmount,0) - sum(isnull(vta_AgTbr.ValueAmount,0))  
      else 0   
      end-- ValueAmount  
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_TotalVal --Total Value rows  
  JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
  ON ci.Id = vta_TotalVal.Headerid  
  AND ci.RollCaste = 16001  
  LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_TotalExe--HO Ex for Imp rows  
  ON  vta_TotalExe.ObjectId = vta_TotalVal.ObjectId  
  AND vta_TotalExe.HeaderId = vta_TotalVal.HeaderId  
  AND vta_TotalExe.ValueTypeId = @vtTotalExemptions   
  LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_AgTbr--ag & timber rows  
  ON  vta_AgTbr.ObjectId = vta_TotalVal.ObjectId  
  AND vta_AgTbr.HeaderId = vta_TotalVal.HeaderId  
  AND vta_AgTbr.ValueTypeId = @vtAssessedByCat   
  AND vta_AgTbr.AddlObjectId in (@vc01,@vc02,@vc03,@vc04,@vc05,@vc06,@vc07)   
  WHERE vta_TotalVal.ValueTypeId = @vtTotalValue     
     GROUP BY vta_TotalVal.Objectid, vta_TotalVal.Headerid, vta_TotalVal.AddlObjectId, vta_TotalVal.SecondaryAddlObjectId,  
     vta_TotalVal.ValueAmount,vta_TotalExe.ValueAmount   
  
  
---- -----------------------------------------------------------------------------------  
---- NET TAXABLE VALUE EXCLUDES TIMBER     Net - (timber cat value - timber cat exempted)  
--clk 2/25/15 added. this will only exclude timber land. Kootenai's fire taxable  
---- -----------------------------------------------------------------------------------  
 INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT   
    vta_TotalVal.Objectid  
   ,@vtNetMinusTbr --ValueTypeId  
   ,vta_TotalVal.Headerid  
   ,vta_TotalVal.AddlObjectId  
   ,vta_TotalVal.SecondaryAddlObjectId  
   ,case when vta_TotalVal.ValueAmount - isnull(vta_TotalExe.ValueAmount,0) - sum(isnull(vta_Tbr.ValueAmount,0)) >0   
      then vta_TotalVal.ValueAmount - isnull(vta_TotalExe.ValueAmount,0) - sum(isnull(vta_Tbr.ValueAmount,0))  
      else 0   
      end-- ValueAmount  
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_TotalVal --Total Value rows  
  JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
  ON ci.Id = vta_TotalVal.Headerid  
  AND ci.RollCaste = 16001  
  LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_TotalExe--HO Ex for Imp rows  
  ON  vta_TotalExe.ObjectId = vta_TotalVal.ObjectId  
  AND vta_TotalExe.HeaderId = vta_TotalVal.HeaderId  
  AND vta_TotalExe.ValueTypeId = @vtTotalExemptions   
  LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_Tbr-- timber rows  
  ON  vta_Tbr.ObjectId = vta_TotalVal.ObjectId  
  AND vta_Tbr.HeaderId = vta_TotalVal.HeaderId  
  AND vta_Tbr.ValueTypeId = @vtAssessedByCat   
  AND vta_Tbr.AddlObjectId in (@vc06,@vc07)   
  WHERE vta_TotalVal.ValueTypeId = @vtTotalValue     
     GROUP BY vta_TotalVal.Objectid, vta_TotalVal.Headerid, vta_TotalVal.AddlObjectId, vta_TotalVal.SecondaryAddlObjectId,  
     vta_TotalVal.ValueAmount,vta_TotalExe.ValueAmount   
 
 
---- ----------------------------------------------------------------------------------------------------------
---- POPULATATE ATR CREDIT FOR ANNUAL ROLL																			--sab WO22007 07/24/2023 (89 NEW ROWS ENTIRE SECTION) 
---- ----------------------------------------------------------------------------------------------------------
--ANNUAL
 if @RollCaste = 16001
	BEGIN
				INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])
				SELECT 
					 w.Objectid
					,@vtATR_NetTaxable --ValueTypeId
					,w.Headerid
					,w.AddlObjectId
					,w.SecondaryAddlObjectId
					,w.ValueAmount 
				FROM #results w 
				WHERE w.ValueTypeId = @vtNetTaxValue
	END


 IF @RollCaste = 16001
	BEGIN
		IF exists (select distinct RateValueType from TafRate where TaxYear = @AssessmentYear and RateValueType = @vtFireTax)
			BEGIN
				INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])
				SELECT 
					 w.Objectid
					,@vtATR_FireTax --ValueTypeId
					,w.Headerid
					,w.AddlObjectId
					,w.SecondaryAddlObjectId
					,w.ValueAmount 
				FROM #results w  
				WHERE w.ValueTypeId = @vtFireTax	
			END
	END


 IF @RollCaste = 16001
	BEGIN
		IF exists (select distinct RateValueType from TafRate where TaxYear = @AssessmentYear and RateValueType = @vtFloodTax)
			BEGIN
				INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])
				SELECT 
					 w.Objectid
					,@vtATR_FloodTax --ValueTypeId
					,w.Headerid
					,w.AddlObjectId
					,w.SecondaryAddlObjectId
					,w.ValueAmount 
				FROM #results w  
				WHERE w.ValueTypeId = @vtFloodTax	
			END
	END


 IF @RollCaste = 16001
	BEGIN
		IF exists (select distinct RateValueType from TafRate where TaxYear = @AssessmentYear and RateValueType = @vtNetImpOnly)
			BEGIN
				INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])
				SELECT 
					 w.Objectid
					,@vtATR_ImpOnly --ValueTypeId
					,w.Headerid
					,w.AddlObjectId
					,w.SecondaryAddlObjectId
					,w.ValueAmount 
				FROM #results w  
				WHERE w.ValueTypeId = @vtNetImpOnly	
			END
	END


 IF @RollCaste = 16001
	BEGIN
		IF exists (select distinct RateValueType from TafRate where TaxYear = @AssessmentYear and RateValueType = @vtNetMinusAgTbr)
			BEGIN
				INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])
				SELECT 
					 w.Objectid
					,@vtATR_LessAgTimber --ValueTypeId
					,w.Headerid
					,w.AddlObjectId
					,w.SecondaryAddlObjectId
					,w.ValueAmount 
				FROM #results w  
				WHERE w.ValueTypeId = @vtNetMinusAgTbr	
			END
	END


 IF @RollCaste = 16001
	BEGIN
		IF exists (select distinct RateValueType from TafRate where TaxYear = @AssessmentYear and RateValueType = @vtNetMinusTbr)
			BEGIN
				INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])
				SELECT 
					 w.Objectid
					,@vtATR_LessTimber --ValueTypeId
					,w.Headerid
					,w.AddlObjectId
					,w.SecondaryAddlObjectId
					,w.ValueAmount 
				FROM #results w  
				WHERE w.ValueTypeId = @vtNetMinusTbr	
			END
	END

	
---- -------------------------------------------------------------------------------------------------------- 
---- TOTAL TOTAL ANNUAL/SUPP NET VALUES (this is the vt used when calculating taxes) -- mwd 6/29/2021 
---- -------------------------------------------------------------------------------------------------------- 
--This table will be used later on when calculating total value to annual net and supp net combined. 

  Insert into #WorkAnnualNet ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId], 
							  [SecondaryAddlObjectId],[ValueAmount],[flag])     

  SELECT  
      cisub.id						--id 
	, ros.id						--ObjectId 
	, vta.ValueTypeId				--ValueTypeId	
	, cisub.Id                      --HeaderId 
	, vta.AddlObjectId              --AddlObjectId 
	, vta.SecondaryAddlObjectId     --Secondardy 
	, vta.Valueamount               --ValueAmount  
	, 'Net'     --flag    
  FROM dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels 
  INNER JOIN cadInv ci --annual 
  ON ci.RevObjId = cisub.RevObjId 
  AND ci.RollCaste = 16001 
  AND year(ci.ValEffDate) = @AssessmentYear 
  AND ci.EffStatus = 'A' 
  AND ci.id = (select max(id) from CadInv cisub where cisub.revobjid = ci.revobjid and cisub.CadLevelId = ci.CadLevelid 
      and cisub.RollCaste = 16001 
      AND year(cisub.ValEffDate) = @AssessmentYear) --ensures that we only pull in the most current cadastre info 
  INNER JOIN RevobjSite ros 
  on ros.RevObjId = ci.RevObjId 
  and ros.EffStatus = 'A' 
  and ros.BegEffDate = (select max(BegEffDate) from RevObjSite rossub where rossub.id = ros.id) 
  and ros.SiteType <> 15908  --exclude specials sitetype 
  INNER JOIN ValueTypeAmount vta 
  on vta.HeaderId = ci.id 
  and vta.ValueTypeId in (455,456,457,458,459,460,405) 
  WHERE cisub.RollCaste = 16002 
  and year(cisub.ValEffDate) = @AssessmentYear 

---------------------------------------------------------------------------------  
--SUPPLEMENTAL NET TAXABLE VALUE - added clk 2-26-15  
----------------------------------------------------------------------------------  
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT   
    vta.Objectid  
   ,@vtSUPNetTaxVal --ValueTypeId  
   ,vta.Headerid  
   ,vta.AddlObjectId  
   ,vta.SecondaryAddlObjectId  
   ,vta.ValueAmount - (isnull(vta_exe.ValueAmount,0) - isnull(vta_exe1.valueamount,0)) -- ValueAmount  
  FROM #TempValueTypeAmount vta  --TotalValue rows or if supp it represents the total prorated rows  
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
  ON ci.Id = vta.Headerid  
  AND ci.RollCaste = 16002  
  LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) as vta_exe  
  ON vta_exe.ObjectId = vta.ObjectId  
  AND vta_exe.HeaderId = vta.HeaderId  
  AND vta_exe.ValueTypeId = @vtTotalExemptions  
  LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) as vta_exe1  
  ON vta_exe1.ObjectId = vta.ObjectId  
  AND vta_exe1.HeaderId = vta.HeaderId  
  AND vta_exe1.ValueTypeId = @vtExemptStatute  

 
  -- add NET TAXABLE to the #Work table so we can use that in a later calc below  
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],  
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])      
  SELECT   
    Headerid  --id  
   ,ObjectId  --ObjectId  
   ,ValueTypeId --ValueTypeId  (vtSUPNetTaxVal)   
   ,HeaderId  --HeaderId  
   ,AddlObjectId --AddlObjectId  
   ,SecondaryAddlObjectId --Secondardy  
   ,ValueAmount --ValueAmount   
   ,'NetSupp'  --flag   --homeowners percent indicator  
   ,@v_ProcessStepTrackingId  
  FROM #results  --contains the homeowner eligible value  
  WHERE ValueTypeId = @vtSUPNetTaxVal  
    
  
--SUPPLEMENTAL - SupTaxFire  
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT   
    w.Objectid  
   ,@vtSUPTaxFire --ValueTypeId  
   ,w.Headerid  
   ,w.AddlObjectId  
   ,w.SecondaryAddlObjectId  
   ,case when ci.RollType not in (1200004) then w.ValueAmount     
      when ci.RollType in (1200004) then 0       
      else 0   
    end-- ValueAmount  
  FROM #Work w  --Net Taxable Value rows  
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
  ON ci.Id = w.Headerid  
  AND ci.RollCaste = 16002  
  WHERE w.flag='NetSupp'  
    
--SUPPLEMENTALSUPTaxFlood  
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT   
    w.Objectid  
   ,@vtSUPTaxFlood --ValueTypeId  
   ,w.Headerid  
   ,w.AddlObjectId  
   ,w.SecondaryAddlObjectId  
   ,case when ci.RollType not in (1200002,1200004) then w.ValueAmount     
      when ci.RollType in (1200002,1200004) then 0       
      else 0   
    end-- ValueAmount  
  FROM #Work w  --Net Taxable Value rows  
  JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
  ON ci.Id = w.Headerid  
  AND ci.RollCaste = 16002  
  WHERE w.flag='NetSupp'  
    
--SUPPLEMENTAL SUPTaxImpOnly  
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT   
    vta_Imp.Objectid  
   ,@vtSUPTaxImpOnly --ValueTypeId  743
   ,vta_Imp.Headerid  
   ,vta_Imp.AddlObjectId  
   ,vta_Imp.SecondaryAddlObjectId  
   ,case when vta_Imp.ValueAmount - sum(isnull(vta_ExByCat.ValueAmount,0)) >0   
      then vta_Imp.ValueAmount - sum(isnull(vta_ExByCat.ValueAmount,0))  
      else 0   
      end-- ValueAmount  
  FROM #workSuppProratedTotalImpOnly as vta_Imp --Total Imp rows  
  LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_ExByCat--Ex for Imp rows  
  ON  vta_ExByCat.ObjectId = vta_Imp.ObjectId  
  AND vta_ExByCat.HeaderId = vta_Imp.HeaderId  
  AND vta_ExByCat.ValueTypeId in (@vtSupHO_ByCat,@vtHOEX_ByCat, @vtGovernmentByCat, @vtReligiousByCat, @vtFratCharByCat, @vtHospitalByCat,  
          @vtSchoolByCat, @vtCemLibByCat, @vtHardshipByCat,@vtPPExemptionByCat,@vtCasLossByCat)   
  AND vta_ExByCat.AddlObjectId in (@vc26H,@vc31H,@vc34H,@vc37H,@vc41H,@vc46H,@vc47H,  
           @vc48H,@vc49H,@vc50H,@vc55H,@vc57H,@vc65H,@vc69H,@vc81)   
  GROUP BY vta_Imp.Objectid, vta_Imp.Headerid, vta_Imp.AddlObjectId, vta_Imp.SecondaryAddlObjectId,vta_Imp.ValueAmount  
  
--SUPPLEMENTAL SUPTaxExclAgTbr  
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT   
    w.Objectid  
   ,@vtSUPTaxExclAgTbr --ValueTypeId  
   ,w.Headerid  
   ,w.AddlObjectId  
   ,w.SecondaryAddlObjectId  
   ,w.ValueAmount   
       
  FROM #Work w --Net   
    WHERE w.ValueTypeId = @vtSUPNetTaxVal   
  AND w.Flag = 'NetSupp'    
     GROUP BY w.Objectid, w.Headerid, w.AddlObjectId, w.SecondaryAddlObjectId, w.ValueAmount  
  
--SUPPLEMENTAL SUPTaxExclTbr  
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])  
  SELECT   
    w.Objectid  
   ,@vtSUPTaxExclTbr --ValueTypeId  
   ,w.Headerid  
   ,w.AddlObjectId  
   ,w.SecondaryAddlObjectId  
   ,w.ValueAmount   
       
  FROM #Work w --Net   
    WHERE w.ValueTypeId = @vtSUPNetTaxVal   
  AND w.Flag = 'NetSupp'    
     GROUP BY w.Objectid, w.Headerid, w.AddlObjectId, w.SecondaryAddlObjectId, w.ValueAmount  


  
--added from STC taxable step - not sure what it's for and it will work for this step 2-26-25  
--NET (non urd pins)  
  INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])     
  SELECT   
    r.Objectid  
   ,@vtSUP_Annual_Net --ValueTypeId  
   ,r.Headerid  
   ,r.AddlObjectId  
   ,r.SecondaryAddlObjectId  
   ,r.ValueAmount + isnull(w.ValueAmount,0) -- ValueAmount   
  FROM #Results r   --supp parcels  
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels  
  ON cisub.id = r.headerid  
  LEFT OUTER JOIN #WorkAnnualNet w  
  ON w.ObjectId = r.ObjectId   
  AND w.ValueTypeId = @vtNetTaxValue   
  WHERE r.ValueTypeId = @vtSUPNetTaxVal  
  and cisub.rollCaste = 16002  
  and year(cisub.ValEffDate) = @AssessmentYear  
  --AND cisub.revobjid not in (select objectid   
  --      from dbo.grm_levy_TifRolebyeffdate ( cisub.ValEffDate, 'A'))  
  -- MWD remove TIFRole restrictions from creating ValueType 02102023
    
  
  --FIRE  (non urd pins)  
  INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])     
  SELECT   
    r.Objectid  
   ,@vtSUP_Annual_Fire --ValueTypeId  
   ,r.Headerid  
   ,r.AddlObjectId  
   ,r.SecondaryAddlObjectId  
   ,r.ValueAmount + isnull(w.ValueAmount,0) -- ValueAmount   
  FROM #Results r   --supp parcels  
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels  
  ON cisub.id = r.headerid    
  LEFT OUTER JOIN #WorkAnnualNet w  
  ON w.ObjectId = r.ObjectId   
  AND w.ValueTypeId = @vtFireTax   
  WHERE r.ValueTypeId = @vtSUPTaxFire  
  and cisub.rollCaste = 16002  
  and year(cisub.ValEffDate) = @AssessmentYear  
  --AND cisub.revobjid not in (select objectid   
  --      from dbo.grm_levy_TifRolebyeffdate ( cisub.ValEffDate, 'A')) 
  -- MWD remove TIFRole restrictions from creating ValueType 02102023  
  
  
  --FLOOD  (non urd pins)  
  INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])     
  SELECT   
    r.Objectid  
   ,@vtSUP_Annual_Flood --ValueTypeId  
   ,r.Headerid  
   ,r.AddlObjectId  
   ,r.SecondaryAddlObjectId  
   ,r.ValueAmount + isnull(w.ValueAmount,0) -- ValueAmount   
  FROM #Results r   --supp parcels  
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels  
  ON cisub.id = r.headerid    
  LEFT OUTER JOIN #WorkAnnualNet w  
  ON w.ObjectId = r.ObjectId   
  AND w.ValueTypeId = @vtFloodTax   
  WHERE r.ValueTypeId = @vtSUPTaxFlood  
  and cisub.rollCaste = 16002  
  and year(cisub.ValEffDate) = @AssessmentYear  
  --AND cisub.revobjid not in (select objectid   
  --      from dbo.grm_levy_TifRolebyeffdate ( cisub.ValEffDate, 'A'))  
  -- MWD remove TIFRole restrictions from creating ValueType 02102023
          
          
          
  --IMP ONLY  (non urd pins)  
  INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])     
  SELECT   
    r.Objectid  
   ,@vtSUP_Annual_Imp --ValueTypeId  
   ,r.Headerid  
   ,r.AddlObjectId  
   ,r.SecondaryAddlObjectId  
   ,r.ValueAmount + isnull(w.ValueAmount,0) -- ValueAmount   
  FROM #Results r   --supp parcels  
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels  
  ON cisub.id = r.headerid    
  LEFT OUTER JOIN #WorkAnnualNet w  
  ON w.ObjectId = r.ObjectId   
  AND w.ValueTypeId = @vtNetImpOnly   
  WHERE r.ValueTypeId = @vtSUPTaxImpOnly  
  and cisub.rollCaste = 16002  
  and year(cisub.ValEffDate) = @AssessmentYear  
     
  --AND cisub.revobjid not in (select objectid   
  --      from dbo.grm_levy_TifRolebyeffdate ( cisub.ValEffDate, 'A'))  
  -- MWD remove TIFRole restrictions from creating ValueType 02102023
          
          
  
  --NET EXCLUDES AG & TIMBER ONLY (non urd pins)  
  INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])     
  SELECT   
    r.Objectid  
   ,@vtSUP_Annual_AgTbr --ValueTypeId  
   ,r.Headerid  
   ,r.AddlObjectId  
   ,r.SecondaryAddlObjectId  
   ,r.ValueAmount + isnull(w.ValueAmount,0) -- ValueAmount   
  FROM #Results r   --supp parcels  
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels  
  ON cisub.id = r.headerid    
  LEFT OUTER JOIN #WorkAnnualNet w  
  ON w.ObjectId = r.ObjectId   
  AND w.ValueTypeId = @vtNetMinusAgTbr   
  WHERE r.ValueTypeId = @vtSUPTaxExclAgTbr  and cisub.rollCaste = 16002  
  and year(cisub.ValEffDate) = @AssessmentYear  
  --AND cisub.revobjid not in (select objectid   
  --      from dbo.grm_levy_TifRolebyeffdate ( cisub.ValEffDate, 'A'))  
  -- MWD remove TIFRole restrictions from creating ValueType 02102023
  
  
  --NET EXCLUDES  TIMBER ONLY (non urd pins)  
  INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])     
  SELECT   
    r.Objectid  
   ,@vtSUP_Annual_Tbr --ValueTypeId  
   ,r.Headerid  
   ,r.AddlObjectId  
   ,r.SecondaryAddlObjectId  
   ,r.ValueAmount + isnull(w.ValueAmount,0) -- ValueAmount   
  FROM #Results r   --supp parcels  
  INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels  
  ON cisub.id = r.headerid    
  LEFT OUTER JOIN #WorkAnnualNet w  
  ON w.ObjectId = r.ObjectId   
  AND w.ValueTypeId = @vtNetMinusTbr   
  WHERE r.ValueTypeId = @vtSUPTaxExclTbr  and cisub.rollCaste = 16002  
  and year(cisub.ValEffDate) = @AssessmentYear  
  --AND cisub.revobjid not in (select objectid   
  --      from dbo.grm_levy_TifRolebyeffdate ( cisub.ValEffDate, 'A'))  
  -- MWD remove TIFRole restrictions from creating ValueType 02102023
  


---- --------------------------------------------------------------------------------------------------------
---- TOTAL TOTAL ANNUAL/SUPP ATR VALUES vt756   --sab 12/07/2023  
---- --------------------------------------------------------------------------------------------------------
	 --This table will be used later on when calculating total value to annual net and supp net combined.
		 if @RollCaste = 16002
			BEGIN
				Insert into #WorkAnnualATR ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],
											[SecondaryAddlObjectId],[ValueAmount],[flag])    
				SELECT 
					 cisub.id				--id
					,ros.id					--ObjectId
					,vta.ValueTypeId		--ValueTypeId 
					,cisub.Id				--HeaderId
					,vta.AddlObjectId		--AddlObjectId
					,vta.SecondaryAddlObjectId --Secondardy
					,vta.Valueamount		--ValueAmount 
					,'ATR'					--flag   
				FROM dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels
				INNER JOIN cadInv ci --annual
				ON ci.RevObjId = cisub.RevObjId
				AND ci.RollCaste = 16001
				AND year(ci.ValEffDate) = @AssessmentYear
				AND ci.EffStatus = 'A'
				AND ci.id = (select max(id) from CadInv cisub where cisub.revobjid = ci.revobjid and cisub.CadLevelId = ci.CadLevelid
								and cisub.RollCaste = 16001
								AND year(cisub.ValEffDate) = @AssessmentYear) --ensures that we only pull in the most current cadastre info
				INNER JOIN RevobjSite ros
				on ros.RevObjId = ci.RevObjId
				and ros.EffStatus = 'A'
				and ros.BegEffDate = (select max(BegEffDate) from RevObjSite rossub where rossub.id = ros.id)
				and ros.SiteType <> 15908  --exclude specials sitetype
				INNER JOIN ValueTypeAmount vta
				on vta.HeaderId = ci.id
				and vta.ValueTypeId in (@vtATR_NetTaxable,@vtATR_FireTax,@vtATR_FloodTax,@vtATR_ImpOnly,@vtATR_LessAgTimber,@vtATR_LessTimber)
				WHERE cisub.RollCaste = 16002
				and year(cisub.ValEffDate) = @AssessmentYear
				AND ci.revobjid not in (select objectid 
										from TifRole tr
										where tr.BegEffDate = (select max(BegEffDate) from TifRole trsub where trsub.id = tr.id)
										and tr.ObjectType = 100002
										and tr.EffStatus = 'A'
										)
			END		

		--ATR ON OCCUPANCIES (non urd pins) WE JUST COPY THE ANNUAL ATR TO THE SUPPLEMENTAL ATR SO THAT WE DON'T LOSE THE ANNUAL ATR AND WE DON'T INCREASE IT FOR THE SUPP OCCUPANCY 
		 if @RollCaste = 16002 and @OCC_ChangeReason = 'Y'
			BEGIN
				INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])   
				SELECT 
					 ros.Id
					,vta.ValueTypeId --ValueTypeId
					,ci.id	--HeaderId
					,''		--AddlObjectId
					,''		--SecondaryAddlObjectId
					,vta.ValueAmount --ValueAmount
				FROM dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci 
				INNER JOIN cadInv ci2 --annual
				ON ci2.RevObjId = ci.RevObjId
				AND ci2.RollCaste = 16001
				AND year(ci2.ValEffDate) = @AssessmentYear
				AND ci2.EffStatus = 'A'
				AND ci2.id = (select max(id) from CadInv cisub where cisub.revobjid = ci2.revobjid and cisub.CadLevelId = ci2.CadLevelid
								and cisub.RollCaste = 16001
								AND year(cisub.ValEffDate) = @AssessmentYear) --ensures that we only pull in the most current cadastre info
				INNER JOIN RevobjSite ros
				on ros.RevObjId = ci.RevObjId
				and ros.EffStatus = 'A'
				and ros.BegEffDate = (select max(BegEffDate) from RevObjSite rossub where rossub.id = ros.id)
				and ros.SiteType <> 15908  --exclude specials sitetype
				INNER JOIN ValueTypeAmount vta
				on vta.HeaderId = ci2.id
				and vta.ValueTypeId in (@vtATR_NetTaxable,@vtATR_FireTax,@vtATR_FloodTax,@vtATR_ImpOnly,@vtATR_LessAgTimber,@vtATR_LessTimber)  --ATR valuetypes
				WHERE ci.RollCaste = 16002		
			END	


		--NET ATR ON SUBROLL EXCLUDING OCCUPANCY (non urd pins)
		 if @RollCaste = 16002 and @OCC_ChangeReason = 'N'
			BEGIN
				INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])   
				SELECT 
					 r.Objectid
					,@vtSUP_ANL_NetATR --ValueTypeId
					,r.Headerid
					,r.AddlObjectId
					,r.SecondaryAddlObjectId
					,case when @OCC_ChangeReason = 'Y' then isnull(w.ValueAmount,0) --if occ list annual only
					 else r.ValueAmount --if not occc list both annual and supp
					 end  -- ValueAmount 
				FROM #Results r   --total of supp and annual net taxable values (which can be used for the Total Supp and Annual ATR;  remember that we don't use the total on occupancy parcels, we use the annual atr) 
				INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels
				ON cisub.id = r.headerid
				LEFT OUTER JOIN #WorkAnnualATR w   --annual ATR values
				ON w.ObjectId = r.ObjectId	
				AND w.ValueTypeId = @vtATR_NetTaxable
				WHERE r.ValueTypeId = @vtSUP_Annual_Net
				and cisub.rollCaste = 16002
				and year(cisub.ValEffDate) = @AssessmentYear
				AND cisub.revobjid not in (select objectid 
										from TifRole tr
										where tr.BegEffDate = (select max(BegEffDate) from TifRole trsub where trsub.id = tr.id)
										and tr.ObjectType = 100002
										and tr.EffStatus = 'A'
										)		
			END	


		--FIRE ATR ON SUBROLL EXCLUDING OCCUPANCY   (non urd pins)
		 if @RollCaste = 16002 and @OCC_ChangeReason = 'N'
			BEGIN
				INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])   
				SELECT 
					 r.Objectid
					,@vtSUP_Anl_FireATR --ValueTypeId
					,r.Headerid
					,r.AddlObjectId
					,r.SecondaryAddlObjectId
					,case when @OCC_ChangeReason = 'Y' then isnull(w.ValueAmount,0) --if occ list annual only
					 else r.ValueAmount --if not occc list both annual and supp
					 end  -- ValueAmount 
				FROM #Results r   --total of supp and annual net taxable values (which can be used for the Total Supp and Annual ATR;  remember that we don't use the total on occupancy parcels, we use the annual atr) 
				INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels
				ON cisub.id = r.headerid
				LEFT OUTER JOIN #WorkAnnualATR w   --annual ATR values
				ON w.ObjectId = r.ObjectId	
				AND w.ValueTypeId = @vtATR_FireTax
				WHERE r.ValueTypeId = @vtSUP_Annual_Fire
				and cisub.rollCaste = 16002
				and year(cisub.ValEffDate) = @AssessmentYear
				AND cisub.revobjid not in (select objectid 
										from TifRole tr
										where tr.BegEffDate = (select max(BegEffDate) from TifRole trsub where trsub.id = tr.id)
										and tr.ObjectType = 100002
										and tr.EffStatus = 'A'
										)		
			END	




		--FLOOD ATR ON SUBROLL EXCLUDING OCCUPANCY(non urd pins)
		 if @RollCaste = 16002  and @OCC_ChangeReason = 'N'
			BEGIN
				INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])   
				SELECT 
					 r.Objectid
					,@vtSUP_ANL_FloodATR --ValueTypeId
					,r.Headerid
					,r.AddlObjectId
					,r.SecondaryAddlObjectId
					,case when @OCC_ChangeReason = 'Y' then isnull(w.ValueAmount,0) --if occ list annual only
					 else r.ValueAmount --if not occc list both annual and supp
					 end  -- ValueAmount 
				FROM #Results r   --total of supp and annual net taxable values (which can be used for the Total Supp and Annual ATR;  remember that we don't use the total on occupancy parcels, we use the annual atr) 
				INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels
				ON cisub.id = r.headerid
				LEFT OUTER JOIN #WorkAnnualATR w   --annual ATR values
				ON w.ObjectId = r.ObjectId	
				AND w.ValueTypeId = @vtATR_FloodTax
				WHERE r.ValueTypeId = @vtSUP_Annual_Flood
				and cisub.rollCaste = 16002
				and year(cisub.ValEffDate) = @AssessmentYear
				AND cisub.revobjid not in (select objectid 
										from TifRole tr
										where tr.BegEffDate = (select max(BegEffDate) from TifRole trsub where trsub.id = tr.id)
										and tr.ObjectType = 100002
										and tr.EffStatus = 'A'
										)		
			END	

		--IMP ONLY ATR ON SUBROLL EXCLUDING OCCUPANCY(non urd pins)
		 if @RollCaste = 16002  and @OCC_ChangeReason = 'N'
			BEGIN
				INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])   
				SELECT 
					 r.Objectid
					,@vtSUP_ANL_ImpATR --ValueTypeId
					,r.Headerid
					,r.AddlObjectId
					,r.SecondaryAddlObjectId
					,case when @OCC_ChangeReason = 'Y' then isnull(w.ValueAmount,0) --if occ list annual only
					 else r.ValueAmount --if not occc list both annual and supp
					 end  -- ValueAmount 
				FROM #Results r   --total of supp and annual net taxable values (which can be used for the Total Supp and Annual ATR;  remember that we don't use the total on occupancy parcels, we use the annual atr) 
				INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels
				ON cisub.id = r.headerid
				LEFT OUTER JOIN #WorkAnnualATR w   --annual ATR values
				ON w.ObjectId = r.ObjectId	
				AND w.ValueTypeId = @vtATR_ImpOnly
				WHERE r.ValueTypeId = @vtSUP_Annual_Imp
				and cisub.rollCaste = 16002
				and year(cisub.ValEffDate) = @AssessmentYear
				AND cisub.revobjid not in (select objectid 
										from TifRole tr
										where tr.BegEffDate = (select max(BegEffDate) from TifRole trsub where trsub.id = tr.id)
										and tr.ObjectType = 100002
										and tr.EffStatus = 'A'
										)		
			END	

		--LESS AG TIMBER ATR ON SUBROLL EXCLUDING OCCUPANCY(non urd pins)
		 if @RollCaste = 16002  and @OCC_ChangeReason = 'N'
			BEGIN
				INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])   
				SELECT 
					 r.Objectid
					,@vtSUP_ANL_AGTbrATR --ValueTypeId
					,r.Headerid
					,r.AddlObjectId
					,r.SecondaryAddlObjectId
					,case when @OCC_ChangeReason = 'Y' then isnull(w.ValueAmount,0) --if occ list annual only
					 else r.ValueAmount --if not occc list both annual and supp
					 end  -- ValueAmount 
				FROM #Results r   --total of supp and annual net taxable values (which can be used for the Total Supp and Annual ATR;  remember that we don't use the total on occupancy parcels, we use the annual atr) 
				INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels
				ON cisub.id = r.headerid
				LEFT OUTER JOIN #WorkAnnualATR w   --annual ATR values
				ON w.ObjectId = r.ObjectId	
				AND w.ValueTypeId = @vtATR_LessAgTimber
				WHERE r.ValueTypeId = @vtSUP_Annual_AgTbr
				and cisub.rollCaste = 16002
				and year(cisub.ValEffDate) = @AssessmentYear
				AND cisub.revobjid not in (select objectid 
										from TifRole tr
										where tr.BegEffDate = (select max(BegEffDate) from TifRole trsub where trsub.id = tr.id)
										and tr.ObjectType = 100002
										and tr.EffStatus = 'A'
										)		
			END	


		--LESS AG TIMBER ATR ON SUBROLL EXCLUDING OCCUPANCY(non urd pins)
		 if @RollCaste = 16002
			BEGIN
				INSERT INTO #Results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])   
				SELECT 
					 r.Objectid
					,@vtSUP_ANL_AGTbrATR --ValueTypeId
					,r.Headerid
					,r.AddlObjectId
					,r.SecondaryAddlObjectId
					,case when @OCC_ChangeReason = 'Y' then isnull(w.ValueAmount,0) --if occ list annual only
					 else r.ValueAmount --if not occc list both annual and supp
					 end  -- ValueAmount 
				FROM #Results r   --total of supp and annual net taxable values (which can be used for the Total Supp and Annual ATR;  remember that we don't use the total on occupancy parcels, we use the annual atr) 
				INNER JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) cisub   --supp parcels
				ON cisub.id = r.headerid
				LEFT OUTER JOIN #WorkAnnualATR w   --annual ATR values
				ON w.ObjectId = r.ObjectId	
				AND w.ValueTypeId = @vtATR_LessTimber
				WHERE r.ValueTypeId = @vtSUP_ANL_TbrATR
				and cisub.rollCaste = 16002
				and year(cisub.ValEffDate) = @AssessmentYear
				AND cisub.revobjid not in (select objectid 
										from TifRole tr
										where tr.BegEffDate = (select max(BegEffDate) from TifRole trsub where trsub.id = tr.id)
										and tr.ObjectType = 100002
										and tr.EffStatus = 'A'
										)		
			END	






---- -----------------------------------------------------------------------------------  
--RETURN RESULTS  
---- -----------------------------------------------------------------------------------  
  SELECT  r.ObjectId  
   , r.ValueTypeId  
   , r.HeaderId  
   , @stCadInv AS HeaderType  
   , r.AddlObjectId  
   , r.SecondaryAddlObjectId  
   , r.ValueAmount  
  FROM #results r  
  ORDER BY HeaderId  
  
 END TRY  
   
--INSERT LOG RESULTS  
 BEGIN CATCH  
  INSERT INTO #log_results VALUES(0,0, ERROR_MESSAGE(), 1)  
 END CATCH  
  
 SELECT * FROM #log_results  
  
--DROP TABLES  
  
drop table #log_results  
drop table #results  
drop table #tempvaluetypeamount  
drop table #work  
drop table #workannualnet  
drop table #worksuppproratedbycat  
drop table #worksuppproratedtotalimponly  
  
END 
GO


