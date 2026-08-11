{{
    config(
        materialized='table'
    )
}}

with incremental_leads as (
    select * from {{ ref('incremental_leads')}}
)

, shopify_transactions as (
    select * from {{ ref('shopify_transactions')}}
)


select
*
from incremental_leads
