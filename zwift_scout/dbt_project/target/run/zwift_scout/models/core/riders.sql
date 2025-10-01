
  
    
    

    create  table
      "analytics"."main_core"."riders__dbt_tmp"
  
    as (
      

with intermediate as (
    select * from "analytics"."main_intermediate"."int_riders"
),

final as (
    select
        -- Identity
        rider_id,
        name,
        gender,
        country,
        age,
        height,
        weight,

        -- Category & Performance
        zp_category as category,
        zp_ftp as ftp,
        ftp_per_kg,

        -- Key power metrics (most commonly used)
        watts_kg_5s,
        watts_kg_60s,
        watts_kg_300s,
        watts_5s,
        watts_60s,
        watts_300s,
        critical_power,
        power_rating,

        -- Current racing status
        current_rating,
        current_race_at,
        current_mixed_category,
        current_mixed_number,

        -- 30-day peak performance
        max30_rating,
        max30_race_at,
        max30_expires_at,

        -- Race statistics
        finishes,
        dnfs,
        wins,
        podiums,
        win_rate_pct,
        podium_rate_pct,
        dnf_rate_pct,

        -- Rider type
        phenotype as rider_type,
        phenotype_bias,
        sprinter_score,
        puncheur_score,
        pursuiter_score,
        climber_score,
        tt_score,

        -- Terrain strengths
        handicap_flat,
        handicap_rolling,
        handicap_hilly,
        handicap_mountainous,

        -- Club
        club_id,
        club_name,

        -- Metadata
        loaded_at,
        _dlt_id as record_id

    from intermediate
)

select * from final
    );
  
  