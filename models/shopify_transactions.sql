{{
    config(
        materialized='table'
    )
}}

with shopify_orders as (
    select
    *
    from
    {{ source('shopify','ORDER') }}
)

, shopify_customers as (
    select
    *
    from
    {{ source('shopify','customer') }}
)

select 
* 
from shopify_orders o
left join shopify_customers c
    on o.customer_id = c.id
where o.customer_id is not null