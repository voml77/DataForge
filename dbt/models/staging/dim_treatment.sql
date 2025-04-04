{{ config(materialized='table') }}

SELECT DISTINCT
    treatment_id,
    CONCAT('Behandlung ', treatment_id) AS treatment_name,
    ROUND(RAND() * 150 + 50, 2) AS base_cost
FROM 
    {{ source('dataforge', 'fact_appointments') }}