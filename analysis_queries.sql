

CREATE TABLE military_data (
    rank                                    NUMBER,
    country                                 VARCHAR2(100),
    region                                  VARCHAR2(50),
    total_population                        NUMBER,
    total_military_manpower                 NUMBER,
    fit_for_service                         NUMBER,
    pop_military_age_annually               NUMBER,
    active_personnel                        NUMBER,
    reserve_personnel                       NUMBER,
    paramilitary                            NUMBER,
    total_military_aircraft                 NUMBER,
    fighter_aircraft                        NUMBER,
    attack_aircraft                         NUMBER,
    transport_aircraft                      NUMBER,
    trainer_aircraft                        NUMBER,
    special_mission_aircraft                NUMBER,
    tanker_aircraft                         NUMBER,
    total_military_helicopters              NUMBER,
    attack_helicopters                      NUMBER,
    tanks                                   NUMBER,
    armored_fighting_vehicles               NUMBER,
    self_propelled_artillery                NUMBER,
    towed_artillery                         NUMBER,
    rocket_projectors                       NUMBER,
    total_naval_fleet                       NUMBER,
    total_naval_fleet_tonnage_mt            NUMBER,
    aircraft_carriers                       NUMBER,
    helicopter_carriers                     NUMBER,
    submarines                              NUMBER,
    destroyers                              NUMBER,
    frigates                                NUMBER,
    corvettes                               NUMBER,
    coastal_patrol_craft                    NUMBER,
    mine_warfare_craft                      NUMBER,
    defense_budget_usd                      NUMBER,
    external_debt_usd                       NUMBER,
    purchasing_power_parity_usd             NUMBER,
    fx_gold_reserves_usd                    NUMBER,
    total_serviceable_airports              NUMBER,
    labour_force                            NUMBER,
    major_ports_and_terminals               NUMBER,
    total_merchant_marine_fleet             NUMBER,
    railway_coverage_km                     NUMBER,
    roadway_coverage_km                     NUMBER,
    oil_production_bbl                      NUMBER,
    oil_consumption_bbl                     NUMBER,
    proven_oil_reserves_bbl                 NUMBER,
    natural_gas_production_cum              NUMBER,
    natural_gas_consumption_cum             NUMBER,
    proven_natural_gas_reserves             NUMBER,
    coal_production_cum                     NUMBER,
    coal_consumption_mt                     NUMBER,
    proven_coal_reserves_cum                NUMBER,
    total_land_area_sq_km                   NUMBER,
    coastline_coverage_km                   NUMBER,
    border_coverage_km                      NUMBER,
    waterway_coverage_km                    NUMBER
);

select * from military_data;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(country) AS has_country,
    COUNT(active_personnel) AS has_active_personnel,
    COUNT(defense_budget_usd) AS has_budget,
    COUNT(tanks) AS has_tanks,
    COUNT(region) AS has_region
FROM military_data;

SELECT country, active_personnel, defense_budget_usd, tanks, total_military_aircraft
FROM military_data
WHERE active_personnel = 0 OR defense_budget_usd = 0
ORDER BY rank;

SELECT region, COUNT(*) AS country_count
FROM military_data
GROUP BY region
ORDER BY country_count DESC;

SELECT *
FROM (
    SELECT rank, country, 
           ROUND(defense_budget_usd / 1e9, 1) AS budget_billion
    FROM military_data
    WHERE defense_budget_usd > 0
    ORDER BY defense_budget_usd DESC
)
WHERE ROWNUM <= 10;

SELECT country, active_personnel, tanks, total_military_aircraft
FROM military_data
WHERE active_personnel > 5000000
   OR tanks > 20000
   OR active_personnel < 0;





SELECT *
FROM (
    SELECT 
        rank,
        country,
        region,
        active_personnel,
        reserve_personnel,
        (active_personnel + reserve_personnel) AS total_force
    FROM military_data
    WHERE active_personnel > 0
    ORDER BY active_personnel DESC
)
WHERE ROWNUM <= 10;



-- Region üzrə ümumi manpower
SELECT 
    region,
    COUNT(country)                          AS country_count,
    SUM(active_personnel)                   AS total_active,
    ROUND(AVG(active_personnel), 0)         AS avg_active,
    MAX(active_personnel)                   AS max_active
FROM military_data
WHERE active_personnel > 0
GROUP BY region
ORDER BY total_active DESC;


-- ═══════════════════════════════════════
-- BLOK 2: BÜDCƏ ANALİZİ
-- ═══════════════════════════════════════

-- TOP 10 büdcə + hər ölkənin dünya büdcəsindən faizi
SELECT * FROM
(SELECT 
    rank,
    country,
    ROUND(defense_budget_usd / 1e9, 1)          AS budget_billion_usd,
    ROUND(defense_budget_usd * 100.0 / 
          SUM(defense_budget_usd) OVER (), 1)    AS pct_of_world
FROM military_data
WHERE defense_budget_usd > 0
ORDER BY defense_budget_usd DESC
)WHERE ROWNUM<=10;

-- Büdcə vs əhali nisbəti (hər nəfərə düşən xərc)
SELECT * FROM(
SELECT 
    country,
    ROUND(defense_budget_usd / 1e9, 1)                          AS budget_B,
    ROUND(defense_budget_usd / NULLIF(total_population, 0), 0)  AS budget_per_capita_usd
FROM military_data
WHERE defense_budget_usd > 0 AND total_population > 0
ORDER BY budget_per_capita_usd DESC
)WHERE ROWNUM<=15;


-- ═══════════════════════════════════════
-- BLOK 3: HƏRBİ TƏXNİKA
-- ═══════════════════════════════════════

-- TOP 10 hava gücü
SELECT * FROM(
SELECT 
    rank,
    country,
    total_military_aircraft,
    fighter_aircraft,
    attack_aircraft,
    total_military_helicopters,
    attack_helicopters
FROM military_data
WHERE total_military_aircraft > 0
ORDER BY total_military_aircraft DESC
)WHERE ROWNUM<=10;

-- TOP 10 quru gücü
SELECT * FROM(
SELECT 
    rank,
    country,
    tanks,
    armored_fighting_vehicles,
    self_propelled_artillery,
    towed_artillery,
    rocket_projectors,
    tanks + armored_fighting_vehicles AS armored_total
FROM military_data
WHERE tanks > 0
ORDER BY tanks DESC
)WHERE ROWNUM<=10;

-- TOP 10 dəniz gücü
SELECT * FROM(
SELECT 
    rank,
    country,
    total_naval_fleet,
    aircraft_carriers,
    submarines,
    destroyers,
    frigates
FROM military_data
WHERE total_naval_fleet > 0
ORDER BY total_naval_fleet DESC
)WHERE ROWNUM<=10;

-- ═══════════════════════════════════════
-- BLOK 4: MÜRƏKKƏB ANALİZ
-- ═══════════════════════════════════════

-- Region üzrə ortalama rank (aşağı = güclü)
SELECT 
    region,
    ROUND(AVG(rank), 1)              AS avg_rank,
    MIN(rank)                        AS best_rank,
    COUNT(country)                   AS country_count,
    ROUND(SUM(defense_budget_usd) / 1e9, 0) AS total_budget_B
FROM military_data
GROUP BY region
ORDER BY avg_rank;

-- Hər regionun #1 ölkəsi
SELECT region, country, rank, 
       ROUND(defense_budget_usd / 1e9, 1) AS budget_B
FROM (
    SELECT region, country, rank, defense_budget_usd,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY rank) AS rn
    FROM military_data
)
WHERE rn = 1
ORDER BY rank;

-- Büdcə olmadan güclü ölkələr (effektiv ordular)
SELECT 
    country,
    rank,
    ROUND(defense_budget_usd / 1e9, 1)  AS budget_B,
    active_personnel,
    tanks,
    total_military_aircraft
FROM military_data
WHERE rank <= 20
ORDER BY rank;


