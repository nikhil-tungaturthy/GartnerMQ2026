{{
    config(
        materialized='table'
    )
}}

with leads as (

    select *
    from {{ ref('incremental_leads') }}

),

shopify_transactions as (

    select *
    from {{ ref('shopify_transactions') }}

),

shopify_customer_rollup as (

    select
        customer_email,
        count(*) as transaction_count,
        min(order_created_at) as first_purchase_at,
        max(order_created_at) as most_recent_purchase_at,
        sum(total_price) as lifetime_value
    from shopify_transactions
    where customer_email is not null
    group by 1

)

select
    leads.lead_id,
    leads.first_name,
    leads.last_name,
    leads.title,
    leads.company,
    leads.email,
    leads.phone,
    leads.street,
    leads.city,
    leads.state,
    leads.postal_code,
    leads.country,
    leads.created_date,
    leads.last_modified_date,
    leads.lead_source,
    leads.status,
    leads.industry,
    coalesce(shopify_customer_rollup.transaction_count, 0) > 0 as has_purchase_history,
    shopify_customer_rollup.first_purchase_at,
    shopify_customer_rollup.most_recent_purchase_at,
    coalesce(shopify_customer_rollup.lifetime_value, 0) as lifetime_value
from leads
left join shopify_customer_rollup
    on lower(trim(leads.email)) = shopify_customer_rollup.customer_email
