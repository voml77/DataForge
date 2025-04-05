{{ config(materialized='view') }}

SELECT
    appointment_id,
    patient_id,
    treatment_id,
    dentist_id,
    appointment_date,
    total_cost,
    insurance_coverage,
    patient_payment,
    
    ROUND((patient_payment / total_cost) * 100, 2) AS patient_share_percent,
    ROUND(((insurance_coverage + patient_payment) / total_cost) * 100, 2) AS total_coverage_check,

    dd.weekday_type,
    dd.year,
    dd.month,
    dd.`year_month`
FROM
    {{ source('dataforge', 'fact_appointments') }} fa
LEFT JOIN 
    {{ ref('dim_date') }} dd
    ON fa.appointment_date = dd.date_day
WHERE
    total_cost > 0