

Select parcel_base.lrsn, parcel_base.status, property_class, parcel_id, township_number, owner1, prop_street, tax_bill_id, extension, extensions.status, extensions.ext_description, parcel_base.neighborhood from parcel_base LEFT OUTER JOIN extensions ON parcel_base.lrsn = extensions.lrsn
WHERE parcel_base.lrsn IN (

52623,
52624,
53265,
53523,
55937,
55941,
55943,
55951,
55979,
55998,
56016,
56043,
56055,
56093,
56101,
56151,
56182,
56244,
56321,
57303,
57309,
57317,
57322,
57339,
56105,
56143)

order by parcel_base.lrsn
