{{
    config(
        materialized='table'
    )
}}

with date_series as (

    select
        dateadd(
            day,
            seq4(),
            dateadd(year, -10, date_trunc('year', current_date()))
        )::date as date_day
    from table(generator(rowcount => 4384))

)

select
    date_day
from date_series
where date_day < dateadd(year, 1, date_trunc('year', current_date()))
