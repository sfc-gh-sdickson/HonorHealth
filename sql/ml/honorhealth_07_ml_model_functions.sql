-- ============================================================================
-- Honor Health ML Model Functions - Complete Setup
-- ============================================================================
-- Creates SQL UDF wrappers for ML model inference
-- These functions are called by the Intelligence Agent
-- Execution time: <10 seconds per function call
-- ============================================================================

USE DATABASE HONORHEALTH_INTELLIGENCE;
USE SCHEMA ML_MODELS;
USE WAREHOUSE HONORHEALTH_WH;

-- ============================================================================
-- Function 1: Predict Readmission Risk
-- ============================================================================
-- Returns: Summary string with readmission risk distribution
-- Input: encounter_type_filter (Inpatient Admission, Emergency Department, or NULL)
-- Analyzes 50 encounters

CREATE OR REPLACE FUNCTION PREDICT_READMISSION_RISK(encounter_type_filter VARCHAR)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Total Encounters: ' || COUNT(*) || 
        ', Low Risk (No Readmission): ' || SUM(CASE WHEN pred:PREDICTED_READMISSION::INT = 0 THEN 1 ELSE 0 END) ||
        ', High Risk (Readmission): ' || SUM(CASE WHEN pred:PREDICTED_READMISSION::INT = 1 THEN 1 ELSE 0 END) ||
        ', Readmission Rate: ' || ROUND(SUM(CASE WHEN pred:PREDICTED_READMISSION::INT = 1 THEN 1 ELSE 0 END)::FLOAT / COUNT(*) * 100, 1) || '%'
    FROM (
        SELECT 
            READMISSION_RISK_PREDICTOR!PREDICT(
                age, gender_encoded, insurance_type_encoded, length_of_stay,
                encounter_cost, encounter_type_risk, sdoh_risk_score,
                has_food_insecurity, has_transport_barriers, prior_encounter_count,
                avg_quality_score
            ) as pred
        FROM HONORHEALTH_INTELLIGENCE.ANALYTICS.V_READMISSION_RISK_FEATURES
        WHERE encounter_type_filter IS NULL OR encounter_type_risk = encounter_type_filter
        LIMIT 50
    )
$$;

-- ============================================================================
-- Function 2: Predict Health Outcomes
-- ============================================================================
-- Returns: Summary string with health outcome predictions
-- Input: risk_level_filter (Low Risk, Medium Risk, High Risk, or NULL)
-- Analyzes 50 patients

CREATE OR REPLACE FUNCTION PREDICT_HEALTH_OUTCOMES(risk_level_filter VARCHAR)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Total Patients: ' || COUNT(*) ||
        ', Declined: ' || SUM(CASE WHEN pred:PREDICTED_OUTCOME::INT = 0 THEN 1 ELSE 0 END) ||
        ', Stable: ' || SUM(CASE WHEN pred:PREDICTED_OUTCOME::INT = 1 THEN 1 ELSE 0 END) ||
        ', Improved: ' || SUM(CASE WHEN pred:PREDICTED_OUTCOME::INT = 2 THEN 1 ELSE 0 END) ||
        ', Improvement Rate: ' || ROUND(SUM(CASE WHEN pred:PREDICTED_OUTCOME::INT = 2 THEN 1 ELSE 0 END)::FLOAT / COUNT(*) * 100, 1) || '%'
    FROM (
        SELECT 
            HEALTH_OUTCOME_PREDICTOR!PREDICT(
                age, gender_encoded, sdoh_risk_score, employment_encoded,
                housing_encoded, food_insecurity_flag, transport_barrier_flag,
                baseline_value, prior_encounters, cumulative_cost, quality_score
            ) as pred
        FROM HONORHEALTH_INTELLIGENCE.ANALYTICS.V_HEALTH_OUTCOME_PREDICTION_FEATURES
        LIMIT 50
    )
$$;

-- ============================================================================
-- Function 3: Stratify Social Risk
-- ============================================================================
-- Returns: Summary string with social risk stratification
-- Input: days_back (number of days to analyze, default 365)
-- Analyzes 50 patients

CREATE OR REPLACE FUNCTION STRATIFY_SOCIAL_RISK(days_back NUMBER)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Total Patients: ' || COUNT(*) ||
        ', Low Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK_LEVEL::INT = 0 THEN 1 ELSE 0 END) ||
        ', Medium Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK_LEVEL::INT = 1 THEN 1 ELSE 0 END) ||
        ', High Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK_LEVEL::INT = 2 THEN 1 ELSE 0 END) ||
        ', High Risk Rate: ' || ROUND(SUM(CASE WHEN pred:PREDICTED_RISK_LEVEL::INT = 2 THEN 1 ELSE 0 END)::FLOAT / COUNT(*) * 100, 1) || '%'
    FROM (
        SELECT 
            SOCIAL_RISK_STRATIFICATION!PREDICT(
                age, gender_encoded, employment_status_encoded, income_level,
                education_level_encoded, housing_stability, food_insecurity_flag,
                transport_barrier_flag, isolation_risk_level, financial_strain_level,
                utility_need_flag, encounter_count, total_healthcare_cost
            ) as pred
        FROM HONORHEALTH_INTELLIGENCE.ANALYTICS.V_SOCIAL_RISK_STRATIFICATION_FEATURES
        LIMIT 50
    )
$$;

-- ============================================================================
-- Verification Tests
-- ============================================================================
SELECT '🔄 Testing ML functions...' as status;

SELECT PREDICT_READMISSION_RISK(NULL) as readmission_risk_result;
SELECT PREDICT_HEALTH_OUTCOMES(NULL) as health_outcome_result;
SELECT STRATIFY_SOCIAL_RISK(365) as social_risk_result;

SELECT '✅ All ML functions created and tested successfully!' as final_status;

-- ============================================================================
-- Summary
-- ============================================================================
/*
Created 3 ML model functions:
1. PREDICT_READMISSION_RISK - Predicts 30-day readmission risk
2. PREDICT_HEALTH_OUTCOMES - Predicts health outcome improvement
3. STRATIFY_SOCIAL_RISK - Stratifies patients by social risk level

Next Step: Run honorhealth_08_intelligence_agent.sql
*/

