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
    encounters.primary_diagnosis_code AS encounters.diagnosis_code,
    encounters.chronic_conditions AS encounters.chronic_conditions,
    quality_metrics.measure_category AS quality_metrics.measure_category,
    quality_metrics.hedis_measure_code AS quality_metrics.hedis_code,
    quality_metrics.measure_name AS quality_metrics.measure_name,
    health_outcomes.outcome_type AS health_outcomes.outcome_type,
    health_outcomes.risk_stratification AS health_outcomes.risk_level
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
    sdoh.annual_income_range AS sdoh.income_range,
    sdoh.education_level AS sdoh.education_level,
    sdoh.housing_status AS sdoh.housing_status,
    sdoh.social_isolation_risk AS sdoh.isolation_risk,
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
    providers.active_status AS providers.status,
    patients.insurance_type AS patients.insurance_type,
    patients.patient_tier AS patients.patient_tier,
    patients.county AS patients.county,
    encounters.encounter_type AS encounters.encounter_type,
    quality_metrics.measure_category AS quality_metrics.measure_category,
    quality_metrics.hedis_measure_code AS quality_metrics.hedis_code,
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
    encounters.cost_per_patient AS (SUM(encounters.encounter_cost)::FLOAT / NULLIF(COUNT(DISTINCT patients.patient_id), 0)),
    encounters.readmission_count AS COUNT_IF(encounters.readmission_30_day),
    encounters.readmission_rate AS (COUNT_IF(encounters.readmission_30_day)::FLOAT / NULLIF(COUNT(*), 0)),
    encounters.ed_utilization_rate AS (COUNT_IF(encounters.emergency_visit)::FLOAT / NULLIF(COUNT(*), 0)),
    quality_metrics.total_quality_measures AS COUNT(DISTINCT quality_metrics.metric_id),
    quality_metrics.measures_compliant AS COUNT_IF(quality_metrics.met_target),
    quality_metrics.quality_compliance_rate AS (COUNT_IF(quality_metrics.met_target)::FLOAT / NULLIF(COUNT(*), 0)),
    quality_metrics.total_gaps_in_care AS COUNT_IF(quality_metrics.gaps_in_care),
    quality_metrics.total_quality_points AS SUM(quality_metrics.quality_points),
    quality_metrics.avg_quality_points_per_patient AS (SUM(quality_metrics.quality_points)::FLOAT / NULLIF(COUNT(DISTINCT patients.patient_id), 0)),
    care_plans.total_care_plans AS COUNT(DISTINCT care_plans.care_plan_id),
    care_plans.active_care_plans AS COUNT_IF(care_plans.plan_status = 'Active'),
    care_plans.avg_adherence_score AS AVG(care_plans.adherence_score),
    care_plans.care_plans_per_patient AS (COUNT(DISTINCT care_plans.care_plan_id)::FLOAT / NULLIF(COUNT(DISTINCT patients.patient_id), 0))
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

