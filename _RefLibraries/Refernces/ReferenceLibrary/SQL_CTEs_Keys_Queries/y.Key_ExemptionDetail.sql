/* aa_KOOTENAI_ExemptionDetail step  */



--sab 05/26/2023 WO21847  1.) Populate new valuetype vt307 and vt308. These are the new valuetypes used to contain the homeowners value after the homeowner exemption (and all other exemptions have been subtracted, ie. Casualty Loss.) has been subtracted. 
--                            vt307 will be used by all taxing districts excluding McCall Fire District. vt308 will be used by the McCall Fire District. 



/****** Object:  StoredProcedure [dbo].[aa_kootenai_exemptionDetail]    Script Date: 6/13/2023 11:53:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'aa_kootenai_exemptionDetail'--sab 05/26/2023
)
	DROP PROCEDURE [dbo].[aa_kootenai_exemptionDetail]
GO    


  --03/20/2023 XTR MWD - staging for release
   
CREATE PROCEDURE [dbo].[aa_kootenai_exemptionDetail]    
 @p_HeaderType                 INT    
 , @p_HeaderId                 INT    
 , @p_ProcessStepTrackingId    INT    
 , @p_BegObjectId              INT    
 , @p_EndObjectId              INT    
 , @p_DebugMode                SMALLINT    
AS    
BEGIN    
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
  ObjectId                INT NOT NULL    
  , ValueTypeId           INT NOT NULL    
  , HeaderId              INT NOT NULL    
  , AddlObjectId          INT NOT NULL    
  , SecondaryAddlObjectId INT NOT NULL    
  , ValueAmount           DECIMAL(28,10) NOT NULL    
 )    
 CREATE CLUSTERED INDEX #results1 on #results ( ValueTypeId, HeaderId )    
    
 CREATE TABLE #log_results    
 (    
  SourceObjectType        INT    
  , SourceObjectId        INT    
  , LogMessage            VARCHAR(256)    
  , IsError               SMALLINT    
 )     
    
 --GENERAL USE WORK TABLE    
 CREATE TABLE #work (    
   id int  not null    
  ,ObjectId int    
  ,ValueTypeId int not null    
  ,HeaderId int not null    
  ,AddlObjectId int    
  ,SecondaryAddlObjectId int    
  ,ValueAmount decimal(28,10)    
  ,flag char(9) null    
  ,ValueAmount2 decimal (28,10) null default 0    
  ,ValueAmount3 decimal (28,10) null default 0    
 )    
 CREATE CLUSTERED INDEX #work1 ON #work( ValueTypeId, HeaderId )    
     
 --ALL MODIFIERS EXCLUDING HO    
 CREATE TABLE #WorkAllModForHO    
 (    
  [Id] [int] NOT NULL,    -- we will be adding records with zeros later    
  [ObjectId] [int] NOT NULL,    
  [ValueTypeId] [int] NOT NULL,    
  [HeaderId] [int] NOT NULL,    
  [AddlObjectId] [int] NOT NULL,    
  [SecondaryAddlObjectId] [int] NOT NULL,    
  [ValueAmount] [decimal](28, 10) NOT NULL,    
  [flag] [varchar](10)  NULL    
 )    
 CREATE CLUSTERED INDEX #WorkAllModForHO1 ON #WorkAllModForHO ( ValueTypeId, HeaderId )    
    
 --HOMEOWNER ELIGIBLE BY CAT WORK TABLE    
 CREATE TABLE #WorkHoElByCat (    
   id int  not null    
  ,ObjectId int    
  ,ValueTypeId int not null    
  ,HeaderId int not null    
  ,AddlObjectId int    
  ,SecondaryAddlObjectId int    
  ,ValueAmount decimal(28,10)    
  ,flag char(9) null    
  ,ValueAmount2 decimal (28,10) null default 0    
  ,ValueAmount3 decimal (28,10) null default 0    
 )    
 CREATE CLUSTERED INDEX #WorkHoElByCat1 on #WorkhoElByCat( ValueTypeId,HeaderId )    
     
 --HOMEOWNER ELIGIBLE BY CAT WORK TABLE    
 CREATE TABLE #WorkValByCatAfHo (    
   id int  not null    
  ,ObjectId int    
  ,ValueTypeId int not null    
  ,HeaderId int not null    
  ,AddlObjectId int    
  ,SecondaryAddlObjectId int    
  ,ValueAmount decimal(28,10)    
  ,flag char(10) null    
  ,ValueAmount2 decimal (28,10) null default 0    
  ,ValueAmount3 decimal (28,10) null default 0    
 )    
 CREATE CLUSTERED INDEX #WorkValByCatAfHo1 ON #WorkValByCatAfHo ( ValueTypeId, HeaderId )    
    
 --HOMEOWNER TOTAL ELIGIBLE WORK TABLE    
 IF exists (select * from sysobjects where name = 'TempTotalHoElig')    
  BEGIN    
   DROP TABLE TempTotalHoElig    
  END    
       
 CREATE TABLE TempTotalHoElig (    
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
 CREATE CLUSTERED INDEX TempTotalHoElig1 ON TempTotalHoElig ( ValueTypeId, ObjectId )    
     
 --HOMEOWNER TOTAL ELIGIBLE WORK TABLE    
 IF exists (select * from sysobjects where name = 'TempCalcCapOverride')    
  BEGIN    
   DROP TABLE TempCalcCapOverride    
  END    
       
 CREATE TABLE TempCalcCapOverride (    
   id int  not null    
  ,ObjectId int    
  ,ValueTypeId int    
  ,HeaderId int      
  ,AddlObjectId int    
  ,SecondaryAddlObjectId int    
  ,ValueAmount decimal(28,10)    
  ,flag char(9) null    
  ,RevObj1Id int    
 )     
 CREATE CLUSTERED INDEX TempCalcCapOverride1 ON TempCalcCapOverride ( ValueTypeId, HeaderId )    
    
 --HOMEOWNER EXEMPTION BY CAT WORK TABLE     
 CREATE TABLE #WorkHoExByCat (    
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
 CREATE CLUSTERED INDEX #WorkHoExByCat1 ON #WorkHoExByCat ( ValueTypeId, HeaderId )    
    
 --HOMEOWNER EXEMPTION IMP ONLY    
 CREATE TABLE #WorkHOEX_ImpOnly (    
   id int  not null    
  ,ObjectId int    
  ,ValueTypeId int    
  ,HeaderId int      
  ,AddlObjectId int    
  ,SecondaryAddlObjectId int    
  ,ValueAmount decimal(28,10)    
  ,flag char(9) null    
  ,ValueAmount2 decimal (28,10) null default 0    
 )    
 CREATE CLUSTERED INDEX #WorkHOEX_ImpOnly1 ON #WorkHOEX_ImpOnly ( ValueTypeId, HeaderId )    
    
 --PTR ELIGIBLE LAND WORK TABLE    
 CREATE TABLE #WorkPTREligLand (    
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
 CREATE CLUSTERED INDEX #WorkPTREligLand1 ON #WorkPTREligLand ( ValueTypeId, HeaderId )    
    
 --PTR ELIGIBLE IMP WORK TABLE    
 CREATE TABLE #WorkPTREligImp (    
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
 CREATE CLUSTERED INDEX #WorkPTREligImp1 ON #WorkPTREligImp ( ValueTypeId, HeaderId )    
     
 --PTR HOMEOWNER WORK TABLE    
 CREATE TABLE #WorkPTRHomeowners (    
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
 CREATE CLUSTERED INDEX #WorkPTRHomeowners1 ON #WorkPTRHomeowners ( ValueTypeId, HeaderId )    
    
 --PTR HOMEOWNER WORK TABLE    
 CREATE TABLE #WorkPTRHomeownersImpOnly (    
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
 CREATE CLUSTERED INDEX #WorkPTRHomeownersImpOnly1 ON #WorkPTRHomeownersImpOnly ( ValueTypeId, HeaderId )    
    
 --ALL MODIFIERS EXCLUDING HO    
 CREATE TABLE #WorkAllModExceptHO    
 (    
  [Id] [int] NOT NULL,    -- we will be adding records with zeros later    
  [ObjectId] [int] NOT NULL,    
  [ValueTypeId] [int] NOT NULL,    
  [HeaderId] [int] NOT NULL,    
  [AddlObjectId] [int] NOT NULL,    
  [SecondaryAddlObjectId] [int] NOT NULL,    
  [ValueAmount] [decimal](28, 10) NOT NULL,    
  [flag] [varchar](10)  NULL    
 )    
 CREATE CLUSTERED INDEX #WorkAllModExceptHO1 ON #WorkAllModExceptHO( ValueTypeId, HeaderId )    
       
 --HOMEOWNER CAP WORK TABLE    
 CREATE TABLE #TempValueTypeAmount    
 (    
  [Id] [int] NOT NULL,    -- we will be adding records with zeros later    
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
 CREATE CLUSTERED INDEX #TempValueTypeAmount1 ON #TempValueTypeAmount ( ValueTypeId, HeaderId )    
    
 --PP EXEMPTION WORK TABLE    
 CREATE TABLE #WorkPPEX (    
   id int  not null    
  ,ObjectId int    
  ,ValueTypeId int    
  ,HeaderId int      
  ,AddlObjectId int    
  ,SecondaryAddlObjectId int    
  ,ValueAmount decimal(28,10)    
  ,flag char(9) null    
  ,ValueAmount2 decimal (28,10) null default 0    
 )    
 CREATE CLUSTERED INDEX #WorkPPEX1 ON #WorkPPEX ( ValueTypeId, HeaderId )    
     

--SUM OF EXEMPTIONS WORK TABLE -EXCLUDING HO  --sab 05/26/2023
CREATE TABLE #workTotalExByCat (
	HeaderId int	
  ,AddlObjectId int 	
  ,TotalExByCat decimal(28,10)
	)
 CREATE CLUSTERED INDEX #workTotalExByCat ON #workTotalExByCat ( HeaderId, AddlObjectId )  

     
 --PP EXEMPTION WORK TABLE FOR SUPP    
 IF exists (select * from sysobjects where name = 'tsb_PPEX_Supp')    
  BEGIN    
   DROP TABLE tsb_PPEX_Supp    
  END     
   CREATE TABLE tsb_PPEX_Supp (    
     ObjectId int    
    ,HeaderId int    
    ,ValueAmountCap decimal(28,10)    
    ,ValueAmountUsed decimal(28,10)    
    ,ValueAmountAvailable decimal(28,10)         
   )    
    
    
 BEGIN TRY    
  --Cadastre Sys Types    
    
  DECLARE @stCadLevel INT; EXEC aa_GetSysTypeId 'Object Type', 'CadLevel',@stCadLevel OUTPUT    
  DECLARE @stCadInv   INT; EXEC aa_GetSysTypeId 'Object Type', 'CadInv',  @stCadInv   OUTPUT    
    
  DECLARE @stExemptionType INT; EXEC aa_GetSysTypeId 'VTCat', 'ExemptionType',   @stExemptionType OUTPUT    
  DECLARE @stPersonal_ofRollType INT; EXEC aa_GetSysTypeId 'RollType', 'Personal', @stPersonal_ofRollType OUTPUT    
    
  DECLARE @ASMTADMIN_ofFCalFunclArea  int; EXEC aa_GetSysTypeId 'FCalFunclArea',    'AsmtAdmin', @ASMTADMIN_ofFCalFunclArea OUTPUT    
    
  DECLARE @vc10H  INT; EXEC aa_GetSysTypeId 'ValCd',   '10H',  @vc10H  OUTPUT --10H Homesite For HO     
  DECLARE @vc12H  INT; EXEC aa_GetSysTypeId 'ValCd',   '12H',  @vc12H  OUTPUT --12H Rural Res For HO    
  DECLARE @vc15H  INT; EXEC aa_GetSysTypeId 'ValCd',   '15H',  @vc15H  OUTPUT --15H Rural Res Sub For HO    
  DECLARE @vc20H  INT; EXEC aa_GetSysTypeId 'ValCd',   '20H',  @vc20H  OUTPUT --20H City Res Lot For HO    
  DECLARE @vc26H  INT; EXEC aa_GetSysTypeId 'ValCd',   '26H',  @vc26H  OUTPUT --26H Condo/twnhse For HO    
  DECLARE @vc26LH  INT; EXEC aa_GetSysTypeId 'ValCd',   '26LH', @vc26LH OUTPUT --26LH Condo Land For HO    
  DECLARE @vc31H  INT; EXEC aa_GetSysTypeId 'ValCd',   '31H',  @vc31H  OUTPUT --31H Res imp on 10 for HO    
  DECLARE @vc34H  INT; EXEC aa_GetSysTypeId 'ValCd',   '34H',  @vc34H  OUTPUT --34H Res imp on 12 for HO    
  DECLARE @vc37H  INT; EXEC aa_GetSysTypeId 'ValCd',   '37H',  @vc37H  OUTPUT --37H Res imp on 15 for HO    
  DECLARE @vc41H  INT; EXEC aa_GetSysTypeId 'ValCd',   '41H',  @vc41H  OUTPUT --41H Res imp on 20 for HO    
  DECLARE @vc46H  INT; EXEC aa_GetSysTypeId 'ValCd',   '46H',  @vc46H  OUTPUT --46H Mfg housing For HO    
  DECLARE @vc47H  INT; EXEC aa_GetSysTypeId 'ValCd',   '47H',  @vc47H  OUTPUT --47H Impr to mfg housing for HO    
  DECLARE @vc48H  INT; EXEC aa_GetSysTypeId 'ValCd',   '48H',  @vc48H  OUTPUT --48H Mfg House on Real Prop HO    
  DECLARE @vc49H  INT; EXEC aa_GetSysTypeId 'ValCd',   '49H',  @vc49H  OUTPUT --49H Manufactured Housing for HO    
  DECLARE @vc50H  INT; EXEC aa_GetSysTypeId 'ValCd',   '50H',  @vc50H  OUTPUT --50H Res imp on Leased Land for HO    
  DECLARE @vc55H  INT; EXEC aa_GetSysTypeId 'ValCd',   '55H',  @vc55H  OUTPUT --55H AIRPLANES/BOATS for HO    
  DECLARE @vc57H  INT; EXEC aa_GetSysTypeId 'ValCd',   '57H',  @vc57H  OUTPUT --57H Equities Imp in State Land HO    
  DECLARE @vc57LH  INT; EXEC aa_GetSysTypeId 'ValCd',   '57LH', @vc57LH OUTPUT --57LH Eq/State Land For HO    
  DECLARE @vc65H  INT; EXEC aa_GetSysTypeId 'ValCd',   '65H',  @vc65H  OUTPUT --65H Mfg housing pers for HO    
  DECLARE @vc69H  INT; EXEC aa_GetSysTypeId 'ValCd',   '69H',  @vc69H  OUTPUT --69H Recreational Vehicles for HO    
    
    
  -- input Value Types    
  DECLARE @vtLandUse           INT; EXEC aa_GetValueTypeId 'LandUse',  @vtLandUse OUTPUT    
  DECLARE @vtLandMarket        INT; EXEC aa_GetValueTypeId 'LandMarket',  @vtLandMarket OUTPUT    
  DECLARE @vtSpecLandDeferred  INT; EXEC aa_GetValueTypeId 'SpecLandDeferred', @vtSpecLandDeferred OUTPUT -- Land Market minum Land Use, matching on attr    
  DECLARE @vtTotalValue   INT; EXEC aa_GetValueTypeId 'Total Value',   @vtTotalValue  OUTPUT --vt109 Total Value    
  DECLARE @vtAssessedByCat     INT; EXEC aa_GetValueTypeId 'AssessedByCat',  @vtAssessedByCat OUTPUT --vt470 AssessedByCat    
  DECLARE @vtHOEX_Cap       INT; EXEC aa_GetValueTypeId 'HOEX_Cap',   @vtHOEX_Cap   OUTPUT --vt301 Homeowner Cap    
  DECLARE @vtHOEX_CapOverride  INT; EXEC aa_GetValueTypeId 'HOEX_CapOverride', @vtHOEX_CapOverride OUTPUT --vt302 Homeowner Calculated Cap Override    
  DECLARE @vtHOEX_CapManual  INT; EXEC aa_GetValueTypeId 'HOEX_CapManual',  @vtHOEX_CapManual OUTPUT --vt303 Homeowner Manual Cap Override    
  DECLARE @vtPTRBenefit      INT; EXEC aa_GetValueTypeId 'PTRBenefit',   @vtPTRBenefit  OUTPUT --vt401 PTR Benefit    
  DECLARE @vtPTRLand       INT; EXEC aa_GetValueTypeId 'PTRLand',    @vtPTRLand   OUTPUT --vt402 PTR Land Percent    
  DECLARE @vtPTRImp       INT; EXEC aa_GetValueTypeId 'PTRImp',    @vtPTRImp   OUTPUT --vt403 PTR Imp Percent    
  DECLARE @vtGovernment   INT; EXEC aa_GetValueTypeId 'Government',   @vtGovernment  OUTPUT --vt201 Government    
  DECLARE @vtReligious   INT; EXEC aa_GetValueTypeId 'Religious',   @vtReligious  OUTPUT --vt202 Religious     
  DECLARE @vtFraternalCharity  INT; EXEC aa_GetValueTypeId 'FraternalCharity', @vtFraternalCharity OUTPUT --vt203 FraternalCharity    
  DECLARE @vtHospital    INT; EXEC aa_GetValueTypeId 'Hospital',   @vtHospital   OUTPUT --vt204 Hospital    
  DECLARE @vtSchool    INT; EXEC aa_GetValueTypeId 'School',    @vtSchool   OUTPUT --vt205 School    
  DECLARE @vtCemeteryLibrary  INT; EXEC aa_GetValueTypeId 'CemeteryLibrary',  @vtCemeteryLibrary OUTPUT --vt206 CemeteryLibrary    
  DECLARE @vtHardship    INT; EXEC aa_GetValueTypeId 'Hardship',   @vtHardship   OUTPUT --vt207 Hardship    
  DECLARE @vtCasualtyLoss   INT; EXEC aa_GetValueTypeId 'CasualtyLoss',  @vtCasualtyLoss  OUTPUT --vt212 CasualtyLoss    
  DECLARE @vtRemediatedLand  INT; EXEC aa_GetValueTypeId 'RemediatedLand',  @vtRemediatedLand OUTPUT --vt208 RemediatedLand    
  DECLARE @vtPostConsumerWste  INT; EXEC aa_GetValueTypeId 'PostConsumerWste', @vtPostConsumerWste OUTPUT --vt209 PostConsumerWste    
  DECLARE @vtLowIncomeHousing  INT; EXEC aa_GetValueTypeId 'LowIncomeHousing', @vtLowIncomeHousing OUTPUT --vt210 LowIncomeHousing    
  DECLARE @vtPollutionControl  INT; EXEC aa_GetValueTypeId 'PollutionControl', @vtPollutionControl OUTPUT --vt211 PollutionControl    
  DECLARE @vtEffectOfChngeUse  INT; EXEC aa_GetValueTypeId 'EffectOfChngeUse', @vtEffectOfChngeUse OUTPUT --vt213 EffectOfChngeUse Exemption    
  DECLARE @vtQIE     INT; EXEC aa_GetValueTypeId 'QIE',     @vtQIE    OUTPUT --vt214 QIE Exemption    
  DECLARE @vtResPropZonedArea  INT; EXEC aa_GetValueTypeId 'ResPropZonedArea', @vtResPropZonedArea OUTPUT --vt215 ResPropZonedArea Exemption    
  DECLARE @vtIntangiblePP   INT; EXEC aa_GetValueTypeId 'IntangiblePP',  @vtIntangiblePP  OUTPUT --vt219 IntangiblePP Exemption    
  DECLARE @vtMHasCowSheepCamp  INT; EXEC aa_GetValueTypeId 'MHasCowSheepCamp', @vtMHasCowSheepCamp OUTPUT --vt220 MHasCowSheepCamp Exemption    
  DECLARE @vtSigCapInvestment  INT; EXEC aa_GetValueTypeId 'SigCapInvestment', @vtSigCapInvestment OUTPUT --vt221 SigCapInvestment Exemption    
  DECLARE @vtPlantInvestment  INT; EXEC aa_GetValueTypeId 'PlantInvestment',  @vtPlantInvestment OUTPUT --vt222 PlantInvestment Exemption    
  DECLARE @vtWildlifeHabitat  INT; EXEC aa_GetValueTypeId 'WildlifeHabitat',  @vtWildlifeHabitat OUTPUT --vt223 WildlifeHabitat Exemption    
  DECLARE @vtSmallEmplrGrowth  INT; EXEC aa_GetValueTypeId 'SmallEmplrGrowth', @vtSmallEmplrGrowth OUTPUT --vt224 SmallEmplrGrowth Exemption    
  DECLARE @vtPPExemptionCap  INT; EXEC aa_GetValueTypeId 'PPExemptionCap',  @vtPPExemptionCap OUTPUT --vt227 PPExemptionCap     
  DECLARE @vtMonths   INT; EXEC aa_GetValueTypeId 'Months',   @vtMonths   OUTPUT --vt710 Months  -- MWD -ADDED    from ProRation
    
  -- Output Value Types    
  DECLARE @vtHOEX_Percent   INT; EXEC aa_GetValueTypeId 'HOEX_Percent',     @vtHOEX_Percent  OUTPUT --vt300 Homeowner Percent    
  DECLARE @vtHOEX_EligibleVal  INT; EXEC aa_GetValueTypeId 'HOEX_EligibleVal', @vtHOEX_EligibleVal OUTPUT --vt304 Homeowner Eligible    
  DECLARE @vtHOEX_Exemption  INT; EXEC aa_GetValueTypeId 'HOEX_Exemption',  @vtHOEX_Exemption OUTPUT --vt305 Homeowner Exemption    --MWD - Prorate
  DECLARE @vtHOEX_ImpOnly   INT; EXEC aa_GetValueTypeId 'HOEX_ImpOnly',  @vtHOEX_ImpOnly  OUTPUT --vt306 Homeowner Exemption Imp Only      --MWD - Prorate  
  DECLARE @vtHTR_Value		 INT; EXEC aa_GetValueTypeId 'HTR_Value',			@vtHTR_Value		OUTPUT --vt307 HTR Value                    --sab 05/26/2023
  DECLARE @vtHTR_ValueImpOnly	 INT; EXEC aa_GetValueTypeId 'HTR_ValueImpOnly',	@vtHTR_ValueImpOnly	OUTPUT --vt308 HTR Value Improvements Only  --sab 05/26/2023
  DECLARE @vtTotalExemptions  INT; EXEC aa_GetValueTypeId 'Total Exemptions', @vtTotalExemptions OUTPUT --vt320 Total Exemptions    --MWD - Prorate    
  DECLARE @vtHOEligibleByCat  INT; EXEC aa_GetValueTypeId 'HOEligibleByCat',  @vtHOEligibleByCat OUTPUT --vt473 Homeowner Eligible By Cat    
  DECLARE @vtHOEX_ByCat   INT; EXEC aa_GetValueTypeId 'HOEX_ByCat',   @vtHOEX_ByCat  OUTPUT --vt472 Homeowner Exemption By Cat    
  DECLARE @vtPTRHO    INT; EXEC aa_GetValueTypeId 'PTRHO',    @vtPTRHO   OUTPUT --vt404 PTR Homeowners Exemption    
  DECLARE @vtPTRValue    INT; EXEC aa_GetValueTypeId 'PTRValue',   @vtPTRValue   OUTPUT --vt405 PTR Taxable Value    
  DECLARE @vtPTRElgLandV   INT; EXEC aa_GetValueTypeId 'PTRElgLandV',   @vtPTRElgLandV  OUTPUT --vt406 PTR Eligible Land Value    
  DECLARE @vtPTRElgImpV   INT; EXEC aa_GetValueTypeId 'PTRElgImpV',   @vtPTRElgImpV  OUTPUT --vt407 PTR Eligible Land Value    
  DECLARE @vtPTRHOImpOnly   INT; EXEC aa_GetValueTypeId 'PTRHOImpOnly',  @vtPTRHOImpOnly  OUTPUT --vt408 PTR Homeowners Exemption    
  DECLARE @vtPTRValImpOnly  INT; EXEC aa_GetValueTypeId 'PTRValImpOnly',  @vtPTRValImpOnly OUTPUT --vt409 PTR Taxable Value    
  DECLARE @vtGovernmentByCat  INT; EXEC aa_GetValueTypeId 'GovernmentByCat',  @vtGovernmentByCat OUTPUT --vt431 GovernmentByCat    
  DECLARE @vtReligiousByCat  INT; EXEC aa_GetValueTypeId 'ReligiousByCat',  @vtReligiousByCat OUTPUT --vt432 Religious By Cat    
  DECLARE @vtFratCharByCat  INT; EXEC aa_GetValueTypeId 'FratCharByCat',  @vtFratCharByCat OUTPUT --vt433 Fraternal/Charitable Exemption    
  DECLARE @vtHospitalByCat  INT; EXEC aa_GetValueTypeId 'HospitalByCat',  @vtHospitalByCat OUTPUT --vt434 HospitalByCat Exemption    
  DECLARE @vtSchoolByCat   INT; EXEC aa_GetValueTypeId 'SchoolByCat',   @vtSchoolByCat  OUTPUT --vt435 SchoolByCat Exemption    
  DECLARE @vtCemLibByCat   INT; EXEC aa_GetValueTypeId 'CemLibByCat',   @vtCemLibByCat  OUTPUT --vt436 CemLibByCat Exemption    
  DECLARE @vtHardshipByCat  INT; EXEC aa_GetValueTypeId 'HardshipByCat',  @vtHardshipByCat OUTPUT --vt490 Hardship Exemption    
  DECLARE @vtCasLossByCat   INT; EXEC aa_GetValueTypeId 'CasLossByCat',  @vtCasLossByCat  OUTPUT --vt491 CasLossByCat Exemption    
  DECLARE @vtRemedLandByCat  INT; EXEC aa_GetValueTypeId 'RemedLandByCat',  @vtRemedLandByCat OUTPUT --vt497 RemedLandByCat Exemption    
  DECLARE @vtPostConsWstByCat  INT; EXEC aa_GetValueTypeId 'PostConsWstByCat', @vtPostConsWstByCat OUTPUT --vt495 PostConsWstByCat Exemption    
  DECLARE @vtLowIncHousByCat  INT; EXEC aa_GetValueTypeId 'LowIncHousByCat',  @vtLowIncHousByCat  OUTPUT --vt493 LowIncHousByCat Exemption    
  DECLARE @vtPollContrByCat  INT; EXEC aa_GetValueTypeId 'PollContrByCat',  @vtPollContrByCat   OUTPUT --vt494 PollContrByCat Exemption    
  DECLARE @vtEffChgUseByCat  INT; EXEC aa_GetValueTypeId 'EffChgUseByCat',  @vtEffChgUseByCat OUTPUT --vt492 EffChgUseByCat Exemption    
  DECLARE @vtIntangPPropByCat  INT; EXEC aa_GetValueTypeId 'IntangPPropByCat', @vtIntangPPropByCat OUTPUT --vt464 IntangPPropByCat Exemption    
  DECLARE @vtMHasCowShpByCat  INT; EXEC aa_GetValueTypeId 'MHasCowShpByCat',  @vtMHasCowShpByCat OUTPUT --vt465 MHasCowShpByCat Exemption    
  DECLARE @vtSigCapInvByCat  INT; EXEC aa_GetValueTypeId 'SigCapInvByCat',  @vtSigCapInvByCat OUTPUT --vt466 SigCapInvByCat Exemption    
  DECLARE @vtPlantInvByCat  INT; EXEC aa_GetValueTypeId 'PlantInvByCat',  @vtPlantInvByCat OUTPUT --vt467 PlantInvByCat Exemption    
  DECLARE @vtWildlifeHabByCat  INT; EXEC aa_GetValueTypeId 'WildlifeHabByCat', @vtWildlifeHabByCat OUTPUT --vt468 WildlifeHabByCat Exemption    
  DECLARE @vtSmallEmplrByCat  INT; EXEC aa_GetValueTypeId 'SmallEmplrByCat',  @vtSmallEmplrByCat OUTPUT --vt469 SmallEmplrByCat Exemption    
  --DECLARE @vtSiteImpExByCat    INT; EXEC aa_GetValueTypeId 'SiteImpExByCat',  @vtSiteImpExByCat OUTPUT --vt499 SiteImpExByCat    
  DECLARE @vtPP_Exemption   INT; EXEC aa_GetValueTypeId 'PP_Exemption',  @vtPP_Exemption  OUTPUT --vt310 PP Exemption    
    
  DECLARE @vtPPExemptionByCat  INT; EXEC aa_GetValueTypeId 'PPExemptionByCat', @vtPPExemptionByCat OUTPUT --vt487 PPExemptionByCat    
  DECLARE @vtObsolescence   INT; EXEC aa_GetValueTypeId 'Obsolescence',  @vtObsolescence OUTPUT --Obsolescence    
    
    
    
-- PROCESS INFO    
    
  DECLARE @v_ProcessStepId INT, @v_ProcessCdTrackingId INT, @v_ProcGrpNumber  INT    
    
  exec dbo.aa_ProcessInformation    
   @p_ProcessStepTrackingId = @v_ProcessStepTrackingId    
   , @p_ProcessStepId         = @v_ProcessStepId OUT    
   , @p_ProcessCdTrackingId   = @v_ProcessCdTrackingId OUT    
   , @p_ProcGrpNumber         = @v_ProcGrpNumber OUT    
    
  IF @v_HeaderType <> @stCadLevel    
  BEGIN    
   RAISERROR (N'Expecting HeaderType of CadLevel', 11, 1)    
  END    
    
-- GET THE ASSESSMENT YEAR    
  DECLARE @AssessmentYear SMALLINT;    
    
  SELECT  @AssessmentYear = MAX(cr.AssessmentYear) FROM  CadRoll cr     
  WHERE EXISTS(SELECT * FROM CadLevel cl WHERE cl.Id = @v_HeaderId AND cl.CadRollId = cr.Id)    
    

-- GET THE ROLL CASTE  --sab 05/26/2023
		DECLARE @RollCaste SMALLINT; 
		
		SELECT  distinct @RollCaste = ci.RollCaste FROM dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci 


-- GET THE HTR CREDIT DATE CRITERIA  (SECOND MONDAY IN JULY EVERY YEAR)  --sab 05/26/2023
		  DECLARE @DATE DATE = '07/01/' + cast(@AssessmentYear as char(4))

		  DECLARE @HTR_DateCriteria date = 
		 ( SELECT
				 DATEADD(mm, DATEDIFF(mm, 0, @DATE), 0) --truncate date to month start
				- DATEPART(dw, 
						5 -- 5 is adjustment so that DATEPART returns 7 for all months starting Mon
						+ DATEADD(mm,datediff(mm,0,@date),0) --truncate date to month start
					) 
				+ 14) --Days added to get to the second Monday in the month
	 


  -- -----------------------------------------------------------------------------------    
  -- -----------------------------------------------------------------------------------    
  -- SOME OF THESE CALCS DEPEND ON OTHERS SO THE ORDER BELOW IS IMPORTANT    
  --    
  -- THESE VALUES WILL BE ALSO PLACED INTO THE #TempValueTypeAmount TABLE FOR USE IN    
  -- LATTER CALCULATIONS BELOW    
  -- -----------------------------------------------------------------------------------    
    
    
  -- -----------------------------------------------------------------------------------    
---- -----------------------------------------------------------------------------------    
---- ALL MODIFIERS FOR HO    
---- -----------------------------------------------------------------------------------    
  Insert into #WorkAllModForHO ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'AllHoMod'   --flag       
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk    
  (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) --all modifiers except ho    
  WHERE ValueTypeId in (@vtHOEX_Cap,@vtHOEX_CapOverride,@vtHOEX_CapManual)     
    
	drop table if exists temp_WorkAllModForHO
	select * into temp_WorkAllModForHO from #WorkAllModForHO
    
---- -----------------------------------------------------------------------------------    
---- HOMEOWNER CAP vt301    
---- -----------------------------------------------------------------------------------    
---- If the user puts a percent on the ho cap modifier, Manatron's sp for modifiers is automatically multiplying    
---- the percent by the cap for that year.  This is not what we want the percent to be used for.  We want the percent    
---- to multiply against the homeowner eligible value instead.  So, we need to update the ho cap in this section and     
---- change the cap back to the original amount before any other calculations are performed.       
    
  UPDATE ValueTypeAmount     
  SET ValueTypeAmount.ValueAmount = mo.ValueAmount, ValueTypeAmount.CalculatedAmount = mo.ValueAmount    
  FROM GRM_AA_ModifierOutputByEffYear( @AssessmentYear, 'A' ) mo,    
  #WorkAllModForHO as vta_HoCat--all eligible cats    
  WHERE vta_HoCat.HeaderId = ValueTypeAmount.Headerid    
  AND vta_HoCat.ObjectId = ValueTypeAmount.ObjectId    
  AND vta_HoCat.ValueTypeId = ValueTypeAmount.ValueTypeid     
  AND vta_HoCat.ValueTypeId = (@vtHOEX_Cap)    
  AND mo.OutputValueTypeId = ValueTypeAmount.ValueTypeId     
  AND mo.ValueAmount <> ValueTypeAmount.ValueAmount    
  AND mo.ModifierId = 7    
  --AND left(mo.BegTaxYear,4) = @AssessmentYear    
  --AND mo.EffStatus = 'A'    
  --AND mo.BegTaxYear = (select max(BegTaxYear) from ModifierOutput mosub where mosub.id = mo.id)      
  AND ValueTypeAmount.ValueTypeId = (@vtHOEX_Cap)    
    
  --RESET CAP TO THE NEW VALUEAMOUNT SET IN THE PREVIOUS STEP    
  update #WorkAllModForHO    
  set ValueAmount = vta.ValueAmount    
  from ValueTypeAmount vta    
  where #WorkAllModForHO.HeaderId = vta.Headerid    
  AND #WorkAllModForHO.ObjectId = vta.ObjectId    
  AND #WorkAllModForHO.ValueTypeId = vta.ValueTypeid     
  AND #WorkAllModForHO.ValueTypeId = (@vtHOEX_Cap)    
  AND #WorkAllModForHO.ValueAmount <> vta.ValueAmount     
    
     
  -- GET VALUETYPES INPUT NEEDED FOR PROCESSING     
  Insert into #TempValueTypeAmount ([Id],[ObjectId],[ValueTypeId],[HeaderType],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[CalculatedAmount],[ProcessStepTrackingId])        
  select vta.Id    
   ,vta.Objectid    
   ,vta.ValueTypeId    
   ,vta.HeaderType    
   ,vta.Headerid    
   ,vta.AddlObjectId    
   ,vta.SecondaryAddlObjectid    
   ,vta.ValueAmount    
   ,vta.CalculatedAmount    
   ,vta.ProcessStepTrackingId    
  from dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta        
  where vta.ValueTypeId IN (@vtHOEX_Cap,@vtHOEX_CapManual,@vtHOEX_CapOverride)    
    
    
		drop table if exists temp_TempValueTypeAmount1
	select * into temp_TempValueTypeAmount1 from #TempValueTypeAmount

---- -----------------------------------------------------------------------------------    
---- HOMEOWNER PERCENT vt300    
---- -----------------------------------------------------------------------------------    
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta.Objectid    
   ,@vtHOEX_Percent --ValueTypeId    
   ,vta.Headerid    
   ,vta.AddlObjectId    
   ,vta.SecondaryAddlObjectId    
   ,rsm.ModifierPercent  -- ValueAmount    
  FROM #TempValueTypeAmount vta    
  INNER JOIN CadInv ci     
   ON ci.id = vta.HeaderId    
    AND vta.HeaderType = @stCadInv -- 100153 = CadInv    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
  CROSS APPLY (SELECT r_sub.Id    
     FROM grm_records_RevObjByEffDate( fcl.EndDate, 'A' ) r_sub    
     WHERE r_sub.id = ci.RevObjId    
   ) AS r    
  CROSS APPLY (SELECT ros_sub.Id    
     FROM GRM_AA_RevObjSiteByEffDate( fcl.EndDate, 'A' ) as ros_sub    
     WHERE ros_sub.RevObjid = r.Id    
      AND ros_sub.SiteType in ( 15905, 15909 ) --includes Real and Default    
   ) AS ros    
  INNER JOIN GRM_AA_RevObjSiteModifierByEffYear( @AssessmentYear, 'A' ) as rsm    
   ON rsm.RevObjSiteId = ros.id    
    AND rsm.ModifierId in ( 7, 8, 9 )     -- SCB OMG  
    AND rsm.ExpirationYear >= @AssessmentYear    
  WHERE vta.ValueTypeId in (@vtHOEX_Cap,@vtHOEX_CapOverride,@vtHOEX_CapManual)    
   AND rsm.ModifierPercent <> 100    
    
		drop table if exists temp_results1
	select * into temp_results1 from #results
    
  -- add homeowner percent to the #Work table so we can use that in a later calc below    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId  (vt300 homeowner percent)     
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'HoPcnt'  --flag   --homeowners percent indicator    
   ,@v_ProcessStepTrackingId    
  FROM #results  --contains the homeowner eligible value    
  WHERE ValueTypeId = @vtHOEX_Percent    
    
    
    
    
---- -----------------------------------------------------------------------------------    
---- HOMEOWNER ELIGIBLE BY CAT vt473    
---- -----------------------------------------------------------------------------------    
 INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
 SELECT vta.Objectid    
  , @vtHOEligibleByCat AS ValueTypeId    
  , vta.HeaderId    
  , vta_Appraised.AddlObjectId   --group code    
  , vta.SecondaryAddlObjectId    
  , round( vta_Appraised.ValueAmount * isnull( w.ValueAmount * .01, 1 ), 0 ) --ValueAmount    
 FROM #TempValueTypeAmount AS vta --parcels with a reg ho cap OR calc cap override OR manual cap override    
 INNER JOIN CadInv AS ci    
  ON ci.id = vta.HeaderId    
   AND vta.HeaderType = @stCadInv -- 100153 = CadInv    
 INNER JOIN ClassCdMap AS ccm    
  ON ccm.ClassCd = ci.ClassCd    
 INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
  ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
   AND fcl.CalendarType = ccm.CalendarType    
 INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) AS vta_Appraised--all eligible cats    
  ON vta_Appraised.HeaderId = vta.HeaderId    
   AND vta_Appraised.ObjectId = vta.ObjectId    
   AND vta_Appraised.ValueTypeId = @vtAssessedByCat    
   AND vta_Appraised.AddlObjectId IN ( SELECT s.id FROM systype AS s    
            WHERE s.SysTypeCatId = 10340 -- 10340 = ValCd    
             AND s.shortDescr like '%H'    
             AND s.EffStatus = 'A'    
             AND s.begEffDate = (select max(STSUB.begEffDate)    
                  from SysType STSUB    
                  where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1) AND STSUB.Id = s.Id    
                 )    
           )    
 LEFT OUTER JOIN #work AS w   --parcels with a ho percent    
  ON  w.headerId = vta.HeaderId    
   AND w.ObjectId = vta.ObjectId    
    
 -- populate #WorkHoElByCat driving table so we can use that in a later calc below    
 Insert into #WorkHoElByCat ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
  [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
 SELECT    
   Headerid  --id    
  ,ObjectId  --ObjectId    
  ,ValueTypeId --ValueTypeId  (vt473 homeowner eligible by cat)     
  ,HeaderId  --HeaderId    
  ,AddlObjectId --AddlObjectId    
  ,SecondaryAddlObjectId --Secondardy    
  ,ValueAmount --ValueAmount     
  ,'HoElByCat' --flag   --homeowners eligible indicator    
  ,@v_ProcessStepTrackingId    
 FROM #results  --contains the homeowner eligible value    
 WHERE ValueTypeId = @vtHOEligibleByCat    
    
    
---- -----------------------------------------------------------------------------------    
---- HOMEOWNER ELIGIBLE TOTAL vt304    
---- -----------------------------------------------------------------------------------    
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta.Objectid    
   ,@vtHOEX_EligibleVal --ValueTypeId    
   ,vta.Headerid    
   ,vta.AddlObjectId    
   ,vta.SecondaryAddlObjectId    
   ,sum(isnull(w.ValueAmount,0))  as ValueAmount    
  FROM #TempValueTypeAmount vta    --used to get the homeowners cap    
  INNER JOIN #WorkHoElByCat w     
  ON w.headerId = vta.HeaderId    
  AND w.ObjectId = vta.ObjectId    
  AND w.flag = 'HoElByCat'      
  AND w.ValueTypeId in (@vtHOEligibleByCat)    
  WHERE vta.ValueTypeId in (@vtHOEX_Cap,@vtHOEX_CapManual,@vtHOEX_CapOverride)    
  GROUP BY     
    vta.Objectid    
   ,vta.Headerid    
   ,vta.AddlObjectId    
   ,vta.SecondaryAddlObjectId    
    
    
  		drop table if exists temp_results2
	select * into temp_results2 from #results
	

  -- add homeowner eligible to the TempTotalHoElig table so we can use that in a later calc below    
  Insert into TempTotalHoElig ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId  (vt304 homeowner eligible)     
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'HoEligTot' --flag   --homeowners exemption indicator    
   ,0--@v_ProcessStepTrackingId    
  FROM #results  --contains the homeowner eligible value    
  WHERE ValueTypeId = @vtHOEX_EligibleVal    
    
    
---- --------------------------------------------------------------------------------------------------------------------------------------    
---- HOMEOWNER CALCULATED CAP OVERRIDE vt302  ON parcels that are not in RelRevObj    
---- --------------------------------------------------------------------------------------------------------------------------------------    
  UPDATE ValueTypeAmount    
  SET ValueAmount = (select ValueAmount     
         from GRM_AA_ModifierOutputByEffYear( @AssessmentYear, 'A' ) mo    
         where mo.ModifierId = 7  --SCB OMG  
         --and left(mo.BegTaxYear,4) = @AssessmentYear    
         --and mo.EffStatus = 'A'    
         --and mo.BegTaxYear = (select max(BegTaxYear) from ModifierOutput mosub where mosub.id = mo.id)    
         ),    
   CalculatedAmount = (select ValueAmount     
         from GRM_AA_ModifierOutputByEffYear( @AssessmentYear, 'A' ) mo    
         where mo.ModifierId = 7  --SCB OMG  
         --and left(mo.BegTaxYear,4) = @AssessmentYear    
         --and mo.EffStatus = 'A'    
         --and mo.BegTaxYear = (select max(BegTaxYear) from ModifierOutput mosub where mosub.id = mo.id)    
         )    
  WHERE ValueTypeId = @vtHOEX_CapOverride    
  AND ObjectId in (select revobjid from cadinv where id in     
        (select headerid from #WorkAllModForHO    
         where ValueTypeId = @vtHOEX_CapOverride    
         )    
       )    
  AND ObjectId not in (select revobj1id --primary pin    
        from RelRevObj rro     
        where rro.EffStatus = 'A'    
        and rro.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rsub where rsub.id = rro.id)     
        )    
  AND ObjectId not in (select revobj2id --secondary pins    
        from RelRevObj rro2     
        where rro2.EffStatus = 'A'    
        and rro2.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rsub where rsub.id = rro2.id)     
        )            
    
    
    
    
---- --------------------------------------------------------------------------------------------------------------------------------------    
---- HOMEOWNER CALCULATED CAP OVERRIDE vt302  ON REVOBJ1ID   --this section updates vt302 which was populated in the Exemption Process Step    
---- --------------------------------------------------------------------------------------------------------------------------------------    
    
  -- add parcels with a calc cap override    
  Insert into TempCalcCapOverride ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[RevObj1Id])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId  (vt304 homeowner eligible)     
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondary    
   ,ValueAmount --ValueAmount     
   ,'CalcCap'  --flag   --homeowners exemption indicator    
   ,0    --lrsn for the primary pin; this field is used when verifying that the total cap between the parcels matches the standard yearly cap    
  FROM #WorkAllModForHO as vta_HoCalcX    
  WHERE ValueTypeId = (@vtHOEX_CapOverride)    
    
    
 DECLARE ID_cursor CURSOR LOCAL    
 FOR    
   SELECT r.Revobj1id    
   FROM RelRevObj r    
 WHERE r.EffStatus = 'A'    
 AND r.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rsub where rsub.id = r.id)    
 AND r.Revobj1id in (select revobjid from cadinv where id in     
        (select headerid from #WorkAllModForHO    
         where ValueTypeId = @vtHOEX_CapOverride))    
 AND r.Revobj1id in (select revobjid from cadinv where id in     
        (select headerid from dbo.GRM_AA_calc_ValueTypeAmountByChunk     
        (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId)    
         where ValueTypeId = @vtTotalValue and valueAmount <> 0 ))          
      
 OPEN id_cursor    
    
 DECLARE @id1 as int    
     
 FETCH NEXT FROM id_cursor INTO @id1    
 WHILE (@@FETCH_STATUS <> -1)    
 BEGIN    
    IF (@@FETCH_STATUS <> -2)    
    BEGIN       
     
   --REGULAR HOMEOWNER CAP    
   declare @hocap integer    
   set @hocap = (select ValueAmount from GRM_AA_ModifierOutputByEffYear( @AssessmentYear, 'A' ) mo where ModifierId = 7 --and left(BegTaxYear,4) = @AssessmentYear    
         )  --SCB OMG  
      
     
   --PARCEL 1 TOTAL ELIGIBLE VALUE REVOBJ1ID    
   declare @PinVal_1 decimal(28,10)    
   set @PinVal_1 = (select tho.ValueAmount      
        FROM TempTotalHoElig tho --total ho eligible after percent applied    
        WHERE tho.ObjectId = @id1    
        AND tho.flag = 'HoEligTot'    
        AND tho.ValueTypeId = @vtHOEX_EligibleVal  --vt304       
       )       
           
    
    
   --PARCEL 2 TOTAL ELIGIBLE VALUE REVOBJ2ID    
   declare @PinId_2 int    
   set @PinId_2 = (select distinct rro.revobj2id      
        FROM CadInv ci      
        INNER JOIN RelRevObj rro    
        ON rro.RevObj1id = ci.RevobjId    
        and rro.Revobj1id = @id1    
        and rro.EffStatus = 'A'    
        and rro.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rrosub where rrosub.id = rro.id)    
        and rro.RevObj2Id = (select min(RevObj2Id)     
              from RelRevObj rrosub2     
              where rrosub2.EffStatus = 'A'    
              and rrosub2.Revobj1id = @id1    
              and rrosub2.BegEffDate = (SELECT max(BegEffDate)     
                   from RelRevObj rrosub3     
                   where rrosub3.id = rrosub2.id    
                   )    
              and rrosub2.RevObj2id in (select objectid     
                      from #WorkAllModForHO as vta_HoCalcX    
                   where ValueTypeId = (@vtHOEX_CapOverride)    
                   )     
              )    
        WHERE ci.EffStatus = 'A'    
        AND ci.revobjid = @id1    
        AND ci.Id in (select HeaderId     
             from #WorkAllModForHO as vta_HoCalcX    
             where ValueTypeId = (@vtHOEX_CapOverride)--secondary pin must have a calc cap override or variable is 0    
             )     
        --AND rro.RevObj2id in (select distinct objectid    
        --       from TempCalcCapOverride    
        --       where ValueTypeId = 302--(@vtHOEX_CapOverride)        
        --       )                  
       )                 
                 
              
       
           
   declare @PinVal_2 decimal(28,10)    
   set @PinVal_2 =  (select tho.ValueAmount      
        FROM TempTotalHoElig tho --total ho eligible after percent applied    
        WHERE tho.ObjectId = @PinId_2    
        AND tho.flag = 'HoEligTot'    
        AND tho.ValueTypeId = @vtHOEX_EligibleVal  --vt304       
        )    
    
    
   --PARCEL 3 TOTAL ELIGIBLE VALUE REVOBJ2ID (this is for a second relationship between the primary parcel and the second secondary parcel)    
   declare @PinId_3 int    
   set @PinId_3 = isnull((select rro.revobj2id      
        FROM CadInv ci      
        INNER JOIN RelRevObj rro    
        ON rro.RevObj1id = ci.RevobjId    
        and rro.Revobj1id = @id1    
        and rro.EffStatus = 'A'    
        and rro.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rrosub where rrosub.id = rro.id)    
        and rro.RevObj2Id <> @PinId_2    
        and rro.RevObj2Id = (select min(RevObj2Id)     
              from RelRevObj rrosub2     
              where rrosub2.EffStatus = 'A'    
              and rrosub2.Revobj1id = @id1    
              and rrosub2.RevObj2id <> @PinId_2    
              and rrosub2.BegEffDate = (SELECT max(BegEffDate)     
                   from RelRevObj rrosub3     
                   where rrosub3.id = rrosub2.id    
                   )    
              and rrosub2.RevObj2id in (select objectid     
                      from #WorkAllModForHO as vta_HoCalcX    
                   where ValueTypeId = (@vtHOEX_CapOverride)    
                   )     
               )    
        WHERE ci.EffStatus = 'A'    
        AND ci.revobjid = @id1    
        --AND ci.Id in (select HeaderId from dbo.GRM_AA_calc_ValueTypeAmountByChunk     
        --    (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_HoCalcX    
        --     where ValueTypeId = (@vtHOEX_CapOverride)    
        --     )    
             and ci.id in (select distinct headerId    
               from TempCalcCapOverride    
               where ValueTypeId = 302--(@vtHOEX_CapOverride)  --SCB OMG      
               )                  
                                
                  
             ),0)       
    
    
   declare @PinVal_3 decimal(28,10)    
   set @PinVal_3 =  (select tho.ValueAmount      
        FROM TempTotalHoElig tho --total ho eligible after percent applied    
        WHERE tho.ObjectId = @PinId_3    
        AND tho.flag = 'HoEligTot'    
        AND tho.ValueTypeId = @vtHOEX_EligibleVal  --vt304       
        )       
        
        
        
    
   ----TOTAL ELIGIBLE VALUE REVOBJ2ID (this is for a second relationship between parcel 1 and another parcel)    
   declare @PinId_4 int    
   set @PinId_4 = isnull((select rro.revobj2id      
        FROM CadInv ci      
        INNER JOIN RelRevObj rro    
        ON rro.RevObj1id = ci.RevobjId    
        and rro.Revobj1id = @id1    
        and rro.EffStatus = 'A'    
        and rro.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rrosub where rrosub.id = rro.id)    
        and rro.RevObj2Id not in (@PinId_2,@PinId_3)    
        and rro.RevObj2Id = (select min(RevObj2Id)     
              from RelRevObj rrosub2     
              where rrosub2.EffStatus = 'A'    
              and rrosub2.Revobj1id = @id1    
              and rrosub2.RevObj2id not in (@PinId_2,@PinId_3)    
              and rrosub2.BegEffDate = (SELECT max(BegEffDate)     
                   from RelRevObj rrosub3     
                   where rrosub3.id = rrosub2.id    
                   )    
              and rrosub2.RevObj2id in (select objectid     
                      from #WorkAllModForHO as vta_HoCalcX    
                   where ValueTypeId = (@vtHOEX_CapOverride)    
                   )                        
              )    
        WHERE ci.EffStatus = 'A'    
        AND ci.revobjid = @id1    
        --AND ci.Id in (select HeaderId from dbo.GRM_AA_calc_ValueTypeAmountByChunk     
        --    (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_HoCalcX    
        --     where ValueTypeId = (@vtHOEX_CapOverride)    
        --     )    
             and ci.id in (select distinct headerId    
               from TempCalcCapOverride    
               where ValueTypeId = 302--(@vtHOEX_CapOverride)  --SCB OMG      
               )                  
             ),0)       
          
       
   declare @PinVal_4 decimal(28,10)    
   set @PinVal_4 =  (select tho.ValueAmount      
        FROM TempTotalHoElig tho --total ho eligible after percent applied    
        WHERE tho.ObjectId = @PinId_4    
        AND tho.flag = 'HoEligTot'    
        AND tho.ValueTypeId = @vtHOEX_EligibleVal  --vt304       
        )     
             
             
   ----TOTAL ELIGIBLE VALUE REVOBJ2ID (this is for a second relationship between parcel 1 and another parcel)    
   declare @PinId_5 int    
   set @PinId_5 = isnull((select rro.revobj2id      
        FROM CadInv ci      
        INNER JOIN RelRevObj rro    
        ON rro.RevObj1id = ci.RevobjId    
        and rro.Revobj1id = @id1    
        and rro.EffStatus = 'A'    
        and rro.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rrosub where rrosub.id = rro.id)    
        and rro.RevObj2Id not in (@PinId_2,@PinId_3,@PinId_4)    
        and rro.RevObj2Id = (select min(RevObj2Id)     
              from RelRevObj rrosub2     
              where rrosub2.EffStatus = 'A'    
              and rrosub2.Revobj1id = @id1    
              and rrosub2.RevObj2id not in (@PinId_2,@PinId_3,@PinId_4)    
              and rrosub2.BegEffDate = (SELECT max(BegEffDate)     
                   from RelRevObj rrosub3     
                   where rrosub3.id = rrosub2.id    
                   )    
              and rrosub2.RevObj2id in (select objectid     
                      from #WorkAllModForHO as vta_HoCalcX    
                   where ValueTypeId = (@vtHOEX_CapOverride)    
                   )                        
             )    
        WHERE ci.EffStatus = 'A'    
        AND ci.revobjid = @id1    
        --AND ci.Id in (select HeaderId from dbo.GRM_AA_calc_ValueTypeAmountByChunk     
        --    (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_HoCalcX    
        --     where ValueTypeId = (@vtHOEX_CapOverride)    
        --     )    
             and ci.id in (select distinct headerId    
               from TempCalcCapOverride    
               where ValueTypeId = 302--(@vtHOEX_CapOverride)      --SCB OMG  
               )                  
             ),0)       
          
       
   declare @PinVal_5 decimal(28,10)    
   set @PinVal_5 =  (select tho.ValueAmount      
        FROM TempTotalHoElig tho --total ho eligible after percent applied    
        WHERE tho.ObjectId = @PinId_5    
        AND tho.flag = 'HoEligTot'    
        AND tho.ValueTypeId = @vtHOEX_EligibleVal  --vt304       
        )         
             
             
             
                     
     
  --REVOBJ1ID Update pin 1; this is the primary pin    
  UPDATE ValueTypeAmount    
  SET ValueTypeAmount.ValueAmount = round(@PinVal_1 / (isnull(@PinVal_1,0) + isnull(@PinVal_2,0) + isnull(@PinVal_3,0) + isnull(@PinVal_4,0) + isnull(@PinVal_5,0)) * @hocap ,0)      
  ,ValueTypeAmount.CalculatedAmount = round(@PinVal_1 / (isnull(@PinVal_1,0) + isnull(@PinVal_2,0) + isnull(@PinVal_3,0) + isnull(@PinVal_4,0) + isnull(@PinVal_5,0)) * @hocap ,0)      
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk     
  (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_HoCalc--ho calc override cats    
  INNER JOIN CadInv ci      
  on ci.id = vta_HoCalc.HeaderId    
  AND ci.EffStatus = 'A'    
  AND ci.revobjid = @id1    
  WHERE vta_HoCalc.HeaderId = ValueTypeAmount.Headerid    
  AND vta_HoCalc.ObjectId = ValueTypeAmount.ObjectId    
  AND vta_HoCalc.ValueTypeId = ValueTypeAmount.ValueTypeid     
  AND vta_HoCalc.ValueTypeId = (@vtHOEX_CapOverride)--ho calc override    
  AND @PinVal_1 > 0    
      
  --update table so that it can be used when dealing with rounding issue on all related parcels with a calc cap override    
  UPDATE TempCalcCapOverride    
  SET RevObj1id = @id1 --primary pin    
  WHERE ObjectId in (@id1,@PinId_2,@PinId_3,@PinId_4,@PinId_5)     
      
  END     
    FETCH NEXT FROM id_cursor INTO @id1    
 END    
 CLOSE id_cursor    
 DEALLOCATE id_cursor    
     
     
    
    
------ -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
------ HOMEOWNER CALCULATED CAP OVERRIDE vt302  ON REVOBJ2ID (secondary parcels related to revobj1id) --this section updates vt302 which was populated in the Exemption Process Step    
------ -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
    
 DECLARE ID_cursor CURSOR LOCAL    
 FOR    
   SELECT r.Revobj2id    
 FROM RelRevObj r    
 WHERE r.EffStatus = 'A'    
 AND r.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rsub where rsub.id = r.id)    
 AND r.Revobj2id in (select revobjid from cadinv where id in     
        (select headerid from #WorkAllModForHO    
         where ValueTypeId = @vtHOEX_CapOverride))    
 AND r.Revobj2id in (select revobjid from cadinv where id in     
        (select headerid from dbo.GRM_AA_calc_ValueTypeAmountByChunk     
        (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId)    
         where ValueTypeId = @vtTotalValue and valueAmount <> 0 ))     
      
 OPEN id_cursor    
    
 DECLARE @id2 as int    
     
 FETCH NEXT FROM id_cursor INTO @id2    
 WHILE (@@FETCH_STATUS <> -1)    
 BEGIN    
    IF (@@FETCH_STATUS <> -2)    
    BEGIN       
     
   --HOMEOWNER CAP    
   declare @hocap2 integer    
   set @hocap2 = (select ValueAmount from GRM_AA_ModifierOutputByEffYear( @AssessmentYear, 'A' ) mo where ModifierId = 7 --and left(BegTaxYear,4) = @assessmentYear    
        )    
    
     
   --REVOBJ2ID TOTAL ELIGIBLE VALUE  (this is the first parcel in revobj2id related to the primary parcel revobj1id)    
   declare @PinId_22 int    
   set @PinId_22 = (select distinct rro.revobj2id      
        FROM CadInv ci      
        INNER JOIN RelRevObj rro    
        ON rro.RevObj2id = ci.RevobjId    
        and rro.Revobj2id = @id2    
        and rro.EffStatus = 'A'    
        and rro.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rrosub where rrosub.id = rro.id)    
        WHERE ci.EffStatus = 'A'    
        AND ci.revobjid = @id2    
        --AND ci.Id in (select HeaderId from dbo.GRM_AA_calc_ValueTypeAmountByChunk     
        --    (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_HoCalcX    
        --     where ValueTypeId = (@vtHOEX_CapOverride)    
        --     )     
       and ci.RevObjid in (select distinct objectid    
            from TempCalcCapOverride    
            where ValueTypeId = 302--(@vtHOEX_CapOverride)      --SCB OMG  
               )                  
       )        
       
   declare @PinVal_22 decimal(28,10)    
   set @PinVal_22 =  (select tho.ValueAmount      
        FROM TempTotalHoElig tho --total ho eligible after percent applied    
        WHERE tho.ObjectId = @PinId_22    
        AND tho.flag = 'HoEligTot'    
        AND tho.ValueTypeId = @vtHOEX_EligibleVal  --vt304       
        )         
             
     
    
   --PARCEL REVOBJ1ID TOTAL ELIGIBLE VALUE    
   declare @PinId_11 int    
   set @PinId_11 = (select rro.revobj1id      
        FROM CadInv ci      
        INNER JOIN RelRevObj rro    
        ON rro.RevObj2id = ci.RevobjId    
        and rro.RevObj2id = @id2    
        and rro.RevObj2id = @PinId_22    
        and rro.EffStatus = 'A'    
        and rro.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rrosub where rrosub.id = rro.id)    
        WHERE ci.EffStatus = 'A'    
        AND ci.revobjid = @id2    
        --AND ci.Id in (select HeaderId from dbo.GRM_AA_calc_ValueTypeAmountByChunk     
        --    (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_HoCalcX    
        --     where ValueTypeId = (@vtHOEX_CapOverride)    
        --     )     
             and ci.id in (select distinct headerId    
               from TempCalcCapOverride    
               where ValueTypeId = 302--(@vtHOEX_CapOverride)      --SCB OMG  
               )                 
                 
       )       
       
    
   declare @PinVal_11 decimal(28,10)    
   set @PinVal_11 =  (select tho.ValueAmount      
        FROM TempTotalHoElig tho --total ho eligible after percent applied    
        WHERE tho.ObjectId = @PinId_11    
        AND tho.flag = 'HoEligTot'    
        AND tho.ValueTypeId = @vtHOEX_EligibleVal  --vt304       
        )    
    
    
    
    
    
    
    
   --TOTAL ELIGIBLE VALUE REVOBJ2ID (this is for a second relationship between parcel 1 and another parcel)    
   declare @PinId_33 int    
   set @PinId_33 = isnull((select rro.revobj2id      
        FROM RelRevObj rro    
        WHERE rro.EffStatus = 'A'    
        and rro.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rrosub where rrosub.id = rro.id)    
        and rro.RevObj1Id in (select revobj1id from RelRevObj rrosub     
               where effStatus = 'A'     
               and RevObj2id = @PinId_22     
               and BegEffDate =     
               (SELECT max(BegEffDate)     
                from RelRevObj rro2     
                where rro2.id = rrosub.id))    
        and rro.RevObj2Id = (select min(RevObj2Id)     
              from RelRevObj rrosub2     
              where rrosub2.EffStatus = 'A'    
              and rrosub2.Revobj1id = rro.RevObj1id    
              and rrosub2.RevObj2id <> @PinId_22    
              and rrosub2.BegEffDate = (SELECT max(BegEffDate)     
                   from RelRevObj rrosub3     
                   where rrosub3.id = rrosub2.id    
                   )    
              --and rrosub2.RevObj2id in (select objectid     
              --        from dbo.GRM_AA_calc_ValueTypeAmountByChunk (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_HoCalcX    
              --     where ValueTypeId = (@vtHOEX_CapOverride)    
              --     )    
              and rrosub2.RevObj2id in (select distinct objectid    
                   from TempCalcCapOverride    
                   where ValueTypeId = 302--(@vtHOEX_CapOverride)     --SCB OMG   
                   )                  
              )    
        ),0)       
          
       
    
   declare @PinVal_33 decimal(28,10)    
   set @PinVal_33 =  (select tho.ValueAmount      
        FROM TempTotalHoElig tho --total ho eligible after percent applied    
        WHERE tho.ObjectId = @PinId_33    
        AND tho.flag = 'HoEligTot'    
        AND tho.ValueTypeId = @vtHOEX_EligibleVal  --vt304       
        )    
    
    
 --  --TOTAL ELIGIBLE VALUE REVOBJ2ID (this is for a second relationship between parcel 1 and another parcel)    
   declare @PinId_44 int    
   set @PinId_44 = isnull((select rro.revobj2id      
        FROM RelRevObj rro    
        WHERE rro.EffStatus = 'A'    
        and rro.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rrosub where rrosub.id = rro.id)    
        and rro.RevObj1Id in (select revobj1id from RelRevObj rrosub     
               where effStatus = 'A'     
               and RevObj2id in (@PinId_22,@PinId_33)     
               and BegEffDate =     
               (SELECT max(BegEffDate)     
                from RelRevObj rro2     
                where rro2.id = rrosub.id))    
        and rro.RevObj2Id = (select min(RevObj2Id)     
              from RelRevObj rrosub2     
              where rrosub2.EffStatus = 'A'    
              and rrosub2.Revobj1id = rro.RevObj1id    
              and rrosub2.RevObj2id not in (@PinId_22,@PinId_33)    
              and rrosub2.BegEffDate = (SELECT max(BegEffDate)     
                   from RelRevObj rrosub3     
                   where rrosub3.id = rrosub2.id    
                   )    
              --and rrosub2.RevObj2id in (select objectid     
              --        from dbo.GRM_AA_calc_ValueTypeAmountByChunk (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_HoCalcX    
              --     where ValueTypeId = (@vtHOEX_CapOverride)    
              --     )     
              and rrosub2.RevObj2id in (select distinct objectid    
                   from TempCalcCapOverride    
                   where ValueTypeId = 302--(@vtHOEX_CapOverride)      --SCB OMG  
                   )                                          
              )    
            ),0)       
          
       
    
   declare @PinVal_44 decimal(28,10)    
   set @PinVal_44 =  (select tho.ValueAmount      
        FROM TempTotalHoElig tho --total ho eligible after percent applied    
        WHERE tho.ObjectId = @PinId_44    
        AND tho.flag = 'HoEligTot'    
        AND tho.ValueTypeId = @vtHOEX_EligibleVal  --vt304       
        )    
    
    
    
 --  --TOTAL ELIGIBLE VALUE REVOBJ2ID (this is for a second relationship between parcel 1 and another parcel)    
   declare @PinId_55 int    
   set @PinId_55 = ISNULL((SELECT rro.revobj2id      
       FROM RelRevObj rro    
       WHERE rro.EffStatus = 'A'    
        AND rro.BegEffDate = (SELECT max(BegEffDate) from RelRevObj rrosub where rrosub.id = rro.id)    
        AND rro.RevObj1Id in (select revobj1id from RelRevObj rrosub     
                where effStatus = 'A'     
                and RevObj2id in (@PinId_22,@PinId_33,@PinId_44)     
                and BegEffDate =     
                (SELECT max(BegEffDate)     
                 from RelRevObj rro2     
                 where rro2.id = rrosub.id))    
        AND rro.RevObj2Id = (select min(RevObj2Id)     
               from RelRevObj rrosub2     
               where rrosub2.EffStatus = 'A'    
               and rrosub2.Revobj1id = rro.RevObj1id    
               and rrosub2.RevObj2id not in (@PinId_22,@PinId_33,@PinId_44)    
               and rrosub2.BegEffDate = (SELECT max(BegEffDate)     
                    from RelRevObj rrosub3     
                    where rrosub3.id = rrosub2.id    
                    )    
               --and rrosub2.RevObj2id in (select objectid     
               --        from dbo.GRM_AA_calc_ValueTypeAmountByChunk (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_HoCalcX    
               --     where ValueTypeId = (@vtHOEX_CapOverride)    
               --     )     
               and rrosub2.RevObj2id in (select distinct objectid    
                    from TempCalcCapOverride    
                    where ValueTypeId = 302--(@vtHOEX_CapOverride)      --SCB OMG  
                    )                                          
            )    
        ),0)       
          
       
    
   declare @PinVal_55 decimal(28,10)    
   SET @PinVal_55 =  ( SELECT tho.ValueAmount    
        FROM TempTotalHoElig tho --total ho eligible after percent applied    
        WHERE tho.ObjectId = @PinId_55    
         AND tho.flag = 'HoEligTot'    
         AND tho.ValueTypeId = @vtHOEX_EligibleVal  --vt304       
      )    
    
    
  --REVOBJ2ID (first parcel related to revobj1id)    
  UPDATE ValueTypeAmount     
  SET ValueTypeAmount.ValueAmount = round(@PinVal_22 / (isnull(@PinVal_22,0) + isnull(@PinVal_11,0) + isnull(@PinVal_33,0)+ isnull(@PinVal_44,0) + isnull(@PinVal_55,0)    
  ) * @hocap2 ,0)    
  ,ValueTypeAmount.CalculatedAmount = round(@PinVal_22 / (isnull(@PinVal_22,0) + isnull(@PinVal_11,0) + isnull(@PinVal_33,0)+ isnull(@PinVal_44,0) + isnull(@PinVal_55,0)    
  ) * @hocap2 ,0)    
  FROM #WorkAllModForHO as vta_HoCalc--ho calc override cats    
  INNER JOIN CadInv ci    
   ON ci.id = vta_HoCalc.HeaderId    
    AND ci.EffStatus = 'A'    
    AND ci.revobjid = @id2    
  WHERE vta_HoCalc.HeaderId = ValueTypeAmount.Headerid    
   AND vta_HoCalc.ObjectId = ValueTypeAmount.ObjectId    
   AND vta_HoCalc.ValueTypeId = ValueTypeAmount.ValueTypeid     
   AND vta_HoCalc.ValueTypeId = (@vtHOEX_CapOverride)--ho calc override    
   AND @PinVal_22 <> 0    
  END    
    
  FETCH NEXT FROM id_cursor INTO @id2    
 END    
 CLOSE id_cursor    
 DEALLOCATE id_cursor    
     
     
 --update #TempValueTypeAmount with the new ho calc cap override so that it can be used when calculating the homeowner exemption in vt472    
 UPDATE #TempValueTypeAmount    
 SET Valueamount = vta.ValueAmount, CalculatedAmount = vta.ValueAmount    
 FROM ValueTypeAmount vta     
 WHERE vta.HeaderId = #TempValueTypeAmount.HeaderId    
 AND vta.ValueTypeId = #TempValueTypeAmount.ValueTypeId    
 AND vta.ValueTypeId = @vtHOEX_CapOverride    
    
 UPDATE TempCalcCapOverride    
 SET ValueAmount = vta.ValueAmount    
 FROM ValueTypeAmount vta     
 WHERE vta.HeaderId = TempCalcCapOverride.HeaderId    
 AND vta.ObjectId = TempCalcCapOverride.ObjectId    
 AND vta.ValueTypeId = TempCalcCapOverride.ValueTypeId    
 AND vta.ValueTypeId = @vtHOEX_CapOverride    
    
    
    
-------------------------------------------------------------------------------------------------------------------------------------    
  --IF THE TOTAL OF THE HO ELIGIBLE IS UNDER/OVER 1 DOLLAR FROM THE STANDARD CAP;     
  --THIS PORTION WILL ADD/SUBTRACT THE REMAINING DOLLAR TO THE PRIMARY PARCEL    
  --THIS CAN HAPPEN WHEN THERE ARE THREE OR MORE SECONDARY PARCELS WITH A CALCULATED CAP OVERRIDE      
-------------------------------------------------------------------------------------------------------------------------------------      
 DECLARE ID_cursor CURSOR LOCAL    
 FOR    
 SELECT distinct RevObj1id    
 FROM TempCalcCapOverride t    
 WHERE RevObj1id <> 0     
 GROUP BY RevObj1Id    
 HAVING sum(ValueAmount) <>  (select ValueAmount --standard cap    
         from GRM_AA_ModifierOutputByEffYear( @AssessmentYear, 'A' ) m    
         where m.ModifierId = 7    
         --and m.effStatus = 'A'    
         --and m.BegTaxYear = (select max(BegTaxYear) from ModifierOutput msub where msub.id = m.id)    
         --and left(m.BegTaxYear,4) = @AssessmentYear    
       ) order by 1    
      
 OPEN id_cursor    
    
 DECLARE @Primary as int    
     
 FETCH NEXT FROM id_cursor INTO @Primary    
 WHILE (@@FETCH_STATUS <> -1)    
 BEGIN    
    IF (@@FETCH_STATUS <> -2)    
    BEGIN       
    
  UPDATE ValueTypeAmount     
  SET ValueTypeAmount.ValueAmount = ValueTypeAmount.ValueAmount +  --calc cap on primary pin     
   (select ValueAmount --standard cap    
    from GRM_AA_ModifierOutputByEffYear( @AssessmentYear, 'A' ) m    
    where m.ModifierId = 7     
    --and m.effStatus = 'A'     
    --and m.BegTaxYear = (select max(BegTaxYear) from ModifierOutput msub where msub.id = m.id)    
    --and left(m.BegTaxYear,4) = @AssessmentYear    
    )    
    - isnull(( select sum(ValueAmount) --total calc cap on all related parcel (both primary and secondary)    
      from TempCalcCapOverride t2    
      where t2.RevObj1id = @Primary    
     )    
     ,0)    
                   
  FROM TempCalcCapOverride as t  --Establish the primary pin which will be used to add the -1 or the +1 difference    
  WHERE ValueTypeAmount.ValueTypeId = @vtHOEX_CapOverride    
  AND t.ObjectId = ValueTypeAmount.ObjectId    
  AND t.HeaderId = ValueTypeAmount.Headerid    
  AND t.ObjectId = @Primary    
    
  --update ValueTypeAmount.CalculatedAmount    
  UPDATE ValueTypeAmount     
  SET ValueTypeAmount.CalculatedAmount = ValueTypeAmount.ValueAmount     
  WHERE ValueTypeAmount.ValueTypeId = @vtHOEX_CapOverride    
  AND ValueTypeAmount.ValueAmount <> ValueTypeAmount.CalculatedAmount    
  AND ValueTypeAmount.ObjectId = @Primary    
    
  END    
    
  FETCH NEXT FROM id_cursor INTO @Primary    
 END    
 CLOSE id_cursor    
 DEALLOCATE id_cursor    
     
     
    
---- -----------------------------------------------------------------------------------    
---- HOMEOWNER EXEMPTION BY CAT vt472    
---- -----------------------------------------------------------------------------------    
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    w.Objectid    
   ,@vtHOEX_ByCat --ValueTypeId    
   ,w.Headerid    
   ,w.AddlObjectId   --group code     
   ,w.SecondaryAddlObjectId    
              --360,000      / 2  > 81,000          then round(27,500        / 360,000        * 81,000      
   ,case when w1.ValueAmount / 2  > vta.ValueAmount then round(w.ValueAmount / w1.ValueAmount * vta.ValueAmount,0)     
      when w1.ValueAmount / 2 <= vta.ValueAmount then round(w.ValueAmount / w1.ValueAmount * round((w1.ValueAmount / 2),0),0)    
      else 0    
    end --ValueAmount    
  FROM #WorkHoElByCat w                --eligible categories rows    
  INNER JOIN TempTotalHoElig w1       --total ho elig --includes ho calc cap override    
ON w1.Objectid = w.ObjectId    
  AND w1.HeaderId = w.HeaderId    
  AND w1.Flag = 'HoEligTot'    
  AND w1.ValueTypeId = @vtHOEX_EligibleVal    
  INNER JOIN #TempValueTypeAmount vta    
  ON vta.ObjectId = w.Objectid    
  AND vta.HeaderId = w.HeaderId    
  AND vta.ValueTypeId IN (@vtHOEX_Cap,@vtHOEX_CapManual,@vtHOEX_CapOverride)  --ho cap    
  AND w1.ValueAmount <> 0    
  WHERE w.Flag = 'HoElByCat'    
  AND w.ValueTypeId = @vtHOEligibleByCat    

  drop table if exists temp_results3
  select * into temp_results3 from #results
    
    
    
-------------------------------------------------------------------------------------------------------------------------------------    
  --IF THE TOTAL OF THE HO ELIGIBLE BY CATEGORY IS UNDER/OVER 1 DOLLAR FROM THE HO CAP; AND THE HO ELIGIBLE VALUE > THE HO CAP     
  --THIS PORTION WILL ADD/SUBTRACT THE REMAINING DOLLAR TO THE LARGEST CATEGORY NUMBER    
  --THIS CAN HAPPEN WHEN THERE ARE AT LEAST TWO OR MORE HO GROUP CODES WHERE THE ROUNDING IS UNDER/OVER BY 1 DOLLAR    
-------------------------------------------------------------------------------------------------------------------------------------      
  UPDATE #results    
  SET #results.ValueAmount = #results.ValueAmount + (vta_HOExCap.ValueAmount - isnull((   select sum(ValueAmount)     
                         from #results v2    
                         where v2.ObjectId = vta_HOExCap.ObjectId    
                         and v2.HeaderId = vta_HOExCap.HeaderId    
                         and v2.ValueTypeId = (@vtHOEX_ByCat)    
                         ),0)    
              )    
  FROM #WorkAllModForHO as vta_HOExCap  --HO Cap    
  WHERE vta_HOExCap.HeaderId = #results.Headerid    
  AND vta_HOExCap.ObjectId = #results.ObjectId    
  AND vta_HOExCap.ValueAmount < isnull((select (sum(ValueAmount)) / 2     
             from #results v2    
             where v2.ObjectId = vta_HOExCap.ObjectId    
             and v2.HeaderId = vta_HOExCap.HeaderId    
             and v2.ValueTypeId = (@vtHOEligibleByCat)    
             ),0)    
  AND vta_HOExCap.ValueTypeId = @vtHOEX_Cap--vt301    
  AND #results.ValueTypeId = @vtHOEX_ByCat  --vt472    
  AND #results.AddlObjectId =(select max(AddlObjectId)    
         from #results r    
         where r.ObjectId = #results.ObjectId    
         and r.HeaderId = #results.HeaderId    
         and r.ValueTypeId = #results.ValueTypeId    
         and r.ValueTypeId = (@vtHOEX_ByCat)    
         )    
     
      drop table if exists temp_results4
  select * into temp_results4 from #results
    
    
  -- populate Work Exemption By Cat driving table so we can use that in a later calc below    
  truncate table #Work      
      
  Insert into #WorkHoExByCat ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT    
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId  (vt473 homeowner eligible by cat)     
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'HoExByCat'   --flag   --homeowners exemption by cat indicator    
   ,@v_ProcessStepTrackingId    
  FROM #results  --contains the homeowner eligible value    
  WHERE ValueTypeId = @vtHOEX_ByCat    
    
	  drop table if exists temp_WorkHoExByCat
  select * into temp_WorkHoExByCat from #WorkHoExByCat
    
  -- populate Work Value After Ho Exemption By Cat driving table so we can use it in a later calc below    
  Insert into #WorkValByCatAfHo ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT    
    vta.HeaderId  --id    
   ,vta.ObjectId  --ObjectId    
   ,vta.ValueTypeId  --ValueTypeId  (vt473 homeowner eligible by cat)     
   ,vta.HeaderId  --HeaderId    
   ,vta.AddlObjectId --AddlObjectId    
   ,vta.SecondaryAddlObjectId --Secondardy    
   ,vta.ValueAmount - isnull(r2.Valueamount,0) --ValueAmount     
   ,'CatValAfHo'  --flag   --homeowners exemption by cat indicator    
   ,@v_ProcessStepTrackingId    
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk( @v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId ) as vta--all eligible cats    
  LEFT OUTER JOIN #results AS r2  --contains the ho ex by cat      
   ON r2.HeaderId = vta.HeaderId    
    AND r2.ObjectId = vta.ObjectId    
    AND r2.AddlObjectId = vta.AddlObjectId    
    AND r2.ValueTypeId = @vtHOEX_ByCat    
  WHERE vta.ValueTypeId = @vtAssessedByCat    
    
    
    
---- -----------------------------------------------------------------------------------    
---- HOMEOWNER TOTAL EXEMPTION vt305    
---- -----------------------------------------------------------------------------------    
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta.Objectid    
   ,@vtHOEX_Exemption --ValueTypeId    
   ,vta.Headerid    
   ,vta.AddlObjectId    
   ,vta.SecondaryAddlObjectId    
   ,sum(w.ValueAmount)  as ValueAmount    
  FROM #TempValueTypeAmount vta    
  inner join #WorkHoExByCat w    
  on w.headerId = vta.HeaderId    
  and w.ObjectId = vta.ObjectId    
  WHERE w.ValueTypeId in (@vtHOEX_ByCat)    
  and w.flag = 'HoExByCat'  --homeowners eligible    
  GROUP BY vta.Objectid, vta.HeaderId, vta.AddlObjectId, vta.SecondaryAddlObjectid    
    
    
  -- add homeowner exemption to the #Work table so we can use that in a later calc below    
  truncate table #Work      
        
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'HoEx'   --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results      
  WHERE ValueTypeId = @vtHOEX_Exemption    
    
    
---- -----------------------------------------------------------------------------------    
---- HOMEOWNER EXEMPTION IMP ONLY vt306    
---- -----------------------------------------------------------------------------------    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta.Objectid    
   ,@vtHOEX_ImpOnly --ValueTypeId    
   ,vta.Headerid    
   ,vta.AddlObjectId    
   ,vta.SecondaryAddlObjectId    
   ,sum(w.ValueAmount)  as ValueAmount    
  FROM #TempValueTypeAmount vta    
  inner join #WorkHoExByCat w    
  on w.headerId = vta.HeaderId    
  and w.ObjectId = vta.ObjectId    
  WHERE w.ValueTypeId in (@vtHOEX_ByCat)    
  and w.flag = 'HoExByCat'  --homeowners eligible    
  and w.AddlObjectId in (@vc26H,@vc31H,@vc34H,@vc37H,@vc41H,@vc46H,@vc47H,@vc48H,@vc49H,@vc50H,@vc55H,@vc57H,@vc65H,@vc69H)    
  GROUP BY vta.Objectid, vta.HeaderId, vta.AddlObjectId, vta.SecondaryAddlObjectid    
    
    
  Insert into #WorkHOEX_ImpOnly ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'HOEX_ImpO'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results           
  WHERE ValueTypeId = @vtHOEX_ImpOnly    
    
    
    
    
    
    
    
---- -----------------------------------------------------------------------------------    
---- ALL MODIFIERS EXCEPT HO    
---- -----------------------------------------------------------------------------------    
  Insert into #WorkAllModExceptHO ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'AllMod'  --flag       
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk    
  (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) --all modifiers except ho    
  WHERE ValueTypeId in (@vtPTRBenefit,@vtPTRLand,@vtPTRImp,@vtGovernment,@vtReligious,@vtFraternalCharity,@vtHospital,    
  @vtSchool,@vtCemeteryLibrary,@vtHardship,@vtCasualtyLoss,@vtRemediatedLand,@vtPostConsumerWste,@vtLowIncomeHousing,@vtPollutionControl,    
  @vtEffectOfChngeUse,@vtQIE,@vtResPropZonedArea,@vtIntangiblePP,@vtMHasCowSheepCamp,@vtSigCapInvestment,@vtPlantInvestment,@vtWildlifeHabitat,    
  @vtSmallEmplrGrowth,@vtPPExemptionCap)     
     
     
---- -----------------------------------------------------------------------------------    
---- PTR ELIGIBLE LAND VALUE vt406    
---- -----------------------------------------------------------------------------------    
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT    
    vta_PTRLand.Objectid    
   ,@vtPTRElgLandV          --ValueTypeId    
   ,vta_PTRLand.Headerid    
   ,vta_PTRLand.AddlObjectId    
   ,vta_PTRLand.SecondaryAddlObjectId    
   ,round(vta_PTRLand.ValueAmount *.01 * sum(isnull(w1.ValueAmount,0)),0)  --ValueAmount    
  FROM #WorkAllModExceptHO AS vta_PTRLand  --all ptr land percent rows    
  INNER JOIN #WorkHoElByCat AS w1 --all ptr land eligible cat rows    
  ON w1.ObjectId = vta_PTRLand.ObjectId    
  AND w1.HeaderId = vta_PTRLand.HeaderId    
  AND w1.ValueTypeId = @vtHOEligibleByCat    
  AND w1.AddlObjectId in (@vc10H,@vc12H,@vc15H,@vc20H,@vc26LH,@vc57LH)    
  WHERE vta_PTRLand.ValueTypeId = @vtPTRLand    
  GROUP BY vta_PTRLand.Objectid    
    ,vta_PTRLand.Headerid    
    ,vta_PTRLand.AddlObjectId    
    ,vta_PTRLand.SecondaryAddlObjectId    
    ,vta_PTRLand.ValueAmount     
    
    
  Insert into #WorkPTREligLand ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT    
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'PTRLand'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results           
  WHERE ValueTypeId = @vtPTRElgLandV    
    
        
---- -----------------------------------------------------------------------------------    
---- PTR ELIGIBLE IMPROVEMENT VALUE vt407    
---- -----------------------------------------------------------------------------------    
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT    
    vta_PTRImp.Objectid    
   ,@vtPTRElgImpV       --ValueTypeId    
   ,vta_PTRImp.Headerid    
   ,vta_PTRImp.AddlObjectId    
   ,vta_PTRImp.SecondaryAddlObjectId    
   ,round(vta_PTRImp.ValueAmount *.01 * sum(isnull(w1.ValueAmount,0)),0)  --ValueAmount    
  FROM #WorkAllModExceptHO as vta_PTRImp--all ptr imp percent rows    
  INNER JOIN #WorkHoElByCat w1--all ptr imp eligible cat rows    
  ON w1.ObjectId = vta_PTRImp.ObjectId    
  AND w1.HeaderId = vta_PTRImp.HeaderId    
  AND w1.ValueTypeId = @vtHOEligibleByCat    
  AND w1.AddlObjectId in (@vc26H,@vc31H,@vc34H,@vc37H,@vc41H,@vc46H,@vc47H,    
                          @vc48H,@vc49H,@vc50H,@vc55H,@vc57H,@vc65H,@vc69H)    
  WHERE vta_PTRImp.ValueTypeId = @vtPTRImp    
  GROUP BY vta_PTRImp.Objectid    
    ,vta_PTRImp.Headerid    
    ,vta_PTRImp.AddlObjectId    
    ,vta_PTRImp.SecondaryAddlObjectId    
    ,vta_PTRImp.ValueAmount    
    
    
  Insert into #WorkPTREligImp ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT    
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'PTRImp'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results           
  WHERE ValueTypeId = @vtPTRElgImpV     
         
         
         
---- -----------------------------------------------------------------------------------    
---- PTR HOMEOWNERS EXEMPTION vt404    
---- -----------------------------------------------------------------------------------    
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT    
    vta.Objectid    
   ,@vtPTRHO       --ValueTypeId    
   ,vta.Headerid    
   ,vta.AddlObjectId    
   ,vta.SecondaryAddlObjectId    
--   ,case when (isnull(wp.ValueAmount,0) + isnull(wi.ValueAmount,0)) / 2 > vta.ValueAmount    
 ,case when ((isnull(wp.ValueAmount,0) + isnull(wi.ValueAmount,0)) / 2  > (vta.ValueAmount * (vta_PTRLandPct.ValueAmount *.01)))  
       then vta.ValueAmount * (vta_PTRLandPct.ValueAmount *.01)  
--         then vta.ValueAmount    
         else round((isnull(wp.ValueAmount,0) + isnull(wi.ValueAmount,0)) / 2 ,0)    
         end --ValueAmount    
  FROM #TempValueTypeAmount vta--all ho cap rows    
  INNER JOIN #WorkAllModExceptHO as vta_PTRBenefit    
  ON vta_PTRBenefit.ObjectId = vta.ObjectId    
  AND vta_PTRBenefit.HeaderId = vta.HeaderId    
  AND vta_PTRBenefit.ValueTypeId IN (@vtPTRBenefit)    
  INNER JOIN #WorkAllModExceptHO as vta_PTRLandPct  
 ON vta_PTRLandPct.ObjectId = vta.ObjectId  
 AND vta_PTRLandPct.HeaderId = vta.HeaderId  
 AND vta_PTRLandPct.ValueTypeId IN (@vtPTRLand)      
  LEFT OUTER JOIN #WorkPTREligImp wi-- ptr imp value rows    
  ON wi.ObjectId = vta.ObjectId    
  AND wi.HeaderId = vta.HeaderId    
  AND wi.ValueTypeId = @vtPTRElgImpV    
  AND wi.Flag = 'PTRImp'    
  LEFT OUTER JOIN #WorkPTREligLand wp-- ptr land value rows    
  ON wp.ObjectId = vta.ObjectId    
  AND wp.HeaderId = vta.HeaderId    
  AND wp.ValueTypeId = @vtPTRElgLandV    
  AND wp.Flag = 'PTRLand'    
  WHERE isnull(wp.ValueAmount,0) + isnull(wi.ValueAmount,0) <> 0    
    
    
  --driving table for PTR Homeowners, this table will be used to calc the PTR Taxable Value    
  Insert into #WorkPTRHomeowners ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
  [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'PTRHO'  --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtPTRHO    
     
    
---- -----------------------------------------------------------------------------------    
---- PTR HOMEOWNERS EXEMPTION IMP ONLY vt408    
---- -----------------------------------------------------------------------------------    
     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta.Objectid    
   ,@vtPTRHOImpOnly       --ValueTypeId    
   ,vta.Headerid    
   ,vta.AddlObjectId    
   ,vta.SecondaryAddlObjectId    
       
   --          40,100 ptrimp            / 2 > 81,000                 
   ,case when isnull(wi.ValueAmount,0) / 2 > vta.ValueAmount     
         then vta.ValueAmount     
         else round(isnull(wi.ValueAmount,0) / 2 ,0)    
         end --ValueAmount    
  FROM #WorkHOEX_ImpOnly vta--all ho cap rows    
  INNER JOIN #WorkAllModExceptHO as vta_PTRBenefit    
  ON vta_PTRBenefit.ObjectId = vta.ObjectId    
  AND vta_PTRBenefit.HeaderId = vta.HeaderId    
  AND vta_PTRBenefit.ValueTypeId IN (@vtPTRBenefit)    
  LEFT OUTER JOIN #WorkPTREligImp wi-- ptr imp value rows    
  ON wi.ObjectId = vta.ObjectId    
  AND wi.HeaderId = vta.HeaderId    
  AND wi.ValueTypeId = @vtPTRElgImpV    
  AND wi.Flag = 'PTRImp'    
  WHERE isnull(wi.ValueAmount,0) <> 0    
    
    
  --driving table for PTR Homeowners, this table will be used to calc the PTR Taxable Value    
  Insert into #WorkPTRHomeownersImpOnly ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
  [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'PTRHOImpO' --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtPTRHOImpOnly    
      
      
      
      
       
---- -----------------------------------------------------------------------------------    
---- PTR TAXABLE VALUE vt405    
---- -----------------------------------------------------------------------------------    
     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    wh.Objectid    
   ,@vtPTRValue       --ValueTypeId    
   ,wh.Headerid    
   ,wh.AddlObjectId    
   ,wh.SecondaryAddlObjectId    
   ,(isnull(wp.ValueAmount,0) + isnull(wi.ValueAmount,0)) - wh.ValueAmount --ValueAmount    
  FROM #WorkPTRHomeowners wh    
  LEFT OUTER JOIN #WorkPTREligImp wi-- ptr imp value rows    
  ON wi.ObjectId = wh.ObjectId    
  AND wi.HeaderId = wh.HeaderId    
  AND wi.ValueTypeId = @vtPTRElgImpV    
  AND wi.Flag = 'PTRImp'    
  LEFT OUTER JOIN #WorkPTREligLand wp-- ptr land value rows    
  ON wp.ObjectId = wh.ObjectId    
  AND wp.HeaderId = wh.HeaderId    
  AND wp.ValueTypeId = @vtPTRElgLandV    
  AND wp.Flag = 'PTRLand'    
  WHERE wh.ValueTypeId = @vtPTRHO    
  AND wh.Flag = 'PTRHO'    
     
      
---- -----------------------------------------------------------------------------------    
---- PTR TAXABLE VALUE IMP ONLY vt409    
---- -----------------------------------------------------------------------------------    
     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    wh.Objectid    
   ,@vtPTRValImpOnly       --ValueTypeId    
   ,wh.Headerid    
   ,wh.AddlObjectId    
   ,wh.SecondaryAddlObjectId    
     --        237,395 ptrimp - 81,000 ptrHoexImpOnly    
   ,isnull(wi.ValueAmount,0) -     
   wh.ValueAmount --ValueAmount    
  FROM #WorkPTRHomeownersImpOnly wh    
  LEFT OUTER JOIN #WorkPTREligImp wi-- ptr imp value rows    
  ON wi.ObjectId = wh.ObjectId    
  AND wi.HeaderId = wh.HeaderId    
  AND wi.ValueTypeId = @vtPTRElgImpV    
  AND wi.Flag = 'PTRImp'    
  WHERE wh.ValueTypeId = @vtPTRHOImpOnly    
  AND wh.Flag = 'PTRHOImpO'     
     
    
---- -----------------------------------------------------------------------------------    
---- GOVERNMENT EXEMPTION vt431    
---- -----------------------------------------------------------------------------------     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta_cat.Objectid    
   ,@vtGovernmentByCat --ValueTypeId    
   ,vta_cat.Headerid    
   ,vta_cat.AddlObjectId   --group code     
   ,vta_cat.SecondaryAddlObjectId    
   ,round(vta_cat.ValueAmount * (vta_gov.ValueAmount * .01),0) --ValueAmount    
  FROM #WorkAllModExceptHO as vta_gov --eligible categories rows    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_cat  --total ho elig     
  ON vta_cat.ObjectId = vta_gov.Objectid    
  AND vta_cat.HeaderId = vta_gov.HeaderId    
  AND vta_cat.ValueTypeId = @vtAssessedByCat    
  WHERE vta_gov.ValueTypeId = @vtGovernment    
      
  --used when figuring the Total Exemptions     
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'Gov'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results      
  WHERE ValueTypeId = @vtGovernmentByCat      
      
         
---- -----------------------------------------------------------------------------------    
---- CHURCH EXEMPTION vt432    
---- -----------------------------------------------------------------------------------     
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta_cat.Objectid    
   ,@vtReligiousByCat --ValueTypeId    
   ,vta_cat.Headerid    
   ,vta_cat.AddlObjectId   --group code     
   ,vta_cat.SecondaryAddlObjectId    
   ,round(vta_cat.ValueAmount * (vta_rel.ValueAmount * .01),0) --ValueAmount    
  FROM #WorkAllModExceptHO vta_rel --eligible categories rows    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_cat       --total ho elig     
  ON vta_cat.ObjectId = vta_rel.Objectid    
  AND vta_cat.HeaderId = vta_rel.HeaderId    
  AND vta_cat.ValueTypeId = @vtAssessedByCat    
  WHERE vta_rel.ValueTypeId = @vtReligious    
      
  --used when figuring the Total Exemptions     
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'Relig'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results      
  WHERE ValueTypeId = @vtReligiousByCat     
      
     
---- -----------------------------------------------------------------------------------    
---- FRATERNAL / CHARITABLE EXEMPTION vt433    
---- -----------------------------------------------------------------------------------     
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta_cat.Objectid    
   ,@vtFratCharByCat --ValueTypeId    
   ,vta_cat.Headerid    
   ,vta_cat.AddlObjectId   --group code     
   ,vta_cat.SecondaryAddlObjectId    
   ,round(vta_cat.ValueAmount * (vta_exe.ValueAmount * .01),0) --ValueAmount    
  FROM #WorkAllModExceptHO vta_exe --eligible categories rows    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_cat       --total ho elig     
  ON vta_cat.ObjectId = vta_exe.Objectid    
  AND vta_cat.HeaderId = vta_exe.HeaderId    
  AND vta_cat.ValueTypeId = @vtAssessedByCat    
  WHERE vta_exe.ValueTypeId = @vtFraternalCharity    
      
  --used when figuring the Total Exemptions     
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'Frat'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results      
  WHERE ValueTypeId = @vtFratCharByCat      
      
     
---- -----------------------------------------------------------------------------------    
---- HOSPITAL EXEMPTION vt434    
---- -----------------------------------------------------------------------------------     
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta_cat.Objectid    
   ,@vtHospitalByCat --ValueTypeId    
   ,vta_cat.Headerid    
   ,vta_cat.AddlObjectId   --group code     
   ,vta_cat.SecondaryAddlObjectId    
   ,round(vta_cat.ValueAmount * (vta_exe.ValueAmount * .01),0) --ValueAmount    
  FROM #WorkAllModExceptHO vta_exe --eligible categories rows    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_cat       --total ho elig     
  ON vta_cat.ObjectId = vta_exe.Objectid    
  AND vta_cat.HeaderId = vta_exe.HeaderId    
  AND vta_cat.ValueTypeId = @vtAssessedByCat    
  WHERE vta_exe.ValueTypeId = @vtHospital    
      
  --used when figuring the Total Exemptions     
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'Hosp'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results      
  WHERE ValueTypeId = @vtHospitalByCat     
      
      
     
---- -----------------------------------------------------------------------------------    
---- SCHOOL EXEMPTION vt435    
---- -----------------------------------------------------------------------------------     
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta_cat.Objectid    
   ,@vtSchoolByCat --ValueTypeId    
   ,vta_cat.Headerid    
   ,vta_cat.AddlObjectId   --group code    
   ,vta_cat.SecondaryAddlObjectId    
   ,round(vta_cat.ValueAmount * (vta_exe.ValueAmount * .01),0) --ValueAmount    
  FROM #WorkAllModExceptHO vta_exe --eligible categories rows    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_cat       --total ho elig     
  ON vta_cat.ObjectId = vta_exe.ObjectId    
   AND vta_cat.HeaderId = vta_exe.HeaderId    
   AND vta_cat.ValueTypeId = @vtAssessedByCat    
  WHERE vta_exe.ValueTypeId = @vtSchool    
      
  --used when figuring the Total Exemptions    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'School'  --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtSchoolByCat    
    
---- -----------------------------------------------------------------------------------    
---- CEMETERY LIBRARY EXEMPTION vt436    
---- -----------------------------------------------------------------------------------     
    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta_cat.Objectid    
   ,@vtCemLibByCat --ValueTypeId    
   ,vta_cat.Headerid    
   ,vta_cat.AddlObjectId   --group code    
   ,vta_cat.SecondaryAddlObjectId    
   ,round(vta_cat.ValueAmount * (vta_exe.ValueAmount * .01),0) --ValueAmount    
  FROM #WorkAllModExceptHO vta_exe --eligible categories rows    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_cat       --total ho elig    
  ON vta_cat.ObjectId = vta_exe.Objectid    
  AND vta_cat.HeaderId = vta_exe.HeaderId    
  AND vta_cat.ValueTypeId = @vtAssessedByCat    
  WHERE vta_exe.ValueTypeId = @vtCemeteryLibrary    
      
  --used when figuring the Total Exemptions     
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'CemLib'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results      
  WHERE ValueTypeId = @vtCemLibByCat       
    
    
------ -----------------------------------------------------------------------------------    
------ PP EXEMPTION CALCULATED EXEMPTION vt310    
------ -----------------------------------------------------------------------------------    
    
------ -----------------------------------------------------------------------------------    
------ PP EXEMPTION CALCULATED EXEMPTION vt310-- 12/12/14 clk added the STCs calculation back to use ppexemption modifier instead of the valueoverride.    
------ -----------------------------------------------------------------------------------    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta_exe.Objectid    
   ,@vtPP_Exemption --ValueTypeId    
   ,vta_exe.Headerid    
   ,vta_exe.AddlObjectId   --group code     
   ,vta_exe.SecondaryAddlObjectId    
   ,case when (isnull(vta_total.ValueAmount,0) - isnull(vta_obo.ValueAmount,0) -     
      isnull(vta_qie.ValueAmount,0)   - isnull(vta_cas.ValueAmount,0)) > vta_exe.ValueAmount     
         then vta_exe.ValueAmount    
         when (isnull(vta_total.ValueAmount,0) - isnull(vta_obo.ValueAmount,0) -     
               isnull(vta_qie.ValueAmount,0)   - isnull(vta_cas.ValueAmount,0)) <= vta_exe.ValueAmount     
         then (isnull(vta_total.ValueAmount,0) - isnull(vta_obo.ValueAmount,0) -     
               isnull(vta_qie.ValueAmount,0)   - isnull(vta_cas.ValueAmount,0))     
      else 0     
    end--ValueAmount    
  FROM #WorkAllModExceptHO vta_exe --pp exemption cap    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_total --total mkt     
  ON vta_total.ObjectId = vta_exe.Objectid    
  AND vta_total.HeaderId = vta_exe.HeaderId    
  AND vta_total.ValueTypeId = @vtTotalValue    
  LEFT OUTER JOIN #WorkAllModExceptHO vta_obo --obosolescence    
  ON vta_total.ObjectId = vta_exe.Objectid    
  AND vta_total.HeaderId = vta_exe.HeaderId    
  AND vta_total.ValueTypeId = @vtObsolescence      
  LEFT OUTER JOIN #WorkAllModExceptHO vta_qie --qie    
  ON vta_total.ObjectId = vta_exe.Objectid    
  AND vta_total.HeaderId = vta_exe.HeaderId    
  AND vta_total.ValueTypeId = @vtQie     
  LEFT OUTER JOIN #WorkAllModExceptHO vta_cas --casualty loss    
  ON vta_total.ObjectId = vta_exe.Objectid    
  AND vta_total.HeaderId = vta_exe.HeaderId    
  AND vta_total.ValueTypeId = @vtCasualtyLoss          
  WHERE vta_exe.ValueTypeId = @vtPPExemptionCap    
    
  -- populate Work Exemption By Cat driving table so we can use that in a later calc below    
  truncate table #WorkPPEX      
      
  Insert into #WorkPPEX ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId  (vt473 homeowner eligible by cat)     
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'PPEX'   --flag   --homeowners exemption by cat indicator    
   ,@v_ProcessStepTrackingId    
  FROM #results  --contains the homeowner eligible value    
  WHERE ValueTypeId = @vtPP_Exemption    
    
--POPULATE tsb_PPEX_Supp    
  INSERT INTO tsb_PPEX_Supp    
  SELECT     
    vta_cap.ObjectId  --ObjectId    
  , vta_cap.HeaderId  --HeaderId    
  , vta_cap.ValueAmount --ValueAmountCap    
  , isnull(vta_used.ValueAmount,0) --ValueAmountUsed    
  , vta_cap.ValueAmount - isnull(vta_used.ValueAmount,0)  --ValueAmountAvailable    
  from #WorkPPEX vta_cap --pp ex cap    
  LEFT OUTER JOIN ValueTypeAmount vta_used  -- exemption actually used for the annual    
  ON vta_used.ObjectId = vta_cap.ObjectId    
  and vta_used.ValueTypeId = 310    
      
  and vta_used.HeaderId in (select ci.id     
          from CadInv ci    
          inner join RevObjSite ros    
          on ros.revobjid = ci.revobjid    
          and ros.id = vta_used.ObjectId    
          and ros.BegEffDate = (select max(BegEffDate) from RevObjSite rossub where rossub.id = ros.id)    
          and ros.EffStatus = 'A'    
          inner join CadLevel cl    
          on cl.id = ci.CadLevelId    
          inner join CadRoll cr    
          on cr.id = cl.CadRollId    
          and cr.AssessmentYear = @AssessmentYear    
          where ci.RollCaste = 16001    
          )     
             
    
    
---- -----------------------------------------------------------------------------------    
---- PP EXEMPTION BY CAT vt487    
---- -----------------------------------------------------------------------------------    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta_cat.Objectid    
   ,@vtPPExemptionByCat  AS ValueTypeId    
   ,vta_cat.HeaderId    
   ,vta_cat.AddlObjectId  -- ValCd    
   ,vta_cat.SecondaryAddlObjectId    
   ,case when (vta_total.ValueAmount - isnull(vta_qie.ValueAmount,0) - isnull(vta_cas.ValueAmount,0))    
      <= vta_exe.ValueAmount    
      then vta_cat.ValueAmount    
      when (vta_total.ValueAmount - isnull(vta_qie.ValueAmount,0) - isnull(vta_cas.ValueAmount,0))    
      > vta_exe.ValueAmount    
      then round(isnull(vta_cat.ValueAmount,0) /     
        (vta_total.ValueAmount - isnull(vta_qie.ValueAmount,0) - isnull(vta_cas.ValueAmount,0)) *    
        vta_exe.ValueAmount,0)    
    else 0    
    end --ValueAmount    
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_cat -- cat value    
  INNER JOIN CadInv ci     
   ON ci.Id = vta_cat.HeaderId    
    AND vta_cat.HeaderType = @stCadInv -- 100153 = CadInv    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
  INNER JOIN #WorkPPEX vta_exe    
   ON vta_exe.ObjectId = vta_cat.Objectid    
    AND vta_exe.HeaderId = vta_cat.HeaderId    
    AND vta_exe.ValueTypeId = @vtPP_Exemption    
    AND vta_exe.Flag = 'PPEX'    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_total --total mkt    
   ON vta_total.ObjectId = vta_exe.Objectid    
    AND vta_total.HeaderId = vta_exe.HeaderId    
    AND vta_total.ValueTypeId = @vtTotalValue    
  LEFT OUTER JOIN #WorkAllModExceptHO vta_qie    
   ON vta_qie.ObjectId = vta_exe.Objectid    
    AND vta_qie.HeaderId = vta_exe.HeaderId    
    AND vta_qie.ValueTypeId = @vtQie    
  LEFT OUTER JOIN #WorkAllModExceptHO vta_cas    
   ON vta_cas.ObjectId = vta_exe.Objectid    
    AND vta_cas.HeaderId = vta_exe.HeaderId    
    AND vta_cas.ValueTypeId = @vtCasualtyLoss    
  WHERE vta_cat.ValueTypeId = @vtAssessedByCat    
   AND vta_cat.AddlObjectId IN (    
         SELECT s.id    
         FROM systype as s    
         where s.systypecatid = 10340 -- 10340 = ValCd    
          AND s.EffStatus = 'A'    
          AND NOT ( s.shortDescr LIKE '94%' OR s.shortDescr LIKE '81%' )    
          AND s.begEffDate = (SELECT MAX(STSUB.begEffDate)    
               FROM SysType STSUB    
               WHERE STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                AND STSUB.Id = s.Id    
              )    
        )    
   AND vta_cat.ValueAmount > 0    
    
  --IF THE TOTAL OF THE PP EX BY CAT IS SHORT 1 DOLLAR FROM THE PP EX CAP ENTERED IN MODIFIERS;     
  --THIS PORTION WILL ADD THE REMAINING DOLLAR TO THE HIGHEST GROUP CODE FOR PP EX    
  --THIS CAN HAPPEN WHEN THERE ARE THREE OR MORE GROUP CODES RECEIVING THE PP EXEMPTION     
  UPDATE #results    
  SET #results.ValueAmount = #results.ValueAmount + (vta_PPEX.ValueAmount - isnull((select sum(ValueAmount)     
                      from #results v2    
                      where v2.ObjectId = vta_PPEX.ObjectId    
                       and v2.HeaderId = vta_PPEX.HeaderId    
    and v2.ValueTypeId = (@vtPPExemptionByCat)    
                     ),0)    
               )    
  FROM #WorkPPEX as vta_PPEX  --pp ex cap    
  WHERE vta_PPEX.HeaderId = #results.Headerid    
  AND vta_PPEX.ObjectId = #results.ObjectId    
  AND vta_PPEX.ValueTypeId = @vtPP_Exemption    
  AND #results.ValueTypeId = @vtPPExemptionByCat    
  AND #results.AddlObjectId = (select max( r.AddlObjectId )    
           from #results r    
           where r.ObjectId = #results.ObjectId    
           and r.HeaderId = #results.HeaderId    
           and r.ValueTypeId = #results.ValueTypeId    
           and r.ValueTypeId = (@vtPPExemptionByCat)    
          )    
       
      
      
  --USED LATER WHEN FIGURING THE TOTAL EXEMPTIONS     
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'PPEX'  --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtPPExemptionByCat    
    
    
---- -----------------------------------------------------------------------------------    
---- HARDSHIP EXEMPTION vt490    
---- -----------------------------------------------------------------------------------     
    
      
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta_cat.Objectid    
   ,@vtHardshipByCat --ValueTypeId    
   ,vta_cat.Headerid    
   ,vta_cat.AddlObjectId   --group code    
   ,vta_cat.SecondaryAddlObjectId    
   ,round((vta_exe.ValueAmount / (vta_tot.ValueAmount - isnull(w.ValueAmount,0))* (vta_cat.ValueAmount - isnull(w2.ValueAmount,0))),0) --ValueAmount    
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_exe --hardship value    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_cat --assessed val           
  ON vta_cat.ObjectId = vta_exe.Objectid    
  AND vta_cat.HeaderId = vta_exe.HeaderId    
  AND vta_cat.ValueTypeId = @vtAssessedByCat    
  LEFT OUTER JOIN #WorkHoExByCat w2  --homeowner ex by cat    
  ON w2.ObjectId = vta_cat.Objectid    
  AND w2.HeaderId = vta_cat.HeaderId    
  AND w2.AddlObjectId = vta_cat.AddlObjectId    
  AND w2.flag = 'HoExByCat'       
  INNER JOIN #WorkAllModExceptHO vta_tot --total value           
  ON vta_tot.ObjectId = vta_exe.Objectid    
  AND vta_tot.HeaderId = vta_exe.HeaderId    
  AND vta_tot.ValueTypeId = @vtTotalValue     
  LEFT OUTER JOIN #Work w  --total homeowner exemption    
  ON w.ObjectId = vta_tot.Objectid    
  AND w.HeaderId = vta_tot.HeaderId    
  AND w.flag = 'HoEx'     
  WHERE vta_exe.ValueTypeId = @vtHardship    
        
       
  --used when figuring the Total Exemptions     
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'Hardship'  --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtHardshipByCat    
     
     
     
---- -----------------------------------------------------------------------------------    
---- CASUALTY LOSS EXEMPTION vt491    
---- -----------------------------------------------------------------------------------     
      
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    vta_cat.Objectid    
   ,@vtCasLossByCat --ValueTypeId    
   ,vta_cat.Headerid    
   ,vta_cat.AddlObjectId   --group code     
   ,vta_cat.SecondaryAddlObjectId    
   ,round((vta_exe.ValueAmount / (vta_tot.ValueAmount - isnull(w.ValueAmount,0))* (vta_cat.ValueAmount - isnull(w2.ValueAmount,0))),0) --ValueAmount    
  FROM #WorkAllModExceptHO vta_exe --casualty loss value    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_cat --assessed val           
  ON vta_cat.ObjectId = vta_exe.Objectid    
  AND vta_cat.HeaderId = vta_exe.HeaderId    
  AND vta_cat.ValueTypeId = @vtAssessedByCat    
  LEFT OUTER JOIN #WorkHoExByCat w2  --homeowner ex by cat    
  ON w2.ObjectId = vta_cat.Objectid    
  AND w2.HeaderId = vta_cat.HeaderId    
  AND w2.AddlObjectId = vta_cat.AddlObjectId    
  AND w2.flag = 'HoExByCat'       
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta_tot --total value           
  ON vta_tot.ObjectId = vta_exe.Objectid    
  AND vta_tot.HeaderId = vta_exe.HeaderId    
  AND vta_tot.ValueTypeId = @vtTotalValue     
  LEFT OUTER JOIN #Work w  --total homeowner exemption    
  ON w.ObjectId = vta_tot.Objectid    
  AND w.HeaderId = vta_tot.HeaderId    
  AND w.flag = 'HoEx'     
  WHERE vta_exe.ValueTypeId = @vtCasualtyLoss    
    
    
  --IF THE TOTAL OF THE CAS LOSS BY CAT IS SHORT 1 DOLLAR FROM THE CAS LOSS ENTERED IN MODIFIERS;     
  --THIS PORTION WILL ADD THE REMAINING DOLLAR TO THE HIGHEST GROUP CODE FOR CASUALTY LOSS    
  --THIS CAN HAPPEN WHEN THERE ARE THREE OR MORE GROUP CODES RECEIVING THE CASUALTY LOSS EXEMPTION     
  UPDATE #results     
  SET #results.ValueAmount = #results.ValueAmount + (vta_CasLoss.ValueAmount - isnull((select sum(ValueAmount)     
                       from #results v2    
                       where v2.ObjectId = vta_CasLoss.ObjectId    
                       and v2.HeaderId = vta_CasLoss.HeaderId    
                       and v2.ValueTypeId = (@vtCasLossByCat)    
                       ),0)    
               )    
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk    
  (@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_CasLoss  --Casualty Loss total    
  WHERE vta_CasLoss.HeaderId = #results.Headerid    
  AND vta_CasLoss.ObjectId = #results.ObjectId    
  AND vta_CasLoss.ValueTypeId = @vtCasualtyLoss    
  AND #results.ValueTypeId = @vtCasLossByCat    
  AND #results.AddlObjectId = (select max( r.AddlObjectId )    
         from #results r    
         where r.ObjectId = #results.ObjectId    
          and r.HeaderId = #results.HeaderId    
          and r.ValueTypeId = #results.ValueTypeId    
          and r.ValueTypeId = (@vtCasLossByCat)    
        )    
    
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'CasLoss'  --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results      
  WHERE ValueTypeId = @vtCasLossByCat     
     
     
      
      
      
---- -----------------------------------------------------------------------------------    
---- REMEDIATED LAND BY CAT vt497    
---- -----------------------------------------------------------------------------------     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT w.Objectid    
   ,@vtRemedLandByCat --ValueTypeId    
   ,w.Headerid    
   ,w.AddlObjectId   --group code    
   ,w.SecondaryAddlObjectId    
   ,round(isnull(w.ValueAmount,0) / sum(isnull(w2.ValueAmount,0)) * vta.ValueAmount,0)    
  FROM #WorkAllModExceptHO vta --remediated land exemption    
  INNER JOIN CadInv ci    
   ON ci.id = vta.HeaderId    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
   INNER JOIN #WorkValByCatAfHo w --value by cat after ho ex subtracted out    
  ON w.HeaderId = vta.HeaderId    
   AND w.ObjectId = vta.ObjectId    
   AND w.AddlObjectId in ( select s.id    
         from systype as s    
         where s.systypecatid = 10340    
          and s.EffStatus = 'A'    
          and s.begEffDate = (select max(STSUB.begEffDate)    
               from SysType STSUB    
               where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                and STSUB.Id = s.Id    
              )    
          and s.shortDescr in (    
             select c.tbl_element     
             from codes_table c    
             where c.tbl_type_code = 'impgroup'    
              and c.code_status = 'A'    
              and c.num_1 = 0 -- -- 0 = land, 1 = impr, 9 = ppa    
             )    
        )    
  INNER JOIN #WorkValByCatAfHo w2 --used to sum total land after ho    
   ON w2.HeaderId = w.HeaderId    
    AND w2.ObjectId = w.ObjectId    
    AND w2.AddlObjectId in (    
         select s.id    
         from systype as s    
         where s.systypecatid = 10340    
          and s.EffStatus = 'A'    
          and s.begEffDate = (select max(STSUB.begEffDate)    
               from SysType STSUB    
               where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                and STSUB.Id = s.Id    
              )    
          and s.shortDescr in (    
            select c.tbl_element    
            from codes_table c    
            where c.tbl_type_code = 'impgroup'    
             and c.code_status = 'A'    
             and c.num_1 = 0 -- -- 0 = land, 1 = impr, 9 = ppa    
           )    
       )    
  WHERE vta.ValueTypeId = @vtRemediatedLand    
  GROUP BY w.Objectid    
   ,w.Headerid    
   ,w.AddlObjectId    
   ,w.SecondaryAddlObjectId    
   ,w.ValueAmount    
   ,vta.ValueAmount    
    
    
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'RemLand'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtRemedLandByCat    
    
    
---- -----------------------------------------------------------------------------------    
---- POST CONSUMER WASTE BY CAT vt495    
---- -----------------------------------------------------------------------------------     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    w.Objectid    
   ,@vtPostConsWstByCat --ValueTypeId    
   ,w.Headerid    
   ,w.AddlObjectId   --group code    
   ,w.SecondaryAddlObjectId    
   ,round(isnull(w.ValueAmount,0) / sum(isnull(w2.ValueAmount,0)) * vta.ValueAmount,0)     
  FROM #WorkAllModExceptHO vta --post consumer waste exemption    
  INNER JOIN CadInv ci    
   ON ci.id = vta.HeaderId    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
   INNER JOIN #WorkValByCatAfHo AS w --value by cat after ho ex subtracted out    
   ON w.HeaderId = vta.HeaderId    
    AND w.ObjectId = vta.ObjectId    
    AND w.AddlObjectId in (select s.id    
          from systype as s    
          where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType STSUB   
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (    
             select c.tbl_element    
             from codes_table c    
             where c.tbl_type_code = 'impgroup'    
              and c.code_status = 'A'    
              and c.num_1 = 1 -- -- 0 = land, 1 = impr, 9 = ppa    
              and c.tbl_element in ('38','39','42','43','44')    
            )    
         )    
  INNER JOIN #WorkValByCatAfHo w2 --used to sum total land after ho    
   ON w2.HeaderId = w.HeaderId    
    AND w2.ObjectId = w.ObjectId    
    AND w2.AddlObjectId in (select s.id    
          from systype as s    
          where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (    
            select c.tbl_element    
            from codes_table c    
            where c.tbl_type_code = 'impgroup'    
             and c.code_status = 'A'    
             and c.num_1 = 1 -- -- 0 = land, 1 = impr, 9 = ppa    
             and c.tbl_element in ('38','39','42','43','44')    
           )    
       )    
  WHERE vta.ValueTypeId = @vtPostConsumerWste    
  GROUP BY w.Objectid    
   ,w.Headerid    
   ,w.AddlObjectId    
   ,w.SecondaryAddlObjectId    
   ,w.ValueAmount    
   ,vta.ValueAmount    
    
       
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'PostConWs'  --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results      
  WHERE ValueTypeId = @vtPostConsWstByCat    
      
      
      
---- -----------------------------------------------------------------------------------    
---- LOW INCOME HOUSING BY CAT vt493    
---- -----------------------------------------------------------------------------------     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT w.Objectid    
   ,@vtLowIncHousByCat --ValueTypeId    
   ,w.Headerid    
   ,w.AddlObjectId   --group code     
   ,w.SecondaryAddlObjectId    
   ,round(isnull(w.ValueAmount,0) / sum(isnull(w2.ValueAmount,0)) * vta.ValueAmount,0)     
  FROM #WorkAllModExceptHO vta --low income housing exemption    
  INNER JOIN CadInv ci     
   ON ci.id = vta.HeaderId    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
   INNER JOIN #WorkValByCatAfHo w --value by cat after ho ex subtracted out    
   ON w.HeaderId = vta.HeaderId    
    AND w.ObjectId = vta.ObjectId    
    AND w.AddlObjectId in (    
         select s.id    
         from systype as s    
         where s.systypecatid = 10340    
          and s.EffStatus = 'A'    
          and s.begEffDate = (select max(STSUB.begEffDate)    
               from SysType STSUB    
               where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                and STSUB.Id = s.Id    
              )    
          and s.shortDescr in (select c.tbl_element    
              from codes_table c    
              where c.tbl_type_code = 'impgroup'    
               and c.code_status = 'A'    
               and c.num_1 = 1 -- -- 0 = land, 1 = impr, 9 = ppa    
               and c.tbl_element between '37' and '44'    
              )     
        )     
  INNER JOIN #WorkValByCatAfHo w2 --used to sum total land after ho    
   ON w2.HeaderId = w.HeaderId    
    AND w2.ObjectId = w.ObjectId    
    AND w2.AddlObjectId in (select s.id    
           from systype as s    
           where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (    
              select c.tbl_element    
              from codes_table as c    
              where c.tbl_type_code = 'impgroup'    
               and c.code_status = 'A'    
               and c.num_1 = 1 -- -- 0 = land, 1 = impr, 9 = ppa    
               and c.tbl_element between '37' and '44'    
             )    
        )    
  WHERE vta.ValueTypeId = @vtLowIncomeHousing    
  GROUP BY w.Objectid    
   ,w.Headerid    
   ,w.AddlObjectId       
   ,w.SecondaryAddlObjectId    
   ,w.ValueAmount    
   ,vta.ValueAmount    
    
    
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'LowInc'  --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtLowIncHousByCat    
    
    
---- -----------------------------------------------------------------------------------    
---- POLLUTION CONTROL BY CAT vt494    
---- -----------------------------------------------------------------------------------     
  INSERT INTO #results ( [ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount] )    
  SELECT vta_AssessedByCat.ObjectId    
   , @vtPollContrByCat --ValueTypeId    
   , vta_AssessedByCat.Headerid    
   , vta_AssessedByCat.AddlObjectId   --group code    
   , 0    AS SecondaryAddlObjectId    
   , SUM( vta_AssessedByCat.ValueAmount ) AS ValueAmount    
  FROM  dbo.GRM_AA_calc_ValueTypeAmountByChunk( @v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId ) as vta_AssessedByCat--all eligible cats    
  INNER JOIN CadInv AS ci    
   ON ci.Id = vta_AssessedByCat.HeaderId    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
  WHERE vta_AssessedByCat.ValueTypeId = @vtAssessedByCat    
   AND vta_AssessedByCat.AddlObjectId IN (    
         select s.id    
         from systype as s    
         where s.systypecatid = 10340 -- 10340 = ValCd    
          and s.EffStatus = 'A'    
          and s.shortDescr LIKE '94%'    
          and s.begEffDate = (select max(STSUB.begEffDate)    
               from SysType STSUB    
               where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                and STSUB.Id = s.Id    
              )    
         )     
  GROUP BY vta_AssessedByCat.ObjectId    
   , vta_AssessedByCat.HeaderId    
   , vta_AssessedByCat.AddlObjectId    
    
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'PollCtrl'  --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results      
  WHERE ValueTypeId = @vtPollContrByCat    
    
---- -----------------------------------------------------------------------------------    
---- EFFECT OF CHANGE OF USE BY CAT vt492    
---- -----------------------------------------------------------------------------------     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    w.Objectid    
   ,@vtEffChgUseByCat --ValueTypeId    
   ,w.Headerid    
   ,w.AddlObjectId   --group code     
   ,w.SecondaryAddlObjectId    
   ,round(isnull(w.ValueAmount,0) / sum(isnull(w2.ValueAmount,0)) * vta.ValueAmount,0)     
  FROM #WorkAllModExceptHO vta --effect of change of use exemption    
  INNER JOIN CadInv AS ci    
   ON ci.id = vta.HeaderId    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
   INNER JOIN #WorkValByCatAfHo AS w --value by cat after ho ex subtracted out    
   ON w.HeaderId = vta.HeaderId    
    AND w.ObjectId = vta.ObjectId    
    AND w.AddlObjectId IN ( select s.id    
          from systype as s    
          where s.systypecatid = 10340 -- 10340 = ValCd    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (select c.tbl_element    
               from codes_table c    
               where c.tbl_type_code = 'impgroup'    
                and c.code_status = 'A'    
                and c.num_1 = 0 -- -- 0 = land, 1 = impr, 9 = ppa    
               )    
          )     
  INNER JOIN #WorkValByCatAfHo AS w2 --used to sum total land after ho    
   ON w2.HeaderId = w.HeaderId    
    AND w2.ObjectId = w.ObjectId    
    AND w2.AddlObjectId in (select s.id    
          from systype as s    
          where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (select c.tbl_element    
               from codes_table c    
               where c.tbl_type_code = 'impgroup'    
                and c.code_status = 'A'    
                and c.num_1 = 0 -- -- 0 = land, 1 = impr, 9 = ppa    
               )    
        )    
  WHERE vta.ValueTypeId = @vtEffectOfChngeUse    
  GROUP BY w.Objectid    
   ,w.Headerid    
   ,w.AddlObjectId       
   ,w.SecondaryAddlObjectId    
   ,w.ValueAmount    
   ,vta.ValueAmount    
    
    
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'EffChgUse'  --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtEffChgUseByCat    
      
    
        
      
      
---- -----------------------------------------------------------------------------------------------------------------------    
---- QIE BY CAT vt214  (The QIE exemption by cat is already populated in the group code area from posting/pvinterface and the     
----                    aa_IDAHO_assessed sp.  This section will sum the qie and place it in vt214.    
---- -----------------------------------------------------------------------------------------------------------------------     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT    
    vta.Objectid    
   ,@vtQIE --ValueTypeId    
   ,vta.HeaderId    
   ,0      --group code    
   ,vta.SecondaryAddlObjectId    
   ,sum(isnull(vta.ValueAmount,0))    
  FROM #WorkAllModExceptHO AS vta --qie    
  INNER JOIN CadInv AS ci    
   ON ci.id = vta.HeaderId    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
  WHERE vta.ValueTypeId = @vtAssessedByCat    
   AND vta.AddlObjectId in (select s.id    
          from systype as s    
          where s.systypecatid = 10340    
          and s.EffStatus = 'A'    
          and s.begEffDate = (select max(STSUB.begEffDate)    
               from SysType STSUB    
               where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                and STSUB.Id = s.Id    
              )    
           and s.shortDescr in (select c.tbl_element    
               from codes_table c    
               where c.tbl_type_code = 'impgroup'    
                and c.code_status = 'A'    
                and c.num_1 = 9 -- -- 0 = land, 1 = impr, 9 = ppa    
                and c.tbl_element like '%Q'    
               )    
         )    
  GROUP BY vta.Objectid    
   ,vta.Headerid    
   ,vta.AddlObjectId    
   ,vta.SecondaryAddlObjectId    
    
    
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'QIE'   --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtQIE    
    
    
---- -----------------------------------------------------------------------------------    
---- INTANGIBLE PERSONAL PROPERTY BY CAT 602L  vt464    
---- -----------------------------------------------------------------------------------     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT vta2.Objectid    
   ,@vtIntangPPropByCat --ValueTypeId    
   ,vta2.Headerid    
   ,vta2.AddlObjectId   --group code    
   ,vta2.SecondaryAddlObjectId    
   ,round(isnull(vta2.ValueAmount,0) / sum(isnull(w2.ValueAmount,0)) * vta.ValueAmount,0)    
  FROM #WorkAllModExceptHO vta --intangible pp exemption    
  INNER JOIN CadInv AS ci    
   ON ci.id = vta.HeaderId    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) as vta2    
   ON vta2.ObjectId = vta.ObjectId    
    AND vta2.HeaderId = vta.HeaderId    
     AND vta2.AddlObjectId in (    
        select s.id    
        from systype as s    
        where s.systypecatid = 10340    
          and s.EffStatus = 'A'    
          and s.begEffDate = (select max(STSUB.begEffDate)    
               from SysType as STSUB    
               where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                and STSUB.Id = s.Id    
              )    
          and s.shortDescr in (select c.tbl_element    
               from codes_table c    
               where c.tbl_type_code = 'impgroup'    
                and c.code_status = 'A'    
                and c.num_1 = 9 -- -- 0 = land, 1 = impr, 9 = ppa    
                and c.tbl_element not like '%Q'    
              )    
        )    
  INNER JOIN #WorkValByCatAfHo w2 --used to sum total land after ho    
   ON w2.HeaderId = vta2.HeaderId    
    AND w2.ObjectId = vta2.ObjectId    
    AND w2.AddlObjectId in (select s.id    
          from systype as s    
          where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (select c.tbl_element    
               from codes_table c    
               where c.tbl_type_code = 'impgroup'    
                and c.code_status = 'A'    
                and c.num_1 = 9 -- -- 0 = land, 1 = impr, 9 = ppa    
                and c.tbl_element not like '%Q'    
               )    
          )    
  WHERE vta.ValueTypeId = @vtIntangiblePP    
  GROUP BY vta2.Objectid    
   ,vta2.Headerid    
   ,vta2.AddlObjectId    
   ,vta2.SecondaryAddlObjectId    
   ,vta2.ValueAmount    
   ,vta.ValueAmount    
    
    
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'IntangPP'  --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtIntangPPropByCat    
    
---- -----------------------------------------------------------------------------------    
---- MH HOME COW/SHEEP CAMP BY CAT 602DD  vt465    
---- -----------------------------------------------------------------------------------    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT    
    vta2.Objectid    
   ,@vtMHasCowShpByCat --ValueTypeId    
   ,vta2.Headerid    
   ,vta2.AddlObjectId   --group code    
   ,vta2.SecondaryAddlObjectId    
   ,round(isnull(vta2.ValueAmount,0) / sum(isnull(w2.ValueAmount,0)) * vta.ValueAmount,0)    
  FROM #WorkAllModExceptHO vta --mh home cow sheep camp exemption    
  INNER JOIN CadInv AS ci    
   ON ci.id = vta.HeaderId    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) as vta2    
   ON vta2.ObjectId = vta.ObjectId    
    AND vta2.HeaderId = vta.HeaderId    
     AND vta2.AddlObjectId in (    
        select s.id    
        from systype as s    
        where s.systypecatid = 10340    
         and s.EffStatus = 'A'    
         and s.begEffDate = (select max(STSUB.begEffDate)    
              from SysType as STSUB    
              where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
               and STSUB.Id = s.Id    
             )    
         and s.shortDescr in (select c.tbl_element    
              from codes_table c    
              where c.tbl_type_code = 'impgroup'    
               and c.code_status = 'A'    
               and c.num_1 = 1 -- -- 0 = land, 1 = impr, 9 = ppa    
               and c.tbl_element in ('46','46H','47','47H','48','48H','65','65H')    
             )    
        )    
  INNER JOIN #WorkValByCatAfHo w2 --used to sum total land after ho    
   ON w2.HeaderId = vta2.HeaderId    
    AND w2.ObjectId = vta2.ObjectId    
    AND w2.AddlObjectId in (select s.id    
          from systype as s    
          where s.systypecatid = 10340     
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType as STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (select c.tbl_element    
                from codes_table c    
                where c.tbl_type_code = 'impgroup'    
                 and c.code_status = 'A'    
                 and c.num_1 = 1 -- -- 0 = land, 1 = impr, 9 = ppa    
                 and c.tbl_element in ('46','46h','47','47H','48','48H','65','65H')    
               )    
        )    
  WHERE vta.ValueTypeId = @vtMHasCowSheepCamp    
  GROUP BY vta2.Objectid    
   ,vta2.Headerid    
   ,vta2.AddlObjectId       
   ,vta2.SecondaryAddlObjectId    
   ,vta2.ValueAmount    
   ,vta.ValueAmount    
    
       
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'MHCowShp'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtMHasCowShpByCat    
      
      
---- -----------------------------------------------------------------------------------    
---- SIGNIFICANT CAPITAL INVESTMENT BY CAT 602HH  vt466    
---- -----------------------------------------------------------------------------------     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    w.Objectid    
   ,@vtSigCapInvByCat --ValueTypeId    
   ,w.Headerid    
   ,w.AddlObjectId   --group code     
   ,w.SecondaryAddlObjectId    
   ,round(isnull(w.ValueAmount,0) / sum(isnull(w2.ValueAmount,0)) * vta.ValueAmount,0)     
  FROM #WorkAllModExceptHO AS vta --significant cap investment    
  INNER JOIN CadInv AS ci    
   ON ci.id = vta.HeaderId    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
  INNER JOIN #WorkValByCatAfHo AS w    
   ON w.ObjectId = vta.ObjectId    
    AND w.HeaderId = vta.HeaderId    
    AND w.AddlObjectId in ( select s.id    
          from systype as s    
          where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType as STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in ( select c.tbl_element    
                 from codes_table c    
                 where c.tbl_type_code = 'impgroup'    
                  and c.code_status = 'A'    
              )    
          )    
  INNER JOIN #WorkValByCatAfHo AS w2 --used to sum total land after ho    
   ON w2.HeaderId = w.HeaderId    
    AND w2.ObjectId = w.ObjectId    
    AND w2.AddlObjectId in (select s.id    
          from systype as s    
          where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType as STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (select c.tbl_element    
                from codes_table c    
                where c.tbl_type_code = 'impgroup'    
                 and c.code_status = 'A'    
                )    
          )    
  WHERE vta.ValueTypeId = @vtSigCapInvestment    
  GROUP BY w.Objectid    
   ,w.Headerid    
   ,w.AddlObjectId       
   ,w.SecondaryAddlObjectId    
   ,w.ValueAmount    
   ,vta.ValueAmount    
    
       
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'SigCapInv' --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtSigCapInvByCat    
    
---- -----------------------------------------------------------------------------------    
---- PLANT BUILDING INVESTMENT TAX CRITERIA BY CAT 602NN  vt466    
---- -----------------------------------------------------------------------------------     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    w.Objectid    
   ,@vtPlantInvByCat --ValueTypeId    
   ,w.Headerid    
   ,w.AddlObjectId   --group code    
   ,w.SecondaryAddlObjectId    
   ,round(isnull(w.ValueAmount,0) / sum(isnull(w2.ValueAmount,0)) * vta.ValueAmount,0)     
  FROM #WorkAllModExceptHO vta --plant bldg investment exemption    
  INNER JOIN CadInv AS ci    
   ON ci.id = vta.HeaderId    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
  INNER JOIN #WorkValByCatAfHo AS w    
   ON w.ObjectId = vta.ObjectId    
    AND w.HeaderId = vta.HeaderId    
     AND w.AddlObjectId in (  select s.id    
           from systype as s    
           where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType as STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (select c.tbl_element    
                from codes_table c    
                where c.tbl_type_code = 'impgroup'    
                 and c.code_status = 'A'    
                )    
          )    
  INNER JOIN #WorkValByCatAfHo AS w2 --used to sum total land after ho    
   ON w2.HeaderId = w.HeaderId    
    AND w2.ObjectId = w.ObjectId    
    AND w2.AddlObjectId in (select s.id    
          from systype as s    
          where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType as STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (select c.tbl_element    
               from codes_table c    
               where c.tbl_type_code = 'impgroup'    
                and c.code_status = 'A'    
               )    
          )    
  WHERE vta.ValueTypeId = @vtPlantInvestment    
  GROUP BY w.Objectid    
   ,w.Headerid    
   ,w.AddlObjectId       
   ,w.SecondaryAddlObjectId    
   ,w.ValueAmount    
   ,vta.ValueAmount    
    
    
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'PlantInv'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtPlantInvByCat    
    
---- -----------------------------------------------------------------------------------    
---- WILDLIFE HABITAT BY CAT 605  vt468    
---- -----------------------------------------------------------------------------------     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    w.Objectid    
   ,@vtWildlifeHabByCat --ValueTypeId    
   ,w.Headerid    
   ,w.AddlObjectId   --group code    
   ,w.SecondaryAddlObjectId    
   ,round(isnull(w.ValueAmount,0) / sum(isnull(w2.ValueAmount,0)) * vta.ValueAmount,0)    
  FROM #WorkAllModExceptHO AS vta --wildlife habitat exemption    
  INNER JOIN CadInv AS ci    
   ON ci.id = vta.HeaderId    
  INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
  INNER JOIN #WorkValByCatAfHo AS w    
   ON w.ObjectId = vta.ObjectId    
    AND w.HeaderId = vta.HeaderId    
     AND w.AddlObjectId in ( select s.id    
          from systype as s    
          where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType as STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in ( select c.tbl_element    
                 from codes_table c    
                 where c.tbl_type_code = 'impgroup'    
                 and c.code_status = 'A'    
                )    
          )    
  INNER JOIN #WorkValByCatAfHo AS w2 --used to sum total land after ho    
   ON w2.HeaderId = w.HeaderId    
    AND w2.ObjectId = w.ObjectId    
    AND w2.AddlObjectId in (select s.id    
          from systype as s    
          where systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType as STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (select c.tbl_element    
                from codes_table c    
                where c.tbl_type_code = 'impgroup'    
                 and c.code_status = 'A'    
                )    
          )    
  WHERE vta.ValueTypeId = @vtWildlifeHabitat    
  GROUP BY w.Objectid    
   ,w.Headerid    
   ,w.AddlObjectId       
   ,w.SecondaryAddlObjectId    
   ,w.ValueAmount    
   ,vta.ValueAmount    
    
       
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId    
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount    
   ,'Wildlife'  --flag    
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtWildlifeHabByCat    
    
------ -----------------------------------------------------------------------------------    
------ SMALL EMPLOYER GROWTH BY CAT 606A  vt469    
------ -----------------------------------------------------------------------------------     
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT     
    w.Objectid    
   ,@vtSmallEmplrByCat --ValueTypeId    
   ,w.Headerid    
   ,w.AddlObjectId   --group code    
   ,w.SecondaryAddlObjectId    
   ,round(isnull(w.ValueAmount,0) / sum(isnull(w2.ValueAmount,0)) * vta.ValueAmount,0)    
  FROM #WorkAllModExceptHO AS vta --small employer growth exemption    
  INNER JOIN CadInv AS ci    
   ON ci.id = vta.HeaderId      INNER JOIN ClassCdMap AS ccm    
   ON ccm.ClassCd = ci.ClassCd    
  INNER JOIN grm_FW_FCLGetDatesForYear( @AssessmentYear ) AS fcl    
   ON fcl.FunclAreaType = @ASMTADMIN_ofFCalFunclArea    
    AND fcl.CalendarType = ccm.CalendarType    
  INNER JOIN #WorkValByCatAfHo AS w    
   ON w.ObjectId = vta.ObjectId    
    AND w.HeaderId = vta.HeaderId    
     AND w.AddlObjectId in ( select s.id    
          from systype as s    
          where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType as STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (    
               select c.tbl_element    
               from codes_table c    
               where c.tbl_type_code = 'impgroup'    
                and c.code_status = 'A'    
              )    
          )    
  INNER JOIN #WorkValByCatAfHo AS w2 --used to sum total land after ho    
   ON w2.HeaderId = w.HeaderId    
    AND w2.ObjectId = w.ObjectId    
    AND w2.AddlObjectId in (select s.id    
          from systype as s    
          where s.systypecatid = 10340    
           and s.EffStatus = 'A'    
           and s.begEffDate = (select max(STSUB.begEffDate)    
                from SysType as STSUB    
                where STSUB.begEffDate < DATEADD(day, 0, DATEDIFF(day, 0, fcl.EndDate ) + 1)    
                 and STSUB.Id = s.Id    
               )    
           and s.shortDescr in (    
             select c.tbl_element    
             from codes_table c    
             where c.tbl_type_code = 'impgroup'    
              and c.code_status = 'A'    
            )    
       )    
  WHERE vta.ValueTypeId = @vtSmallEmplrGrowth    
  GROUP BY w.Objectid    
   ,w.Headerid    
   ,w.AddlObjectId    
   ,w.SecondaryAddlObjectId    
   ,w.ValueAmount    
   ,vta.ValueAmount    
    
       
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
  Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
   [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])        
  SELECT     
    Headerid  --id    
   ,ObjectId  --ObjectId    
   ,ValueTypeId --ValueTypeId      
   ,HeaderId  --HeaderId    
   ,AddlObjectId --AddlObjectId    
   ,SecondaryAddlObjectId --Secondardy    
   ,ValueAmount --ValueAmount     
   ,'SmallEmp'  --flag       
   ,@v_ProcessStepTrackingId    
  FROM #results    
  WHERE ValueTypeId = @vtSmallEmplrByCat    
    
------ -----------------------------------------------------------------------------------    
------ SITE DEVELOPER EXEMPTION BY CAT   vt499   clk 2-28-14 not needed in Kootenai    
------ -----------------------------------------------------------------------------------    
    
  --USED LATER WHEN CALCULATING THE TOTAL EXEMPTIONS    
 -- Insert into #Work ([Id],[ObjectId],[ValueTypeId],[HeaderId],[AddlObjectId],    
 --  [SecondaryAddlObjectId],[ValueAmount],[flag],[ValueAmount2])    
 -- SELECT     
 --   Headerid  --id    
 --  ,ObjectId  --ObjectId    
 --  ,ValueTypeId --ValueTypeId    
 --  ,HeaderId  --HeaderId    
 --  ,AddlObjectId --AddlObjectId    
 --  ,SecondaryAddlObjectId --Secondardy    
 --  ,ValueAmount --ValueAmount    
 --  ,'SiteImpEx' --flag    
 --  ,@v_ProcessStepTrackingId    
 -- FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) vta --site imp val    
 -- WHERE vta.ValueTypeId = @vtSiteImpExByCat    
    
    
---- -----------------------------------------------------------------------------------    
---- SITE IMPROVEMENTS    
---- -----------------------------------------------------------------------------------    
--   HANDLED IN aa_IDAHO_assessed    
    

-- -----------------------------------------------------------------------------------
-- HTR VALUE  vt307                                                   --sab 05/26/2023
-- -----------------------------------------------------------------------------------
		--USED TO CALCULATE THE TOTAL EXEMPTION ALREADY APPLIED BY CAT  --sab 05/26/2023
		INSERT INTO #workTotalExByCat ([HeaderId],[AddlObjectid],[TotalExByCat])    
		SELECT 
			 HeaderId					--CadInv HeaderId
		    ,AddlObjectid				--Category
			,isnull(sum(ValueAmount),0)	--TotalExByCat 
		FROM #work  
		WHERE Flag not in ('HoPcnt', 'HOEX')
		GROUP BY HeaderId,AddlObjectid	


		
		--ANNUAL HTR CREDIT 
				INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])
				SELECT 
					 hoel.Objectid
					,@vtHTR_Value --ValueTypeId
					,hoel.Headerid
					,hoel.AddlObjectId   --group code 
					,hoel.SecondaryAddlObjectId
					,hoel.ValueAmount - w.ValueAmount - isnull(sum(OtherExByCat.TotalExByCat),0) --ValueAmount
				FROM dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci 
				INNER JOIN TempTotalHoElig hoel
				ON hoel.HeaderId = ci.id
				AND hoel.Flag = 'HOELigTot'	
				INNER JOIN #Work w
				ON w.HeaderId = ci.id
				AND w.Flag = 'HoEx'
				INNER JOIN RevObjSiteModifier rsm
				ON rsm.RevObjSiteId = hoel.ObjectId
				AND rsm.EffStatus = 'A'
				AND rsm.BegTaxYear = (select max(BegTaxYear) from RevObjSiteModifier rsmsub where rsmsub.id = rsm.id)	
				AND rsm.ModifierId in (select m.id 
									   from Modifier m
									   where m.EffStatus = 'A'
									   and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id)
									   and m.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
									   )
				AND rsm.ApplyDate <= @HTR_DateCriteria
				LEFT OUTER JOIN #workTotalExByCat OtherExByCat--OtherExemptions
				ON OtherExByCat.HeaderId = ci.Id
				AND OtherExByCat.AddlObjectId in (select id 
												  from SysType s
												  where s.EffStatus = 'A'
												  and s.BegEffDate = (select max(BegEffDate) from SysType ssub where ssub.id = s.id) 
												  and s.SysTypeCatId = 10340 --category.
												  and s.ShortDescr like '%H'
												  )
				WHERE ci.RollCaste = 16001
				and @RollCaste = 16001
				GROUP BY hoel.Objectid, hoel.Headerid, hoel.AddlObjectId, hoel.SecondaryAddlObjectId, hoel.ValueAmount, w.ValueAmount


---- -----------------------------------------------------------------------------------
---- HTR VALUE IMP ONLY vt308                                           --sab 05/26/2023
---- -----------------------------------------------------------------------------------
		--ANNUAL HTR CREDIT 
				INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])
				SELECT 
					 hoel.Objectid
					,@vtHTR_ValueImpOnly --ValueTypeId
					,hoel.Headerid
					,hoel.AddlObjectId   --group code 
					,hoel.SecondaryAddlObjectId
					,sum(hoel.ValueAmount) - w.ValueAmount - isnull(sum(OtherExByCat.TotalExByCat),0) --ValueAmount
				FROM dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci 
				INNER JOIN #WorkHoElByCat hoel
				ON hoel.HeaderId = ci.id
				AND hoel.Flag = 'HOELigTot'	
				INNER JOIN #WorkHOEX_ImpOnly w
				ON w.HeaderId = ci.id
				AND w.Flag = 'HOEX_ImpO'
				INNER JOIN RevObjSiteModifier rsm
				ON rsm.RevObjSiteId = hoel.ObjectId
				AND rsm.EffStatus = 'A'
				AND rsm.BegTaxYear = (select max(BegTaxYear) from RevObjSiteModifier rsmsub where rsmsub.id = rsm.id)	
				AND rsm.ModifierId in (select m.id 
									   from Modifier m
									   where m.EffStatus = 'A'
									   and m.BegTaxYear = (select max(BegTaxYear) from Modifier msub where msub.id = m.id)
									   and m.ShortDescr in ('_HOEXCap','_HOEXCapCalc','_HOEXCapManual')
									   )
				AND rsm.ApplyDate <= @HTR_DateCriteria
				LEFT OUTER JOIN #workTotalExByCat OtherExByCat--OtherExemptions
				ON OtherExByCat.HeaderId = ci.Id
				AND OtherExByCat.AddlObjectId = hoel.AddlObjectId
				AND OtherExByCat.AddlObjectId in (select id 
												  from SysType s
												  where s.EffStatus = 'A'
												  and s.BegEffDate = (select max(BegEffDate) from SysType ssub where ssub.id = s.id) 
												  and s.SysTypeCatId = 10340 --category.
												  and s.ShortDescr like '%H'
												  )
				WHERE ci.RollCaste = 16001
				and @RollCaste = 16001
				GROUP BY hoel.Objectid, hoel.Headerid, hoel.AddlObjectId, hoel.SecondaryAddlObjectId, w.ValueAmount






---- -----------------------------------------------------------------------------------    
---- TOTAL EXEMPTIONS vt320    
---- -----------------------------------------------------------------------------------    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT v.ObjectId    
   , @vtTotalExemptions AS ValueTypeId    
   , v.HeaderId    
   , 0      AS AddlObjectId    
   , 0      AS SecondaryAddlObjectId    
   , SUM( v.ValueAmount ) AS ValueAmount    
  FROM ( SELECT r.ObjectId    
     , r.HeaderId    
     , r.ValueAmount    
    FROM #results AS r    
    INNER JOIN ValueType AS vt    
     ON vt.Id = r.ValueTypeId    
      AND vt.ValueTypeCat = @stExemptionType    
    
    UNION ALL    
    
    SELECT vta.ObjectId    
     , vta.HeaderId    
     , vta.ValueAmount    
    FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk( @v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) AS vta    
    INNER JOIN ValueType AS vt    
     ON vt.Id = vta.ValueTypeId    
      AND vt.ValueTypeCat = @stExemptionType    
   ) AS v    
  GROUP BY v.ObjectId    
   , v.HeaderId    
    
    
  --    
  -- SpecLandDeferred: -- Land Market minus Land Use, matching on attr(ValCd)    
  --    
  INSERT INTO #results ([ObjectId], [ValueTypeId], [HeaderId], [AddlObjectId], [SecondaryAddlObjectId], [ValueAmount])    
  SELECT r_LandMarket.ObjectId    
   , @vtSpecLandDeferred AS ValueTypeId    
   , r_LandMarket.HeaderId    
   , r_LandMarket.AddlObjectId    
   , 0      AS SecondaryAddlObjectId    
   , SUM( r_LandMarket.ValueAmount - COALESCE( r_LandUse.ValueAmount, 0 ) ) AS ValueAmount    
  FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk( @v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) AS r_LandMarket    
  INNER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk( @v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) AS r_LandUse    
   ON r_LandUse.ValueTypeId = @vtLandUse    
    AND r_LandUse.ObjectId = r_LandMarket.ObjectId    
    AND r_LandUse.HeaderId = r_LandMarket.HeaderId    
    AND r_LandUse.AddlObjectId = r_LandMarket.AddlObjectId    
    AND r_LandUse.ValueAmount > 0    
  WHERE r_LandMarket.ValueTypeId = @vtLandMarket    
  GROUP BY r_LandMarket.ObjectId, r_LandMarket.HeaderId, r_LandMarket.AddlObjectId    


  drop table if exists temp_results5
  select * into temp_results5 from #results

--------------------------------------------------------------------------
--- MWD 02172023 --- Sub/Occ Proration for exemptions
--------------------------------------------------------------------------
 
	-- HOEX_Exemption - vt305
	update r
	SET ValueAmount =	CASE 
							WHEN ROUND(ROUND((vta_months.ValueAmount/12) * r_exempt.ValueAmount,0) * (0.500000000),0) < 125000.00
							THEN ROUND(ROUND((vta_months.ValueAmount/12) * r_exempt.ValueAmount,0) * (0.500000000),0)
							ELSE 125000.00
						END
	FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_months --ProRate Supp Months  
	JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
		ON ci.Id = vta_months.Headerid  
	JOIN #results r_exempt 
		ON ci.id = r_exempt.HeaderId
	JOIN #results r
		ON ci.id = r.HeaderId
	LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_exe
		ON ci.Id = vta_exe.Headerid 
	WHERE vta_months.ValueTypeId = @vtMonths
	AND r_exempt.ValueTypeId = @vtHOEX_EligibleVal
	AND vta_months.ValueAmount < 12	
	AND ci.RollCaste = 16002 -- Supp only
	and r.ValueTypeId = @vtHOEX_Exemption
	
	-- HOEX_ImpOnly - vt306
	update r
	SET ValueAmount =	CASE 
							WHEN ROUND(ROUND((vta_months.ValueAmount/12) * r_exempt.ValueAmount,0) * (0.500000000),0) < 125000.00
							THEN ROUND(ROUND((vta_months.ValueAmount/12) * r_exempt.ValueAmount,0) * (0.500000000),0)
							ELSE 125000.00
						END
	FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_months --ProRate Supp Months  
	JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
		ON ci.Id = vta_months.Headerid  
	JOIN #results r_exempt 
		ON ci.id = r_exempt.HeaderId
	JOIN #results r
		ON ci.id = r.HeaderId
	LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_exe
		ON ci.Id = vta_exe.Headerid 
	WHERE vta_months.ValueTypeId = @vtMonths
	AND r_exempt.ValueTypeId = @vtHOEX_EligibleVal
	AND vta_months.ValueAmount < 12	
	AND ci.RollCaste = 16002 -- Supp only
	and r.ValueTypeId = @vtHOEX_ImpOnly

	-- TotalExemptions - vt320
	update r
	SET ValueAmount =	CASE 
							WHEN ROUND(ROUND((vta_months.ValueAmount/12) * r_exempt.ValueAmount,0) * (0.500000000),0) < 125000.00
							THEN ROUND(ROUND((vta_months.ValueAmount/12) * r_exempt.ValueAmount,0) * (0.500000000),0)
							ELSE 125000.00
						END
	FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_months --ProRate Supp Months  
	JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
		ON ci.Id = vta_months.Headerid  
	JOIN #results r_exempt 
		ON ci.id = r_exempt.HeaderId
	JOIN #results r
		ON ci.id = r.HeaderId
	LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_exe
		ON ci.Id = vta_exe.Headerid 
	WHERE vta_months.ValueTypeId = @vtMonths
	AND r_exempt.ValueTypeId = @vtHOEX_EligibleVal
	AND vta_months.ValueAmount < 12	
	AND ci.RollCaste = 16002 -- Supp only
	and r.ValueTypeId = @vtTotalExemptions


	--@vtHOEX_ByCat vt472
	update r
	SET ValueAmount =	CASE 
							WHEN ROUND(ROUND((vta_months.ValueAmount/12) * vta_tot.ValueAmount,0) * (0.500000000),0) < 125000.00
							THEN ROUND(ROUND((vta_months.ValueAmount/12) * vta_tot.ValueAmount,0) * (0.500000000),0)
							ELSE 125000.00
						END
	FROM dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_months --ProRate Supp Months  
	JOIN dbo.grm_aa_calc_CadInvByChunk(@v_ProcessCdTrackingId,@v_BegObjectId,@v_EndObjectId) ci   
	JOIN #results r
		ON ci.id = r.HeaderId
		ON ci.Id = vta_months.Headerid  
	JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_tot
		ON ci.Id = vta_tot.Headerid and vta_tot.AddlObjectId = r.AddlObjectId
	LEFT OUTER JOIN dbo.GRM_AA_calc_ValueTypeAmountByChunk(@v_ProcessCdTrackingId, @v_BegObjectId, @v_EndObjectId) as vta_exe
		ON ci.Id = vta_exe.Headerid 
	WHERE vta_months.ValueTypeId = @vtMonths
	AND vta_tot.ValueTypeId = @vtAssessedByCat -- by CAT
	AND vta_months.ValueAmount < 12	
	AND ci.RollCaste = 16002 -- Supp only
	and r.ValueTypeId = @vtHOEX_ByCat



---- -----------------------------------------------------------------------------------    
---- RETURN RESULTS    
---- -----------------------------------------------------------------------------------    
    
  SELECT  r.ObjectId    
   , r.ValueTypeId    
   , r.HeaderId    
   , @stCadInv AS HeaderType    
   , r.AddlObjectId    
   , r.SecondaryAddlObjectId    
   , r.ValueAmount    
  FROM #results r    
  INNER JOIN ValueType AS vt    
   ON vt.Id = r.ValueTypeId    
  WHERE ( vt.SaveIfZero = 0 AND r.ValueAmount > 0 )    
   OR vt.SaveIfZero = 1    
  ORDER BY HeaderId    
    
 END TRY    
    
--INSERT LOG RESULTS    
 BEGIN CATCH    
  INSERT INTO #log_results VALUES(0,0, LEFT( 'Line# ' + CAST( ERROR_LINE() AS varchar ) + '. ' + ERROR_MESSAGE(), 256 ), 1)    
 END CATCH    
    
 SELECT * FROM #log_results    
    
--DROP TABLES  
   
 DROP TABLE #log_results    
 DROP TABLE #results    
 DROP TABLE #work    
 DROP TABLE #WorkHoElByCat    
 DROP TABLE #WorkValByCatAfHo    
 DROP TABLE TempTotalHoElig    
 DROP TABLE TempCalcCapOverride    
 DROP TABLE #WorkHoExByCat    
 DROP TABLE #WorkHOEX_ImpOnly    
 DROP TABLE #WorkPTREligLand    
 DROP TABLE #WorkPTREligImp    
 DROP TABLE #WorkPTRHomeowners    
 DROP TABLE #WorkPTRHomeownersImpOnly    
 DROP TABLE #TempValueTypeAmount    
 DROP TABLE #WorkPPEX    
 DROP TABLE #WorkAllModExceptHO    
 DROP TABLE #WorkAllModForHO   
 DROP TABLE #workTotalExByCat	--sab 05/26/2023  

END    
  
  
  
GO


