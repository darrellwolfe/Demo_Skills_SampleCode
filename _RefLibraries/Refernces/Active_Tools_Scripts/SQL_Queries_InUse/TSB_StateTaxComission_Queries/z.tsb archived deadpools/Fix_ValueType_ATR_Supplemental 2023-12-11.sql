--File Name: Fix_ValueType_ATR_Supplemental.sql 
--Description: WO22238  1.) Create the following valuetypes for the ATR Supplemental Roll:vt770 SUP_Anl_NetATR, add vt771 SUP_Anl_FireATR, add vt772 SUP_Anl_FloodATR, add vt773 SUP_Anl_ImpATR, add vt774 SUP_Anl_AGTbrATR.
--						2.) In Kootenai Create the following valuetypes for the ATR Supplemental Roll:vt790 SUP_Anl_NetATR, add vt791 SUP_Anl_FireATR, add vt792 SUP_Anl_FloodATR, add vt793 SUP_Anl_ImpATR, add vt794 SUP_Anl_AGTbrATR, add vt795 SUP_Anl_TbrATR.

		
--Author: Sandy Bowens
--Date Created: 11/20/2023
--Last Modified: 12/08/2023


Declare @County char(10) = (select Descr from County where CountyType = 251252)


----------------------------------------------------------------------------------------------------
---- VALUETYPES  for ATR SUPPLEMENTAL CREDIT
----------------------------------------------------------------------------------------------------
IF @County <> 'Kootenai'
		BEGIN
			delete from ValueType where id in (770,771,772,773,774,775)
		END

IF @County = 'Kootenai'
		BEGIN
			delete from ValueType where id in (790,791,792,793,794,795)
		END
	


IF @County <> 'Kootenai'
		BEGIN
			-- VALUETYPE FIELDNAMES id	shortdescr			Descr									VTClass				VTCat		VTSubCat		UnitOfMeasure		CalcLevel	AttributeType1	 AttributeType2 AttributeType3	AttributeType4	LevyBasisType   DisplaySequence		AllowOverride	SavelZero    
			--SUPP/ANNUAL ATR Additional Tax Relief Credit
			EXEC aa_setup_ValueType 770,'SUP_ANL_NetATR',	'Total Annual/Supp ATR Value',			'AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	1,					0,				1  
			EXEC aa_setup_ValueType 771,'SUP_ANL_FireATR',	'Total Annual/Supp ATR Less OPT',		'AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	2,					0,				1  
			EXEC aa_setup_ValueType 772,'SUP_ANL_FloodATR',	'Total Annual/Supp ATR Less PP and OPT','AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	3,					0,				1  
			EXEC aa_setup_ValueType 773,'SUP_ANL_ImpATR',	'Total Annual/Supp ATR Imp Only',		'AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	4,					0,				1  
			EXEC aa_setup_ValueType 774,'SUP_ANL_AGTbrATR',	'Total Annual/Supp ATR Less Ag Timber',	'AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	5,					0,				1  
			EXEC aa_setup_ValueType 775,'SUP_ANL_TbrATR',	'Total Annual/Supp ATR Less Timber',	'AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	6,					0,				1  
		END

IF @County = 'Kootenai'
		BEGIN
			-- VALUETYPE FIELDNAMES id	shortdescr			Descr									VTClass				VTCat		VTSubCat		UnitOfMeasure		CalcLevel	AttributeType1	 AttributeType2 AttributeType3	AttributeType4	LevyBasisType   DisplaySequence		AllowOverride	SavelZero    
			--SUPP/ANNUAL ATR Additional Tax Relief Credit
			EXEC aa_setup_ValueType 790,'SUP_ANL_NetATR',	'Total Annual/Supp ATR Value',			'AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	1,					0,				1  
			EXEC aa_setup_ValueType 791,'SUP_ANL_FireATR',	'Total Annual/Supp ATR Less OPT',		'AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	2,					0,				1  
			EXEC aa_setup_ValueType 792,'SUP_ANL_FloodATR',	'Total Annual/Supp ATR Less PP and OPT','AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	3,					0,				1  
			EXEC aa_setup_ValueType 793,'SUP_ANL_ImpATR',	'Total Annual/Supp ATR Imp Only',		'AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	4,					0,				1  
			EXEC aa_setup_ValueType 794,'SUP_ANL_AGTbrATR',	'Total Annual/Supp ATR Less Ag Timber',	'AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	5,					0,				1  
			EXEC aa_setup_ValueType 795,'SUP_ANL_TbrATR',	'Total Annual/Supp ATR Less Timber',	'AddlValueCredit',	'Other   ','Default',		'USD             ',	'ValGrp',			'None',		'None',			'None ',		'None ',	'TaxableValue',	6,					0,				1  
		END


	--ATR Additional Tax Relief Credit BASE
	--EXEC aa_setup_ValueType 521,'ATR_URDTotalBase',	'ATR Base Value',						'AddlValueCredit',	'TIFBase   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	7,					0,				0  
	--EXEC aa_setup_ValueType 522,'ATR_URDBaseFire',	'ATR Base Less OPT',					'AddlValueCredit',	'TIFBase   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	8,					0,				0  
	--EXEC aa_setup_ValueType 523,'ATR_URDBaseFlood',	'ATR Base Less PP and OPT',				'AddlValueCredit',	'TIFBase   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	9,					0,				0  
	--EXEC aa_setup_ValueType 524,'ATR_URDBaseImp',	'ATR Base Imp Only ',					'AddlValueCredit',	'TIFBase   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	10,					0,				0  
	--EXEC aa_setup_ValueType 525,'ATR_URDBaseAgTbr',	'ATR Base Less Ag Timber',				'AddlValueCredit',	'TIFBase   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	11,					0,				0  
	--EXEC aa_setup_ValueType 526,'ATR_URDBaseTbr',	'ATR Base Less Timber',					'AddlValueCredit',	'TIFBase   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	12,					0,				0  


	--ATR Additional Tax Relief Credit INCR
	--IF (SELECT Descr from County where CountyType = 251252) <> 'Kootenai'  
	--	BEGIN
	--		EXEC aa_setup_ValueType 621,'ATR_URDTotalIncr',	'ATR Incr Value',						'AddlValueCredit',	'TIFIncr   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	12,					0,				0  
	--	END
	--IF (SELECT Descr from County where CountyType = 251252) <> 'Kootenai'  
	--	BEGIN
	--		EXEC aa_setup_ValueType 622,'ATR_URDIncrFire',	'ATR Incr Less OPT',					'AddlValueCredit',	'TIFIncr   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	13,					0,				0  
	--	END

	--EXEC aa_setup_ValueType 623,'ATR_URDIncrFlood',	'ATR Incr Less PP and OPT',				'AddlValueCredit',	'TIFIncr   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	14,					0,				0  
	--EXEC aa_setup_ValueType 624,'ATR_URDIncrImp',	'ATR Incr Imp Only ',					'AddlValueCredit',	'TIFIncr   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	15,					0,				0  
	--EXEC aa_setup_ValueType 625,'ATR_URDIncrAgTbr',	'ATR Incr Less Ag Timber',				'AddlValueCredit',	'TIFIncr   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	16,					0,				0  
	--EXEC aa_setup_ValueType 626,'ATR_URDIncrTbr',	'ATR Incr Less Timber',					'AddlValueCredit',	'TIFIncr   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	17,					0,				0  

	--IF (SELECT Descr from County where CountyType = 251252) = 'Kootenai'  
	--	BEGIN
	--		EXEC aa_setup_ValueType 627,'ATR_URDTotalIncr',	'ATR Incr Value',						'AddlValueCredit',	'TIFIncr   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	12,					0,				0  
	--	END
	--IF (SELECT Descr from County where CountyType = 251252) = 'Kootenai'  
	--	BEGIN
	--		EXEC aa_setup_ValueType 628,'ATR_URDIncrFire',	'ATR Incr Less OPT',					'AddlValueCredit',	'TIFIncr   ','Default',		'USD             ',	'ValGrp',			'None',		'TIF',			'None ',		'None ',	'TaxableValue',	13,					0,				0  
	--	END


----------------------------------------------------------------------------------------------------
---- VALUETYPECALCINFO
----------------------------------------------------------------------------------------------------
IF @County <> 'Kootenai'
		BEGIN
			delete from ValueTypeCalcInfo where ValueTypeid in (770,771,772,773,774,775)
		END


IF @County = 'Kootenai'
		BEGIN
			delete from ValueTypeCalcInfo where id in (790,791,792,793,794,795)
		END


	--ATR CREDIT
	EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='SUP_ANL_NetATR',		@p_ProcessStep='Taxable',			@p_Formula='',@p_CalcOrder=0
	EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='SUP_ANL_FireATR',		@p_ProcessStep='Taxable',			@p_Formula='',@p_CalcOrder=0
	EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='SUP_ANL_FloodATR',	@p_ProcessStep='Taxable',			@p_Formula='',@p_CalcOrder=0
	EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='SUP_ANL_ImpATR',		@p_ProcessStep='Taxable',			@p_Formula='',@p_CalcOrder=0
	EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='SUP_ANL_AgTbrATR',	@p_ProcessStep='Taxable',			@p_Formula='',@p_CalcOrder=0
	EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='SUP_ANL_TbrATR',		@p_ProcessStep='Taxable',			@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDTotalBase',	@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDBaseFire',		@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDBaseFlood',	@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDBaseImp',		@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDBaseAgTbr',	@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDBaseTbr',		@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDTotalIncr',	@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDIncrFire',		@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDIncrFlood',	@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDIncrImp',		@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDIncrAgTbr',	@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0
	--EXEC aa_setup_ValueTypeCalcInfo @p_ValueType='ATR_URDIncrTbr',		@p_ProcessStep='URD',				@p_Formula='',@p_CalcOrder=0





----------------------------------------------------------------------------------------------------
---- VALUETYPELIST
----------------------------------------------------------------------------------------------------
IF @County <> 'Kootenai'
		BEGIN
			delete from ValueTypeList where ValueTypeid in (770,771,772,773,774,775)
		END

IF @County = 'Kootenai'
		BEGIN
			delete from ValueTypeList where ValueTypeid in (790,791,792,793,794,795)
		END

	--THIS ALLOWS THE VALUETYPE TO DISPLAY IN THE CADASTRE WITHOUT USING THE FILTER
	--none

	--THIS ALLOWS THE VALUETYPE TO DISPLAY IN THE VALUES/EXEMPTION BOX
	--none

	--THIS ALLOWS THE VALUETYPE TO BE USED WHEN CREATING TAX BILLS
	--none

	--THIS ALLOWS THE VALUETYPE TO BE USED WHEN PRINTING TAX BILLS
	--none

	--THIS ALLOWS THE CREDIT VALUES TO BE USED WHEN SETTING TAFRATES
	--none

	--THIS ALLOWS THE CREDIT VALUES TO BE USED AS A SOURCEVALUETYPE IN TAX BILL CALCULATIONS

	--ATR
	exec aa_setup_ValueTypeList 'SVT', 'SUP_Anl_NetATR'
	exec aa_setup_ValueTypeList 'SVT', 'SUP_Anl_FireATR'
	exec aa_setup_ValueTypeList 'SVT', 'SUP_Anl_FloodATR'
	exec aa_setup_ValueTypeList 'SVT', 'SUP_Anl_ImpATR'
	exec aa_setup_ValueTypeList 'SVT', 'SUP_Anl_AGTbrATR'
	exec aa_setup_ValueTypeList 'SVT', 'SUP_Anl_TbrATR'

	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDTotalBase'
	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDBaseFire'
	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDBaseFlood'
	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDBaseImp'
	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDBaseAgTbr'
	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDBaseTbr'

	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDTotalIncr'
	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDIncrFire'
	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDIncrFlood'
	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDIncrImp'
	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDIncrAgTbr'
	--exec aa_setup_ValueTypeList 'SVT', 'ATR_URDIncrTbr'

	--ATR
	exec aa_setup_ValueTypeList 'TaxRollCreate', 'SUP_Anl_NetATR'
	exec aa_setup_ValueTypeList 'TaxRollCreate', 'SUP_Anl_FireATR'
	exec aa_setup_ValueTypeList 'TaxRollCreate', 'SUP_Anl_FloodATR'
	exec aa_setup_ValueTypeList 'TaxRollCreate', 'SUP_Anl_ImpATR'
	exec aa_setup_ValueTypeList 'TaxRollCreate', 'SUP_Anl_AGTbrATR'
	exec aa_setup_ValueTypeList 'TaxRollCreate', 'SUP_Anl_TbrATR'

	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDTotalBase'
	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDBaseFire'
	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDBaseFlood'
	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDBaseImp'
	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDBaseAgTbr'
	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDBaseTbr'

	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDTotalIncr'
	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDIncrFire'
	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDIncrFlood'
	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDIncrImp'
	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDIncrAgTbr'
	--exec aa_setup_ValueTypeList 'TaxRollCreate', 'ATR_URDIncrTbr'
	
	--ATR
	exec aa_setup_ValueTypeList 'TaxRollPrint', 'SUP_Anl_NetATR'
	exec aa_setup_ValueTypeList 'TaxRollPrint', 'SUP_Anl_FireATR'
	exec aa_setup_ValueTypeList 'TaxRollPrint', 'SUP_Anl_FloodATR'
	exec aa_setup_ValueTypeList 'TaxRollPrint', 'SUP_Anl_ImpATR'
	exec aa_setup_ValueTypeList 'TaxRollPrint', 'SUP_Anl_AGTbrATR'
	exec aa_setup_ValueTypeList 'TaxRollPrint', 'SUP_Anl_TbrATR'

	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDTotalBase'
	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDBaseFire'
	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDBaseFlood'
	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDBaseImp'
	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDBaseAgTbr'
	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDBaseTbr'

	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDTotalIncr'
	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDIncrFire'
	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDIncrFlood'
	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDIncrImp'
	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDIncrAgTbr'
	--exec aa_setup_ValueTypeList 'TaxRollPrint', 'ATR_URDIncrTbr'
		
	--THIS ALLOWS THE CREDIT VALUES TO BE USED TO CALCULATE THE TIF INCREMENT

	--ATR
	exec aa_setup_ValueTypeList 'TIFTaxableVTs', 'SUP_Anl_NetATR'
	exec aa_setup_ValueTypeList 'TIFTaxableVTs', 'SUP_Anl_FireATR'
	exec aa_setup_ValueTypeList 'TIFTaxableVTs', 'SUP_Anl_FloodATR'
	exec aa_setup_ValueTypeList 'TIFTaxableVTs', 'SUP_Anl_ImpATR'
	exec aa_setup_ValueTypeList 'TIFTaxableVTs', 'SUP_Anl_AGTbrATR'
	exec aa_setup_ValueTypeList 'TIFTaxableVTs', 'SUP_Anl_TbrATR'


	--THIS ALLOWS THE BASE CREDIT TO BE CALCULATED

	--ATR
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDTotalBase'
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDBaseFire'
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDBaseFlood'
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDBaseImp'
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDBaseAgTbr'
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDBaseTbr'

	--exec aa_setup_ValueTypeList 'TIFBaseVTs', 'ATR_URDTotalBase'
	--exec aa_setup_ValueTypeList 'TIFBaseVTs', 'ATR_URDBaseFire'
	--exec aa_setup_ValueTypeList 'TIFBaseVTs', 'ATR_URDBaseFlood'
	--exec aa_setup_ValueTypeList 'TIFBaseVTs', 'ATR_URDBaseImp'
	--exec aa_setup_ValueTypeList 'TIFBaseVTs', 'ATR_URDBaseAgTbr'
	--exec aa_setup_ValueTypeList 'TIFBaseVTs', 'ATR_URDBaseTbr'


	--THIS ALLOWS THE INCREMENT CREDIT TO BE CALCULATED

	--ATR
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDTotalIncr'
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDIncrFire'
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDIncrFlood'
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDIncrImp'
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDIncrAgTbr'
	--exec aa_setup_ValueTypeList 'TIFSetup', 'ATR_URDIncrTbr'

	--exec aa_setup_ValueTypeList 'TIFIncrVTs', 'ATR_URDTotalIncr'
	--exec aa_setup_ValueTypeList 'TIFIncrVTs', 'ATR_URDIncrFire'
	--exec aa_setup_ValueTypeList 'TIFIncrVTs', 'ATR_URDIncrFlood'
	--exec aa_setup_ValueTypeList 'TIFIncrVTs', 'ATR_URDIncrImp'
	--exec aa_setup_ValueTypeList 'TIFIncrVTs', 'ATR_URDIncrAgTbr'
	--exec aa_setup_ValueTypeList 'TIFIncrVTs', 'ATR_URDIncrTbr'


----------------------------------------------------------------------------------------------------
---- VALUETYPECALC
----------------------------------------------------------------------------------------------------
IF @County <> 'Kootenai'
		BEGIN
			delete from ValueTypeCalc where SourceValueType in  (770,771,772,773,774,775)
		END

IF @County = 'Kootenai'
		BEGIN
			delete from ValueTypeCalc where SourceValueType in (790,791,792,793,794,795)
		END

	-----------------------------------------------------------------------------------------------------------------------------------
	--THIS ALLOWS THE HTR TO CALCULATE (COPY) FROM THE ANNUAL TO THE SUPPLEMENTAL IF AN HTR WAS ON THE ANNUAL   
	-----------------------------------------------------------------------------------------------------------------------------------
	BEGIN 
		delete from ValueTypeCalc where SourceValueType in (307,308,512,513,612,613) and ProcessCdId = (select id from ProcessCd where ShortDescr = 'Supp_TaxRoll')	
	END

	--HTR CREDIT  --SUPPLEMENTAL --WE HAVE TO ALLOW A SUPPLEMENTAL CALCULATION OR THE PROCESS WILL TAKE AWAY THE ANNUAL HTR VALUE BUT WILL NOT CALCULATE A NEW HTR CREDIT (WHICH IS THE ANNUAL COPIED INTO THE SUPPLEMENTAL)
	EXEC aa_setup_ValueTypeCalc 'HTR_Value',		'HTR_Value',		'None', 'Supp_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'HTR_ValueImpOnly',	'HTR_ValueImpOnly',	'None', 'Supp_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'HTR_BaseValue',	'HTR_BaseValue',	'None', 'Supp_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'HTR_BaseValImpOy', 'HTR_BaseValImpOy',	'None', 'Supp_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'HTR_IncrValue',	'HTR_IncrValue',	'None', 'Supp_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'HTR_IncrValImpOy', 'HTR_IncrValImpOy',	'None', 'Supp_TaxRoll'	
	

	--ATR CREDIT  --CORRECTIONS
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_NetATR',	'ATR_NetTaxable',	'None', 'Corr_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_FireATR',	'ATR_FireTax',		'None', 'Corr_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_FloodATR',	'ATR_FloodTax',		'None', 'Corr_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_ImpATR',	'ATR_ImpOnly',		'None', 'Corr_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_AGTbrATR', 'ATR_LessAgTimber',	'None', 'Corr_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_TbrATR',	'ATR_LessTimber',	'None', 'Corr_TaxRoll'

	--EXEC aa_setup_ValueTypeCalc 'ATR_URDTotalBase',	'ATR_URDTotalBase',	'None', 'Corr_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDBaseFire',	'ATR_URDBaseFire',	'None', 'Corr_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDBaseFlood',	'ATR_URDBaseFlood',	'None', 'Corr_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDBaseImp',	'ATR_URDBaseImp',	'None', 'Corr_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDBaseAgTbr',	'ATR_URDBaseAgTbr',	'None', 'Corr_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDBaseTbr',	'ATR_URDBaseTbr',	'None', 'Corr_TaxRoll'

	--EXEC aa_setup_ValueTypeCalc 'ATR_URDTotalIncr',	'ATR_URDTotalIncr',	'None', 'Corr_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDIncrFire',	'ATR_URDIncrFire',	'None', 'Corr_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDIncrFlood',	'ATR_URDIncrFlood',	'None', 'Corr_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDIncrImp',	'ATR_URDIncrImp',	'None', 'Corr_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDIncrAgTbr',	'ATR_URDIncrAgTbr',	'None', 'Corr_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDIncrTbr',	'ATR_URDIncrTbr',	'None', 'Corr_TaxRoll'

	--PER ALAN DORNFEST, IT IS NOT NECESSARY TO INCLUDE THE SCHOOL FACILITY SAVINGS ON THE SUPP TAX BILL 04/04/2023 SAB
	--EXEC aa_setup_ValueTypeCalc 'SchSavings','SchSavings',	'None', 'Supp_TaxRoll'

	--ATR CREDIT  --SUPPLEMENTAL
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_NetATR',	'ATR_NetTaxable',	'None', 'Supp_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_FireATR',	'ATR_FireTax',		'None', 'Supp_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_FloodATR',	'ATR_FloodTax',		'None', 'Supp_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_ImpATR',	'ATR_ImpOnly',		'None', 'Supp_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_AGTbrATR', 'ATR_LessAgTimber',	'None', 'Supp_TaxRoll'
	EXEC aa_setup_ValueTypeCalc 'SUP_Anl_TbrATR',	'ATR_LessTimber',	'None', 'Supp_TaxRoll'

	--EXEC aa_setup_ValueTypeCalc 'ATR_URDTotalBase',	'ATR_URDTotalBase',	'None', 'Supp_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDBaseFire',	'ATR_URDBaseFire',	'None', 'Supp_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDBaseFlood',	'ATR_URDBaseFlood',	'None', 'Supp_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDBaseImp',	'ATR_URDBaseImp',	'None', 'Supp_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDBaseAgTbr',	'ATR_URDBaseAgTbr',	'None', 'Supp_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDBaseTbr',	'ATR_URDBaseTbr',	'None', 'Supp_TaxRoll'

	--EXEC aa_setup_ValueTypeCalc 'ATR_URDTotalIncr',	'ATR_URDTotalIncr',	'None', 'Supp_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDIncrFire',	'ATR_URDIncrFire',	'None', 'Supp_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDIncrFlood',	'ATR_URDIncrFlood',	'None', 'Supp_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDIncrImp',	'ATR_URDIncrImp',	'None', 'Supp_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDIncrAgTbr',	'ATR_URDIncrAgTbr',	'None', 'Supp_TaxRoll'
	--EXEC aa_setup_ValueTypeCalc 'ATR_URDIncrTbr',	'ATR_URDIncrTbr',	'None', 'Supp_TaxRoll'	





---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TIFVALUETYPE 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--REMOVE DATA FROM TIFVALUETYPE FOR VT307,308
--Delete from TifValueType where SourceValueType in (307,308,355,356,357,358,359,360)
--go

--ATR Taxable Value (vt355)

	--IF (SELECT Descr from County where CountyType = 251252) <> 'Kootenai'  
	--	BEGIN
	--		DECLARE ID_cursor CURSOR
	--		FOR
 -- 			SELECT t.id FROM TIF t
	--		WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id) and EffStatus = 'A' ORDER BY 1  
	
	--		OPEN id_cursor

	--		DECLARE @id as int

	--		FETCH NEXT FROM id_cursor INTO @id
	--		WHILE (@@FETCH_STATUS <> -1)
	--		BEGIN
	--		   IF (@@FETCH_STATUS <> -2)
	--		   BEGIN   
	
	--				declare @counter integer
	--				set @counter = (select isnull(max(Id)+1,1) from tifValueType)
	
	--			INSERT INTO tifValueType(id, begEffYear, EffStatus, TranId, TIFId, SourceValueType, BaseValueType, IncrValueType)
	--			SELECT 
	--			@counter	   --id
	--			, t.startYear  --begEffYear
	--			, t.effStatus  --effStatus
	--			, 445		   --tranId
	--			, @id		   --tifId
	--			, 355          --sourceValueType
	--			, 521          --baseValueType
	--			, 621          --IncrValueType		
	--			FROM TIF t
	--			WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id)
	--			AND t.id in (select distinct tifid from tagTif)
	--			AND t.id = @id
	--			ORDER BY t.id
	--			END	
 --  			FETCH NEXT FROM id_cursor INTO @id
	--		END
	--		CLOSE id_cursor
	--		DEALLOCATE id_cursor
	--	END
	--go




----ATR Taxable Value (vt356)
--IF (SELECT Descr from County where CountyType = 251252) <> 'Kootenai'  
--	BEGIN
--		DECLARE ID_cursor CURSOR
--		FOR
--  		SELECT t.id FROM TIF t
--		WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id) and EffStatus = 'A' ORDER BY 1  
	
--		OPEN id_cursor

--		DECLARE @id as int

--		FETCH NEXT FROM id_cursor INTO @id
--		WHILE (@@FETCH_STATUS <> -1)
--		BEGIN
--		   IF (@@FETCH_STATUS <> -2)
--		   BEGIN   
	
--				declare @counter integer
--				set @counter = (select isnull(max(Id)+1,1) from tifValueType)
	
--			INSERT INTO tifValueType(id, begEffYear, EffStatus, TranId, TIFId, SourceValueType, BaseValueType, IncrValueType)
--			SELECT 
--			@counter	   --id
--			, t.startYear  --begEffYear
--			, t.effStatus  --effStatus
--			, 445		   --tranId
--			, @id		   --tifId
--			, 356          --sourceValueType
--			, 522          --baseValueType
--			, 622          --IncrValueType		
--			FROM TIF t
--			WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id)
--			AND t.id in (select distinct tifid from tagTif)
--			AND t.id = @id
--			ORDER BY t.id
--			END	
--   		FETCH NEXT FROM id_cursor INTO @id
--		END
--		CLOSE id_cursor
--		DEALLOCATE id_cursor
--	END
--GO

----ATR Taxable Value (vt357)
--	DECLARE ID_cursor CURSOR
--	FOR
--  	SELECT t.id FROM TIF t
--	WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id) and EffStatus = 'A' ORDER BY 1  
	
--	OPEN id_cursor

--	DECLARE @id as int

--	FETCH NEXT FROM id_cursor INTO @id
--	WHILE (@@FETCH_STATUS <> -1)
--	BEGIN
--	   IF (@@FETCH_STATUS <> -2)
--	   BEGIN   
	
--			declare @counter integer
--			set @counter = (select isnull(max(Id)+1,1) from tifValueType)
	
--		INSERT INTO tifValueType(id, begEffYear, EffStatus, TranId, TIFId, SourceValueType, BaseValueType, IncrValueType)
--		SELECT 
--		@counter	   --id
--		, t.startYear  --begEffYear
--		, t.effStatus  --effStatus
--		, 445		   --tranId
--		, @id		   --tifId
--		, 357          --sourceValueType
--		, 523          --baseValueType
--		, 623          --IncrValueType		
--		FROM TIF t
--		WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id)
--		AND t.id in (select distinct tifid from tagTif)
--		AND t.id = @id
--		ORDER BY t.id
--		END	
--   	FETCH NEXT FROM id_cursor INTO @id
--	END
--	CLOSE id_cursor
--	DEALLOCATE id_cursor
	
--	go


----ATR Taxable Value (vt358)
--	DECLARE ID_cursor CURSOR
--	FOR
--  	SELECT t.id FROM TIF t
--	WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id) and EffStatus = 'A' ORDER BY 1  
	
--	OPEN id_cursor

--	DECLARE @id as int

--	FETCH NEXT FROM id_cursor INTO @id
--	WHILE (@@FETCH_STATUS <> -1)
--	BEGIN
--	   IF (@@FETCH_STATUS <> -2)
--	   BEGIN   
	
--			declare @counter integer
--			set @counter = (select isnull(max(Id)+1,1) from tifValueType)
	
--		INSERT INTO tifValueType(id, begEffYear, EffStatus, TranId, TIFId, SourceValueType, BaseValueType, IncrValueType)
--		SELECT 
--		@counter	   --id
--		, t.startYear  --begEffYear
--		, t.effStatus  --effStatus
--		, 445		   --tranId
--		, @id		   --tifId
--		, 358          --sourceValueType
--		, 524          --baseValueType
--		, 624          --IncrValueType		
--		FROM TIF t
--		WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id)
--		AND t.id in (select distinct tifid from tagTif)
--		AND t.id = @id
--		ORDER BY t.id
--		END	
--   	FETCH NEXT FROM id_cursor INTO @id
--	END
--	CLOSE id_cursor
--	DEALLOCATE id_cursor
	
--	go


----ATR Taxable Value (vt359)
--	DECLARE ID_cursor CURSOR
--	FOR
--  	SELECT t.id FROM TIF t
--	WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id) and EffStatus = 'A' ORDER BY 1  
	
--	OPEN id_cursor

--	DECLARE @id as int

--	FETCH NEXT FROM id_cursor INTO @id
--	WHILE (@@FETCH_STATUS <> -1)
--	BEGIN
--	   IF (@@FETCH_STATUS <> -2)
--	   BEGIN   
	
--			declare @counter integer
--			set @counter = (select isnull(max(Id)+1,1) from tifValueType)
	
--		INSERT INTO tifValueType(id, begEffYear, EffStatus, TranId, TIFId, SourceValueType, BaseValueType, IncrValueType)
--		SELECT 
--		@counter	   --id
--		, t.startYear  --begEffYear
--		, t.effStatus  --effStatus
--		, 445		   --tranId
--		, @id		   --tifId
--		, 359          --sourceValueType
--		, 525          --baseValueType
--		, 625          --IncrValueType		
--		FROM TIF t
--		WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id)
--		AND t.id in (select distinct tifid from tagTif)
--		AND t.id = @id
--		ORDER BY t.id
--		END	
--   	FETCH NEXT FROM id_cursor INTO @id
--	END
--	CLOSE id_cursor
--	DEALLOCATE id_cursor
	
--	go



----ATR Taxable Value (vt360)
--	DECLARE ID_cursor CURSOR
--	FOR
--  	SELECT t.id FROM TIF t
--	WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id) and EffStatus = 'A' ORDER BY 1  
	
--	OPEN id_cursor

--	DECLARE @id as int

--	FETCH NEXT FROM id_cursor INTO @id
--	WHILE (@@FETCH_STATUS <> -1)
--	BEGIN
--	   IF (@@FETCH_STATUS <> -2)
--	   BEGIN   
	
--			declare @counter integer
--			set @counter = (select isnull(max(Id)+1,1) from tifValueType)
	
--		INSERT INTO tifValueType(id, begEffYear, EffStatus, TranId, TIFId, SourceValueType, BaseValueType, IncrValueType)
--		SELECT 
--		@counter	   --id
--		, t.startYear  --begEffYear
--		, t.effStatus  --effStatus
--		, 445		   --tranId
--		, @id		   --tifId
--		, 360          --sourceValueType
--		, 526          --baseValueType
--		, 626          --IncrValueType		
--		FROM TIF t
--		WHERE t.begEffYear = (select max(begEffYear) from tif tsub where tsub.id = t.id)
--		AND t.id in (select distinct tifid from tagTif)
--		AND t.id = @id
--		ORDER BY t.id
--		END	
--   	FETCH NEXT FROM id_cursor INTO @id
--	END
--	CLOSE id_cursor
--	DEALLOCATE id_cursor
	
--	go

	Exec RefreshNextNumber