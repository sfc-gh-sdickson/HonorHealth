-- ============================================================================
-- Honor Health Intelligence Agent - Agent Configuration
-- ============================================================================
-- Purpose: Create Snowflake Intelligence Agent with semantic views and ML tools
-- Agent: HONORHEALTH_CARE_AGENT
-- Tools: 3 semantic views + 3 Cortex Search services + 3 ML model functions
-- ============================================================================

USE DATABASE HONORHEALTH_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE HONORHEALTH_WH;

-- ============================================================================
-- Create Cortex Agent
-- ============================================================================
CREATE OR REPLACE AGENT HONORHEALTH_CARE_AGENT
  COMMENT = 'Honor Health intelligence agent for SDOH and value-based care analytics with ML predictions'
  PROFILE = '{"display_name": "Honor Health Care Assistant", "avatar": "health-icon.png", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 32000

  instructions:
    response: "You are a helpful healthcare intelligence assistant for Honor Health. Provide clear, accurate answers about patients, social determinants of health, value-based care metrics, and health outcomes. When using ML predictions, explain the risk levels and clinical implications clearly. Always cite data sources and protect patient privacy."
    orchestration: "For patient outcomes, encounters, readmissions, and quality metrics use PatientHealthOutcomesAnalyst (SV_PATIENT_HEALTH_OUTCOMES - includes patients, encounters, quality_metrics, health_outcomes tables). For SDOH factors, social risk, care plans, and SDOH interventions use SocialDeterminantsAnalyst (SV_SOCIAL_DETERMINANTS - includes patients, sdoh, encounters, care_plans tables). For provider performance, value-based care metrics, care plan effectiveness, and cost analysis use ValueBasedCareAnalyst (SV_VALUE_BASED_CARE - includes providers, patients, encounters, quality_metrics, care_plans tables). For clinical documentation search use ClinicalNotesSearch. For care plan documents and protocols use CarePlansSearch. For policies and guidelines use HealthPoliciesSearch. For readmission predictions use PredictReadmissionRisk. For health outcome predictions use PredictHealthOutcomes. For social risk stratification use StratifySocialRisk."
    system: "You are an expert healthcare intelligence agent for Honor Health, an Arizona-based integrated healthcare delivery system focused on Social Determinants of Health (SDOH) and Value-Based Care. You help analyze patient outcomes, identify social risk factors, track quality metrics, and provide data-driven insights to improve population health. Always prioritize patient privacy and provide actionable clinical insights."
    sample_questions:
      - question: "How many patients do we have in our system?"
        answer: "I'll query the patient data to get the total count of patients."
      - question: "What is the average SDOH risk score for our patients?"
        answer: "I'll calculate the average social determinants of health risk score across all patients."
      - question: "Show me readmission rates by insurance type"
        answer: "I'll analyze 30-day readmission rates grouped by insurance type to identify patterns."
      - question: "Which counties have the highest rates of food insecurity?"
        answer: "I'll aggregate food insecurity data by county to show geographic patterns."
      - question: "What is our HEDIS measure compliance rate?"
        answer: "I'll calculate the percentage of quality measures that meet target thresholds."
      - question: "How do social determinants impact hospital readmissions?"
        answer: "I'll analyze the correlation between SDOH factors like food insecurity and transportation barriers with readmission rates."
      - question: "Compare healthcare costs between patients with and without social risk factors"
        answer: "I'll segment patients by SDOH risk score and compare average healthcare costs to show the impact."
      - question: "Which providers have the best quality scores and lowest readmission rates?"
        answer: "I'll rank providers by quality performance metrics and readmission rates to identify top performers."
      - question: "Show me the relationship between care plan adherence and health outcomes"
        answer: "I'll analyze the correlation between care plan adherence scores and patient health outcome improvements."
      - question: "What is the trend in emergency department utilization by insurance type?"
        answer: "I'll analyze ED visit rates over time segmented by insurance type to identify trends."
      - question: "Predict readmission risk for patients currently in the hospital"
        answer: "I'll use the readmission risk prediction model to analyze current inpatient encounters and provide risk distribution."
      - question: "Which patients are most likely to show health outcome improvement?"
        answer: "I'll use the health outcome predictor to identify patients with high likelihood of improvement."
      - question: "Identify patients with high social risk who need intervention"
        answer: "I'll use the social risk stratification model to identify high-risk patients requiring SDOH interventions."
      - question: "What is the predicted readmission rate for diabetic patients?"
        answer: "I'll filter for diabetes patients and use the readmission predictor to forecast readmission risk."
      - question: "Show me patients with declining health outcomes despite active care plans"
        answer: "I'll combine outcome predictions with care plan data to identify patients who may need care plan adjustments."

  tools:
    # Semantic Views for Cortex Analyst (Text-to-SQL)
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "PatientHealthOutcomesAnalyst"
        description: "Analyzes patient health outcomes, encounters, readmissions, emergency visits, quality metrics, and care performance. Use for questions about patient outcomes, hospital encounters, readmission rates, quality measure compliance, and overall care quality."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "SocialDeterminantsAnalyst"
        description: "Analyzes social determinants of health including employment, income, education, housing, food insecurity, transportation barriers, and their impact on healthcare utilization and costs. Use for questions about SDOH factors, social risk, and how social factors affect health outcomes."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "ValueBasedCareAnalyst"
        description: "Analyzes value-based care performance including provider quality scores, cost per patient, quality measure compliance, care plan effectiveness, and care coordination metrics. Use for questions about provider performance, value-based care metrics, quality improvement, and cost effectiveness."

    # Cortex Search Services
    - tool_spec:
        type: "cortex_search"
        name: "ClinicalNotesSearch"
        description: "Searches unstructured clinical notes and documentation including progress notes, discharge summaries, and care coordination notes. Use when users ask about clinical documentation, SDOH factors mentioned in notes, or specific patient care narratives."

    - tool_spec:
        type: "cortex_search"
        name: "CarePlansSearch"
        description: "Searches care plans, treatment protocols, and SDOH interventions including diabetes management, heart failure care, and chronic disease management plans. Use when users ask about care plans, treatment protocols, or intervention strategies."

    - tool_spec:
        type: "cortex_search"
        name: "HealthPoliciesSearch"
        description: "Searches health policies, clinical guidelines, and care protocols including value-based care standards and quality improvement guidelines. Use when users ask about policies, clinical guidelines, care standards, or best practices."

    # ML Model Functions
    - tool_spec:
        type: "generic"
        name: "PredictReadmissionRisk"
        description: "Predicts 30-day hospital readmission risk for patients. Returns distribution of low risk vs high risk patients. Use when users ask to predict readmissions, assess readmission risk, or identify high-risk patients. Input: encounter type filter (Inpatient Admission, Emergency Department) or NULL for all encounters."
        input_schema:
          type: "object"
          properties:
            encounter_type_filter:
              type: "string"
              description: "Filter by encounter type: Inpatient Admission, Emergency Department, or NULL for all"
          required: []

    - tool_spec:
        type: "generic"
        name: "PredictHealthOutcomes"
        description: "Predicts patient health outcome trajectory (declined, stable, or improved). Returns distribution of outcome predictions. Use when users ask about health outcome predictions, patient improvement likelihood, or outcome forecasts. Input: risk level filter or NULL."
        input_schema:
          type: "object"
          properties:
            risk_level_filter:
              type: "string"
              description: "Filter by risk level: Low Risk, Medium Risk, High Risk, or NULL for all"
          required: []

    - tool_spec:
        type: "generic"
        name: "StratifySocialRisk"
        description: "Stratifies patients by social risk level (low, medium, high) based on SDOH factors. Returns distribution of risk levels. Use when users ask about social risk stratification, SDOH impact, or identifying patients needing social support. Input: number of days to analyze (default 365)."
        input_schema:
          type: "object"
          properties:
            days_back:
              type: "number"
              description: "Number of days to analyze (default 365)"
          required: []

  tool_resources:
    # Semantic View Resources
    PatientHealthOutcomesAnalyst:
      semantic_view: "HONORHEALTH_INTELLIGENCE.ANALYTICS.SV_PATIENT_HEALTH_OUTCOMES"
    
    SocialDeterminantsAnalyst:
      semantic_view: "HONORHEALTH_INTELLIGENCE.ANALYTICS.SV_SOCIAL_DETERMINANTS"
    
    ValueBasedCareAnalyst:
      semantic_view: "HONORHEALTH_INTELLIGENCE.ANALYTICS.SV_VALUE_BASED_CARE"

    # Cortex Search Resources
    ClinicalNotesSearch:
      name: "HONORHEALTH_INTELLIGENCE.RAW.CLINICAL_NOTES_SEARCH"
      max_results: "10"
      title_column: "note_type"
      id_column: "note_id"

    CarePlansSearch:
      name: "HONORHEALTH_INTELLIGENCE.RAW.CARE_PLANS_SEARCH"
      max_results: "10"
      title_column: "plan_type"
      id_column: "care_plan_id"

    HealthPoliciesSearch:
      name: "HONORHEALTH_INTELLIGENCE.RAW.HEALTH_POLICIES_SEARCH"
      max_results: "5"
      title_column: "policy_title"
      id_column: "policy_id"

    # ML Model Function Resources
    PredictReadmissionRisk:
      type: "function"
      identifier: "HONORHEALTH_INTELLIGENCE.ML_MODELS.PREDICT_READMISSION_RISK"
      execution_environment:
        type: "warehouse"
        warehouse: "HONORHEALTH_WH"
        query_timeout: 60

    PredictHealthOutcomes:
      type: "function"
      identifier: "HONORHEALTH_INTELLIGENCE.ML_MODELS.PREDICT_HEALTH_OUTCOMES"
      execution_environment:
        type: "warehouse"
        warehouse: "HONORHEALTH_WH"
        query_timeout: 60

    StratifySocialRisk:
      type: "function"
      identifier: "HONORHEALTH_INTELLIGENCE.ML_MODELS.STRATIFY_SOCIAL_RISK"
      execution_environment:
        type: "warehouse"
        warehouse: "HONORHEALTH_WH"
        query_timeout: 60
  $$;

-- ============================================================================
-- Grant Permissions
-- ============================================================================
GRANT USAGE ON AGENT HONORHEALTH_CARE_AGENT TO ROLE SYSADMIN;
GRANT USAGE ON AGENT HONORHEALTH_CARE_AGENT TO ROLE PUBLIC;

-- ============================================================================
-- Verification
-- ============================================================================
SHOW AGENTS IN SCHEMA ANALYTICS;

DESC AGENT HONORHEALTH_CARE_AGENT;

SELECT 'Honor Health Intelligence Agent created successfully' AS STATUS;

-- ============================================================================
-- Test Agent (Basic Query)
-- ============================================================================

/*
-- Test simple question
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'HONORHEALTH_INTELLIGENCE.ANALYTICS.HONORHEALTH_CARE_AGENT',
  'How many patients do we have in our system?'
);

-- Test complex question
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'HONORHEALTH_INTELLIGENCE.ANALYTICS.HONORHEALTH_CARE_AGENT',
  'How do social determinants impact hospital readmissions?'
);

-- Test ML prediction
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'HONORHEALTH_INTELLIGENCE.ANALYTICS.HONORHEALTH_CARE_AGENT',
  'Predict readmission risk for patients currently hospitalized'
);

-- Test search
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'HONORHEALTH_INTELLIGENCE.ANALYTICS.HONORHEALTH_CARE_AGENT',
  'Find clinical notes mentioning food insecurity'
);
*/

-- ============================================================================
-- Notes
-- ============================================================================
-- The agent has 9 tools configured:
--   - 3 Semantic Views (Cortex Analyst for text-to-SQL)
--   - 3 Cortex Search Services (for unstructured data)
--   - 3 ML Model Functions (for predictions)
--
-- Sample questions are documented in honorhealth_questions.md
-- Setup guide is in HONORHEALTH_SETUP_GUIDE.md
-- ============================================================================

