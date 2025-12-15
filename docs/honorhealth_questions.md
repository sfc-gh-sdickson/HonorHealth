<img src="../Snowflake_Logo.svg" width="200">

# Honor Health Intelligence Agent - Sample Questions

This document provides 15 sample questions (5 simple, 5 complex, 5 ML-based) for testing the Honor Health Intelligence Agent.

---

## Simple Questions (Direct Data Queries)

### 1. How many patients do we have in our system?
**Expected**: Total patient count from PATIENTS table  
**Uses**: SV_PATIENT_HEALTH_OUTCOMES semantic view

### 2. What is the average SDOH risk score for our patients?
**Expected**: Average social determinants risk score across all patients  
**Uses**: SV_SOCIAL_DETERMINANTS semantic view

### 3. Show me the readmission rate for this month
**Expected**: Percentage of encounters that resulted in 30-day readmissions  
**Uses**: SV_PATIENT_HEALTH_OUTCOMES semantic view

### 4. Which insurance types have the most patients?
**Expected**: Patient count grouped by insurance type (Medicare, Medicaid, Commercial, etc.)  
**Uses**: SV_VALUE_BASED_CARE semantic view

### 5. What percentage of patients have food insecurity?
**Expected**: Rate of food insecurity among assessed patients  
**Uses**: SV_SOCIAL_DETERMINANTS semantic view

---

## Complex Questions (Multi-Table Analysis)

### 6. How do social determinants impact hospital readmissions?
**Expected**: Analysis showing correlation between SDOH factors (food insecurity, transportation barriers) and readmission rates  
**Uses**: SV_SOCIAL_DETERMINANTS + SV_PATIENT_HEALTH_OUTCOMES semantic views

### 7. Compare healthcare costs between patients with and without social risk factors
**Expected**: Average costs segmented by SDOH risk score levels (low, medium, high)  
**Uses**: SV_SOCIAL_DETERMINANTS semantic view with cost analysis

### 8. Which providers have the best quality scores and lowest readmission rates?
**Expected**: Provider rankings by quality metrics and readmission performance  
**Uses**: SV_VALUE_BASED_CARE semantic view

### 9. Show me the relationship between care plan adherence and health outcomes
**Expected**: Correlation analysis between care plan adherence scores and outcome improvement  
**Uses**: SV_VALUE_BASED_CARE semantic view

### 10. What is the trend in emergency department utilization by county?
**Expected**: ED visit rates over time grouped by geographic region  
**Uses**: SV_PATIENT_HEALTH_OUTCOMES semantic view with geographic segmentation

---

## ML Model Questions (Predictions)

### 11. Predict readmission risk for patients currently hospitalized
**Expected**: Risk distribution showing number/percentage of high-risk vs low-risk patients  
**Uses**: PredictReadmissionRisk ML function

### 12. Which patients are most likely to show health outcome improvement?
**Expected**: Patient count predictions for declined/stable/improved outcomes  
**Uses**: PredictHealthOutcomes ML function

### 13. Identify patients with high social risk who need intervention
**Expected**: Social risk stratification showing distribution of low/medium/high risk patients  
**Uses**: StratifySocialRisk ML function

### 14. What is the predicted readmission rate for diabetic patients?
**Expected**: Readmission risk prediction filtered for diabetes patients, showing risk distribution  
**Uses**: PredictReadmissionRisk ML function + clinical notes search for diabetes cases

### 15. Show me patients with declining health outcomes despite active care plans
**Expected**: Combined analysis using outcome predictor and care plan data to identify patients needing intervention  
**Uses**: PredictHealthOutcomes ML function + SV_VALUE_BASED_CARE semantic view

---

## Testing Instructions

1. **Setup**: Ensure all data generation, views, ML models, and agent are deployed
2. **Execute**: Run each question using `SNOWFLAKE.CORTEX.COMPLETE_AGENT()` function
3. **Verify**: Check that responses include:
   - Accurate data from the semantic views
   - Appropriate use of ML predictions
   - Search results from Cortex Search when relevant
   - Clear explanations of findings

## Expected Data Availability

Based on synthetic data generation:
- **Patients**: 50,000 records
- **SDOH Assessments**: 40,000 records (80% of patients)
- **Encounters**: 80,000 records (including inpatient and ED visits)
- **Quality Metrics**: 60,000 records
- **Health Outcomes**: 50,000 records
- **Clinical Notes**: 30,000 records
- **Care Plans**: 25,000 records
- **Providers**: 500 records

## Coverage Matrix

| Question | Semantic View | Cortex Search | ML Function |
|----------|--------------|---------------|-------------|
| 1-5 | ✓ | | |
| 6-10 | ✓ | | |
| 11 | | | ✓ |
| 12 | | | ✓ |
| 13 | | | ✓ |
| 14 | ✓ | ✓ | ✓ |
| 15 | ✓ | | ✓ |

---

## Notes

- All questions are designed to return valid responses based on generated synthetic data
- Questions span the key use cases: SDOH analysis, value-based care, and health outcomes
- ML predictions are calibrated to provide realistic risk distributions
- Search functionality provides relevant clinical documentation context

