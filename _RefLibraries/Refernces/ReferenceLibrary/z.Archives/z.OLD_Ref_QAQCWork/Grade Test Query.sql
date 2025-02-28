

Select parcel_base.lrsn, parcel_base.status, property_class, parcel_id, township_number, owner1, prop_street, tax_bill_id, extension, extensions.status, extensions.ext_description, parcel_base.neighborhood from parcel_base LEFT OUTER JOIN extensions ON parcel_base.lrsn = extensions.lrsn
WHERE parcel_base.lrsn IN (
52432,
52434,
52429,
53046,
53047,
53014,
53017,
52436,
52466,
52469,
52975,
52978,
52981,
53008,
53076,
53545,
53580,
53555,
53084,
53009,
53023,
53024,
53025,
53040,
53043,
53072,
53579)



order by parcel_base.lrsn
