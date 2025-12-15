-- ============================================================================
-- Honor Health Intelligence Agent - Database and Schema Setup
-- ============================================================================
-- Purpose: Initialize database, schemas, and warehouse for Honor Health
-- Focus: Social Determinants of Health (SDOH) and Value-Based Care
-- ============================================================================

-- ============================================================================
-- Step 1: Create Database
-- ============================================================================
CREATE DATABASE IF NOT EXISTS HONORHEALTH_INTELLIGENCE
  COMMENT = 'Honor Health Intelligence Agent - SDOH and Value-Based Care Analytics';

USE DATABASE HONORHEALTH_INTELLIGENCE;

-- ============================================================================
-- Step 2: Create Schemas
-- ============================================================================

-- RAW schema: Source tables with change tracking enabled
CREATE SCHEMA IF NOT EXISTS RAW
  COMMENT = 'Raw patient, encounter, and clinical data tables';

-- ANALYTICS schema: Analytical views, semantic views, and feature engineering
CREATE SCHEMA IF NOT EXISTS ANALYTICS
  COMMENT = 'Analytical views, semantic views, and aggregated metrics';

-- ML_MODELS schema: Machine learning models and prediction functions
CREATE SCHEMA IF NOT EXISTS ML_MODELS
  COMMENT = 'ML models for readmission, outcomes, and social risk prediction';

-- ============================================================================
-- Step 3: Create Warehouse
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS HONORHEALTH_WH
  WITH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for Honor Health analytics and ML workloads';

-- ============================================================================
-- Step 4: Set Context
-- ============================================================================
USE DATABASE HONORHEALTH_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE HONORHEALTH_WH;

-- ============================================================================
-- Step 5: Create Roles and Grant Permissions
-- ============================================================================
-- Grant database usage to SYSADMIN
GRANT USAGE ON DATABASE HONORHEALTH_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON ALL SCHEMAS IN DATABASE HONORHEALTH_INTELLIGENCE TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAW TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ANALYTICS TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ML_MODELS TO ROLE SYSADMIN;
GRANT USAGE ON WAREHOUSE HONORHEALTH_WH TO ROLE SYSADMIN;

-- ============================================================================
-- Verification
-- ============================================================================
SELECT 'Database created: HONORHEALTH_INTELLIGENCE' AS status;
SHOW SCHEMAS IN DATABASE HONORHEALTH_INTELLIGENCE;
SHOW WAREHOUSES LIKE 'HONORHEALTH_WH';

-- ============================================================================
-- Summary
-- ============================================================================
/*
Created:
- Database: HONORHEALTH_INTELLIGENCE
- Schemas: RAW, ANALYTICS, ML_MODELS
- Warehouse: HONORHEALTH_WH (MEDIUM, auto-suspend 5min)

Next Step: Run honorhealth_02_create_tables.sql
*/

