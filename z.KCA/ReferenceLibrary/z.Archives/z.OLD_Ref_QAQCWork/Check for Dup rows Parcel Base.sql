select lrsn, parcel_id, tax_bill_id, count(*) as PINCount from parcel_base
group by lrsn, parcel_id, tax_bill_id
order by pincount desc

