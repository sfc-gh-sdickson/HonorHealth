<img src="Snowflake_Logo.svg" width="200">

# Honor Health Intelligence Agent - Deployment Checklist

Use this checklist to deploy the complete solution step-by-step.

---

##  Pre-Deployment Requirements

- [ ] Snowflake account with ACCOUNTADMIN access
- [ ] MEDIUM or larger warehouse available
- [ ] Snowflake Notebook environment access
- [ ] CORTEX_USER database role granted
- [ ] Estimated 45-60 minutes for complete setup
- [ ] Estimated 20-30 credits for one-time setup

---

##  Deployment Steps

### Phase 1: Foundation Setup (10 minutes)

- [ ] **Step 1**: Execute `sql/setup/honorhealth_01_database_and_schema.sql`
  - Creates: HONORHEALTH_INTELLIGENCE database
  - Creates: RAW, ANALYTICS, ML_MODELS schemas
  - Creates: HONORHEALTH_WH warehouse
  - Verification: `SHOW SCHEMAS IN DATABASE HONORHEALTH_INTELLIGENCE;`

- [ ] **Step 2**: Execute `sql/setup/honorhealth_02_create_tables.sql`
  - Creates: 9 tables with change tracking enabled
  - Verification: `SHOW TABLES IN SCHEMA RAW;` (should show 9 tables)

- [ ] **Step 3**: Execute `sql/data/honorhealth_03_generate_synthetic_data.sql`
  - Generates: ~335,600 rows across all tables
  - Duration: 10-15 minutes on MEDIUM warehouse
  - Verification: Run row count query in script

### Phase 2: Analytics Layer (5 minutes)

- [ ] **Step 4**: Execute `sql/views/honorhealth_04_create_views.sql`
  - Creates: 6 analytical views
  - Creates: 3 ML feature views
  - Verification: `SHOW VIEWS IN SCHEMA ANALYTICS;` (should show 9 views)

- [ ] **Step 5**: Execute `sql/views/honorhealth_05_create_semantic_views.sql`
  - Creates: 3 semantic views (SV_PATIENT_HEALTH_OUTCOMES, SV_SOCIAL_DETERMINANTS, SV_VALUE_BASED_CARE)
  - Verification: `SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;`
  - Test query: `SELECT * FROM SEMANTIC_VIEW(SV_PATIENT_HEALTH_OUTCOMES DIMENSIONS patients.insurance_type METRICS patients.total_patients) LIMIT 10;`

### Phase 3: Search and ML (25 minutes)

- [ ] **Step 6**: Execute `sql/search/honorhealth_06_create_cortex_search.sql`
  - Creates: 3 Cortex Search services
  - Duration: 5-10 minutes (indexing time)
  - Verification: `SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;`
  - Test search: Run sample search query in script

- [ ] **Step 7**: Upload and run ML notebook
  - Upload: `notebooks/honorhealth_ml_models.ipynb` to Snowsight
  - Upload: `notebooks/environment.yml` (if prompted)
  - Configure: Database=HONORHEALTH_INTELLIGENCE, Schema=ANALYTICS, Warehouse=HONORHEALTH_WH
  - Execute: Run all cells (15-20 minutes)
  - Verification: `SHOW MODELS IN SCHEMA ML_MODELS;` (should show 3 models)

- [ ] **Step 8**: Execute `sql/ml/honorhealth_07_ml_model_functions.sql`
  - Creates: 3 ML wrapper functions
  - Verification: `SHOW FUNCTIONS IN SCHEMA ML_MODELS;`
  - Test function: `SELECT PREDICT_READMISSION_RISK(NULL);`

### Phase 4: Agent Deployment (5 minutes)

- [ ] **Step 9**: Execute `sql/agent/honorhealth_08_intelligence_agent.sql`
  - Creates: HONORHEALTH_CARE_AGENT
  - Configures: 9 tools (3 semantic views + 3 search + 3 ML)
  - Verification: `SHOW AGENTS IN SCHEMA ANALYTICS;`
  - Verification: `DESC AGENT HONORHEALTH_CARE_AGENT;`

### Phase 5: Testing (10 minutes)

- [ ] **Step 10**: Test simple questions
  - Question 1: "How many patients do we have in our system?"
  - Question 2: "What is the average SDOH risk score for our patients?"
  - Question 3: "Show me the readmission rate for this month"
  - Question 4: "Which insurance types have the most patients?"
  - Question 5: "What percentage of patients have food insecurity?"

- [ ] **Step 11**: Test complex questions
  - Question 6: "How do social determinants impact hospital readmissions?"
  - Question 7: "Compare healthcare costs between patients with and without social risk factors"
  - Question 8: "Which providers have the best quality scores and lowest readmission rates?"
  - Question 9: "Show me the relationship between care plan adherence and health outcomes"
  - Question 10: "What is the trend in emergency department utilization by county?"

- [ ] **Step 12**: Test ML questions
  - Question 11: "Predict readmission risk for patients currently hospitalized"
  - Question 12: "Which patients are most likely to show health outcome improvement?"
  - Question 13: "Identify patients with high social risk who need intervention"
  - Question 14: "What is the predicted readmission rate for diabetic patients?"
  - Question 15: "Show me patients with declining health outcomes despite active care plans"

---

##  Verification Commands

### Database and Schema
```sql
USE DATABASE HONORHEALTH_INTELLIGENCE;
SHOW SCHEMAS;
-- Expected: RAW, ANALYTICS, ML_MODELS, INFORMATION_SCHEMA, PUBLIC
```

### Tables
```sql
USE SCHEMA RAW;
SHOW TABLES;
-- Expected: 9 tables, all with CHANGE_TRACKING = ON
```

### Data Counts
```sql
SELECT 'PATIENTS' AS table_name, COUNT(*) AS row_count FROM PATIENTS
UNION ALL SELECT 'SOCIAL_DETERMINANTS', COUNT(*) FROM SOCIAL_DETERMINANTS
UNION ALL SELECT 'PROVIDERS', COUNT(*) FROM PROVIDERS
UNION ALL SELECT 'ENCOUNTERS', COUNT(*) FROM ENCOUNTERS
UNION ALL SELECT 'QUALITY_METRICS', COUNT(*) FROM QUALITY_METRICS
UNION ALL SELECT 'HEALTH_OUTCOMES', COUNT(*) FROM HEALTH_OUTCOMES
UNION ALL SELECT 'CLINICAL_NOTES', COUNT(*) FROM CLINICAL_NOTES
UNION ALL SELECT 'CARE_PLANS', COUNT(*) FROM CARE_PLANS
UNION ALL SELECT 'HEALTH_POLICIES', COUNT(*) FROM HEALTH_POLICIES;
-- Expected total: ~335,600 rows
```

### Views
```sql
USE SCHEMA ANALYTICS;
SHOW VIEWS;
-- Expected: 9 views (6 analytical + 3 feature)
```

### Semantic Views
```sql
SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;
-- Expected: 3 semantic views
```

### Cortex Search
```sql
USE SCHEMA RAW;
SHOW CORTEX SEARCH SERVICES;
-- Expected: 3 search services
```

### ML Models
```sql
USE SCHEMA ML_MODELS;
SHOW MODELS;
-- Expected: 3 models
SHOW FUNCTIONS;
-- Expected: 3 functions
```

### Intelligence Agent
```sql
USE SCHEMA ANALYTICS;
SHOW AGENTS;
-- Expected: HONORHEALTH_CARE_AGENT
DESC AGENT HONORHEALTH_CARE_AGENT;
-- Should show 9 tools configured
```

---

##  Troubleshooting

### If Step 1 Fails
- Check ACCOUNTADMIN role access
- Verify database name doesn't already exist
- Check warehouse creation permissions

### If Step 2 Fails
- Verify schemas were created in Step 1
- Check table creation permissions
- Ensure CHANGE_TRACKING can be enabled

### If Step 3 Fails (Data Generation)
- Increase warehouse size to LARGE temporarily
- Check for sufficient compute credits
- Verify foreign key references are valid

### If Step 5 Fails (Semantic Views)
- Ensure all table names are fully qualified
- Verify column names match table definitions exactly
- Check that relationships reference valid primary/foreign keys

### If Step 6 Fails (Cortex Search)
- Verify CHANGE_TRACKING is enabled on source tables
- Check CORTEX_USER role is granted
- Ensure warehouse has capacity for indexing

### If Step 7 Fails (ML Training)
- Verify environment.yml has NO version numbers
- Check feature views return data
- Ensure Python 3.10 runtime selected

### If Step 8 Fails (ML Functions)
- Verify models are registered: `SHOW MODELS;`
- Check feature view column names match model signature
- Ensure models registered with target_platforms=['WAREHOUSE']

### If Step 9 Fails (Agent Creation)
- Verify all semantic views exist
- Check all Cortex Search services are created
- Ensure all ML functions are created
- Validate YAML syntax in agent specification

---

##  Success Criteria

After completing all steps, you should have:

- ✅ 1 Database (HONORHEALTH_INTELLIGENCE)
- ✅ 3 Schemas (RAW, ANALYTICS, ML_MODELS)
- ✅ 1 Warehouse (HONORHEALTH_WH)
- ✅ 9 Tables (with ~335K total rows)
- ✅ 9 Views (6 analytical + 3 feature)
- ✅ 3 Semantic Views
- ✅ 3 Cortex Search Services
- ✅ 3 ML Models
- ✅ 3 ML Functions
- ✅ 1 Intelligence Agent (with 9 tools)

---

##  Post-Deployment

After successful deployment:

1. **Test All Sample Questions**: Use `docs/honorhealth_questions.md`
2. **Monitor Usage**: Check warehouse and Cortex usage
3. **Review Costs**: Monitor credit consumption
4. **User Training**: Educate users on asking questions
5. **Iterate**: Refine based on user feedback

---

##  Support

- **Setup Guide**: `docs/HONORHEALTH_SETUP_GUIDE.md`
- **Sample Questions**: `docs/honorhealth_questions.md`
- **Testing Report**: `docs/TESTING_VALIDATION.md`
- **Project Summary**: `docs/PROJECT_SUMMARY.md`

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Status**: ✅ READY FOR DEPLOYMENT

