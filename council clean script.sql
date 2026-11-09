show databases;
use council_tax_band;
show tables;
select * from council_tax_raw;
SELECT COLUMN_NAME INTO @old_column
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'council_tax_raw'
  AND ORDINAL_POSITION = 1;

-- Build and run the rename statement
SET @rename_sql = CONCAT(
    'ALTER TABLE `council_tax_raw` CHANGE COLUMN `',
    REPLACE(@old_column, '`', '``'),
    '` `geography` TEXT NULL'
);

PREPARE rename_statement FROM @rename_sql;
EXECUTE rename_statement;
DEALLOCATE PREPARE rename_statement;

describe council_tax_raw;

SELECT COUNT(*) AS total_rows
FROM council_tax_raw;
SELECT
    'ecode',
    COUNT(*) AS occurrences
FROM council_tax_raw
GROUP BY 'ecode'
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT TRIM(ecode)) AS unique_area_codes,
    SUM(
        CASE
            WHEN ecode IS NULL OR TRIM(ecode) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_area_codes
FROM council_tax_raw;

SELECT
    SUM(
        CASE
            WHEN geography IS NULL OR TRIM(geography) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_geography,
    SUM(
        CASE
            WHEN area_name IS NULL OR TRIM(area_name) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_area_name
FROM council_tax_raw;

SELECT
    band_value,
    COUNT(*) AS occurrences
FROM (
    SELECT TRIM(band_a) AS band_value FROM council_tax_raw
    UNION ALL
    SELECT TRIM(band_b) FROM council_tax_raw
    UNION ALL
    SELECT TRIM(band_c) FROM council_tax_raw
    UNION ALL
    SELECT TRIM(band_d) FROM council_tax_raw
    UNION ALL
    SELECT TRIM(band_e) FROM council_tax_raw
    UNION ALL
    SELECT TRIM(band_f) FROM council_tax_raw
    UNION ALL
    SELECT TRIM(band_g) FROM council_tax_raw
    UNION ALL
    SELECT TRIM(band_h) FROM council_tax_raw
    UNION ALL
    SELECT TRIM(band_i) FROM council_tax_raw
) AS bands
WHERE band_value IS NULL
   OR band_value NOT REGEXP '^[0-9]+$'
GROUP BY band_value
ORDER BY occurrences DESC;

CREATE TABLE council_tax_clean LIKE council_tax_raw;

INSERT INTO council_tax_clean
SELECT *
FROM council_tax_raw;

SELECT COUNT(*) AS total_rows
FROM council_tax_clean;

UPDATE council_tax_clean
SET
    geography = TRIM(geography),
    ba_code = TRIM(ba_code),
    ecode = TRIM(ecode),
    area_name = TRIM(area_name);

select * from council_tax_clean;

UPDATE council_tax_clean
SET ba_code = CASE
    WHEN UPPER(TRIM(ba_code)) = 'N/A'
         OR TRIM(ba_code) = ''
    THEN NULL
    ELSE TRIM(ba_code)
END;

SELECT
    geography,
    COUNT(*) AS total_rows,
    COUNT(ba_code) AS rows_with_billing_code
FROM council_tax_clean
GROUP BY geography
ORDER BY total_rows DESC;

ALTER TABLE council_tax_clean
ADD COLUMN band_a_count INT UNSIGNED NULL;

UPDATE council_tax_clean
SET band_a_count = CASE
    WHEN TRIM(band_a) REGEXP '^[0-9]+$'
    THEN CAST(TRIM(band_a) AS UNSIGNED)
    ELSE NULL
END;


SELECT
    band_a,
    band_a_count,
    COUNT(*) AS occurrences
FROM council_tax_clean
GROUP BY band_a, band_a_count
ORDER BY occurrences DESC
LIMIT 15;


ALTER TABLE council_tax_clean
ADD COLUMN band_b_count INT UNSIGNED NULL,
ADD COLUMN band_c_count INT UNSIGNED NULL,
ADD COLUMN band_d_count INT UNSIGNED NULL,
ADD COLUMN band_e_count INT UNSIGNED NULL,
ADD COLUMN band_f_count INT UNSIGNED NULL,
ADD COLUMN band_g_count INT UNSIGNED NULL,
ADD COLUMN band_h_count INT UNSIGNED NULL,
ADD COLUMN band_i_count INT UNSIGNED NULL,
ADD COLUMN all_properties_count INT UNSIGNED NULL;

SELECT
    COUNT(*) AS total_rows,
    COUNT(all_properties_count) AS numeric_property_totals
FROM council_tax_clean;

UPDATE council_tax_clean
SET all_properties_count = CASE
    WHEN TRIM(all_properties) REGEXP '^[0-9]+$'
    THEN CAST(TRIM(all_properties) AS UNSIGNED)
    ELSE NULL
END;

SELECT
    all_properties,
    all_properties_count
FROM council_tax_clean
LIMIT 10;


SELECT
    COUNT(*) AS total_rows,
    COUNT(band_a_count) AS numeric_a,
    COUNT(band_b_count) AS numeric_b,
    COUNT(band_c_count) AS numeric_c,
    COUNT(band_d_count) AS numeric_d,
    COUNT(band_e_count) AS numeric_e,
    COUNT(band_f_count) AS numeric_f,
    COUNT(band_g_count) AS numeric_g,
    COUNT(band_h_count) AS numeric_h,
    COUNT(band_i_count) AS numeric_i,
    COUNT(all_properties_count) AS numeric_totals
FROM council_tax_clean;

UPDATE council_tax_clean
SET
    band_b_count = CASE
        WHEN TRIM(band_b) REGEXP '^[0-9]+$'
        THEN CAST(TRIM(band_b) AS UNSIGNED)
        ELSE NULL END,

    band_c_count = CASE
        WHEN TRIM(band_c) REGEXP '^[0-9]+$'
        THEN CAST(TRIM(band_c) AS UNSIGNED)
        ELSE NULL END,

    band_d_count = CASE
        WHEN TRIM(band_d) REGEXP '^[0-9]+$'
        THEN CAST(TRIM(band_d) AS UNSIGNED)
        ELSE NULL END,

    band_e_count = CASE
        WHEN TRIM(band_e) REGEXP '^[0-9]+$'
        THEN CAST(TRIM(band_e) AS UNSIGNED)
        ELSE NULL END,

    band_f_count = CASE
        WHEN TRIM(band_f) REGEXP '^[0-9]+$'
        THEN CAST(TRIM(band_f) AS UNSIGNED)
        ELSE NULL END,

    band_g_count = CASE
        WHEN TRIM(band_g) REGEXP '^[0-9]+$'
        THEN CAST(TRIM(band_g) AS UNSIGNED)
        ELSE NULL END,

    band_h_count = CASE
        WHEN TRIM(band_h) REGEXP '^[0-9]+$'
        THEN CAST(TRIM(band_h) AS UNSIGNED)
        ELSE NULL END,

    band_i_count = CASE
        WHEN TRIM(band_i) REGEXP '^[0-9]+$'
        THEN CAST(TRIM(band_i) AS UNSIGNED)
        ELSE NULL END,

    all_properties_count = CASE
        WHEN TRIM(all_properties) REGEXP '^[0-9]+$'
        THEN CAST(TRIM(all_properties) AS UNSIGNED)
        ELSE NULL END;


SELECT
    COUNT(band_b_count) AS numeric_b,
    COUNT(band_c_count) AS numeric_c,
    COUNT(band_d_count) AS numeric_d,
    COUNT(band_e_count) AS numeric_e,
    COUNT(band_f_count) AS numeric_f,
    COUNT(band_g_count) AS numeric_g,
    COUNT(band_h_count) AS numeric_h,
    COUNT(band_i_count) AS numeric_i
FROM council_tax_clean;

SELECT
    COUNT(*) AS total_rows,
    COUNT(band_f_count) AS numeric_f,
    COUNT(band_g_count) AS numeric_g,
    COUNT(band_h_count) AS numeric_h,
    COUNT(band_i_count) AS numeric_i,
    COUNT(all_properties_count) AS numeric_totals
FROM council_tax_clean;

--analysis with national property totals

SELECT
    area_name,
    all_properties_count AS total_properties
FROM council_tax_clean
WHERE geography = 'NATL'
ORDER BY total_properties DESC;

--country percentage share of total properties
SELECT
    area_name,
    all_properties_count AS total_properties,
    ROUND(
        100.0 * all_properties_count /
        (
            SELECT SUM(all_properties_count)
            FROM council_tax_clean
            WHERE geography = 'NATL'
        ),
        2
    ) AS share_percent
FROM council_tax_clean
WHERE geography = 'NATL'
ORDER BY total_properties DESC;

-- all properties count for England and Wales, National and Unitary authorities
SELECT
    geography,
    area_name,
    all_properties_count
FROM council_tax_clean
WHERE geography IN ('ENGWAL', 'NATL', 'UNMD');
-- total properties and percentage share for each region (REGL) of England and Wales

SELECT
    area_name AS region,
    all_properties_count AS total_properties,
    ROUND(
        100.0 * all_properties_count /
        NULLIF(
            (
                SELECT SUM(all_properties_count)
                FROM council_tax_clean
                WHERE geography = 'REGL'
            ),
            0
        ),
        2
    ) AS regional_share_percent
FROM council_tax_clean
WHERE geography = 'REGL'
ORDER BY total_properties DESC;

-- local authority with most properties in each region (REGL) of England and Wales

SELECT
    ecode,
    area_name AS local_authority,
    all_properties_count AS total_properties
FROM council_tax_clean
WHERE geography = 'LAUA'
ORDER BY total_properties DESC, area_name ASC
LIMIT 10;


-- authority give the highest percentade to band A

SELECT
    area_name AS local_authority,
    all_properties_count AS total_properties,
    band_a_count AS band_a_properties,
    ROUND(
        100.0 * band_a_count /
        NULLIF(all_properties_count, 0),
        2
    ) AS band_a_percent
FROM council_tax_clean
WHERE geography = 'LAUA'
  AND band_a_count IS NOT NULL
  AND all_properties_count > 0
ORDER BY band_a_percent DESC, area_name ASC
LIMIT 10;
-- authority by share band f-h

SELECT
    area_name AS local_authority,
    all_properties_count AS total_properties,
    band_f_count + band_g_count + band_h_count
        AS bands_f_to_h_properties,
    ROUND(
        100.0 * (
            band_f_count + band_g_count + band_h_count
        ) / NULLIF(all_properties_count, 0),
        2
    ) AS bands_f_to_h_percent
FROM council_tax_clean
WHERE geography = 'LAUA'
  AND ecode LIKE 'E%'
  AND band_f_count IS NOT NULL
  AND band_g_count IS NOT NULL
  AND band_h_count IS NOT NULL
  AND all_properties_count > 0
ORDER BY bands_f_to_h_percent DESC, area_name ASC
LIMIT 10;
-- compare band A and band H percentages to f-h 

SELECT
    area_name AS region,
    all_properties_count AS total_properties,

    ROUND(
        100.0 * band_a_count /
        NULLIF(all_properties_count, 0),
        2
    ) AS band_a_percent,

    ROUND(
        100.0 * (
            band_f_count + band_g_count + band_h_count
        ) / NULLIF(all_properties_count, 0),
        2
    ) AS bands_f_to_h_percent

FROM council_tax_clean
WHERE geography = 'REGL'
ORDER BY bands_f_to_h_percent DESC, area_name ASC;

-- how many properties distrubuted across England and Wales

SELECT
    band,
    property_count,
    ROUND(
        100.0 * property_count /
        NULLIF(total_properties, 0),
        2
    ) AS share_percent
FROM (
    SELECT 'A' AS band, band_a_count AS property_count,
           all_properties_count AS total_properties
    FROM council_tax_clean WHERE geography = 'ENGWAL'

    UNION ALL
    SELECT 'B', band_b_count, all_properties_count
    FROM council_tax_clean WHERE geography = 'ENGWAL'

    UNION ALL
    SELECT 'C', band_c_count, all_properties_count
    FROM council_tax_clean WHERE geography = 'ENGWAL'

    UNION ALL
    SELECT 'D', band_d_count, all_properties_count
    FROM council_tax_clean WHERE geography = 'ENGWAL'

    UNION ALL
    SELECT 'E', band_e_count, all_properties_count
    FROM council_tax_clean WHERE geography = 'ENGWAL'

    UNION ALL
    SELECT 'F', band_f_count, all_properties_count
    FROM council_tax_clean WHERE geography = 'ENGWAL'

    UNION ALL
    SELECT 'G', band_g_count, all_properties_count
    FROM council_tax_clean WHERE geography = 'ENGWAL'

    UNION ALL
    SELECT 'H', band_h_count, all_properties_count
    FROM council_tax_clean WHERE geography = 'ENGWAL'

    UNION ALL
    SELECT 'I', band_i_count, all_properties_count
    FROM council_tax_clean WHERE geography = 'ENGWAL'
) AS band_distribution
ORDER BY band;

-- check all nine count

SELECT
    published_total,
    sum_of_bands,
    CAST(published_total AS SIGNED)
        - CAST(sum_of_bands AS SIGNED) AS difference
FROM (
    SELECT
        all_properties_count AS published_total,

        band_a_count + band_b_count + band_c_count
        + band_d_count + band_e_count + band_f_count
        + band_g_count + band_h_count + band_i_count
            AS sum_of_bands

    FROM council_tax_clean
    WHERE geography = 'ENGWAL'
) AS totals_check;

-- check percentage property A-c 

SELECT
    area_name AS region,
    all_properties_count AS total_properties,

    band_a_count + band_b_count + band_c_count
        AS bands_a_to_c_properties,

    ROUND(
        100.0 * (
            band_a_count + band_b_count + band_c_count
        ) / NULLIF(all_properties_count, 0),
        2
    ) AS bands_a_to_c_percent

FROM council_tax_clean
WHERE geography = 'REGL'
ORDER BY bands_a_to_c_percent DESC, area_name ASC;

-- check percentage property A-c, d-e,f-h

CREATE OR REPLACE VIEW vw_regional_band_mix AS
SELECT
    ecode,
    area_name AS region,
    all_properties_count AS total_properties,

    band_a_count + band_b_count + band_c_count
        AS bands_a_to_c,

    band_d_count + band_e_count
        AS bands_d_to_e,

    band_f_count + band_g_count + band_h_count
        AS bands_f_to_h

FROM council_tax_clean
WHERE geography = 'REGL';

-- check percentage property A-c, d-e,f-h

SELECT
    region,
    total_properties,
    ROUND(
        100.0 * bands_a_to_c / NULLIF(total_properties, 0), 2
    ) AS a_to_c_percent,
    ROUND(
        100.0 * bands_d_to_e / NULLIF(total_properties, 0), 2
    ) AS d_to_e_percent,
    ROUND(
        100.0 * bands_f_to_h / NULLIF(total_properties, 0), 2
    ) AS f_to_h_percent
FROM vw_regional_band_mix
ORDER BY a_to_c_percent DESC;

-- sunderland council tax band distribution with England


SELECT
    area_name,
    all_properties_count AS total_properties,

    ROUND(
        100.0 * (band_a_count + band_b_count + band_c_count)
        / NULLIF(all_properties_count, 0), 2
    ) AS a_to_c_percent,

    ROUND(
        100.0 * (band_d_count + band_e_count)
        / NULLIF(all_properties_count, 0), 2
    ) AS d_to_e_percent,

    ROUND(
        100.0 * (band_f_count + band_g_count + band_h_count)
        / NULLIF(all_properties_count, 0), 2
    ) AS f_to_h_percent

FROM council_tax_clean
WHERE (geography = 'LAUA' AND ecode = 'E08000024')
   OR (geography = 'NATL' AND ecode = 'E92000001')
ORDER BY geography;

-- check across all England local authorities using cross join

SELECT
    la.area_name AS local_authority,
    la.all_properties_count AS total_properties,

    ROUND(
        100.0 *
        (la.band_a_count + la.band_b_count + la.band_c_count)
        / NULLIF(la.all_properties_count, 0),
        2
    ) AS a_to_c_percent,

    ROUND(
        100.0 *
        (la.band_a_count + la.band_b_count + la.band_c_count)
        / NULLIF(la.all_properties_count, 0)

        - 100.0 *
        (eng.band_a_count + eng.band_b_count + eng.band_c_count)
        / NULLIF(eng.all_properties_count, 0),
        2
    ) AS gap_from_england_pp

FROM council_tax_clean AS la

CROSS JOIN (
    SELECT *
    FROM council_tax_clean
    WHERE geography = 'NATL'
      AND ecode = 'E92000001'
) AS eng

WHERE la.geography = 'LAUA'
  AND la.ecode LIKE 'E%'
  AND la.band_a_count IS NOT NULL
  AND la.band_b_count IS NOT NULL
  AND la.band_c_count IS NOT NULL
  AND la.all_properties_count > 0

ORDER BY gap_from_england_pp ASC, local_authority ASC
LIMIT 10;

-- compare for wales

SELECT
    area_name,
    all_properties_count AS total_properties,

    ROUND(
        100.0 * (band_a_count + band_b_count + band_c_count)
        / NULLIF(all_properties_count, 0), 2
    ) AS a_to_c_percent,

    ROUND(
        100.0 * (band_d_count + band_e_count)
        / NULLIF(all_properties_count, 0), 2
    ) AS d_to_e_percent,

    ROUND(
        100.0 * (band_f_count + band_g_count + band_h_count)
        / NULLIF(all_properties_count, 0), 2
    ) AS f_to_h_percent,

    ROUND(
        100.0 * band_i_count
        / NULLIF(all_properties_count, 0), 2
    ) AS band_i_percent

FROM council_tax_clean
WHERE geography = 'NATL'
  AND ecode = 'W92000004';
  -- Wales A-C
  
  SELECT
    la.area_name AS local_authority,
    la.all_properties_count AS total_properties,

    ROUND(
        100.0 *
        (la.band_a_count + la.band_b_count + la.band_c_count)
        / NULLIF(la.all_properties_count, 0),
        2
    ) AS a_to_c_percent,

    ROUND(
        100.0 *
        (la.band_a_count + la.band_b_count + la.band_c_count)
        / NULLIF(la.all_properties_count, 0)

        - 100.0 *
        (w.band_a_count + w.band_b_count + w.band_c_count)
        / NULLIF(w.all_properties_count, 0),
        2
    ) AS gap_from_wales_pp

FROM council_tax_clean AS la

CROSS JOIN (
    SELECT *
    FROM council_tax_clean
    WHERE geography = 'NATL'
      AND ecode = 'W92000004'
) AS w

WHERE la.geography = 'LAUA'
  AND la.ecode LIKE 'W%'
  AND la.band_a_count IS NOT NULL
  AND la.band_b_count IS NOT NULL
  AND la.band_c_count IS NOT NULL
  AND la.all_properties_count > 0

ORDER BY gap_from_wales_pp DESC, local_authority ASC;

-- correct the area name for Isle of Anglesey / Ynys Môn
UPDATE council_tax_clean
SET area_name = 'Isle of Anglesey / Ynys Môn'
WHERE geography = 'LAUA'
  AND ecode = 'W06000001';


SELECT
    ecode,
    area_name
FROM council_tax_clean
WHERE ecode = 'W06000001';

-- create a reusable view for your local authority dashboard
CREATE OR REPLACE VIEW vw_local_authority_band_mix AS
SELECT
    ecode,
    area_name AS local_authority,
    CASE
        WHEN ecode LIKE 'E%' THEN 'England'
        WHEN ecode LIKE 'W%' THEN 'Wales'
        ELSE 'Other'
    END AS country,

    all_properties_count AS total_properties,

    band_a_count + band_b_count + band_c_count
        AS bands_a_to_c,

    band_d_count + band_e_count
        AS bands_d_to_e,

    band_f_count + band_g_count + band_h_count
        AS bands_f_to_h,

    band_i_count,

    ROUND(
        100.0 * (band_a_count + band_b_count + band_c_count)
        / NULLIF(all_properties_count, 0), 2
    ) AS a_to_c_percent,

    ROUND(
        100.0 * (band_d_count + band_e_count)
        / NULLIF(all_properties_count, 0), 2
    ) AS d_to_e_percent,

    ROUND(
        100.0 * (band_f_count + band_g_count + band_h_count)
        / NULLIF(all_properties_count, 0), 2
    ) AS f_to_h_percent,

    ROUND(
        100.0 * band_i_count
        / NULLIF(all_properties_count, 0), 2
    ) AS band_i_percent

FROM council_tax_clean
WHERE geography = 'LAUA';

--check
SELECT country, COUNT(*) AS local_authorities
FROM vw_local_authority_band_mix
GROUP BY country;

SELECT *
FROM vw_local_authority_band_mix
ORDER BY total_properties DESC;


SELECT
    COUNT(*) AS total_rows,
    SUM(ecode IS NULL) AS null_ecode,
    SUM(local_authority IS NULL) AS null_local_authority,
    SUM(country IS NULL) AS null_country,
    SUM(total_properties IS NULL) AS null_total_properties,
    SUM(bands_a_to_c IS NULL) AS null_bands_a_to_c,
    SUM(bands_d_to_e IS NULL) AS null_bands_d_to_e,
    SUM(bands_f_to_h IS NULL) AS null_bands_f_to_h,
    SUM(band_i_count IS NULL) AS null_band_i,
    SUM(a_to_c_percent IS NULL) AS null_a_to_c_percent,
    SUM(d_to_e_percent IS NULL) AS null_d_to_e_percent,
    SUM(f_to_h_percent IS NULL) AS null_f_to_h_percent,
    SUM(band_i_percent IS NULL) AS null_band_i_percent
FROM vw_local_authority_band_mix;


SELECT
    ecode,
    area_name,
    band_a, band_b, band_c,
    band_f, band_g, band_h,
    band_a_count, band_b_count, band_c_count,
    band_f_count, band_g_count, band_h_count
FROM council_tax_clean
WHERE geography = 'LAUA'
  AND (
      band_a_count IS NULL
      OR band_b_count IS NULL
      OR band_c_count IS NULL
      OR band_f_count IS NULL
      OR band_g_count IS NULL
      OR band_h_count IS NULL
  )
ORDER BY area_name;