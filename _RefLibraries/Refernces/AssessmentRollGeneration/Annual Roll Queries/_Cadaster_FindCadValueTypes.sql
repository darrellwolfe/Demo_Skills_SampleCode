Select Distinct
vt.id
,vt.ShortDescr
,vt.Descr
From ValueType AS vt
--Where vt.Descr LIKE '%cat%'
--Where vt.ShortDescr LIKE '%cat%'
Where vt.id = 651

Order By vt.Descr

--470	AssessedByCat	Assessed Value
--651	NewConstByCat	New Construction




/*
110	DefLand	07 Deferred Land Value
112	PABLYV	07 Per Acre BLY
111	PAMV	07 Per Acre Market
1039	DEF05	2005 DEFERRED
1038	YIELD05	2005 YIELD
1041	DEF06	2006 DEFERRED
1040	YIELD06	2006 YIELD
1043	DEF07	2007 DEFERRED
1042	YIELD07	2007 YIELD
201	Government	602A Government
207	Hardship	602AA Hardship
202	Religious	602B Religious
208	RemediatedLand	602BB Remediated Land
203	FraternalCharity	602C Fraternal/Charitable
209	PostConsumerWste	602CC Post Consumer Waste
204	Hospital	602D Hospitals
220	MHasCowSheepCamp	602DD MH Home Used For Cow/Sheet Camp
205	School	602E School/Education
206	CemeteryLibrary	602F Cemeteries/Libraries
210	LowIncomeHousing	602GG Non-Profit Low Income Housing
215	ResPropZonedArea	602H Residential Property in Zoned Areas
221	SigCapInvestment	602HH Significant Capital Investment
272	SpecLand	602K Speculative Value of Ag Land
643	PPExemptionCap	602KK PP Exemption Cap
219	IntangiblePP	602L Intangible Personal Property
217	IrrigtnWtrStruc	602N Irrigation Water and Structures
222	PlantInvestment	602NN Plant/Bldg Investment
218	PropUsedIrrDrain	602O Property For Irrigation/Drainage
211	PollutionControl	602P Pollution Control
250	BusInvExempt	602W Business Inventory Exempt From Taxation
212	CasualtyLoss	602X Casualty Loss
213	EffectOfChngeUse	602Y Effect of Change in Use
226	SiteImpDeveloper	603W Site Improvement for Developers
223	WildlifeHabitat	605 Land Protecting Wildlife/Habitat
224	SmallEmplrGrowth	606A Small Employer Growth Incentive
471	AcresByCat	Acres
60	ATR_Factor	Additional Tax Relief Factor
661	AnnexNet	Annexation All Categories
665	AnnexNetNoAg	Annexation Excludes Ag/Timber/OPT
662	AnnexNetNoOPT	Annexation Excludes OPT
663	AnnexNetNoPP_OPT	Annexation Excludes OPT and PP
664	AnnexNetImpOnly	Annexation Imp Only
1047	AQUACR	AQUIFER PROT CREDIT
1048	AQUAOPCR	AQUIFER PROT CREDIT OP
1036	AQUIFER	AQUIFER PROTECTION
1037	AQUAOP	AQUIFER PROTECTION OP
470	AssessedByCat	Assessed Value
524	ATR_URDBaseImp	ATR Base Imp Only
525	ATR_URDBaseAgTbr	ATR Base Less Ag Timber
522	ATR_URDBaseFire	ATR Base Less OPT
523	ATR_URDBaseFlood	ATR Base Less PP and OPT
526	ATR_URDBaseTbr	ATR Base Less Timber
521	ATR_URDTotalBase	ATR Base Value
624	ATR_URDIncrImp	ATR Incr Imp Only
625	ATR_URDIncrAgTbr	ATR Incr Less Ag Timber
628	ATR_URDIncrFire	ATR Incr Less OPT
623	ATR_URDIncrFlood	ATR Incr Less PP and OPT
626	ATR_URDIncrTbr	ATR Incr Less Timber
627	ATR_URDTotalIncr	ATR Incr Value
355	ATR_NetTaxable	ATR Value
358	ATR_ImpOnly	ATR Value Imp Only
359	ATR_LessAgTimber	ATR Value Less Ag Timber
356	ATR_FireTax	ATR Value Less OPT
357	ATR_FloodTax	ATR Value Less PP and OPT
360	ATR_LessTimber	ATR Value Less Timber
672	BaseBfPPEXByCat	BaseBfPPEXByCat
668	BaseReimbursemnt	BaseReimbursemnt
670	BaseReimByCat	BaseReimByCat
491	CasLossByCat	Casualty Loss Exemption
2001	CRate	Cedar - MBF Rate
2027	CValue	Cedar Harvest Value
2003	CPPRate	Cedar Poles & Pilings - LNFT Rate
2029	CPPValue	Cedar Poles & Pilings Harvest Value
2016	CPPNet	Cedar Poles & Pilings Scribner Net
2002	CPRate	Cedar Products - MBF Rate
2028	CPValue	Cedar Products Harvest Value
2015	CPNet	Cedar Products Scribner Net
2014	CNet	Cedar Scribner Net
436	CemLibByCat	Cemetery/Library Exemption
652	ChgOfUseByCat	Change Of Use
1046	DEF08	DEFERRED
641	SpecLandDeferred	Deferred Speculative Land
2004	DFLRate	Douglas Fir/Larch - MBF Rate
2030	DFLValue	Douglas Fir/Larch Harvest Value
2017	DFLNet	Douglas Fir/Larch Scribner Net
492	EffChgUseByCat	Effective Chg Of Use Exemption
642	ExemptStatute	Exempt by Statute
2005	FHRate	Fir/Hemlock - MBF Rate
2031	FHValue	Fir/Hemlock Harvest Value
2018	FHNet	Fir/Hemlock Scribner Net
433	FratCharByCat	Fraternal/Charitable Exemption
431	GovernmentByCat	Government Exemption
490	HardshipByCat	Hardship Exemption
302	HOEX_CapOverride	Homeowner Calculated Cap Override
301	HOEX_Cap	Homeowner Cap
473	HOEligibleByCat	Homeowner Eligible
304	HOEX_EligibleVal	Homeowner Eligible Value
305	HOEX_Exemption	Homeowner Exemption
472	HOEX_ByCat	Homeowner Exemption
306	HOEX_ImpOnly	Homeowner Exemption Imp Only
303	HOEX_CapManual	Homeowner Manual Cap Override
300	HOEX_Percent	Homeowner Percent
61	HTR_Factor	Homeowner Tax Relief Factor
434	HospitalByCat	Hospital Exemption
512	HTR_BaseValue	HTR Homeowner Base Value
513	HTR_BaseValImpOy	HTR Homeowner Base Value Imp Only
612	HTR_IncrValue	HTR Homeowner Incr Value
613	HTR_IncrValImpOy	HTR Homeowner Incr Value Imp Only
307	HTR_Value	HTR Homeowner Value
308	HTR_ValueImpOnly	HTR Homeowner Value Imp Only
103	Imp Assessed	Improvement Assessed
674	IncrBfPPEXByCat	IncrBfPPEXByCat
669	IncrReimbursemnt	IncrReimbursemnt
671	IncrReimByCat	IncrReimByCat
464	IntangPPropByCat	Intangible PP Exemption
489	IrrigWtrByCat	Irrigation Water Structures Exemption
488	PropIrrDrnByCat	Irrigation/Drainage Exemption
102	Land Assessed	Land Assessed
101	LandMarket	Land Market Assessed
108	LandUseAcres	Land Use Acres
100	LandUse	Land Use Assessed
270	PreferentialUse	Land Use Program
2006	LPPRate	Lodgepole Pine - MBF Rate
2032	LPPValue	Lodgepole Pine Harvest Value
2019	LPPNet	Lodgepole Pine Scribner Net
465	MHasCowShpByCat	MH as Cow/Sheep Camp Exemption
2007	MRate	Mixed - MBF Rate
2033	MValue	Mixed Harvest Value
2020	MNet	Mixed Scribner Net
710	Months	Months
653	NegAdjByCat	Negative Adj Chg of Use
455	Net Tax Value	Net Taxable Value
459	Net Minus Ag/Tbr	Net Taxable Value Excludes Ag and Timber
456	Fire Tax	Net Taxable Value Excludes Opt
457	Flood Tax	Net Taxable Value Excludes PP and OPT
460	Net Minus Tbr	Net Taxable Value Excludes Timber
458	Net Imp Only	Net Taxable Value Imp Only
651	NewConstByCat	New Construction
493	LowIncHousByCat	Non-Profit Low Income Housing Exemption
251	NRP	Non-Response Penalty
253	Obsolescence	Obsolescence
666	ObsolescenceByCa	Obsolescence By Category
104	OPT Assessed	Operating Property Assessed
105	PP Assessed	Personal Property Assessed
262	PPPAssessed	Personal Property Assessed Prorated
487	PPExemptionByCat	Personal Property Exemption
426	PPExNEWByCat	Personal Property Exemption NEW
467	PlantInvByCat	Plant/Bldg Investment Exemption
113	PCAssessed	Pollution Control Assessed
494	PollContrByCat	Pollution Control Exemption
2008	PPRate	Ponderosa Pine - MBF Rate
2034	PPValue	Ponderosa Pine Harvest Value
2021	PPNet	Ponderosa Pine Scribner Net
495	PostConsWstByCat	Post Consumer Waste Exemption
310	PP_Exemption	PP Exemption 602KK
311	PP_ExemptionNEW	PP Exemption NEW
401	PTRBenefit	PTR Benefit
406	PTRElgImpV	PTR Eligible Imp Value
407	PTRElgLandV	PTR Eligible Land Value
400	PTRHO	PTR Homeowners Exemption
408	PTRHoImpOnly	PTR Homeowners Exemption Imp Only
403	PTRImp	PTR Imp Percent
402	PTRLand	PTR Land Percent
405	PTRValue	PTR Taxable Value
409	PTRValImpOnly	PTR Taxable Value Imp Only
2009	PWRate	Pulpwood - MBF Rate
2035	PWValue	Pulpwood Harvest Value
2022	PWNet	Pulpwood Scribner Net
2010	PWTRate	Pulpwood Ton - Ton Rate
2036	PWTValue	Pulpwood Ton Harvest Value
2023	PWTNet	Pulpwood Ton Scribner Net
214	QIE	QIE - Qualified Investment Credit
106	QIEAssessed	QIE Assessed
496	QIE_ByCat	QIE Exemption
432	ReligiousByCat	Religious Exemption
497	RemedLandByCat	Remediated Land Exemption
1000	DEFTAX03	S/A-03 DEF TAX
1001	YIELD03	S/A-2003 YEILD
2042	ATHOL	S/A-ATHOL
1002	BAYWTR	S/A-BAYVW WTR/SW
1003	CATWTR	S/A-CAT WTR
1004	CATFP	S/A-CATALDO FP
1005	CATFPA	S/A-CATALDO-FPA
1006	CITYCDA	S/A-CITY CDA
2043	DALTON	S/A-CITY DALTON
1007	CITYPF	S/A-CITY PF
1008	COUNTY	S/A-COUNTY
1009	DALTIRR	S/A-DALT IRR
1010	DD#1	S/A-DD#1
1011	GRFERRY	S/A-GR FERRY
1012	HLKSWR	S/A-H LK SWR
1013	HACKNEY	S/A-HACKNEY
1014	HARRISON	S/A-HARRISON
1015	HAYDEN	S/A-HAYDEN
1016	HYDNLK	S/A-HYDN LK
1017	IDPAN	S/A-ID PANHANDLE
1018	IDPFPA	S/A-ID PNHDL-FPA
1019	KIDDIS	S/A-KIDD IS
1020	KINGSCAT	S/A-KING CAT
1035	KOOTWTR	S/A-KOOTENAI WATER
1049	LKSHWY	S/A-LAKES HWY
1021	MICAFP	S/A-MICA FP
1022	MICAFPA	S/A-MICA-FPA
1044	NKOOTWTR	S/A-N KOOTENAI WATER
1023	OHIOMTC	S/A-OHIO MTC
1024	PFHWY	S/A-PF HWY
1025	PVWEST	S/A-PINEVIEW EST
1026	PVWESTWT	S/A-PINEVIEW WTR
1027	RATHDRUM	S/A-RATHDRUM
1028	REMINGTN	S/A-REMINGTON
1029	SPLAKE	S/A-SP LAKE
1030	TWWTR	S/A-TWIN LKS WTR
1031	WJOEFP	S/A-W ST JOE FP
1032	WJOEFPA	S/A-W ST JOE FPA
1033	WDCOMM	S/A-WASTE DISP-COMM
1034	WDPRES	S/A-WASTE DISP-RES
435	SchoolByCat	School Exemption
58	SchFacFactor	School Facility Factor
59	SchSavings	School Facility Savings
466	SigCapInvByCat	Significant Cap Invest Exemption
711	SiExMonths	Site Imp Ex Months
116	SiteImpExByCat	Site Imp Exemption
115	SiteImpValByCat	Site Imp Value To Be Exempted
469	SmallEmplrByCat	Small Employer Growth Exemption
2011	SMLRate	Small Logs - Ton Rate
2037	SMLValue	Small Logs Harvest Value
2024	SMLNet	Small Logs Scribner Net
51	SpecFactor	Speculative Factor
2012	SRate	Spruce - MBF Rate
2038	SValue	Spruce Harvest Value
2025	SNet	Spruce Scribner Net
263	SLS	State Land Sale
763	SupHO_EL_ByCat	Supp Homeowner Eligible By Cat
760	SupValCat	Supplemental Assessed Value By Cat
762	SupHO_ByCat	Supplemental Homeowner Exemption By Cat
740	SUP Net Tax Val	Supplemental Net Taxable Value
712	SupProratedVal	Supplemental Prorated Value
761	SupValCatPro	Supplemental Prorated Value By Cat
741	SUPTaxFire	Supplemental Taxable  Excludes Timber
744	SUPTaxExclAgTbr	Supplemental Taxable Excludes Ag/Timber/OPT
742	SUPTaxFlood	Supplemental Taxable Excludes PP
745	SUPTaxExclTbr	Supplemental Taxable Excludes Timber
743	SUPTaxImpOnly	Supplemental Taxable Imp Only
271	Timber	Timber Program
107	Total Acres	Total Acres
793	SUP_ANL_ImpATR	Total Annual/Supp ATR Imp Only
794	SUP_ANL_AGTbrATR	Total Annual/Supp ATR Less Ag Timber
791	SUP_ANL_FireATR	Total Annual/Supp ATR Less OPT
792	SUP_ANL_FloodATR	Total Annual/Supp ATR Less PP and OPT
795	SUP_ANL_TbrATR	Total Annual/Supp ATR Less Timber
790	SUP_ANL_NetATR	Total Annual/Supp ATR Value
768	SUP_Annual_AgTbr	Total Annual/Supp Net Excludes Ag/Timber/OPT
766	SUP_Annual_Flood	Total Annual/Supp Net Excludes PP
765	SUP_Annual_Fire	Total Annual/Supp Net Excludes PP and OPT
769	SUP_Annual_Tbr	Total Annual/Supp Net Excludes Timber
767	SUP_Annual_Imp	Total Annual/Supp Net Imp Only
764	SUP_Annual_Net	Total Annual/Supp Net Values
320	Total Exemptions	Total Exemptions
109	Total Value	Total Value
774	URDBaseExAgTSUPP	URD ANNUAL/SUPP Base Total Excludes Ag/Timber/OPT
771	URDBaseFireSUPP	URD ANNUAL/SUPP Base Total Excludes OPT
772	URDBaseFloodSUPP	URD ANNUAL/SUPP Base Total Excludes PP and OPT
775	URDBaseExTbSUPP	URD ANNUAL/SUPP Base Total Excludes Timber
773	URDBaseImpOnSUPP	URD ANNUAL/SUPP Base Total Imp Only
770	URDTotalBaseSUPP	URD ANNUAL/SUPP Base Total Value
780	URDIncrExAgTSUPP	URD ANNUAL/SUPP Incr Total Excludes Ag/Timber/OPT
777	URDIncrFireSUPP	URD ANNUAL/SUPP Incr Total Excludes OPT
778	URDIncrFloodSUPP	URD ANNUAL/SUPP Incr Total Excludes PP and OPT
781	URDIncrExTbSUPP	URD ANNUAL/SUPP Incr Total Excludes Timber
779	URDIncrImpOnSUPP	URD ANNUAL/SUPP Incr Total Imp Only
776	URDTotalIncrSUPP	URD ANNUAL/SUPP Incr Total Value
506	UR_BaseByCat	URD Base by Cat
500	URDBaseModifier	URD Base Modifier
502	URDBaseFire	URD Base Total  Excludes Timber
505	URDBaseExclAgTbr	URD Base Total Excludes Ag/Timber/OPT
503	URDBaseFlood	URD Base Total Excludes PP and OPT
621	URDBaseExclTbr	URD Base Total Excludes Timber
504	URDBaseImpOnly	URD Base Total Imp Only
501	URD Total Base	URD Base Total Value
620	UR_IncrByCat	URD Increment by Cat
605	URDIncrExclAgTbr	URD Increment Total Excludes Ag/Timber/OPT
603	URDIncrFlood	URD Increment Total Excludes PP and OPT
602	URDIncrFire	URD Increment Total Excludes Timber
622	URDIncrExclTbr	URD Increment Total Excludes Timber
604	URDIncrImpOnly	URD Increment Total Imp Only
601	URD Total Incr	URD Increment Total Value
667	URDBaseBfPPEX	URDBaseBfPPEX
673	URDIncrBfPPEX	URDIncrBfPPEX
2013	WPRate	White Pine - MBF Rate
2039	WPValue	White Pine Harvest Value
2026	WPNet	White Pine Scribner Net
468	WildlifeHabByCat	Wildlife/Habitat Exemption
1045	YIELD08	YIELD
2040	YieldHarvest	Yield Harvest Gross Tax
*/