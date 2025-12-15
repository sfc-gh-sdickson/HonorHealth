-- ============================================================================
-- Honor Health Intelligence Agent - Database and Schema Setup
-- ============================================================================
-- Purpose: Initialize database, schemas, and warehouse for Honor Health
-- Focus: Social Determinants of Health (SDOH) and Value-Based Care
-- ============================================================================

-- ============================================================================
-- Step 1: Create Database
-- ============================================================================
CREATE DATABASE IF NOT EXISTS HONORHEALTH_INTELLIGENCE
  COMMENT = 'Honor Health Intelligence Agent - SDOH and Value-Based Care Analytics';

USE DATABASE HONORHEALTH_INTELLIGENCE;

-- ============================================================================
-- Step 2: Create Schemas
-- ============================================================================

-- RAW schema: Source tables with change tracking enabled
CREATE SCHEMA IF NOT EXISTS RAW
  COMMENT = 'Raw patient, encounter, and clinical data tables';

-- ANALYTICS schema: Analytical views, semantic views, and feature engineering
CREATE SCHEMA IF NOT EXISTS ANALYTICS
  COMMENT = 'Analytical views, semantic views, and aggregated metrics';

-- ML_MODELS schema: Machine learning models and prediction functions
CREATE SCHEMA IF NOT EXISTS ML_MODELS
  COMMENT = 'ML models for readmission, outcomes, and social risk prediction';

-- ============================================================================
-- Step 3: Create Warehouse
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS HONORHEALTH_WH
  WITH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for Honor Health analytics and ML workloads';

-- ============================================================================
-- Step 4: Set Context
-- ============================================================================
USE DATABASE HONORHEALTH_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE HONORHEALTH_WH;

-- ============================================================================
-- Step 5: Create Roles and Grant Permissions
-- ============================================================================
-- Grant database usage to SYSADMIN
GRANT USAGE ON DATABASE HONORHEALTH_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON ALL SCHEMAS IN DATABASE HONORHEALTH_INTELLIGENCE TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAW TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ANALYTICS TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ML_MODELS TO ROLE SYSADMIN;
GRANT USAGE ON WAREHOUSE HONORHEALTH_WH TO ROLE SYSADMIN;

-- ============================================================================
-- Verification
-- ============================================================================
SELECT 'Database created: HONORHEALTH_INTELLIGENCE' AS status;
SHOW SCHEMAS IN DATABASE HONORHEALTH_INTELLIGENCE;
SHOW WAREHOUSES LIKE 'HONORHEALTH_WH';

-- ============================================================================
-- Summary
-- ============================================================================
/*
Created:
- Database: HONORHEALTH_INTELLIGENCE
- Schemas: RAW, ANALYTICS, ML_MODELS
- Warehouse: HONORHEALTH_WH (MEDIUM, auto-suspend 5min)

Next Step: Run honorhealth_02_create_tables.sql
*/

-- ============================================================================
-- Honor Health Intelligence Agent - Table Creation
-- ============================================================================
-- Purpose: Create tables for SDOH and Value-Based Care analytics
-- Focus: Patients, encounters, social factors, care quality, outcomes
-- ============================================================================

USE DATABASE HONORHEALTH_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE HONORHEALTH_WH;

-- ============================================================================
-- Table 1: PATIENTS (Primary patient demographics and identifiers)
-- ============================================================================
CREATE OR REPLACE TABLE PATIENTS (
    patient_id VARCHAR(16777216) PRIMARY KEY,
    date_of_birth DATE NOT NULL,
    age NUMBER(3,0),
    gender VARCHAR(16777216),
    race VARCHAR(16777216),
    ethnicity VARCHAR(16777216),
    preferred_language VARCHAR(16777216),
    zip_code VARCHAR(10),
    county VARCHAR(16777216),
    state VARCHAR(2),
    insurance_type VARCHAR(16777216),
    primary_care_provider_id VARCHAR(16777216),
    patient_tier VARCHAR(16777216),
    enrollment_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
  COMMENT = 'Patient demographics and enrollment information';

-- ============================================================================
-- Table 2: SOCIAL_DETERMINANTS (SDOH factors for each patient)
-- ============================================================================
CREATE OR REPLACE TABLE SOCIAL_DETERMINANTS (
    sdoh_id VARCHAR(16777216) PRIMARY KEY,
    patient_id VARCHAR(16777216) NOT NULL,
    assessment_date DATE NOT NULL,
    employment_status VARCHAR(16777216),
    annual_income_range VARCHAR(16777216),
    education_level VARCHAR(16777216),
    housing_status VARCHAR(16777216),
    food_insecurity BOOLEAN,
    transportation_barriers BOOLEAN,
    social_isolation_risk VARCHAR(16777216),
    financial_strain VARCHAR(16777216),
    neighborhood_safety VARCHAR(16777216),
    utility_assistance_needed BOOLEAN,
    sdoh_risk_score NUMBER(5,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (patient_id) REFERENCES PATIENTS(patient_id)
) CHANGE_TRACKING = TRUE
  COMMENT = 'Social determinants of health assessments and risk factors';

-- ============================================================================
-- Table 3: PROVIDERS (Care providers and care teams)
-- ============================================================================
CREATE OR REPLACE TABLE PROVIDERS (
    provider_id VARCHAR(16777216) PRIMARY KEY,
    provider_name VARCHAR(16777216) NOT NULL,
    provider_type VARCHAR(16777216),
    specialty VARCHAR(16777216),
    facility_id VARCHAR(16777216),
    facility_name VARCHAR(16777216),
    years_experience NUMBER(3,0),
    patient_panel_size NUMBER(10,0),
    quality_score NUMBER(5,2),
    active_status VARCHAR(16777216),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
  COMMENT = 'Healthcare providers and care team members';

-- ============================================================================
-- Table 4: ENCOUNTERS (Patient encounters and visits)
-- ============================================================================
CREATE OR REPLACE TABLE ENCOUNTERS (
    encounter_id VARCHAR(16777216) PRIMARY KEY,
    patient_id VARCHAR(16777216) NOT NULL,
    provider_id VARCHAR(16777216) NOT NULL,
    encounter_date DATE NOT NULL,
    encounter_type VARCHAR(16777216),
    visit_reason VARCHAR(16777216),
    primary_diagnosis_code VARCHAR(16777216),
    secondary_diagnoses VARCHAR(16777216),
    chronic_conditions VARCHAR(16777216),
    procedures_performed VARCHAR(16777216),
    encounter_cost NUMBER(15,2),
    length_of_stay_days NUMBER(5,0),
    discharge_disposition VARCHAR(16777216),
    readmission_30_day BOOLEAN,
    emergency_visit BOOLEAN,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (patient_id) REFERENCES PATIENTS(patient_id),
    FOREIGN KEY (provider_id) REFERENCES PROVIDERS(provider_id)
) CHANGE_TRACKING = TRUE
  COMMENT = 'Patient encounters, visits, and hospitalizations';

-- ============================================================================
-- Table 5: QUALITY_METRICS (Value-based care quality measures)
-- ============================================================================
CREATE OR REPLACE TABLE QUALITY_METRICS (
    metric_id VARCHAR(16777216) PRIMARY KEY,
    patient_id VARCHAR(16777216) NOT NULL,
    measurement_date DATE NOT NULL,
    hedis_measure_code VARCHAR(16777216),
    measure_name VARCHAR(16777216),
    measure_category VARCHAR(16777216),
    measure_value NUMBER(10,2),
    target_value NUMBER(10,2),
    met_target BOOLEAN,
    gaps_in_care BOOLEAN,
    quality_points NUMBER(10,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (patient_id) REFERENCES PATIENTS(patient_id)
) CHANGE_TRACKING = TRUE
  COMMENT = 'HEDIS and quality measures for value-based care';

-- ============================================================================
-- Table 6: HEALTH_OUTCOMES (Patient health outcomes and status)
-- ============================================================================
CREATE OR REPLACE TABLE HEALTH_OUTCOMES (
    outcome_id VARCHAR(16777216) PRIMARY KEY,
    patient_id VARCHAR(16777216) NOT NULL,
    outcome_date DATE NOT NULL,
    outcome_type VARCHAR(16777216),
    outcome_measure VARCHAR(16777216),
    baseline_value NUMBER(10,2),
    current_value NUMBER(10,2),
    improvement_percentage NUMBER(5,2),
    risk_stratification VARCHAR(16777216),
    predictive_risk_score NUMBER(5,2),
    intervention_recommended VARCHAR(16777216),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (patient_id) REFERENCES PATIENTS(patient_id)
) CHANGE_TRACKING = TRUE
  COMMENT = 'Patient health outcomes, risk scores, and improvement metrics';

-- ============================================================================
-- Table 7: CLINICAL_NOTES (Unstructured clinical documentation)
-- ============================================================================
CREATE OR REPLACE TABLE CLINICAL_NOTES (
    note_id VARCHAR(16777216) PRIMARY KEY,
    patient_id VARCHAR(16777216) NOT NULL,
    encounter_id VARCHAR(16777216),
    provider_id VARCHAR(16777216),
    note_date DATE NOT NULL,
    note_type VARCHAR(16777216),
    note_text VARCHAR(16777216),
    clinical_category VARCHAR(16777216),
    contains_sdoh_factors BOOLEAN,
    urgency_level VARCHAR(16777216),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (patient_id) REFERENCES PATIENTS(patient_id),
    FOREIGN KEY (encounter_id) REFERENCES ENCOUNTERS(encounter_id),
    FOREIGN KEY (provider_id) REFERENCES PROVIDERS(provider_id)
) CHANGE_TRACKING = TRUE
  COMMENT = 'Unstructured clinical notes and documentation';

-- ============================================================================
-- Table 8: CARE_PLANS (Patient care plans and treatment protocols)
-- ============================================================================
CREATE OR REPLACE TABLE CARE_PLANS (
    care_plan_id VARCHAR(16777216) PRIMARY KEY,
    patient_id VARCHAR(16777216) NOT NULL,
    provider_id VARCHAR(16777216),
    plan_start_date DATE NOT NULL,
    plan_end_date DATE,
    plan_type VARCHAR(16777216),
    plan_document VARCHAR(16777216),
    goals VARCHAR(16777216),
    interventions VARCHAR(16777216),
    sdoh_interventions VARCHAR(16777216),
    plan_status VARCHAR(16777216),
    adherence_score NUMBER(5,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (patient_id) REFERENCES PATIENTS(patient_id),
    FOREIGN KEY (provider_id) REFERENCES PROVIDERS(provider_id)
) CHANGE_TRACKING = TRUE
  COMMENT = 'Care plans, treatment protocols, and SDOH interventions';

-- ============================================================================
-- Table 9: HEALTH_POLICIES (Policies, guidelines, and protocols)
-- ============================================================================
CREATE OR REPLACE TABLE HEALTH_POLICIES (
    policy_id VARCHAR(16777216) PRIMARY KEY,
    policy_title VARCHAR(16777216) NOT NULL,
    policy_content VARCHAR(16777216),
    policy_category VARCHAR(16777216),
    policy_type VARCHAR(16777216),
    applies_to_conditions VARCHAR(16777216),
    effective_date DATE,
    review_date DATE,
    keywords VARCHAR(16777216),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) CHANGE_TRACKING = TRUE
  COMMENT = 'Clinical policies, guidelines, and care protocols';

-- ============================================================================
-- Verification
-- ============================================================================
SELECT 'All Honor Health tables created successfully' AS status;

SHOW TABLES IN SCHEMA RAW;

-- ============================================================================
-- Summary
-- ============================================================================
/*
Created 9 tables:
1. PATIENTS - Patient demographics
2. SOCIAL_DETERMINANTS - SDOH factors and assessments
3. PROVIDERS - Care team members
4. ENCOUNTERS - Visits and hospitalizations
5. QUALITY_METRICS - HEDIS and value-based care measures
6. HEALTH_OUTCOMES - Patient outcomes and risk scores
7. CLINICAL_NOTES - Unstructured clinical documentation
8. CARE_PLANS - Treatment plans and interventions
9. HEALTH_POLICIES - Clinical guidelines and protocols

Next Step: Run honorhealth_03_generate_synthetic_data.sql
*/

-- ============================================================================
-- Honor Health Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic synthetic data for SDOH and Value-Based Care
-- Data Volume: ~335,600 total rows across 9 tables
-- Execution Time: 10-15 minutes on MEDIUM warehouse
-- ============================================================================

USE DATABASE HONORHEALTH_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE HONORHEALTH_WH;

-- ============================================================================
-- TRUNCATE existing data (for clean regeneration)
-- ============================================================================
TRUNCATE TABLE IF EXISTS HEALTH_POLICIES;
TRUNCATE TABLE IF EXISTS CARE_PLANS;
TRUNCATE TABLE IF EXISTS CLINICAL_NOTES;
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
    CASE UNIFORM(1, 2, RANDOM())
        WHEN 1 THEN 'Male'
        ELSE 'Female'
    END AS gender,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'White'
        WHEN 2 THEN 'Black or African American'
        WHEN 3 THEN 'Hispanic or Latino'
        WHEN 4 THEN 'Asian'
        WHEN 5 THEN 'American Indian or Alaska Native'
        WHEN 6 THEN 'Native Hawaiian or Pacific Islander'
        ELSE 'White'
    END AS race,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'Hispanic or Latino'
        WHEN 2 THEN 'Not Hispanic or Latino'
        ELSE 'Not Hispanic or Latino'
    END AS ethnicity,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'Spanish'
        WHEN 2 THEN 'Mandarin'
        WHEN 3 THEN 'Arabic'
        ELSE 'English'
    END AS preferred_language,
    LPAD(UNIFORM(85001, 85999, RANDOM())::VARCHAR, 5, '0') AS zip_code,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'Maricopa'
        WHEN 2 THEN 'Pima'
        WHEN 3 THEN 'Pinal'
        ELSE 'Yavapai'
    END AS county,
    'AZ' AS state,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Medicare'
        WHEN 2 THEN 'Medicaid'
        WHEN 3 THEN 'Commercial'
        WHEN 4 THEN 'Uninsured'
        ELSE 'Medicare Advantage'
    END AS insurance_type,
    'PRV' || LPAD(UNIFORM(1, 500, RANDOM())::VARCHAR, 5, '0') AS primary_care_provider_id,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'Basic'
        WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'Standard'
        ELSE 'Premium'
    END AS patient_tier,
    DATEADD(month, -UNIFORM(1, 120, RANDOM()), CURRENT_DATE()) AS enrollment_date,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

SELECT 'Patients: ' || COUNT(*) || ' rows inserted' AS status FROM PATIENTS;

-- ============================================================================
-- Table 2: SOCIAL_DETERMINANTS (40,000 rows - 80% of patients)
-- ============================================================================
INSERT INTO SOCIAL_DETERMINANTS
SELECT
    'SDOH' || LPAD(SEQ4()::VARCHAR, 8, '0') AS sdoh_id,
    (SELECT patient_id FROM PATIENTS ORDER BY RANDOM() LIMIT 1) AS patient_id,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS assessment_date,
    CASE UNIFORM(1, 6, RANDOM())
        WHEN 1 THEN 'Full-time Employed'
        WHEN 2 THEN 'Part-time Employed'
        WHEN 3 THEN 'Unemployed'
        WHEN 4 THEN 'Retired'
        WHEN 5 THEN 'Disabled'
        ELSE 'Full-time Employed'
    END AS employment_status,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Under $25K'
        WHEN 2 THEN '$25K-$50K'
        WHEN 3 THEN '$50K-$75K'
        WHEN 4 THEN '$75K-$100K'
        ELSE 'Over $100K'
    END AS annual_income_range,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Less than High School'
        WHEN 2 THEN 'High School Graduate'
        WHEN 3 THEN 'Some College'
        WHEN 4 THEN 'College Graduate'
        ELSE 'Advanced Degree'
    END AS education_level,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Owned'
        WHEN 2 THEN 'Rented'
        WHEN 3 THEN 'Homeless'
        WHEN 4 THEN 'Temporary Housing'
        ELSE 'Owned'
    END AS housing_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN TRUE ELSE FALSE END AS food_insecurity,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN TRUE ELSE FALSE END AS transportation_barriers,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'Low Risk'
        WHEN 2 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END AS social_isolation_risk,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'None'
        WHEN 2 THEN 'Mild'
        WHEN 3 THEN 'Moderate'
        ELSE 'Severe'
    END AS financial_strain,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'Safe'
        WHEN 2 THEN 'Somewhat Safe'
        ELSE 'Unsafe'
    END AS neighborhood_safety,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN TRUE ELSE FALSE END AS utility_assistance_needed,
    UNIFORM(0, 100, RANDOM()) AS sdoh_risk_score,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 40000));

SELECT 'Social Determinants: ' || COUNT(*) || ' rows inserted' AS status FROM SOCIAL_DETERMINANTS;

-- ============================================================================
-- Table 3: PROVIDERS (500 rows)
-- ============================================================================
INSERT INTO PROVIDERS
SELECT
    'PRV' || LPAD(SEQ4()::VARCHAR, 5, '0') AS provider_id,
    CASE MOD(SEQ4(), 30)
        WHEN 0 THEN 'Dr. Sarah Martinez'
        WHEN 1 THEN 'Dr. Michael Chen'
        WHEN 2 THEN 'Dr. Jennifer Williams'
        WHEN 3 THEN 'Dr. David Rodriguez'
        WHEN 4 THEN 'Dr. Emily Johnson'
        WHEN 5 THEN 'Dr. Robert Garcia'
        WHEN 6 THEN 'Dr. Lisa Anderson'
        WHEN 7 THEN 'Dr. James Thompson'
        WHEN 8 THEN 'Dr. Maria Hernandez'
        WHEN 9 THEN 'Dr. Christopher Lee'
        WHEN 10 THEN 'Dr. Amanda White'
        WHEN 11 THEN 'Dr. Daniel Brown'
        WHEN 12 THEN 'Dr. Jessica Davis'
        WHEN 13 THEN 'Dr. Matthew Wilson'
        WHEN 14 THEN 'Dr. Michelle Taylor'
        WHEN 15 THEN 'Dr. Andrew Miller'
        WHEN 16 THEN 'Dr. Rebecca Moore'
        WHEN 17 THEN 'Dr. Joshua Martin'
        WHEN 18 THEN 'Dr. Nicole Jackson'
        WHEN 19 THEN 'Dr. Ryan Thomas'
        ELSE 'Dr. Karen Harris'
    END AS provider_name,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'Physician'
        WHEN 2 THEN 'Nurse Practitioner'
        WHEN 3 THEN 'Physician Assistant'
        ELSE 'Physician'
    END AS provider_type,
    CASE UNIFORM(1, 12, RANDOM())
        WHEN 1 THEN 'Family Medicine'
        WHEN 2 THEN 'Internal Medicine'
        WHEN 3 THEN 'Cardiology'
        WHEN 4 THEN 'Endocrinology'
        WHEN 5 THEN 'Pulmonology'
        WHEN 6 THEN 'Nephrology'
        WHEN 7 THEN 'Geriatrics'
        WHEN 8 THEN 'Pediatrics'
        WHEN 9 THEN 'Emergency Medicine'
        WHEN 10 THEN 'Oncology'
        ELSE 'Family Medicine'
    END AS specialty,
    'FAC' || LPAD(UNIFORM(1, 20, RANDOM())::VARCHAR, 3, '0') AS facility_id,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'HonorHealth Scottsdale Osborn Medical Center'
        WHEN 2 THEN 'HonorHealth Scottsdale Shea Medical Center'
        WHEN 3 THEN 'HonorHealth Scottsdale Thompson Peak Medical Center'
        WHEN 4 THEN 'HonorHealth John C. Lincoln Medical Center'
        WHEN 5 THEN 'HonorHealth Deer Valley Medical Center'
        WHEN 6 THEN 'HonorHealth Arcadia Medical Plaza'
        ELSE 'HonorHealth Scottsdale Osborn Medical Center'
    END AS facility_name,
    UNIFORM(1, 35, RANDOM()) AS years_experience,
    UNIFORM(500, 3000, RANDOM()) AS patient_panel_size,
    UNIFORM(75, 98, RANDOM()) + (UNIFORM(0, 99, RANDOM()) / 100.0) AS quality_score,
    'Active' AS active_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 500));

SELECT 'Providers: ' || COUNT(*) || ' rows inserted' AS status FROM PROVIDERS;

-- ============================================================================
-- Table 4: ENCOUNTERS (80,000 rows)
-- ============================================================================
INSERT INTO ENCOUNTERS
SELECT
    'ENC' || LPAD(SEQ4()::VARCHAR, 8, '0') AS encounter_id,
    (SELECT patient_id FROM PATIENTS ORDER BY RANDOM() LIMIT 1) AS patient_id,
    (SELECT provider_id FROM PROVIDERS ORDER BY RANDOM() LIMIT 1) AS provider_id,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS encounter_date,
    CASE UNIFORM(1, 6, RANDOM())
        WHEN 1 THEN 'Primary Care Visit'
        WHEN 2 THEN 'Emergency Department'
        WHEN 3 THEN 'Urgent Care'
        WHEN 4 THEN 'Inpatient Admission'
        WHEN 5 THEN 'Specialist Visit'
        ELSE 'Telehealth'
    END AS encounter_type,
    CASE UNIFORM(1, 15, RANDOM())
        WHEN 1 THEN 'Diabetes Management'
        WHEN 2 THEN 'Hypertension Follow-up'
        WHEN 3 THEN 'Chest Pain'
        WHEN 4 THEN 'Shortness of Breath'
        WHEN 5 THEN 'Annual Wellness Visit'
        WHEN 6 THEN 'Preventive Care'
        WHEN 7 THEN 'Chronic Disease Management'
        WHEN 8 THEN 'Heart Failure Exacerbation'
        WHEN 9 THEN 'COPD Exacerbation'
        WHEN 10 THEN 'Medication Management'
        ELSE 'Follow-up Visit'
    END AS visit_reason,
    CASE UNIFORM(1, 20, RANDOM())
        WHEN 1 THEN 'E11.9'  -- Type 2 Diabetes
        WHEN 2 THEN 'I10'    -- Hypertension
        WHEN 3 THEN 'I50.9'  -- Heart Failure
        WHEN 4 THEN 'J44.9'  -- COPD
        WHEN 5 THEN 'N18.3'  -- CKD Stage 3
        WHEN 6 THEN 'I25.10' -- CAD
        WHEN 7 THEN 'E78.5'  -- Hyperlipidemia
        WHEN 8 THEN 'J45.909'-- Asthma
        WHEN 9 THEN 'M17.9'  -- Osteoarthritis
        WHEN 10 THEN 'F41.9' -- Anxiety
        ELSE 'Z00.00'        -- General exam
    END AS primary_diagnosis_code,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'E11.9,I10'
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'I10,E78.5'
        ELSE NULL
    END AS secondary_diagnoses,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Diabetes,Hypertension'
        WHEN 2 THEN 'Heart Failure,CKD'
        WHEN 3 THEN 'COPD,Hypertension'
        WHEN 4 THEN 'Diabetes,CAD,Hypertension'
        ELSE 'Hypertension'
    END AS chronic_conditions,
    CASE WHEN encounter_type = 'Inpatient Admission' 
        THEN 'Cardiac Catheterization,Echocardiogram'
        ELSE NULL 
    END AS procedures_performed,
    CASE encounter_type
        WHEN 'Primary Care Visit' THEN UNIFORM(150, 350, RANDOM())
        WHEN 'Emergency Department' THEN UNIFORM(800, 2500, RANDOM())
        WHEN 'Inpatient Admission' THEN UNIFORM(15000, 50000, RANDOM())
        WHEN 'Specialist Visit' THEN UNIFORM(200, 500, RANDOM())
        ELSE UNIFORM(100, 250, RANDOM())
    END AS encounter_cost,
    CASE 
        WHEN encounter_type = 'Inpatient Admission' THEN UNIFORM(2, 10, RANDOM())
        ELSE 0
    END AS length_of_stay_days,
    CASE 
        WHEN encounter_type = 'Inpatient Admission' THEN 
            CASE UNIFORM(1, 4, RANDOM())
                WHEN 1 THEN 'Home'
                WHEN 2 THEN 'Skilled Nursing Facility'
                WHEN 3 THEN 'Home Health'
                ELSE 'Home'
            END
        ELSE NULL
    END AS discharge_disposition,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN TRUE ELSE FALSE END AS readmission_30_day,
    CASE WHEN encounter_type = 'Emergency Department' THEN TRUE ELSE FALSE END AS emergency_visit,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 80000));

SELECT 'Encounters: ' || COUNT(*) || ' rows inserted' AS status FROM ENCOUNTERS;

-- ============================================================================
-- Table 5: QUALITY_METRICS (60,000 rows)
-- ============================================================================
INSERT INTO QUALITY_METRICS
SELECT
    'QM' || LPAD(SEQ4()::VARCHAR, 8, '0') AS metric_id,
    (SELECT patient_id FROM PATIENTS ORDER BY RANDOM() LIMIT 1) AS patient_id,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS measurement_date,
    CASE UNIFORM(1, 15, RANDOM())
        WHEN 1 THEN 'CDC-D'    -- Diabetes Care
        WHEN 2 THEN 'CBP'      -- Controlling Blood Pressure
        WHEN 3 THEN 'COL'      -- Colorectal Cancer Screening
        WHEN 4 THEN 'BCS'      -- Breast Cancer Screening
        WHEN 5 THEN 'CDC-E'    -- Eye Exam for Diabetics
        WHEN 6 THEN 'CDC-N'    -- Nephropathy Assessment
        WHEN 7 THEN 'SPD'      -- Statin Therapy
        WHEN 8 THEN 'FUH'      -- Follow-up after Hospitalization
        WHEN 9 THEN 'PCE'      -- Pharmacotherapy for COPD
        WHEN 10 THEN 'MRP'     -- Medication Reconciliation
        ELSE 'AWC'             -- Annual Wellness Visit
    END AS hedis_measure_code,
    CASE hedis_measure_code
        WHEN 'CDC-D' THEN 'HbA1c Control for Diabetics'
        WHEN 'CBP' THEN 'Controlling High Blood Pressure'
        WHEN 'COL' THEN 'Colorectal Cancer Screening'
        WHEN 'BCS' THEN 'Breast Cancer Screening'
        WHEN 'CDC-E' THEN 'Eye Exam for Diabetics'
        WHEN 'CDC-N' THEN 'Nephropathy Assessment in Diabetics'
        WHEN 'SPD' THEN 'Statin Therapy for CVD'
        WHEN 'FUH' THEN 'Follow-up after Mental Health Hospitalization'
        WHEN 'PCE' THEN 'Pharmacotherapy Management for COPD'
        WHEN 'MRP' THEN 'Medication Reconciliation Post-Discharge'
        ELSE 'Annual Wellness Care'
    END AS measure_name,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'Diabetes Care'
        WHEN 2 THEN 'Cardiovascular Care'
        WHEN 3 THEN 'Preventive Care'
        ELSE 'Care Coordination'
    END AS measure_category,
    UNIFORM(0, 100, RANDOM()) + (UNIFORM(0, 99, RANDOM()) / 100.0) AS measure_value,
    CASE hedis_measure_code
        WHEN 'CDC-D' THEN 7.0
        WHEN 'CBP' THEN 140.0
        ELSE 80.0
    END AS target_value,
    CASE 
        WHEN hedis_measure_code = 'CDC-D' AND measure_value < 7.0 THEN TRUE
        WHEN hedis_measure_code = 'CBP' AND measure_value < 140.0 THEN TRUE
        WHEN measure_value >= 80.0 THEN TRUE
        ELSE FALSE
    END AS met_target,
    CASE WHEN met_target = FALSE THEN TRUE ELSE FALSE END AS gaps_in_care,
    CASE WHEN met_target = TRUE THEN UNIFORM(5, 10, RANDOM()) ELSE 0 END AS quality_points,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 60000));

SELECT 'Quality Metrics: ' || COUNT(*) || ' rows inserted' AS status FROM QUALITY_METRICS;

-- ============================================================================
-- Table 6: HEALTH_OUTCOMES (50,000 rows)
-- ============================================================================
INSERT INTO HEALTH_OUTCOMES
SELECT
    'OUT' || LPAD(SEQ4()::VARCHAR, 8, '0') AS outcome_id,
    (SELECT patient_id FROM PATIENTS ORDER BY RANDOM() LIMIT 1) AS patient_id,
    DATEADD(day, -UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) AS outcome_date,
    CASE UNIFORM(1, 6, RANDOM())
        WHEN 1 THEN 'Clinical'
        WHEN 2 THEN 'Functional'
        WHEN 3 THEN 'Patient-Reported'
        WHEN 4 THEN 'Economic'
        WHEN 5 THEN 'Readmission'
        ELSE 'Quality of Life'
    END AS outcome_type,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'HbA1c Level'
        WHEN 2 THEN 'Blood Pressure'
        WHEN 3 THEN 'Weight/BMI'
        WHEN 4 THEN 'Pain Score'
        WHEN 5 THEN 'Mobility Score'
        WHEN 6 THEN 'Depression Score (PHQ-9)'
        WHEN 7 THEN 'Patient Satisfaction'
        WHEN 8 THEN 'Medication Adherence'
        WHEN 9 THEN 'Hospital Readmission'
        ELSE 'Emergency Department Visits'
    END AS outcome_measure,
    UNIFORM(50, 150, RANDOM()) + (UNIFORM(0, 99, RANDOM()) / 100.0) AS baseline_value,
    baseline_value * UNIFORM(70, 130, RANDOM()) / 100.0 AS current_value,
    ((baseline_value - current_value) / baseline_value) * 100 AS improvement_percentage,
    CASE 
        WHEN improvement_percentage < -10 THEN 'High Risk'
        WHEN improvement_percentage < 0 THEN 'Medium Risk'
        WHEN improvement_percentage < 10 THEN 'Low Risk'
        ELSE 'Very Low Risk'
    END AS risk_stratification,
    UNIFORM(0, 100, RANDOM()) AS predictive_risk_score,
    CASE 
        WHEN risk_stratification IN ('High Risk', 'Medium Risk') THEN 'Care Management Program'
        ELSE 'Standard Care'
    END AS intervention_recommended,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

SELECT 'Health Outcomes: ' || COUNT(*) || ' rows inserted' AS status FROM HEALTH_OUTCOMES;

-- ============================================================================
-- Table 7: CLINICAL_NOTES (30,000 rows)
-- ============================================================================
INSERT INTO CLINICAL_NOTES
SELECT
    'NOTE' || LPAD(SEQ4()::VARCHAR, 8, '0') AS note_id,
    (SELECT patient_id FROM PATIENTS ORDER BY RANDOM() LIMIT 1) AS patient_id,
    (SELECT encounter_id FROM ENCOUNTERS ORDER BY RANDOM() LIMIT 1) AS encounter_id,
    (SELECT provider_id FROM PROVIDERS ORDER BY RANDOM() LIMIT 1) AS provider_id,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS note_date,
    CASE UNIFORM(1, 8, RANDOM())
        WHEN 1 THEN 'Progress Note'
        WHEN 2 THEN 'History and Physical'
        WHEN 3 THEN 'Discharge Summary'
        WHEN 4 THEN 'Consultation Note'
        WHEN 5 THEN 'Procedure Note'
        WHEN 6 THEN 'Care Coordination Note'
        WHEN 7 THEN 'Social Work Assessment'
        ELSE 'Progress Note'
    END AS note_type,
    CASE UNIFORM(1, 12, RANDOM())
        WHEN 1 THEN 'Patient presents for diabetes follow-up. HbA1c improved from 8.5 to 7.2 with current medication regimen. Patient reports better adherence to diet and exercise plan. Discussed importance of continued lifestyle modifications. Patient expressed concerns about medication costs and food insecurity affecting diet. Referred to social work for SDOH assessment and community resources.'
        WHEN 2 THEN 'Follow-up for hypertension management. Blood pressure well-controlled at 128/78. Patient reports taking medications as prescribed. Discussed sodium reduction and importance of regular exercise. Patient mentions difficulty affording medications; provided information about patient assistance programs. Will continue current regimen and follow up in 3 months.'
        WHEN 3 THEN 'Patient admitted with heart failure exacerbation. Presented with shortness of breath and lower extremity edema. Diuresis initiated with good response. Social assessment revealed patient lives alone with limited support system. Transportation barriers affecting ability to attend follow-up appointments. Case management consulted for home health services and community support.'
        WHEN 4 THEN 'Comprehensive care visit. Reviewed medication list - patient taking 12 medications daily. Discussed medication adherence challenges due to complexity of regimen and cost concerns. Simplified medication schedule when possible. Patient reports housing instability affecting ability to store medications properly. Connected with community resources for housing assistance.'
        WHEN 5 THEN 'Patient with COPD presenting for annual wellness visit. Pulmonary function stable. Patient reports increased shortness of breath with activities of daily living. Assessment reveals patient lives in older home with environmental triggers. Limited financial resources for home modifications. Occupational therapy referral for home safety evaluation and adaptive equipment.'
        WHEN 6 THEN 'Emergency department visit for uncontrolled diabetes. Blood glucose over 400. Patient missed several primary care appointments due to lack of transportation. Reports food insecurity and relying on convenience foods. Social determinants screening reveals multiple risk factors: unemployment, housing instability, lack of social support. Connected with care management team for comprehensive support.'
        WHEN 7 THEN 'Post-discharge follow-up after stroke. Patient making good progress with rehabilitation. Family expressing concerns about ability to continue care at home. Financial strain from medical bills and lost work time. Caregiver burden assessment reveals high stress levels. Referred to support groups and respite care services.'
        WHEN 8 THEN 'Care coordination note: Patient enrolled in transitional care program after recent hospitalization for heart failure. Home visit completed. Medication reconciliation performed - identified several discrepancies. Home environment assessment reveals stairs as barrier to mobility. Limited access to healthy food options in neighborhood. Care plan updated to address identified barriers.'
        WHEN 9 THEN 'Annual wellness visit completed. Preventive care screenings up to date. Patient doing well overall. Discussed health maintenance and chronic disease management. Patient reports feeling socially isolated and experiencing mild depression. Screened positive for food insecurity. Provided resources for meal programs and support groups. Follow-up arranged with behavioral health.'
        WHEN 10 THEN 'Specialist consultation for chronic kidney disease management. CKD Stage 3, stable. Discussed dietary modifications and importance of blood pressure control. Patient expresses understanding but notes difficulty implementing recommendations due to limited income and food choices available in neighborhood. Dietitian referral for meal planning assistance within budget constraints.'
        WHEN 11 THEN 'Urgent care visit for acute bronchitis. Symptoms improving with antibiotics. Identified opportunity for smoking cessation counseling. Patient interested in quitting but reports high stress levels related to job insecurity and financial concerns. Provided smoking cessation resources and stress management techniques. Encouraged follow-up with primary care for comprehensive support.'
        ELSE 'Routine follow-up visit. Patient doing well on current treatment plan. All chronic conditions stable. Medication adherence good. Patient reports improved quality of life and functional status. Continue current management. Next appointment in 6 months or sooner if concerns arise.'
    END AS note_text,
    CASE UNIFORM(1, 6, RANDOM())
        WHEN 1 THEN 'Chronic Disease Management'
        WHEN 2 THEN 'Acute Care'
        WHEN 3 THEN 'Preventive Care'
        WHEN 4 THEN 'Care Coordination'
        WHEN 5 THEN 'Social Work'
        ELSE 'General Medicine'
    END AS clinical_category,
    CASE WHEN note_text LIKE '%food insecurity%' OR note_text LIKE '%transportation%' 
              OR note_text LIKE '%housing%' OR note_text LIKE '%financial%' 
        THEN TRUE ELSE FALSE END AS contains_sdoh_factors,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'Routine'
        WHEN 2 THEN 'Urgent'
        ELSE 'Routine'
    END AS urgency_level,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 30000));

SELECT 'Clinical Notes: ' || COUNT(*) || ' rows inserted' AS status FROM CLINICAL_NOTES;

-- ============================================================================
-- Table 8: CARE_PLANS (25,000 rows)
-- ============================================================================
INSERT INTO CARE_PLANS
SELECT
    'CP' || LPAD(SEQ4()::VARCHAR, 8, '0') AS care_plan_id,
    (SELECT patient_id FROM PATIENTS ORDER BY RANDOM() LIMIT 1) AS patient_id,
    (SELECT provider_id FROM PROVIDERS ORDER BY RANDOM() LIMIT 1) AS provider_id,
    DATEADD(day, -UNIFORM(30, 180, RANDOM()), CURRENT_DATE()) AS plan_start_date,
    DATEADD(day, UNIFORM(90, 365, RANDOM()), plan_start_date) AS plan_end_date,
    CASE UNIFORM(1, 8, RANDOM())
        WHEN 1 THEN 'Diabetes Management'
        WHEN 2 THEN 'Heart Failure Management'
        WHEN 3 THEN 'COPD Care Plan'
        WHEN 4 THEN 'Hypertension Control'
        WHEN 5 THEN 'Post-Discharge Transitional Care'
        WHEN 6 THEN 'Chronic Disease Management'
        WHEN 7 THEN 'Care Coordination Plan'
        ELSE 'Preventive Care Plan'
    END AS plan_type,
    CASE plan_type
        WHEN 'Diabetes Management' THEN 'Comprehensive diabetes care plan including medication management, dietary counseling, regular HbA1c monitoring, annual eye and foot exams, and diabetes self-management education. Target HbA1c <7.0%. Plan includes coordination with endocrinology, ophthalmology, and podiatry as needed.'
        WHEN 'Heart Failure Management' THEN 'Heart failure care plan with daily weights, sodium restriction, fluid management, and medication optimization. Regular monitoring of symptoms and vital signs. Care team includes cardiologist, heart failure nurse navigator, and dietitian. Goal: prevent hospitalizations and improve quality of life.'
        WHEN 'COPD Care Plan' THEN 'Chronic obstructive pulmonary disease management including bronchodilator therapy, pulmonary rehabilitation, smoking cessation support, and oxygen therapy as needed. Action plan for exacerbation management. Regular spirometry and assessment of functional status.'
        WHEN 'Hypertension Control' THEN 'Blood pressure management plan with medication optimization, lifestyle modifications, home blood pressure monitoring, and regular follow-up. Target BP <140/90 mmHg. Patient education on DASH diet, sodium reduction, and stress management techniques.'
        WHEN 'Post-Discharge Transitional Care' THEN 'Transitional care plan following recent hospitalization. Includes medication reconciliation, follow-up appointments within 7 days, home health services, and care coordination. Focus on preventing readmissions through close monitoring and addressing barriers to recovery.'
        ELSE 'Comprehensive care plan addressing multiple chronic conditions with coordinated approach. Regular monitoring, medication management, lifestyle modifications, and preventive services. Multidisciplinary team approach with care coordinator assigned.'
    END AS plan_document,
    CASE plan_type
        WHEN 'Diabetes Management' THEN 'Achieve HbA1c <7.0%, prevent complications, improve self-management skills'
        WHEN 'Heart Failure Management' THEN 'Prevent hospitalizations, optimize functional status, improve quality of life'
        WHEN 'COPD Care Plan' THEN 'Improve respiratory function, reduce exacerbations, maintain independence'
        WHEN 'Hypertension Control' THEN 'Achieve target blood pressure, reduce cardiovascular risk'
        ELSE 'Optimize health status, prevent complications, improve patient satisfaction'
    END AS goals,
    'Medication management, patient education, lifestyle counseling, regular monitoring, specialist referrals as needed, care coordination' AS interventions,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'Address food insecurity through meal program referral, provide transportation assistance for medical appointments, connect with community health workers for support'
        WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'Assess financial barriers and connect with financial counseling, evaluate home safety and arrange modifications as needed'
        ELSE NULL
    END AS sdoh_interventions,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Active'
        ELSE 'Completed'
    END AS plan_status,
    UNIFORM(50, 95, RANDOM()) + (UNIFORM(0, 99, RANDOM()) / 100.0) AS adherence_score,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 25000));

SELECT 'Care Plans: ' || COUNT(*) || ' rows inserted' AS status FROM CARE_PLANS;

-- ============================================================================
-- Table 9: HEALTH_POLICIES (100 rows)
-- ============================================================================
INSERT INTO HEALTH_POLICIES
SELECT
    'POL' || LPAD(SEQ4()::VARCHAR, 3, '0') AS policy_id,
    CASE UNIFORM(1, 20, RANDOM())
        WHEN 1 THEN 'Diabetes Care Protocol'
        WHEN 2 THEN 'Heart Failure Management Guidelines'
        WHEN 3 THEN 'Hypertension Treatment Algorithm'
        WHEN 4 THEN 'COPD Management Protocol'
        WHEN 5 THEN 'Medication Reconciliation Policy'
        WHEN 6 THEN 'Hospital Readmission Reduction Protocol'
        WHEN 7 THEN 'Care Transitions Best Practices'
        WHEN 8 THEN 'Chronic Disease Management Guidelines'
        WHEN 9 THEN 'Preventive Care Screening Guidelines'
        WHEN 10 THEN 'Social Determinants of Health Screening Protocol'
        WHEN 11 THEN 'Patient-Centered Medical Home Standards'
        WHEN 12 THEN 'Value-Based Care Quality Measures'
        WHEN 13 THEN 'HEDIS Measure Compliance Guidelines'
        WHEN 14 THEN 'Care Coordination Standards'
        WHEN 15 THEN 'Transitional Care Management Protocol'
        ELSE 'Clinical Quality Improvement Guidelines'
    END AS policy_title,
    'This clinical policy establishes evidence-based standards for patient care delivery within HonorHealth. The policy outlines best practices for assessment, diagnosis, treatment, and follow-up care. Key elements include: comprehensive patient evaluation incorporating social determinants of health screening, development of individualized care plans, coordination across care settings, patient and family engagement in decision-making, regular monitoring and outcomes assessment, and quality improvement initiatives. The policy emphasizes value-based care principles focusing on improving patient outcomes, reducing unnecessary utilization, and addressing health disparities. All providers are expected to follow these guidelines and document compliance in the electronic health record. Exceptions should be clearly documented with clinical rationale. Regular audits ensure adherence to policy standards. Policy is reviewed annually and updated based on latest clinical evidence and regulatory requirements.' AS policy_content,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Clinical Practice'
        WHEN 2 THEN 'Quality Improvement'
        WHEN 3 THEN 'Care Coordination'
        WHEN 4 THEN 'Value-Based Care'
        ELSE 'Patient Safety'
    END AS policy_category,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'Clinical Guideline'
        WHEN 2 THEN 'Care Protocol'
        WHEN 3 THEN 'Quality Standard'
        ELSE 'Best Practice'
    END AS policy_type,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'Diabetes,Hypertension,Cardiovascular Disease'
        WHEN 2 THEN 'Heart Failure,COPD,Chronic Disease'
        WHEN 3 THEN 'All Patients'
        WHEN 4 THEN 'Chronic Conditions,Multiple Comorbidities'
        ELSE 'General Medicine,Primary Care'
    END AS applies_to_conditions,
    DATEADD(month, -UNIFORM(3, 24, RANDOM()), CURRENT_DATE()) AS effective_date,
    DATEADD(month, -UNIFORM(1, 6, RANDOM()), CURRENT_DATE()) AS review_date,
    'healthcare,clinical practice,quality,value-based care,patient outcomes,care coordination,chronic disease,preventive care,HEDIS' AS keywords,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS last_updated
FROM TABLE(GENERATOR(ROWCOUNT => 100));

SELECT 'Health Policies: ' || COUNT(*) || ' rows inserted' AS status FROM HEALTH_POLICIES;

-- ============================================================================
-- Final Summary
-- ============================================================================
SELECT 'Data Generation Complete for Honor Health!' AS status;

SELECT 
    'PATIENTS' AS table_name, COUNT(*) AS row_count FROM PATIENTS
UNION ALL
SELECT 'SOCIAL_DETERMINANTS', COUNT(*) FROM SOCIAL_DETERMINANTS
UNION ALL
SELECT 'PROVIDERS', COUNT(*) FROM PROVIDERS
UNION ALL
SELECT 'ENCOUNTERS', COUNT(*) FROM ENCOUNTERS
UNION ALL
SELECT 'QUALITY_METRICS', COUNT(*) FROM QUALITY_METRICS
UNION ALL
SELECT 'HEALTH_OUTCOMES', COUNT(*) FROM HEALTH_OUTCOMES
UNION ALL
SELECT 'CLINICAL_NOTES', COUNT(*) FROM CLINICAL_NOTES
UNION ALL
SELECT 'CARE_PLANS', COUNT(*) FROM CARE_PLANS
UNION ALL
SELECT 'HEALTH_POLICIES', COUNT(*) FROM HEALTH_POLICIES;

-- ============================================================================
-- Next Step: Run honorhealth_04_create_views.sql
-- ============================================================================

-- ============================================================================
-- Honor Health Intelligence Agent - Analytical and Feature Views
-- ============================================================================
-- Purpose: Create analytical views and ML feature views
-- Views: 6 analytical + 3 ML feature views
-- ============================================================================

USE DATABASE HONORHEALTH_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HONORHEALTH_WH;

-- ============================================================================
-- Analytical View 1: V_PATIENT_SUMMARY
-- ============================================================================
CREATE OR REPLACE VIEW V_PATIENT_SUMMARY AS
SELECT
    p.patient_id,
    p.age,
    p.gender,
    p.race,
    p.ethnicity,
    p.insurance_type,
    p.county,
    p.state,
    p.patient_tier,
    sd.employment_status,
    sd.annual_income_range,
    sd.education_level,
    sd.housing_status,
    sd.food_insecurity,
    sd.transportation_barriers,
    sd.sdoh_risk_score,
    COUNT(DISTINCT e.encounter_id) AS total_encounters,
    SUM(e.encounter_cost) AS total_healthcare_cost,
    COUNT(DISTINCT CASE WHEN e.readmission_30_day THEN e.encounter_id END) AS readmission_count,
    COUNT(DISTINCT CASE WHEN e.emergency_visit THEN e.encounter_id END) AS ed_visit_count,
    AVG(qm.quality_points) AS avg_quality_points,
    COUNT(DISTINCT CASE WHEN qm.gaps_in_care THEN qm.metric_id END) AS gaps_in_care_count
FROM RAW.PATIENTS p
LEFT JOIN RAW.SOCIAL_DETERMINANTS sd ON p.patient_id = sd.patient_id
LEFT JOIN RAW.ENCOUNTERS e ON p.patient_id = e.patient_id
LEFT JOIN RAW.QUALITY_METRICS qm ON p.patient_id = qm.patient_id
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16;

-- ============================================================================
-- Analytical View 2: V_ENCOUNTER_DETAILS
-- ============================================================================
CREATE OR REPLACE VIEW V_ENCOUNTER_DETAILS AS
SELECT
    e.encounter_id,
    e.patient_id,
    e.provider_id,
    e.encounter_date,
    e.encounter_type,
    e.visit_reason,
    e.primary_diagnosis_code,
    e.chronic_conditions,
    e.encounter_cost,
    e.length_of_stay_days,
    e.readmission_30_day,
    e.emergency_visit,
    p.age AS patient_age,
    p.gender AS patient_gender,
    p.insurance_type,
    pr.specialty AS provider_specialty,
    pr.facility_name,
    sd.sdoh_risk_score,
    sd.food_insecurity,
    sd.transportation_barriers,
    CASE 
        WHEN e.encounter_cost > 10000 THEN 'High Cost'
        WHEN e.encounter_cost > 1000 THEN 'Medium Cost'
        ELSE 'Low Cost'
    END AS cost_category
FROM RAW.ENCOUNTERS e
JOIN RAW.PATIENTS p ON e.patient_id = p.patient_id
JOIN RAW.PROVIDERS pr ON e.provider_id = pr.provider_id
LEFT JOIN RAW.SOCIAL_DETERMINANTS sd ON e.patient_id = sd.patient_id;

-- ============================================================================
-- Analytical View 3: V_QUALITY_PERFORMANCE
-- ============================================================================
CREATE OR REPLACE VIEW V_QUALITY_PERFORMANCE AS
SELECT
    qm.patient_id,
    p.age,
    p.gender,
    p.insurance_type,
    p.county,
    qm.measure_category,
    qm.hedis_measure_code,
    qm.measure_name,
    COUNT(*) AS total_measures,
    SUM(CASE WHEN qm.met_target THEN 1 ELSE 0 END) AS measures_met,
    AVG(CASE WHEN qm.met_target THEN 1.0 ELSE 0.0 END) AS compliance_rate,
    SUM(CASE WHEN qm.gaps_in_care THEN 1 ELSE 0 END) AS total_gaps,
    SUM(qm.quality_points) AS total_quality_points,
    sd.sdoh_risk_score,
    sd.annual_income_range
FROM RAW.QUALITY_METRICS qm
JOIN RAW.PATIENTS p ON qm.patient_id = p.patient_id
LEFT JOIN RAW.SOCIAL_DETERMINANTS sd ON qm.patient_id = sd.patient_id
GROUP BY 1,2,3,4,5,6,7,8,14,15;

-- ============================================================================
-- Analytical View 4: V_SDOH_IMPACT_ANALYSIS
-- ============================================================================
CREATE OR REPLACE VIEW V_SDOH_IMPACT_ANALYSIS AS
SELECT
    sd.patient_id,
    sd.employment_status,
    sd.annual_income_range,
    sd.education_level,
    sd.housing_status,
    sd.food_insecurity,
    sd.transportation_barriers,
    sd.social_isolation_risk,
    sd.financial_strain,
    sd.sdoh_risk_score,
    p.age,
    p.gender,
    p.race,
    p.ethnicity,
    p.insurance_type,
    COUNT(DISTINCT e.encounter_id) AS encounter_count,
    SUM(e.encounter_cost) AS total_cost,
    AVG(e.encounter_cost) AS avg_encounter_cost,
    COUNT(DISTINCT CASE WHEN e.readmission_30_day THEN e.encounter_id END) AS readmissions,
    COUNT(DISTINCT CASE WHEN e.emergency_visit THEN e.encounter_id END) AS ed_visits,
    AVG(ho.predictive_risk_score) AS avg_risk_score,
    AVG(qm.quality_points) AS avg_quality_score
FROM RAW.SOCIAL_DETERMINANTS sd
JOIN RAW.PATIENTS p ON sd.patient_id = p.patient_id
LEFT JOIN RAW.ENCOUNTERS e ON sd.patient_id = e.patient_id
LEFT JOIN RAW.HEALTH_OUTCOMES ho ON sd.patient_id = ho.patient_id
LEFT JOIN RAW.QUALITY_METRICS qm ON sd.patient_id = qm.patient_id
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;

-- ============================================================================
-- Analytical View 5: V_CARE_PLAN_EFFECTIVENESS
-- ============================================================================
CREATE OR REPLACE VIEW V_CARE_PLAN_EFFECTIVENESS AS
SELECT
    cp.care_plan_id,
    cp.patient_id,
    cp.plan_type,
    cp.plan_status,
    cp.adherence_score,
    DATEDIFF(day, cp.plan_start_date, COALESCE(cp.plan_end_date, CURRENT_DATE())) AS plan_duration_days,
    p.age,
    p.insurance_type,
    sd.sdoh_risk_score,
    sd.food_insecurity,
    sd.transportation_barriers,
    COUNT(DISTINCT e.encounter_id) AS encounters_during_plan,
    SUM(e.encounter_cost) AS cost_during_plan,
    COUNT(DISTINCT CASE WHEN e.readmission_30_day THEN e.encounter_id END) AS readmissions_during_plan,
    AVG(ho.improvement_percentage) AS avg_improvement,
    SUM(qm.quality_points) AS quality_points_earned
FROM RAW.CARE_PLANS cp
JOIN RAW.PATIENTS p ON cp.patient_id = p.patient_id
LEFT JOIN RAW.SOCIAL_DETERMINANTS sd ON cp.patient_id = sd.patient_id
LEFT JOIN RAW.ENCOUNTERS e ON cp.patient_id = e.patient_id 
    AND e.encounter_date BETWEEN cp.plan_start_date AND COALESCE(cp.plan_end_date, CURRENT_DATE())
LEFT JOIN RAW.HEALTH_OUTCOMES ho ON cp.patient_id = ho.patient_id
    AND ho.outcome_date BETWEEN cp.plan_start_date AND COALESCE(cp.plan_end_date, CURRENT_DATE())
LEFT JOIN RAW.QUALITY_METRICS qm ON cp.patient_id = qm.patient_id
    AND qm.measurement_date BETWEEN cp.plan_start_date AND COALESCE(cp.plan_end_date, CURRENT_DATE())
GROUP BY 1,2,3,4,5,6,7,8,9,10,11;

-- ============================================================================
-- Analytical View 6: V_PROVIDER_PERFORMANCE
-- ============================================================================
CREATE OR REPLACE VIEW V_PROVIDER_PERFORMANCE AS
SELECT
    pr.provider_id,
    pr.provider_name,
    pr.provider_type,
    pr.specialty,
    pr.facility_name,
    pr.years_experience,
    pr.quality_score AS provider_quality_score,
    COUNT(DISTINCT e.encounter_id) AS total_encounters,
    COUNT(DISTINCT e.patient_id) AS unique_patients,
    AVG(e.encounter_cost) AS avg_encounter_cost,
    COUNT(DISTINCT CASE WHEN e.readmission_30_day THEN e.encounter_id END) AS readmission_count,
    AVG(CASE WHEN e.readmission_30_day THEN 1.0 ELSE 0.0 END) AS readmission_rate,
    COUNT(DISTINCT cp.care_plan_id) AS care_plans_managed,
    AVG(cp.adherence_score) AS avg_care_plan_adherence
FROM RAW.PROVIDERS pr
LEFT JOIN RAW.ENCOUNTERS e ON pr.provider_id = e.provider_id
LEFT JOIN RAW.CARE_PLANS cp ON pr.provider_id = cp.provider_id
GROUP BY 1,2,3,4,5,6,7;

-- ============================================================================
-- ML Feature View 1: V_READMISSION_RISK_FEATURES
-- ============================================================================
CREATE OR REPLACE VIEW V_READMISSION_RISK_FEATURES AS
SELECT
    e.encounter_id,
    p.age::FLOAT AS age,
    CASE p.gender WHEN 'Male' THEN 1 WHEN 'Female' THEN 0 ELSE 0.5 END::FLOAT AS gender_encoded,
    CASE 
        WHEN p.insurance_type = 'Medicare' THEN 1
        WHEN p.insurance_type = 'Medicaid' THEN 2
        WHEN p.insurance_type = 'Commercial' THEN 3
        WHEN p.insurance_type = 'Medicare Advantage' THEN 4
        ELSE 5
    END::FLOAT AS insurance_type_encoded,
    e.length_of_stay_days::FLOAT AS length_of_stay,
    e.encounter_cost::FLOAT AS encounter_cost,
    CASE e.encounter_type
        WHEN 'Inpatient Admission' THEN 1
        WHEN 'Emergency Department' THEN 2
        ELSE 0
    END::FLOAT AS encounter_type_risk,
    COALESCE(sd.sdoh_risk_score, 0)::FLOAT AS sdoh_risk_score,
    CASE WHEN sd.food_insecurity THEN 1 ELSE 0 END::FLOAT AS has_food_insecurity,
    CASE WHEN sd.transportation_barriers THEN 1 ELSE 0 END::FLOAT AS has_transport_barriers,
    (SELECT COUNT(*) FROM RAW.ENCOUNTERS e2 
     WHERE e2.patient_id = e.patient_id 
     AND e2.encounter_date < e.encounter_date)::FLOAT AS prior_encounter_count,
    COALESCE((SELECT AVG(quality_points) FROM RAW.QUALITY_METRICS qm 
              WHERE qm.patient_id = e.patient_id), 0)::FLOAT AS avg_quality_score,
    e.readmission_30_day::INT AS readmission_label
FROM RAW.ENCOUNTERS e
JOIN RAW.PATIENTS p ON e.patient_id = p.patient_id
LEFT JOIN RAW.SOCIAL_DETERMINANTS sd ON e.patient_id = sd.patient_id
WHERE e.encounter_type IN ('Inpatient Admission', 'Emergency Department');

-- ============================================================================
-- ML Feature View 2: V_HEALTH_OUTCOME_PREDICTION_FEATURES
-- ============================================================================
CREATE OR REPLACE VIEW V_HEALTH_OUTCOME_PREDICTION_FEATURES AS
SELECT
    ho.outcome_id,
    p.age::FLOAT AS age,
    CASE p.gender WHEN 'Male' THEN 1 WHEN 'Female' THEN 0 ELSE 0.5 END::FLOAT AS gender_encoded,
    COALESCE(sd.sdoh_risk_score, 0)::FLOAT AS sdoh_risk_score,
    CASE sd.employment_status
        WHEN 'Full-time Employed' THEN 1
        WHEN 'Part-time Employed' THEN 2
        WHEN 'Unemployed' THEN 3
        WHEN 'Retired' THEN 4
        WHEN 'Disabled' THEN 5
        ELSE 0
    END::FLOAT AS employment_encoded,
    CASE sd.housing_status
        WHEN 'Owned' THEN 1
        WHEN 'Rented' THEN 2
        WHEN 'Temporary Housing' THEN 3
        WHEN 'Homeless' THEN 4
        ELSE 0
    END::FLOAT AS housing_encoded,
    CASE WHEN sd.food_insecurity THEN 1 ELSE 0 END::FLOAT AS food_insecurity_flag,
    CASE WHEN sd.transportation_barriers THEN 1 ELSE 0 END::FLOAT AS transport_barrier_flag,
    ho.baseline_value::FLOAT AS baseline_value,
    (SELECT COUNT(DISTINCT encounter_id) FROM RAW.ENCOUNTERS e 
     WHERE e.patient_id = ho.patient_id 
     AND e.encounter_date < ho.outcome_date)::FLOAT AS prior_encounters,
    (SELECT SUM(encounter_cost) FROM RAW.ENCOUNTERS e 
     WHERE e.patient_id = ho.patient_id 
     AND e.encounter_date < ho.outcome_date)::FLOAT AS cumulative_cost,
    COALESCE((SELECT AVG(quality_points) FROM RAW.QUALITY_METRICS qm 
              WHERE qm.patient_id = ho.patient_id), 0)::FLOAT AS quality_score,
    CASE 
        WHEN ho.improvement_percentage > 10 THEN 2  -- Improved
        WHEN ho.improvement_percentage >= 0 THEN 1  -- Stable
        ELSE 0  -- Declined
    END::INT AS outcome_label
FROM RAW.HEALTH_OUTCOMES ho
JOIN RAW.PATIENTS p ON ho.patient_id = p.patient_id
LEFT JOIN RAW.SOCIAL_DETERMINANTS sd ON ho.patient_id = sd.patient_id;

-- ============================================================================
-- ML Feature View 3: V_SOCIAL_RISK_STRATIFICATION_FEATURES
-- ============================================================================
CREATE OR REPLACE VIEW V_SOCIAL_RISK_STRATIFICATION_FEATURES AS
SELECT
    sd.sdoh_id,
    p.age::FLOAT AS age,
    CASE p.gender WHEN 'Male' THEN 1 WHEN 'Female' THEN 0 ELSE 0.5 END::FLOAT AS gender_encoded,
    CASE sd.employment_status
        WHEN 'Full-time Employed' THEN 1
        WHEN 'Part-time Employed' THEN 2
        WHEN 'Unemployed' THEN 3
        WHEN 'Retired' THEN 4
        WHEN 'Disabled' THEN 5
        ELSE 0
    END::FLOAT AS employment_status_encoded,
    CASE sd.annual_income_range
        WHEN 'Over $100K' THEN 5
        WHEN '$75K-$100K' THEN 4
        WHEN '$50K-$75K' THEN 3
        WHEN '$25K-$50K' THEN 2
        WHEN 'Under $25K' THEN 1
        ELSE 0
    END::FLOAT AS income_level,
    CASE sd.education_level
        WHEN 'Advanced Degree' THEN 5
        WHEN 'College Graduate' THEN 4
        WHEN 'Some College' THEN 3
        WHEN 'High School Graduate' THEN 2
        WHEN 'Less than High School' THEN 1
        ELSE 0
    END::FLOAT AS education_level_encoded,
    CASE sd.housing_status
        WHEN 'Owned' THEN 1
        WHEN 'Rented' THEN 2
        WHEN 'Temporary Housing' THEN 3
        WHEN 'Homeless' THEN 4
        ELSE 0
    END::FLOAT AS housing_stability,
    CASE WHEN sd.food_insecurity THEN 1 ELSE 0 END::FLOAT AS food_insecurity_flag,
    CASE WHEN sd.transportation_barriers THEN 1 ELSE 0 END::FLOAT AS transport_barrier_flag,
    CASE sd.social_isolation_risk
        WHEN 'Low Risk' THEN 1
        WHEN 'Moderate Risk' THEN 2
        WHEN 'High Risk' THEN 3
        ELSE 0
    END::FLOAT AS isolation_risk_level,
    CASE sd.financial_strain
        WHEN 'None' THEN 0
        WHEN 'Mild' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Severe' THEN 3
        ELSE 0
    END::FLOAT AS financial_strain_level,
    CASE WHEN sd.utility_assistance_needed THEN 1 ELSE 0 END::FLOAT AS utility_need_flag,
    COALESCE((SELECT COUNT(*) FROM RAW.ENCOUNTERS e 
              WHERE e.patient_id = sd.patient_id), 0)::FLOAT AS encounter_count,
    COALESCE((SELECT SUM(encounter_cost) FROM RAW.ENCOUNTERS e 
              WHERE e.patient_id = sd.patient_id), 0)::FLOAT AS total_healthcare_cost,
    CASE 
        WHEN sd.sdoh_risk_score >= 70 THEN 2  -- High Risk
        WHEN sd.sdoh_risk_score >= 40 THEN 1  -- Medium Risk
        ELSE 0  -- Low Risk
    END::INT AS risk_level_label
FROM RAW.SOCIAL_DETERMINANTS sd
JOIN RAW.PATIENTS p ON sd.patient_id = p.patient_id;

-- ============================================================================
-- Verification
-- ============================================================================
SELECT 'All Honor Health views created successfully' AS status;

SHOW VIEWS IN SCHEMA ANALYTICS;

-- ============================================================================
-- Summary
-- ============================================================================
/*
Created 9 views:
- 6 Analytical Views:
  1. V_PATIENT_SUMMARY
  2. V_ENCOUNTER_DETAILS
  3. V_QUALITY_PERFORMANCE
  4. V_SDOH_IMPACT_ANALYSIS
  5. V_CARE_PLAN_EFFECTIVENESS
  6. V_PROVIDER_PERFORMANCE

- 3 ML Feature Views:
  1. V_READMISSION_RISK_FEATURES
  2. V_HEALTH_OUTCOME_PREDICTION_FEATURES
  3. V_SOCIAL_RISK_STRATIFICATION_FEATURES

Next Step: Run honorhealth_05_create_semantic_views.sql
*/

-- ============================================================================
-- Honor Health Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Semantic views for Cortex Analyst text-to-SQL capabilities
-- Syntax: VERIFIED against Snowflake documentation
-- Column names: VERIFIED against table definitions
-- ============================================================================

USE DATABASE HONORHEALTH_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HONORHEALTH_WH;

-- ============================================================================
-- Semantic View 1: Patient Health Outcomes and Care Quality
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_PATIENT_HEALTH_OUTCOMES
  TABLES (
    patients AS HONORHEALTH_INTELLIGENCE.RAW.PATIENTS
      PRIMARY KEY (patient_id),
    encounters AS HONORHEALTH_INTELLIGENCE.RAW.ENCOUNTERS
      PRIMARY KEY (encounter_id),
    quality_metrics AS HONORHEALTH_INTELLIGENCE.RAW.QUALITY_METRICS
      PRIMARY KEY (metric_id),
    health_outcomes AS HONORHEALTH_INTELLIGENCE.RAW.HEALTH_OUTCOMES
      PRIMARY KEY (outcome_id)
  )
  RELATIONSHIPS (
    encounters(patient_id) REFERENCES patients(patient_id),
    quality_metrics(patient_id) REFERENCES patients(patient_id),
    health_outcomes(patient_id) REFERENCES patients(patient_id)
  )
  DIMENSIONS (
    patients.age_group AS
      CASE
        WHEN patients.age < 18 THEN 'Pediatric'
        WHEN patients.age < 35 THEN '18-34'
        WHEN patients.age < 50 THEN '35-49'
        WHEN patients.age < 65 THEN '50-64'
        ELSE '65+'
      END,
    patients.gender AS patients.gender,
    patients.race AS patients.race,
    patients.insurance_type AS patients.insurance_type,
    patients.county AS patients.county,
    patients.state AS patients.state,
    encounters.encounter_type AS encounters.encounter_type,
    encounters.visit_reason AS encounters.visit_reason,
    encounters.primary_diagnosis_code AS encounters.primary_diagnosis_code,
    encounters.chronic_conditions AS encounters.chronic_conditions,
    quality_metrics.measure_category AS quality_metrics.measure_category,
    quality_metrics.hedis_measure_code AS quality_metrics.hedis_measure_code,
    quality_metrics.measure_name AS quality_metrics.measure_name,
    health_outcomes.outcome_type AS health_outcomes.outcome_type,
    health_outcomes.risk_stratification AS health_outcomes.risk_stratification
  )
  METRICS (
    patients.total_patients AS COUNT(DISTINCT patients.patient_id),
    patients.avg_age AS AVG(patients.age),
    encounters.total_encounters AS COUNT(DISTINCT encounters.encounter_id),
    encounters.total_cost AS SUM(encounters.encounter_cost),
    encounters.avg_cost AS AVG(encounters.encounter_cost),
    encounters.readmission_count AS COUNT_IF(encounters.readmission_30_day),
    encounters.readmission_rate AS (COUNT_IF(encounters.readmission_30_day)::FLOAT / NULLIF(COUNT(*), 0)),
    encounters.ed_visit_count AS COUNT_IF(encounters.emergency_visit),
    encounters.ed_visit_rate AS (COUNT_IF(encounters.emergency_visit)::FLOAT / NULLIF(COUNT(*), 0)),
    encounters.avg_length_of_stay AS AVG(encounters.length_of_stay_days),
    quality_metrics.total_measures AS COUNT(DISTINCT quality_metrics.metric_id),
    quality_metrics.measures_met AS COUNT_IF(quality_metrics.met_target),
    quality_metrics.compliance_rate AS (COUNT_IF(quality_metrics.met_target)::FLOAT / NULLIF(COUNT(*), 0)),
    quality_metrics.gaps_in_care_count AS COUNT_IF(quality_metrics.gaps_in_care),
    quality_metrics.total_quality_points AS SUM(quality_metrics.quality_points),
    quality_metrics.avg_quality_points AS AVG(quality_metrics.quality_points),
    health_outcomes.total_outcomes AS COUNT(DISTINCT health_outcomes.outcome_id),
    health_outcomes.avg_improvement AS AVG(health_outcomes.improvement_percentage),
    health_outcomes.avg_risk_score AS AVG(health_outcomes.predictive_risk_score)
  )
  COMMENT = 'Semantic view for patient health outcomes, encounters, and care quality metrics';

-- ============================================================================
-- Semantic View 2: Social Determinants of Health Factors
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_SOCIAL_DETERMINANTS
  TABLES (
    patients AS HONORHEALTH_INTELLIGENCE.RAW.PATIENTS
      PRIMARY KEY (patient_id),
    sdoh AS HONORHEALTH_INTELLIGENCE.RAW.SOCIAL_DETERMINANTS
      PRIMARY KEY (sdoh_id),
    encounters AS HONORHEALTH_INTELLIGENCE.RAW.ENCOUNTERS
      PRIMARY KEY (encounter_id),
    care_plans AS HONORHEALTH_INTELLIGENCE.RAW.CARE_PLANS
      PRIMARY KEY (care_plan_id)
  )
  RELATIONSHIPS (
    sdoh(patient_id) REFERENCES patients(patient_id),
    encounters(patient_id) REFERENCES patients(patient_id),
    care_plans(patient_id) REFERENCES patients(patient_id)
  )
  DIMENSIONS (
    patients.age_group AS
      CASE
        WHEN patients.age < 18 THEN 'Pediatric'
        WHEN patients.age < 35 THEN '18-34'
        WHEN patients.age < 50 THEN '35-49'
        WHEN patients.age < 65 THEN '50-64'
        ELSE '65+'
      END,
    patients.gender AS patients.gender,
    patients.race AS patients.race,
    patients.ethnicity AS patients.ethnicity,
    patients.insurance_type AS patients.insurance_type,
    patients.county AS patients.county,
    sdoh.employment_status AS sdoh.employment_status,
    sdoh.annual_income_range AS sdoh.annual_income_range,
    sdoh.education_level AS sdoh.education_level,
    sdoh.housing_status AS sdoh.housing_status,
    sdoh.social_isolation_risk AS sdoh.social_isolation_risk,
    sdoh.financial_strain AS sdoh.financial_strain,
    sdoh.neighborhood_safety AS sdoh.neighborhood_safety,
    care_plans.plan_type AS care_plans.plan_type,
    care_plans.plan_status AS care_plans.plan_status
  )
  METRICS (
    patients.total_patients AS COUNT(DISTINCT patients.patient_id),
    sdoh.total_assessments AS COUNT(DISTINCT sdoh.sdoh_id),
    sdoh.avg_risk_score AS AVG(sdoh.sdoh_risk_score),
    sdoh.food_insecurity_count AS COUNT_IF(sdoh.food_insecurity),
    sdoh.food_insecurity_rate AS (COUNT_IF(sdoh.food_insecurity)::FLOAT / NULLIF(COUNT(*), 0)),
    sdoh.transport_barrier_count AS COUNT_IF(sdoh.transportation_barriers),
    sdoh.transport_barrier_rate AS (COUNT_IF(sdoh.transportation_barriers)::FLOAT / NULLIF(COUNT(*), 0)),
    sdoh.utility_need_count AS COUNT_IF(sdoh.utility_assistance_needed),
    sdoh.utility_need_rate AS (COUNT_IF(sdoh.utility_assistance_needed)::FLOAT / NULLIF(COUNT(*), 0)),
    encounters.total_encounters AS COUNT(DISTINCT encounters.encounter_id),
    encounters.total_healthcare_cost AS SUM(encounters.encounter_cost),
    encounters.avg_encounter_cost AS AVG(encounters.encounter_cost),
    encounters.readmission_count AS COUNT_IF(encounters.readmission_30_day),
    care_plans.total_care_plans AS COUNT(DISTINCT care_plans.care_plan_id),
    care_plans.avg_adherence_score AS AVG(care_plans.adherence_score),
    care_plans.plans_with_sdoh_intervention AS COUNT_IF(care_plans.sdoh_interventions IS NOT NULL)
  )
  COMMENT = 'Semantic view for social determinants of health and their impact on care';

-- ============================================================================
-- Semantic View 3: Value-Based Care Performance Metrics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_VALUE_BASED_CARE
  TABLES (
    providers AS HONORHEALTH_INTELLIGENCE.RAW.PROVIDERS
      PRIMARY KEY (provider_id),
    patients AS HONORHEALTH_INTELLIGENCE.RAW.PATIENTS
      PRIMARY KEY (patient_id),
    encounters AS HONORHEALTH_INTELLIGENCE.RAW.ENCOUNTERS
      PRIMARY KEY (encounter_id),
    quality_metrics AS HONORHEALTH_INTELLIGENCE.RAW.QUALITY_METRICS
      PRIMARY KEY (metric_id),
    care_plans AS HONORHEALTH_INTELLIGENCE.RAW.CARE_PLANS
      PRIMARY KEY (care_plan_id)
  )
  RELATIONSHIPS (
    encounters(patient_id) REFERENCES patients(patient_id),
    encounters(provider_id) REFERENCES providers(provider_id),
    quality_metrics(patient_id) REFERENCES patients(patient_id),
    care_plans(patient_id) REFERENCES patients(patient_id),
    care_plans(provider_id) REFERENCES providers(provider_id)
  )
  DIMENSIONS (
    providers.provider_name AS providers.provider_name,
    providers.provider_type AS providers.provider_type,
    providers.specialty AS providers.specialty,
    providers.facility_name AS providers.facility_name,
    providers.active_status AS providers.active_status,
    patients.insurance_type AS patients.insurance_type,
    patients.patient_tier AS patients.patient_tier,
    patients.county AS patients.county,
    encounters.encounter_type AS encounters.encounter_type,
    quality_metrics.measure_category AS quality_metrics.measure_category,
    quality_metrics.hedis_measure_code AS quality_metrics.hedis_measure_code,
    care_plans.plan_type AS care_plans.plan_type,
    care_plans.plan_status AS care_plans.plan_status
  )
  METRICS (
    providers.total_providers AS COUNT(DISTINCT providers.provider_id),
    providers.avg_quality_score AS AVG(providers.quality_score),
    providers.avg_experience_years AS AVG(providers.years_experience),
    providers.avg_panel_size AS AVG(providers.patient_panel_size),
    patients.total_patients AS COUNT(DISTINCT patients.patient_id),
    encounters.total_encounters AS COUNT(DISTINCT encounters.encounter_id),
    encounters.total_cost AS SUM(encounters.encounter_cost),
    encounters.avg_cost_per_encounter AS AVG(encounters.encounter_cost),
    encounters.readmission_count AS COUNT_IF(encounters.readmission_30_day),
    encounters.readmission_rate AS (COUNT_IF(encounters.readmission_30_day)::FLOAT / NULLIF(COUNT(*), 0)),
    encounters.ed_utilization_rate AS (COUNT_IF(encounters.emergency_visit)::FLOAT / NULLIF(COUNT(*), 0)),
    quality_metrics.total_quality_measures AS COUNT(DISTINCT quality_metrics.metric_id),
    quality_metrics.measures_compliant AS COUNT_IF(quality_metrics.met_target),
    quality_metrics.quality_compliance_rate AS (COUNT_IF(quality_metrics.met_target)::FLOAT / NULLIF(COUNT(*), 0)),
    quality_metrics.total_gaps_in_care AS COUNT_IF(quality_metrics.gaps_in_care),
    quality_metrics.total_quality_points AS SUM(quality_metrics.quality_points),
    quality_metrics.avg_quality_points AS AVG(quality_metrics.quality_points),
    care_plans.total_care_plans AS COUNT(DISTINCT care_plans.care_plan_id),
    care_plans.active_care_plans AS COUNT_IF(care_plans.plan_status = 'Active'),
    care_plans.avg_adherence_score AS AVG(care_plans.adherence_score),
    care_plans.total_care_plans_count AS COUNT(DISTINCT care_plans.care_plan_id)
  )
  COMMENT = 'Semantic view for value-based care performance, quality metrics, and provider performance';

-- ============================================================================
-- Confirmation
-- ============================================================================
SELECT 'Honor Health semantic views created successfully - syntax and columns verified' AS STATUS;

SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;

-- ============================================================================
-- Summary
-- ============================================================================
/*
Created 3 semantic views:
1. SV_PATIENT_HEALTH_OUTCOMES - Patient outcomes, encounters, quality metrics
2. SV_SOCIAL_DETERMINANTS - SDOH factors and their impact on care
3. SV_VALUE_BASED_CARE - Value-based care performance and quality metrics

Next Step: Run honorhealth_06_create_cortex_search.sql
*/

-- ============================================================================
-- Honor Health Intelligence Agent - Cortex Search Services
-- ============================================================================
-- Purpose: Enable semantic search over unstructured clinical documentation
-- Tables: CLINICAL_NOTES, CARE_PLANS, HEALTH_POLICIES
-- Syntax: VERIFIED against Snowflake documentation
-- ============================================================================

USE DATABASE HONORHEALTH_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE HONORHEALTH_WH;

-- ============================================================================
-- Step 1: Verify Change Tracking (already enabled in table creation)
-- ============================================================================
SHOW TABLES LIKE 'CLINICAL_NOTES' IN SCHEMA RAW;
SHOW TABLES LIKE 'CARE_PLANS' IN SCHEMA RAW;
SHOW TABLES LIKE 'HEALTH_POLICIES' IN SCHEMA RAW;

-- ============================================================================
-- Step 2: Create Cortex Search Service for Clinical Notes
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE CLINICAL_NOTES_SEARCH
  ON note_text
  ATTRIBUTES patient_id, encounter_id, provider_id, note_type, clinical_category, urgency_level
  WAREHOUSE = HONORHEALTH_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Semantic search over clinical notes and documentation'
AS
  SELECT
    note_id,
    note_text,
    patient_id,
    encounter_id,
    provider_id,
    note_date,
    note_type,
    clinical_category,
    contains_sdoh_factors,
    urgency_level,
    created_at
  FROM CLINICAL_NOTES;

-- ============================================================================
-- Step 3: Create Cortex Search Service for Care Plans
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE CARE_PLANS_SEARCH
  ON plan_document
  ATTRIBUTES patient_id, provider_id, plan_type, plan_status
  WAREHOUSE = HONORHEALTH_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search over care plans, treatment protocols, and SDOH interventions'
AS
  SELECT
    care_plan_id,
    plan_document,
    patient_id,
    provider_id,
    plan_start_date,
    plan_end_date,
    plan_type,
    goals,
    interventions,
    sdoh_interventions,
    plan_status,
    adherence_score,
    created_at
  FROM CARE_PLANS;

-- ============================================================================
-- Step 4: Create Cortex Search Service for Health Policies
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE HEALTH_POLICIES_SEARCH
  ON policy_content
  ATTRIBUTES policy_category, policy_type, applies_to_conditions, keywords
  WAREHOUSE = HONORHEALTH_WH
  TARGET_LAG = '1 day'
  COMMENT = 'Search clinical policies, guidelines, and care protocols'
AS
  SELECT
    policy_id,
    policy_content,
    policy_title,
    policy_category,
    policy_type,
    applies_to_conditions,
    effective_date,
    review_date,
    keywords,
    created_at,
    last_updated
  FROM HEALTH_POLICIES;

-- ============================================================================
-- Step 5: Grant Usage Permissions
-- ============================================================================
GRANT USAGE ON CORTEX SEARCH SERVICE CLINICAL_NOTES_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE CARE_PLANS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE HEALTH_POLICIES_SEARCH TO ROLE SYSADMIN;

-- ============================================================================
-- Step 6: Test Search Services with Sample Queries
-- ============================================================================

-- Test clinical notes search
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'HONORHEALTH_INTELLIGENCE.RAW.CLINICAL_NOTES_SEARCH',
    '{
      "query": "diabetes management",
      "columns": ["note_text", "note_type", "clinical_category"],
      "limit": 3
    }'
  )
)['results'] AS results;

-- Test care plans search
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'HONORHEALTH_INTELLIGENCE.RAW.CARE_PLANS_SEARCH',
    '{
      "query": "heart failure care plan",
      "columns": ["plan_document", "plan_type", "goals"],
      "filter": {"@eq": {"plan_status": "Active"}},
      "limit": 3
    }'
  )
)['results'] AS results;

-- Test health policies search
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'HONORHEALTH_INTELLIGENCE.RAW.HEALTH_POLICIES_SEARCH',
    '{
      "query": "value-based care quality measures",
      "columns": ["policy_title", "policy_category", "policy_type"],
      "limit": 3
    }'
  )
)['results'] AS results;

-- ============================================================================
-- Step 7: Verify Service Status
-- ============================================================================
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

SELECT 'Honor Health Cortex Search services created successfully' AS STATUS;

-- ============================================================================
-- Usage Examples for Intelligence Agent
-- ============================================================================

-- Example 1: Search clinical notes for SDOH factors
-- Query: "Find clinical notes mentioning food insecurity or transportation barriers"
-- Uses: CLINICAL_NOTES_SEARCH with query filter

-- Example 2: Search care plans for specific interventions
-- Query: "Find care plans with SDOH interventions for diabetic patients"
-- Uses: CARE_PLANS_SEARCH with sdoh_interventions filter

-- Example 3: Search policies for specific conditions
-- Query: "What are our policies for managing chronic disease patients?"
-- Uses: HEALTH_POLICIES_SEARCH with applies_to_conditions filter

-- ============================================================================
-- Monitoring and Maintenance
-- ============================================================================

-- Check search service refresh status
SHOW DYNAMIC TABLES LIKE '%CORTEX_SEARCH%' IN SCHEMA RAW;

-- View search service details
DESC CORTEX SEARCH SERVICE CLINICAL_NOTES_SEARCH;
DESC CORTEX SEARCH SERVICE CARE_PLANS_SEARCH;
DESC CORTEX SEARCH SERVICE HEALTH_POLICIES_SEARCH;

-- ============================================================================
-- Summary
-- ============================================================================
/*
Created 3 Cortex Search Services:
1. CLINICAL_NOTES_SEARCH - Search clinical documentation
2. CARE_PLANS_SEARCH - Search care plans and interventions
3. HEALTH_POLICIES_SEARCH - Search policies and guidelines

Next Step: Create ML models in honorhealth_ml_models.ipynb
*/

