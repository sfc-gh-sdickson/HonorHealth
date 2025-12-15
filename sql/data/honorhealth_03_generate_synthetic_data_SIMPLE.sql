-- ============================================================================
-- Honor Health Intelligence Agent - SIMPLE Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic synthetic data for SDOH and Value-Based Care
-- Pattern: Simple INSERTs without complex CTEs
-- ============================================================================

USE DATABASE HONORHEALTH_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE HONORHEALTH_WH;

-- ============================================================================
-- TRUNCATE existing data
-- ============================================================================
TRUNCATE TABLE IF EXISTS HEALTH_POLICIES;
TRUNCATE TABLE IF EXISTS CLINICAL_NOTES;
TRUNCATE TABLE IF EXISTS CARE_PLANS;
TRUNCATE TABLE IF EXISTS HEALTH_OUTCOMES;
TRUNCATE TABLE IF EXISTS QUALITY_METRICS;
TRUNCATE TABLE IF EXISTS ENCOUNTERS;
TRUNCATE TABLE IF EXISTS PROVIDERS;
TRUNCATE TABLE IF EXISTS SOCIAL_DETERMINANTS;
TRUNCATE TABLE IF EXISTS PATIENTS;

-- ============================================================================
-- Table 1: PATIENTS (50,000 rows)
-- ============================================================================
INSERT INTO PATIENTS
SELECT
    'PT' || LPAD(SEQ4()::VARCHAR, 8, '0') AS patient_id,
    DATEADD(year, -UNIFORM(18, 85, RANDOM()), CURRENT_DATE()) AS date_of_birth,
    DATEDIFF(year, date_of_birth, CURRENT_DATE()) AS age,
    CASE UNIFORM(1, 2, RANDOM()) WHEN 1 THEN 'Male' ELSE 'Female' END AS gender,
    CASE UNIFORM(1, 6, RANDOM())
        WHEN 1 THEN 'White' WHEN 2 THEN 'Black or African American'
        WHEN 3 THEN 'Hispanic or Latino' WHEN 4 THEN 'Asian' ELSE 'White' END AS race,
    CASE UNIFORM(1, 3, RANDOM()) WHEN 1 THEN 'Hispanic or Latino' ELSE 'Not Hispanic or Latino' END AS ethnicity,
    CASE UNIFORM(1, 10, RANDOM()) WHEN 1 THEN 'Spanish' ELSE 'English' END AS preferred_language,
    LPAD(UNIFORM(85001, 85999, RANDOM())::VARCHAR, 5, '0') AS zip_code,
    CASE UNIFORM(1, 4, RANDOM()) WHEN 1 THEN 'Maricopa' WHEN 2 THEN 'Pima' WHEN 3 THEN 'Pinal' ELSE 'Yavapai' END AS county,
    'AZ' AS state,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Medicare' WHEN 2 THEN 'Medicaid' WHEN 3 THEN 'Commercial'
        WHEN 4 THEN 'Uninsured' ELSE 'Medicare Advantage' END AS insurance_type,
    'PRV' || LPAD(UNIFORM(1, 500, RANDOM())::VARCHAR, 5, '0') AS primary_care_provider_id,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'Basic'
         WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'Standard' ELSE 'Premium' END AS patient_tier,
    DATEADD(month, -UNIFORM(1, 120, RANDOM()), CURRENT_DATE()) AS enrollment_date,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

SELECT 'Patients: ' || COUNT(*) AS status FROM PATIENTS;

-- ============================================================================
-- Table 2: SOCIAL_DETERMINANTS (40,000 rows - first 40K patients)
-- ============================================================================
INSERT INTO SOCIAL_DETERMINANTS
SELECT
    'SDOH' || LPAD(SEQ4()::VARCHAR, 8, '0') AS sdoh_id,
    'PT' || LPAD(SEQ4()::VARCHAR, 8, '0') AS patient_id,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS assessment_date,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Full-time Employed' WHEN 2 THEN 'Part-time Employed'
        WHEN 3 THEN 'Unemployed' WHEN 4 THEN 'Retired' ELSE 'Disabled' END AS employment_status,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Under $25K' WHEN 2 THEN '$25K-$50K' WHEN 3 THEN '$50K-$75K'
        WHEN 4 THEN '$75K-$100K' ELSE 'Over $100K' END AS annual_income_range,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Less than High School' WHEN 2 THEN 'High School Graduate'
        WHEN 3 THEN 'Some College' WHEN 4 THEN 'College Graduate' ELSE 'Advanced Degree' END AS education_level,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'Owned' WHEN 2 THEN 'Rented' WHEN 3 THEN 'Homeless' ELSE 'Temporary Housing' END AS housing_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN TRUE ELSE FALSE END AS food_insecurity,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN TRUE ELSE FALSE END AS transportation_barriers,
    CASE UNIFORM(1, 3, RANDOM()) WHEN 1 THEN 'Low Risk' WHEN 2 THEN 'Moderate Risk' ELSE 'High Risk' END AS social_isolation_risk,
    CASE UNIFORM(1, 4, RANDOM()) WHEN 1 THEN 'None' WHEN 2 THEN 'Mild' WHEN 3 THEN 'Moderate' ELSE 'Severe' END AS financial_strain,
    CASE UNIFORM(1, 3, RANDOM()) WHEN 1 THEN 'Safe' WHEN 2 THEN 'Somewhat Safe' ELSE 'Unsafe' END AS neighborhood_safety,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN TRUE ELSE FALSE END AS utility_assistance_needed,
    UNIFORM(0, 100, RANDOM()) AS sdoh_risk_score,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 40000));

SELECT 'Social Determinants: ' || COUNT(*) AS status FROM SOCIAL_DETERMINANTS;

-- ============================================================================
-- Table 3: PROVIDERS (500 rows)
-- ============================================================================
INSERT INTO PROVIDERS
SELECT
    'PRV' || LPAD(SEQ4()::VARCHAR, 5, '0') AS provider_id,
    'Dr. Provider ' || SEQ4() AS provider_name,
    CASE UNIFORM(1, 3, RANDOM()) WHEN 1 THEN 'Physician' WHEN 2 THEN 'Nurse Practitioner' ELSE 'Physician Assistant' END AS provider_type,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'Family Medicine' WHEN 2 THEN 'Internal Medicine' WHEN 3 THEN 'Cardiology'
        WHEN 4 THEN 'Endocrinology' WHEN 5 THEN 'Pulmonology' WHEN 6 THEN 'Nephrology'
        WHEN 7 THEN 'Geriatrics' WHEN 8 THEN 'Pediatrics' WHEN 9 THEN 'Emergency Medicine' ELSE 'Oncology' END AS specialty,
    'FAC' || LPAD(UNIFORM(1, 20, RANDOM())::VARCHAR, 3, '0') AS facility_id,
    'HonorHealth Facility ' || UNIFORM(1, 6, RANDOM()) AS facility_name,
    UNIFORM(1, 35, RANDOM()) AS years_experience,
    UNIFORM(500, 3000, RANDOM()) AS patient_panel_size,
    UNIFORM(75, 98, RANDOM()) + (UNIFORM(0, 99, RANDOM()) / 100.0) AS quality_score,
    'Active' AS active_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 500));

SELECT 'Providers: ' || COUNT(*) AS status FROM PROVIDERS;

-- ============================================================================
-- Table 4: ENCOUNTERS (80,000 rows - references first 40K patients)
-- ============================================================================
INSERT INTO ENCOUNTERS
SELECT
    'ENC' || LPAD(SEQ4()::VARCHAR, 8, '0') AS encounter_id,
    'PT' || LPAD(UNIFORM(0, 39999, RANDOM())::VARCHAR, 8, '0') AS patient_id,
    'PRV' || LPAD(UNIFORM(0, 499, RANDOM())::VARCHAR, 5, '0') AS provider_id,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS encounter_date,
    CASE UNIFORM(1, 6, RANDOM())
        WHEN 1 THEN 'Primary Care Visit' WHEN 2 THEN 'Emergency Department'
        WHEN 3 THEN 'Urgent Care' WHEN 4 THEN 'Inpatient Admission'
        WHEN 5 THEN 'Specialist Visit' ELSE 'Telehealth' END AS encounter_type,
    'Visit Reason' AS visit_reason,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'E11.9' WHEN 2 THEN 'I10' WHEN 3 THEN 'I50.9' WHEN 4 THEN 'J44.9' ELSE 'Z00.00' END AS primary_diagnosis_code,
    NULL AS secondary_diagnoses,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Diabetes,Hypertension' WHEN 2 THEN 'Heart Failure,CKD'
        WHEN 3 THEN 'COPD,Hypertension' WHEN 4 THEN 'Diabetes,CAD,Hypertension' ELSE 'Hypertension' END AS chronic_conditions,
    NULL AS procedures_performed,
    CASE encounter_type
        WHEN 'Primary Care Visit' THEN UNIFORM(150, 350, RANDOM())
        WHEN 'Emergency Department' THEN UNIFORM(800, 2500, RANDOM())
        WHEN 'Inpatient Admission' THEN UNIFORM(15000, 50000, RANDOM())
        ELSE UNIFORM(100, 500, RANDOM()) END AS encounter_cost,
    CASE WHEN encounter_type = 'Inpatient Admission' THEN UNIFORM(2, 10, RANDOM()) ELSE 0 END AS length_of_stay_days,
    CASE WHEN encounter_type = 'Inpatient Admission' THEN 'Home' ELSE NULL END AS discharge_disposition,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN TRUE ELSE FALSE END AS readmission_30_day,
    CASE WHEN encounter_type = 'Emergency Department' THEN TRUE ELSE FALSE END AS emergency_visit,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 80000));

SELECT 'Encounters: ' || COUNT(*) AS status FROM ENCOUNTERS;

-- ============================================================================
-- Table 5: QUALITY_METRICS (60,000 rows)
-- ============================================================================
INSERT INTO QUALITY_METRICS
SELECT
    'QM' || LPAD(SEQ4()::VARCHAR, 8, '0') AS metric_id,
    'PT' || LPAD(UNIFORM(0, 39999, RANDOM())::VARCHAR, 8, '0') AS patient_id,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS measurement_date,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'CDC-D' WHEN 2 THEN 'CBP' WHEN 3 THEN 'COL' WHEN 4 THEN 'BCS' ELSE 'AWC' END AS hedis_measure_code,
    'Measure Name' AS measure_name,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'Diabetes Care' WHEN 2 THEN 'Cardiovascular Care'
        WHEN 3 THEN 'Preventive Care' ELSE 'Care Coordination' END AS measure_category,
    UNIFORM(0, 100, RANDOM()) + (UNIFORM(0, 99, RANDOM()) / 100.0) AS measure_value,
    80.0 AS target_value,
    CASE WHEN measure_value >= 80.0 THEN TRUE ELSE FALSE END AS met_target,
    CASE WHEN met_target = FALSE THEN TRUE ELSE FALSE END AS gaps_in_care,
    CASE WHEN met_target = TRUE THEN UNIFORM(5, 10, RANDOM()) ELSE 0 END AS quality_points,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 60000));

SELECT 'Quality Metrics: ' || COUNT(*) AS status FROM QUALITY_METRICS;

-- ============================================================================
-- Table 6: HEALTH_OUTCOMES (50,000 rows)
-- ============================================================================
INSERT INTO HEALTH_OUTCOMES
SELECT
    'OUT' || LPAD(SEQ4()::VARCHAR, 8, '0') AS outcome_id,
    'PT' || LPAD(UNIFORM(0, 39999, RANDOM())::VARCHAR, 8, '0') AS patient_id,
    DATEADD(day, -UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) AS outcome_date,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Clinical' WHEN 2 THEN 'Functional' WHEN 3 THEN 'Patient-Reported'
        WHEN 4 THEN 'Economic' ELSE 'Quality of Life' END AS outcome_type,
    'Outcome Measure' AS outcome_measure,
    UNIFORM(50, 150, RANDOM()) + (UNIFORM(0, 99, RANDOM()) / 100.0) AS baseline_value,
    baseline_value * UNIFORM(70, 130, RANDOM()) / 100.0 AS current_value,
    ((baseline_value - current_value) / baseline_value) * 100 AS improvement_percentage,
    CASE WHEN improvement_percentage < -10 THEN 'High Risk'
         WHEN improvement_percentage < 0 THEN 'Medium Risk'
         WHEN improvement_percentage < 10 THEN 'Low Risk' ELSE 'Very Low Risk' END AS risk_stratification,
    UNIFORM(0, 100, RANDOM()) AS predictive_risk_score,
    'Intervention' AS intervention_recommended,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

SELECT 'Health Outcomes: ' || COUNT(*) AS status FROM HEALTH_OUTCOMES;

-- ============================================================================
-- Table 7: CLINICAL_NOTES (30,000 rows)
-- ============================================================================
INSERT INTO CLINICAL_NOTES
SELECT
    'NOTE' || LPAD(SEQ4()::VARCHAR, 8, '0') AS note_id,
    'PT' || LPAD(UNIFORM(0, 39999, RANDOM())::VARCHAR, 8, '0') AS patient_id,
    'ENC' || LPAD(UNIFORM(0, 79999, RANDOM())::VARCHAR, 8, '0') AS encounter_id,
    'PRV' || LPAD(UNIFORM(0, 499, RANDOM())::VARCHAR, 5, '0') AS provider_id,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS note_date,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Progress Note' WHEN 2 THEN 'History and Physical'
        WHEN 3 THEN 'Discharge Summary' WHEN 4 THEN 'Consultation Note' ELSE 'Care Coordination Note' END AS note_type,
    'Patient presents for follow-up. Clinical assessment shows progress. Patient expressed concerns about medication costs and food insecurity affecting diet. Referred to social work for SDOH assessment and community resources.' AS note_text,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Chronic Disease Management' WHEN 2 THEN 'Acute Care'
        WHEN 3 THEN 'Preventive Care' WHEN 4 THEN 'Care Coordination' ELSE 'General Medicine' END AS clinical_category,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN TRUE ELSE FALSE END AS contains_sdoh_factors,
    CASE UNIFORM(1, 3, RANDOM()) WHEN 1 THEN 'Routine' WHEN 2 THEN 'Urgent' ELSE 'Routine' END AS urgency_level,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 30000));

SELECT 'Clinical Notes: ' || COUNT(*) AS status FROM CLINICAL_NOTES;

-- ============================================================================
-- Table 8: CARE_PLANS (25,000 rows)
-- ============================================================================
INSERT INTO CARE_PLANS
SELECT
    'CP' || LPAD(SEQ4()::VARCHAR, 8, '0') AS care_plan_id,
    'PT' || LPAD(UNIFORM(0, 39999, RANDOM())::VARCHAR, 8, '0') AS patient_id,
    'PRV' || LPAD(UNIFORM(0, 499, RANDOM())::VARCHAR, 5, '0') AS provider_id,
    DATEADD(day, -UNIFORM(30, 180, RANDOM()), CURRENT_DATE()) AS plan_start_date,
    DATEADD(day, UNIFORM(90, 365, RANDOM()), plan_start_date) AS plan_end_date,
    CASE UNIFORM(1, 8, RANDOM())
        WHEN 1 THEN 'Diabetes Management' WHEN 2 THEN 'Heart Failure Management'
        WHEN 3 THEN 'COPD Care Plan' WHEN 4 THEN 'Hypertension Control'
        WHEN 5 THEN 'Post-Discharge Transitional Care' WHEN 6 THEN 'Chronic Disease Management'
        WHEN 7 THEN 'Care Coordination Plan' ELSE 'Preventive Care Plan' END AS plan_type,
    'Comprehensive care plan with goals and interventions.' AS plan_document,
    'Care goals' AS goals,
    'Care interventions' AS interventions,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'SDOH interventions included' ELSE NULL END AS sdoh_interventions,
    CASE UNIFORM(1, 2, RANDOM()) WHEN 1 THEN 'Active' ELSE 'Completed' END AS plan_status,
    UNIFORM(50, 95, RANDOM()) + (UNIFORM(0, 99, RANDOM()) / 100.0) AS adherence_score,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 25000));

SELECT 'Care Plans: ' || COUNT(*) AS status FROM CARE_PLANS;

-- ============================================================================
-- Table 9: HEALTH_POLICIES (100 rows)
-- ============================================================================
INSERT INTO HEALTH_POLICIES
SELECT
    'POL' || LPAD(SEQ4()::VARCHAR, 3, '0') AS policy_id,
    'Policy Title ' || SEQ4() AS policy_title,
    'This clinical policy establishes evidence-based standards for patient care delivery.' AS policy_content,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'Clinical Practice' WHEN 2 THEN 'Quality Improvement'
        WHEN 3 THEN 'Care Coordination' ELSE 'Value-Based Care' END AS policy_category,
    'Clinical Guideline' AS policy_type,
    'Diabetes,Hypertension,Chronic Disease' AS applies_to_conditions,
    DATEADD(month, -UNIFORM(3, 24, RANDOM()), CURRENT_DATE()) AS effective_date,
    DATEADD(month, -UNIFORM(1, 6, RANDOM()), CURRENT_DATE()) AS review_date,
    'healthcare,clinical practice,quality' AS keywords,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 100));

SELECT 'Health Policies: ' || COUNT(*) AS status FROM HEALTH_POLICIES;

-- ============================================================================
-- Final Summary
-- ============================================================================
SELECT 'Data Generation Complete!' AS status;

SELECT 
    'PATIENTS' AS table_name, COUNT(*) AS row_count FROM PATIENTS
UNION ALL SELECT 'SOCIAL_DETERMINANTS', COUNT(*) FROM SOCIAL_DETERMINANTS
UNION ALL SELECT 'PROVIDERS', COUNT(*) FROM PROVIDERS
UNION ALL SELECT 'ENCOUNTERS', COUNT(*) FROM ENCOUNTERS
UNION ALL SELECT 'QUALITY_METRICS', COUNT(*) FROM QUALITY_METRICS
UNION ALL SELECT 'HEALTH_OUTCOMES', COUNT(*) FROM HEALTH_OUTCOMES
UNION ALL SELECT 'CLINICAL_NOTES', COUNT(*) FROM CLINICAL_NOTES
UNION ALL SELECT 'CARE_PLANS', COUNT(*) FROM CARE_PLANS
UNION ALL SELECT 'HEALTH_POLICIES', COUNT(*) FROM HEALTH_POLICIES;

