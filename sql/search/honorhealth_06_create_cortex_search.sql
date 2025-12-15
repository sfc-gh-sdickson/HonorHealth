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

