{{
    config(
        materialized='table'
    )
}}

with orders as (

    select
        id as transaction_id,
        customer_id,
        order_number,
        name as order_name,
        created_at as order_created_at,
        processed_at,
        financial_status,
        fulfillment_status,
        currency,
        total_price,
        total_tax,
        total_discounts
    from {{ source('shopify', 'ORDER') }}
    where not coalesce(_fivetran_deleted, false)

),

customers as (

    select
        id as customer_id,
        lower(trim(email)) as customer_email,
        first_name as customer_first_name,
        last_name as customer_last_name
    from {{ source('shopify', 'customer') }}
    where not coalesce(_fivetran_deleted, false)

)

select
    orders.transaction_id,
    orders.customer_id,
    customers.customer_email,
    customers.customer_first_name,
    customers.customer_last_name,
    orders.order_number,
    orders.order_name,
    orders.order_created_at,
    orders.processed_at,
    orders.financial_status,
    orders.fulfillment_status,
    orders.currency,
    orders.total_price,
    orders.total_tax,
    orders.total_discounts
from orders
left join customers
    on orders.customer_id = customers.customer_id
