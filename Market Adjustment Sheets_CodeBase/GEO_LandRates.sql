/*
AsTxDBProd
GRM_Main

LTRIM(RTRIM())
*/

/*
Land Reports
Crystal Settings
{?CountyName} <> '' and
{land_val_element.neighborhood} in {?NeighborhoodStart} to {?NeighborhoodEnd} and
{land_val_element.model_ser_numb} = {?ModelNumber} and
{neigh_control.inactivate_date} = 99991231
*/

--------------------------------
--GEO Land Legends, Remainng Acres, Carea, Etc.
--------------------------------

SELECT
lve.neighborhood AS [GEO],
lve.lcm AS [LCM#],
lm.method_desc AS [Land Method],
lve.model_ser_numb AS [Land Model],
lve.land_type AS [LandType#],
lt.land_type_desc AS [LandType],
lve.df1,
lve.df2,
lve.df3,
lve.df4,
lve.df5,
lve.df6,
lve.df7,
lve.df8,
lve.df9,
lve.df10,
lve.df11,
lve.df12,
lve.df13,
lve.df14,
lve.df15,
lve.df16,
lve.df17,
lve.df18,
lve.df19,
lve.df20,
lve.df21,
lve.df22,
lve.df23,
lve.df24,
lve.df25,
lve.df26,
lve.df27,
lve.df28,
lve.df29,
lve.df30

FROM land_methods AS lm
JOIN land_val_element AS lve ON lm.method_number=lve.lcm
JOIN neigh_control AS nc ON lve.neighborhood=nc.neighborhood
JOIN land_types AS lt ON lve.land_type=lt.land_type


WHERE nc.inactivate_date=99991231
  AND lm.method_status='A'
  AND nc.county_number='28'
  AND lve.land_ve_status='A'
  AND lve.neighborhood<>0
----------------------------------------------------------------------
--Model is 70YYYY of the desired year, 2023 is 702023
----------------------------------------------------------------------
  AND lve.model_ser_numb='702023'

Order By [GEO] 




