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

