{{ config(materialized='table') }}

SELECT DISTINCT
    dentist_id,
    CONCAT('Dr. Zahn ', dentist_id) AS dentist_name,
    CASE 
        WHEN MOD(dentist_id, 3) = 0 THEN 'implantologist'
        WHEN MOD(dentist_id, 3) = 1 THEN 'orthodontist'
        ELSE 'general dentist'
    END AS specialization
FROM 
    {{ source('dataforge', 'fact_appointments') }}