
  
    

  create  table
    `dataforge`.`dim_treatment__dbt_tmp`
    
    
      as
    
    (
      

SELECT DISTINCT
    treatment_id,
    CONCAT('Behandlung ', treatment_id) AS treatment_name,
    ROUND(RAND() * 150 + 50, 2) AS base_cost
FROM 
    `dataforge`.`fact_appointments`
    )

  