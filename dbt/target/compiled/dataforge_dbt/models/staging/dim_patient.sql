

SELECT DISTINCT
    patient_id,
    CONCAT('Patient ', patient_id) AS patient_name,
    FLOOR(RAND() * 60) + 18 AS age,
    CASE 
        WHEN MOD(patient_id, 2) = 0 THEN 'female'
        ELSE 'male'
    END AS gender
FROM 
    `dataforge`.`fact_appointments`