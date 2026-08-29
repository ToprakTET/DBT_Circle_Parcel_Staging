
select 
    parcel_id,
    Mnb_products,
    qty
from {{ source('raw_data_circle','raw_data_parcel_product')}}