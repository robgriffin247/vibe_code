

with source as (
    select * from raw.zr_raw.riders
),

-- Get most recent load for each rider
most_recent as (
    select
        rider_id,
        max(_dlt_load_id) as latest_load_id
    from source
    group by rider_id
),

-- Filter to only most recent records
latest_records as (
    select s.*
    from source s
    inner join most_recent mr
        on s.rider_id = mr.rider_id
        and s._dlt_load_id = mr.latest_load_id
),

renamed as (
    select
        -- Identity
        rider_id,
        name,
        gender,
        country,
        age,
        height,
        coalesce(weight, weight__v_double)::float as weight,

        -- Category & FTP
        zp_category,
        zp_ftp,

        -- Power watts/kg - renamed from power__wkg[duration]
        power__wkg5::float as watts_kg_5s,
        power__wkg15::float as watts_kg_15s,
        power__wkg30::float as watts_kg_30s,
        power__wkg60::float as watts_kg_60s,
        power__wkg120::float as watts_kg_120s,
        power__wkg300::float as watts_kg_300s,
        power__wkg1200::float as watts_kg_1200s,

        -- Power watts - renamed from power__w[duration]
        power__w5::float as watts_5s,
        power__w15::float as watts_15s,
        power__w30::float as watts_30s,
        power__w60::float as watts_60s,
        power__w120::float as watts_120s,
        power__w300::float as watts_300s,
        power__w1200::float as watts_1200s,

        -- Power analysis
        power__cp::float as critical_power,
        power__awc::float as anaerobic_work_capacity,
        power__compound_score::float as compound_score,
        power__power_rating::float as power_rating,

        -- Race data - last
        race__last__rating::float as last_rating,
        race__last__date::bigint as last_date,
        race__last__mixed__category as last_mixed_category,
        race__last__mixed__number::int as last_mixed_number,

        -- Race data - current
        race__current__rating::float as current_rating,
        race__current__date::bigint as current_date,
        race__current__mixed__category as current_mixed_category,
        race__current__mixed__number::int as current_mixed_number,

        -- Race data - max30
        race__max30__rating::float as max30_rating,
        race__max30__date::bigint as max30_date,
        race__max30__expires::bigint as max30_expires,
        race__max30__mixed__category as max30_mixed_category,
        race__max30__mixed__number::int as max30_mixed_number,

        -- Race data - max90
        race__max90__rating::float as max90_rating,
        race__max90__date::bigint as max90_date,
        race__max90__expires::bigint as max90_expires,
        race__max90__mixed__category as max90_mixed_category,
        race__max90__mixed__number::int as max90_mixed_number,

        -- Race statistics
        race__finishes::int as finishes,
        race__dnfs::int as dnfs,
        race__wins::int as wins,
        race__podiums::int as podiums,

        -- Handicaps
        handicaps__profile__flat::float as handicap_flat,
        handicaps__profile__rolling::float as handicap_rolling,
        handicaps__profile__hilly::float as handicap_hilly,
        handicaps__profile__mountainous::float as handicap_mountainous,

        -- Phenotype scores
        phenotype__scores__sprinter::float as sprinter_score,
        phenotype__scores__puncheur::float as puncheur_score,
        phenotype__scores__pursuiter::float as pursuiter_score,
        phenotype__scores__climber::float as climber_score,
        phenotype__scores__tt::float as tt_score,
        phenotype__value as phenotype,
        phenotype__bias::float as phenotype_bias,

        -- Club
        club__id::int as club_id,
        club__name as club_name,

        -- DLT metadata
        _dlt_load_id,
        _dlt_id

    from latest_records
)

select * from renamed