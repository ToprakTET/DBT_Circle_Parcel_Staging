WITH nb_products_parcel AS (
  SELECT
    parcel_id
    ,SUM(qty) AS qty
    ,COUNT(DISTINCT model_name) AS nb_products
  FROM {{source("raw_data_circle,","raw_data_parcel_product")}}
  GROUP BY parcel_id
)
SELECT
parcel_id
,parcel_tracking
,transporter
,priority
-- tarih --
,PARSE_DATE("%B %e, %Y", date_purchase) AS date_purchase
,PARSE_DATE("%B %e, %Y", date_shipping) AS date_shipping
,PARSE_DATE("%B %e, %Y", date_delivery) AS date_delivery
,PARSE_DATE("%B %e, %Y", date_cancelled) AS date_cancelled
-- ay --
,EXTRACT(MONTH FROM PARSE_DATE("%B %e, %Y", date_purchase)) AS month_purchase
-- durum --
,CASE
WHEN date_cancelled IS NOT NULL THEN 'İptal Edildi'
WHEN date_shipping IS NULL THEN 'Devam Ediyor'
WHEN date_delivery IS NULL THEN 'Taşınıyor'
WHEN date_delivery IS NOT NULL THEN 'Teslim Edildi'
ELSE NULL
END AS status
-- zaman --
,DATE_DIFF(PARSE_DATE("%B %e, %Y", date_shipping),PARSE_DATE("%B %e, %Y", date_purchase),DAY) AS expedition_time
,DATE_DIFF(PARSE_DATE("%B %e, %Y", date_delivery),PARSE_DATE("%B %e, %Y", date_shipping),DAY) AS transport_time
,DATE_DIFF(PARSE_DATE("%B %e, %Y", date_delivery),PARSE_DATE("%B %e, %Y", date_purchase),DAY) AS delivery_time
-- gecikme --
,IF(date_delivery IS NULL,NULL,IF(DATE_DIFF(PARSE_DATE("%B %e, %Y", date_delivery),PARSE_DATE("%B %e, %Y", date_purchase),DAY)>5,1,0)) AS delay
-- Metrikler --
,qty
,nb_products
FROM {{source("raw_data_circle,","raw_cc_parcel")}}
LEFT JOIN (select 
              ParCEL_id as parcel_id,
              Model_mAME as nb_products,
              QUANTITY as qty
          from {{source("raw_data_circle,","raw_data_parcel_product")}}
          ) USING (parcel_id)


select * from nb_products_parcel

