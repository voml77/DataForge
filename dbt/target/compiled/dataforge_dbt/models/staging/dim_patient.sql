

SELECT
    patient_id,
    CONCAT('Patient ', patient_id) AS patient_name,
    MIN(FLOOR(RAND() * 60) + 18) AS age,
    MIN(
      CASE 
          WHEN MOD(patient_id, 2) = 0 THEN 'female'
          ELSE 'male'
      END
    ) AS gender
FROM 
    `dataforge`.`fact_appointments`
GROUP BY patient_id