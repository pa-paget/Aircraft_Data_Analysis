with airlines as (
    select * from {{ref('dim_airlines')}}
),

flight_summary as (
    select * from {{ref('stg_flight_summary_data')}}
),


-- Création d'un CTE pour calculer le total par année par compagnie
airlines_summary as (
    select
        YEAR(flight_summary.date) as year,
        flight_summary.airline_code,
        airlines.airline_name,
        sum(flight_summary.RPM_domestic) as domestic_revenue,
        sum(flight_summary.RPM_international) as international_revenue,
        (sum(flight_summary.RPM_domestic) + sum(flight_summary.RPM_international)) as total_revenue
    FROM flight_summary
    JOIN airlines ON flight_summary.airline_code = airlines.airline_code
    GROUP BY 
        YEAR(flight_summary.date),
        flight_summary.airline_code,
        airlines.airline_name
)


-- Classement par fenêtre windows pour afficher le l'année du Top 1 domestic, le top 1 international et le top 1 total par compagnie

-- meilleure année pour 'domestic'
select 
    airlines_summary.airline_code,
    airlines_summary.airline_name,
    year,
    domestic_revenue as revenue,
    'domestic' as metric
FROM airlines_summary
QUALIFY ROW_NUMBER() OVER (
    partition by airline_code
    order by domestic_revenue DESC
) = 1

UNION ALL

-- meilleure année pour 'international'
select
    airlines_summary.airline_code,
    airlines_summary.airline_name,
    year,
    international_revenue as revenue,
    'international' as metric
from airlines_summary
QUALIFY ROW_NUMBER() OVER (
    partition by airline_code
    order by international_revenue DESC
) = 1

UNION ALL

-- meilleure année pour 'total'
select 
    airlines_summary.airline_code,
    airlines_summary.airline_name,
    year,
    total_revenue as revenue,
    'total' as metric
from airlines_summary
QUALIFY ROW_NUMBER() OVER(
    partition by airline_code
    order by total_revenue DESC
) = 1