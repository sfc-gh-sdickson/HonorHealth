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
WITH sdoh_patients AS (
    SELECT patient_id, ROW_NUMBER() OVER (ORDER BY RANDOM()) AS rn
    FROM SOCIAL_DETERMINANTS
)
SELECT
    'ENC' || LPAD(SEQ4()::VARCHAR, 8, '0') AS encounter_id,
    (SELECT patient_id FROM sdoh_patients WHERE rn = MOD(SEQ4(), 40000) + 1) AS patient_id,
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
WITH sdoh_patients AS (
    SELECT patient_id, ROW_NUMBER() OVER (ORDER BY RANDOM()) AS rn
    FROM SOCIAL_DETERMINANTS
)
SELECT
    'QM' || LPAD(SEQ4()::VARCHAR, 8, '0') AS metric_id,
    (SELECT patient_id FROM sdoh_patients WHERE rn = MOD(SEQ4(), 40000) + 1) AS patient_id,
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
WITH sdoh_patients AS (
    SELECT patient_id, ROW_NUMBER() OVER (ORDER BY RANDOM()) AS rn
    FROM SOCIAL_DETERMINANTS
)
SELECT
    'OUT' || LPAD(SEQ4()::VARCHAR, 8, '0') AS outcome_id,
    (SELECT patient_id FROM sdoh_patients WHERE rn = MOD(SEQ4(), 40000) + 1) AS patient_id,
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
WITH sdoh_patients AS (
    SELECT patient_id, ROW_NUMBER() OVER (ORDER BY RANDOM()) AS rn
    FROM SOCIAL_DETERMINANTS
),
enc_pool AS (
    SELECT encounter_id, patient_id, ROW_NUMBER() OVER (ORDER BY RANDOM()) AS rn
    FROM ENCOUNTERS
)
SELECT
    'NOTE' || LPAD(SEQ4()::VARCHAR, 8, '0') AS note_id,
    (SELECT patient_id FROM sdoh_patients WHERE rn = MOD(SEQ4(), 40000) + 1) AS patient_id,
    (SELECT encounter_id FROM enc_pool WHERE rn = MOD(SEQ4(), 80000) + 1) AS encounter_id,
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
WITH sdoh_patients AS (
    SELECT patient_id, ROW_NUMBER() OVER (ORDER BY RANDOM()) AS rn
    FROM SOCIAL_DETERMINANTS
)
SELECT
    'CP' || LPAD(SEQ4()::VARCHAR, 8, '0') AS care_plan_id,
    (SELECT patient_id FROM sdoh_patients WHERE rn = MOD(SEQ4(), 40000) + 1) AS patient_id,
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

