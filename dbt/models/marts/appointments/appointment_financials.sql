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
    
    -- Berechneter Anteil, den der Patient selbst zahlt
    ROUND((patient_payment / total_cost) * 100, 2) AS patient_share_percent,

    -- Check: Summe von Versicherungsleistung + Patientenzahlung = Gesamtkosten?
    ROUND(((insurance_coverage + patient_payment) / total_cost) * 100, 2) AS total_coverage_check

FROM 
    {{ source('dataforge', 'fact_appointments') }}
WHERE
    total_cost > 0