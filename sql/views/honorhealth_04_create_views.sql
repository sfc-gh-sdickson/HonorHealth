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
    COALESCE(CASE sd.employment_status
        WHEN 'Full-time Employed' THEN 1
        WHEN 'Part-time Employed' THEN 2
        WHEN 'Unemployed' THEN 3
        WHEN 'Retired' THEN 4
        WHEN 'Disabled' THEN 5
        ELSE 0
    END, 0)::FLOAT AS employment_encoded,
    COALESCE(CASE sd.housing_status
        WHEN 'Owned' THEN 1
        WHEN 'Rented' THEN 2
        WHEN 'Temporary Housing' THEN 3
        WHEN 'Homeless' THEN 4
        ELSE 0
    END, 0)::FLOAT AS housing_encoded,
    COALESCE(CASE WHEN sd.food_insecurity THEN 1 ELSE 0 END, 0)::FLOAT AS food_insecurity_flag,
    COALESCE(CASE WHEN sd.transportation_barriers THEN 1 ELSE 0 END, 0)::FLOAT AS transport_barrier_flag,
    COALESCE(ho.baseline_value, 0)::FLOAT AS baseline_value,
    COALESCE((SELECT COUNT(DISTINCT encounter_id) FROM RAW.ENCOUNTERS e 
     WHERE e.patient_id = ho.patient_id 
     AND e.encounter_date < ho.outcome_date), 0)::FLOAT AS prior_encounters,
    COALESCE((SELECT SUM(encounter_cost) FROM RAW.ENCOUNTERS e 
     WHERE e.patient_id = ho.patient_id 
     AND e.encounter_date < ho.outcome_date), 0)::FLOAT AS cumulative_cost,
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

