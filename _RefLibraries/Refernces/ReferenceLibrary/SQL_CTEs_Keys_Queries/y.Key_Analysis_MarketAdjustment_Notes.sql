/*
AsTxDBProd
GRM_Main

When using Power BI or Tableau to perform this analysis, it can make sense to have several tables instead of one large table. This can help with data organization and make it easier to create meaningful visualizations and perform analyses.

For example, you could have one table for parcel data that includes information such as parcel ID, location, acreage, zoning, and other characteristics. Another table could include data on building characteristics such as number of bedrooms, square footage, year built, and whether the property is waterfront or not. You could also have a table for sales data that includes sale price, date, and other relevant information.

To combine these tables, you can use primary keys and foreign keys to link them together. For example, the parcel table might have a unique parcel ID that is used as a primary key, while the building table might have a foreign key that references the parcel ID. This would allow you to join the tables together to create a complete picture of each property and its characteristics.

When breaking the tables into buckets, you can group them by categories that make sense for your analysis. For example, you could group the sales data table by year, quarter, or month. The building characteristics table could be grouped by style, location, or waterfront status. The parcel data table could be grouped by zoning or acreage. By grouping the tables in this way, you can more easily filter and aggregate the data to a

Description/Table
Parcel Data that includes information such as parcel ID, location, acreage, zoning, and other characteristics: 
KCv_PARCELMASTER1

Building characteristics such as number of bedrooms, square footage, year built, and whether the property is waterfront or not.
improvements
dwellings
manuf_housing
comm_bldg
buildings(? buildings tab in proval, but not the name of table)


Sales data that includes sale price, date, and other relevant information.
transfer

System Assessor Values
valuation (note the difference between Certified (land_use_val, imp_val) and Assessed (land_assess, imp_assess, includes things like Timber exemption/reduction)
reconciliation (Worksheet Values (Worksheet Cost Approach: cost_model, cost_value plus+ land_mkt_val_cost = calculate total cost value), (Worksheet Income Approach:income_model, income_value minus- land_mkt_val_inc = improvement value on incopme ))

*Keys and Codes
codes_table
memos
land_types
allocations
prop_type -- Commercial Buildings
use_type_codes -- Commercial Buildings
ValueTypes -- Exemptions (HOEX 13, etc...)
ValueType -- Similar but different table, is this Aumentum?



*/

