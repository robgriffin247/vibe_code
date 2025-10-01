{{
    config(
        materialized='view'
    )
}}

with staged as (
    select * from {{ ref('stg_riders') }}
),

transformed as (
    select
        *,

        -- Convert _dlt_load_id to human-readable timestamp
        -- _dlt_load_id format is Unix timestamp with microseconds (e.g., 1759308455.704154)
        to_timestamp(cast(split_part(_dlt_load_id, '.', 1) as bigint)) as loaded_at,

        -- Calculate FTP per kg
        case
            when weight > 0 then round(zp_ftp / weight, 2)
            else null
        end as ftp_per_kg,

        -- Convert race dates from Unix timestamp to timestamp
        to_timestamp(last_date) as last_race_at,
        to_timestamp(current_date) as current_race_at,
        to_timestamp(max30_date) as max30_race_at,
        to_timestamp(max30_expires) as max30_expires_at,
        to_timestamp(max90_date) as max90_race_at,
        to_timestamp(max90_expires) as max90_expires_at,

        -- Calculate win rate
        case
            when finishes > 0 then round((wins::float / finishes) * 100, 2)
            else 0
        end as win_rate_pct,

        -- Calculate podium rate
        case
            when finishes > 0 then round((podiums::float / finishes) * 100, 2)
            else 0
        end as podium_rate_pct,

        -- Calculate DNF rate
        case
            when (finishes + dnfs) > 0 then round((dnfs::float / (finishes + dnfs)) * 100, 2)
            else 0
        end as dnf_rate_pct

    from staged
)

select * from transformed
