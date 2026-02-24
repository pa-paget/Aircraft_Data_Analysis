with aircrafts as (
    select * from {{ref('dim_aircrafts')}}
),

individual_flights as(
    select * from {{ref('stg_individual_flights')}}
),

aircraft_flights as (
    select
        aircrafts.aircraft_id,
        aircrafts.aircraft_type,
        count(distinct individual_flights.flight_id) as nb_flights
    from aircrafts
    join individual_flights on aircrafts.aircraft_id = individual_flights.aircraft_id
    group by aircrafts.aircraft_id , aircrafts.aircraft_type
)

select * from aircraft_flights