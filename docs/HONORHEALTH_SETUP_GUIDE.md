<img src="../Snowflake_Logo.svg" width="200">

# Honor Health Intelligence Agent - Complete Setup Guide

**Step-by-Step Instructions for Deployment**

---

##  Prerequisites

### Required Access
- ✅ Snowflake account with ACCOUNTADMIN role
- ✅ Warehouse (MEDIUM or larger recommended)
- ✅ Snowflake Notebook environment access
- ✅ CORTEX_USER database role granted

### Estimated Time
- **Total Setup**: 45-60 minutes
- Database setup: 5 minutes
- Data generation: 10-15 minutes
- ML model training: 15-20 minutes
- Agent configuration: 5 minutes
- Testing: 10 minutes

### Cost Estimate
- **One-time setup**: ~20-30 credits (MEDIUM warehouse)
- **Ongoing**: ~5-10 credits/month (depends on query volume)

---

##  Step-by-Step Setup

### Step 1: Database and Schema Setup (5 minutes)

**File**: `honorhealth_01_database_and_schema.sql`

```bash
# Execute in Snowsight or CLI
snow sql -f honorhealth_01_database_and_schema.sql
```

**What it creates:**
- Database: `HONORHEALTH_INTELLIGENCE`
- Schemas: `RAW`, `ANALYTICS`, `ML_MODELS`
- Warehouse: `HONORHEALTH_WH` (MEDIUM, auto-suspend 5min)

**Verification:**
```sql
USE DATABASE HONORHEALTH_INTELLIGENCE;
SHOW SCHEMAS;
-- Should see: RAW, ANALYTICS, ML_MODELS
```

---

### Step 2: Create Tables (2 minutes)

**File**: `honorhealth_02_create_tables.sql`

```bash
snow sql -f honorhealth_02_create_tables.sql
```

**What it creates:**
1. PATIENTS (50,000 rows planned)
2. SOCIAL_DETERMINANTS (40,000 rows planned)
3. PROVIDERS (500 rows planned)
4. ENCOUNTERS (80,000 rows planned)
5. QUALITY_METRICS (60,000 rows planned)
6. HEALTH_OUTCOMES (50,000 rows planned)
7. CLINICAL_NOTES (30,000 rows planned)
8. CARE_PLANS (25,000 rows planned)
9. HEALTH_POLICIES (100 rows planned)

**Verification:**
```sql
USE SCHEMA RAW;
SHOW TABLES;
-- Should see all 9 tables with CHANGE_TRACKING = ON
```

---

### Step 3: Generate Synthetic Data (10-15 minutes)

**File**: `honorhealth_03_generate_synthetic_data.sql`

⚠️ **IMPORTANT**: This step takes 10-15 minutes on MEDIUM warehouse.

```bash
# Increase warehouse size for faster generation (optional)
ALTER WAREHOUSE HONORHEALTH_WH SET WAREHOUSE_SIZE = 'LARGE';

# Run data generation
snow sql -f honorhealth_03_generate_synthetic_data.sql

# Return to MEDIUM
ALTER WAREHOUSE HONORHEALTH_WH SET WAREHOUSE_SIZE = 'MEDIUM';
```

**What it generates:**
- 50,000 patients with demographics across Arizona
- 40,000 SDOH assessments with risk factors
- 500 healthcare providers across Honor Health facilities
- 80,000 encounters (primary care, ED, inpatient, specialist)
- 60,000 quality metrics (HEDIS measures)
- 50,000 health outcomes with improvement tracking
- 30,000 clinical notes (unstructured)
- 25,000 care plans with SDOH interventions
- 100 health policies and guidelines

**Verification:**
```sql
-- Check row counts
SELECT 'PATIENTS' AS table_name, COUNT(*) AS row_count FROM PATIENTS
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
```

Expected total: **~335,600 rows**

---

### Step 4: Create Analytical and Feature Views (2 minutes)

**File**: `honorhealth_04_create_views.sql`

```bash
snow sql -f honorhealth_04_create_views.sql
```

**What it creates:**
- 6 analytical views (for reporting)
- 3 ML feature views (for model training)

**Analytical Views:**
1. `V_PATIENT_SUMMARY` - Patient demographics and utilization
2. `V_ENCOUNTER_DETAILS` - Detailed encounter information
3. `V_QUALITY_PERFORMANCE` - Quality measure performance
4. `V_SDOH_IMPACT_ANALYSIS` - SDOH impact on outcomes
5. `V_CARE_PLAN_EFFECTIVENESS` - Care plan outcomes
6. `V_PROVIDER_PERFORMANCE` - Provider quality metrics

**ML Feature Views:**
1. `V_READMISSION_RISK_FEATURES` - Features for readmission prediction
2. `V_HEALTH_OUTCOME_PREDICTION_FEATURES` - Features for outcome prediction
3. `V_SOCIAL_RISK_STRATIFICATION_FEATURES` - Features for risk stratification

**Verification:**
```sql
USE SCHEMA ANALYTICS;
SHOW VIEWS;
-- Should see 9 views total
```

---

### Step 5: Train ML Models (15-20 minutes)

**File**: `honorhealth_ml_models.ipynb`

1. **Upload Notebook to Snowflake:**
   - In Snowsight, go to **Projects** → **Notebooks**
   - Click **+ Notebook** → **Import .ipynb file**
   - Upload `honorhealth_ml_models.ipynb`
   - Upload `environment.yml` if prompted

2. **Configure Notebook:**
   - Database: `HONORHEALTH_INTELLIGENCE`
   - Schema: `ANALYTICS`
   - Warehouse: `HONORHEALTH_WH`

3. **Run All Cells:**
   - Click **Run All** or execute cells sequentially
   - Wait 15-20 minutes for training

**Models Created:**
1. `READMISSION_RISK_PREDICTOR` - Predicts 30-day readmission risk (2 classes)
2. `HEALTH_OUTCOME_PREDICTOR` - Predicts health outcomes (3 classes)
3. `SOCIAL_RISK_STRATIFICATION` - Stratifies social risk (3 classes)

**Verification:**
```sql
USE SCHEMA ML_MODELS;
SHOW MODELS;
-- Should see 3 models registered
```

---

### Step 6: Create Semantic Views (2 minutes)

**File**: `honorhealth_05_create_semantic_views.sql`

⚠️ **CRITICAL**: Syntax has been verified against Snowflake documentation.

```bash
snow sql -f honorhealth_05_create_semantic_views.sql
```

**What it creates:**
1. `SV_PATIENT_HEALTH_OUTCOMES` - Patient outcomes and care quality
2. `SV_SOCIAL_DETERMINANTS` - SDOH factors and impact
3. `SV_VALUE_BASED_CARE` - Value-based care performance

**Verification:**
```sql
USE SCHEMA ANALYTICS;
SHOW SEMANTIC VIEWS;
-- Should see 3 semantic views

-- Test a semantic view
SELECT * FROM SEMANTIC_VIEW(
  SV_PATIENT_HEALTH_OUTCOMES
  DIMENSIONS patients.insurance_type
  METRICS encounters.total_encounters, encounters.readmission_rate
) LIMIT 10;
```

---

### Step 7: Create Cortex Search Services (5-10 minutes)

**File**: `honorhealth_06_create_cortex_search.sql`

```bash
snow sql -f honorhealth_06_create_cortex_search.sql
```

**What it creates:**
1. `CLINICAL_NOTES_SEARCH` - Search clinical documentation
2. `CARE_PLANS_SEARCH` - Search care plans and interventions
3. `HEALTH_POLICIES_SEARCH` - Search policies and guidelines

**Verification:**
```sql
USE SCHEMA RAW;
SHOW CORTEX SEARCH SERVICES;
-- Should see 3 search services

-- Test a search service
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'HONORHEALTH_INTELLIGENCE.RAW.CLINICAL_NOTES_SEARCH',
    '{
      "query": "diabetes management",
      "columns": ["note_text", "note_type"],
      "limit": 3
    }'
  )
)['results'];
```

---

### Step 8: Create ML Model Wrapper Functions (2 minutes)

**File**: `honorhealth_07_ml_model_functions.sql`

```bash
snow sql -f honorhealth_07_ml_model_functions.sql
```

**What it creates:**
1. `PREDICT_READMISSION_RISK(encounter_type_filter VARCHAR)` - SQL function
2. `PREDICT_HEALTH_OUTCOMES(risk_level_filter VARCHAR)` - SQL function
3. `STRATIFY_SOCIAL_RISK(days_back NUMBER)` - SQL function

**Verification:**
```sql
USE SCHEMA ML_MODELS;
SHOW FUNCTIONS;
-- Should see 3 functions

-- Test a function
SELECT PREDICT_READMISSION_RISK(NULL);
-- Should return JSON with risk predictions
```

---

### Step 9: Create Intelligence Agent (3 minutes)

**File**: `honorhealth_08_intelligence_agent.sql`

```bash
snow sql -f honorhealth_08_intelligence_agent.sql
```

**What it creates:**
- Snowflake Intelligence Agent: `HONORHEALTH_CARE_AGENT`
- Configured with:
  - 3 semantic views (for Cortex Analyst)
  - 3 Cortex Search services
  - 3 ML model tools

**Verification:**
```sql
SHOW AGENTS IN SCHEMA ANALYTICS;
-- Should see HONORHEALTH_CARE_AGENT

DESC AGENT HONORHEALTH_CARE_AGENT;
-- Review agent configuration
```

---

### Step 10: Test the Agent (10 minutes)

**Test Simple Questions:**
```sql
-- Ask the agent a question
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'HONORHEALTH_CARE_AGENT',
  'How many patients do we have in our system?'
);
```

**Test Complex Questions:**
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'HONORHEALTH_CARE_AGENT',
  'How do social determinants impact hospital readmissions?'
);
```

**Test ML Model Questions:**
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
  'HONORHEALTH_CARE_AGENT',
  'Predict readmission risk for patients currently hospitalized'
);
```

Refer to `honorhealth_questions.md` for all 15 sample questions.

---

##  Deployment Checklist

Use this checklist to track your progress:

- [ ] Step 1: Database and schemas created
- [ ] Step 2: All 9 tables created with change tracking
- [ ] Step 3: Synthetic data generated (~336K rows)
- [ ] Step 4: 9 views created (6 analytical + 3 feature)
- [ ] Step 5: 3 ML models trained and registered
- [ ] Step 6: 3 semantic views created
- [ ] Step 7: 3 Cortex Search services created
- [ ] Step 8: 3 ML wrapper functions created
- [ ] Step 9: Intelligence Agent configured
- [ ] Step 10: Agent tested with sample questions

---

##  Troubleshooting

### Issue: Semantic View Creation Fails
**Error**: "Syntax error" or "Invalid identifier"

**Solution**:
1. Verify all table names match exactly (case-sensitive)
2. Check that column names in DIMENSIONS/METRICS exist in base tables
3. Ensure RELATIONSHIPS reference correct primary/foreign keys

### Issue: Cortex Search Service Fails
**Error**: "Change tracking not enabled"

**Solution**:
```sql
-- Enable change tracking on tables
ALTER TABLE CLINICAL_NOTES SET CHANGE_TRACKING = TRUE;
ALTER TABLE CARE_PLANS SET CHANGE_TRACKING = TRUE;
ALTER TABLE HEALTH_POLICIES SET CHANGE_TRACKING = TRUE;
```

### Issue: ML Model Training Fails
**Error**: "Package not found" or "Import error"

**Solution**:
1. Ensure notebook uses correct Python runtime (3.10)
2. Verify environment.yml has NO version numbers (per lessons learned)
3. Check feature view exists and returns data

### Issue: Model Wrapper Function Fails
**Error**: "Model not found" or "No data returned"

**Solution**:
1. Verify model is registered: `SHOW MODELS IN SCHEMA ML_MODELS;`
2. Check feature view has data: `SELECT * FROM V_READMISSION_RISK_FEATURES LIMIT 10;`
3. Ensure model was registered with `target_platforms=['WAREHOUSE']`

---

##  Monitoring and Maintenance

### Monitor Warehouse Usage
```sql
-- View credit consumption
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME = 'HONORHEALTH_WH'
  AND START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC;
```

### Monitor Agent Usage
```sql
-- View agent query history
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_ANALYST_USAGE_HISTORY
WHERE START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC;
```

### Monitor Cortex Search Usage
```sql
-- View search service usage
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_SEARCH_DAILY_USAGE_HISTORY
WHERE USAGE_DATE >= DATEADD(day, -7, CURRENT_DATE())
ORDER BY USAGE_DATE DESC;
```

---

##  Next Steps

1. **Customize Semantic Views**: Add more dimensions/metrics specific to your use case
2. **Enhance ML Models**: Retrain with production data and tune hyperparameters
3. **Add More Search Services**: Index additional unstructured data sources
4. **Build Applications**: Create Streamlit apps or integrate with business tools
5. **Production Deployment**: Configure RBAC, monitoring, and alerts

---

##  Support Resources

- **Snowflake Documentation**: https://docs.snowflake.com
- **Cortex Analyst Guide**: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst
- **Cortex Search Guide**: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search
- **Model Registry**: https://docs.snowflake.com/en/developer-guide/snowpark-ml/model-registry

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Estimated Setup Time**: 45-60 minutes  
**Estimated Cost**: 20-30 credits (one-time setup)

