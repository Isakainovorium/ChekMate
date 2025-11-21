-- Migration: Cultural System Evolution - Phase 1
-- Purpose: Add free-form text fields and vector embeddings to cultural profiles
-- Date: November 20, 2025
-- Version: 1.0.0

-- Step 1: Add new columns to cultural_profiles table
ALTER TABLE cultural_profiles 
  -- Free-form text fields
  ADD COLUMN IF NOT EXISTS heritage_description TEXT,
  ADD COLUMN IF NOT EXISTS community_affiliations TEXT[],
  ADD COLUMN IF NOT EXISTS generational_identity TEXT,
  ADD COLUMN IF NOT EXISTS cultural_practices TEXT[],
  ADD COLUMN IF NOT EXISTS cultural_interests_text TEXT[],
  
  -- Vector embeddings (384 dimensions for all-MiniLM-L6-v2 model)
  ADD COLUMN IF NOT EXISTS cultural_vector FLOAT8[384],
  
  -- Pattern discovery fields
  ADD COLUMN IF NOT EXISTS discovered_clusters TEXT[],
  ADD COLUMN IF NOT EXISTS profile_richness DECIMAL(3,2) DEFAULT 0.0,
  
  -- Migration tracking
  ADD COLUMN IF NOT EXISTS migration_status VARCHAR(50) DEFAULT 'enum_only',
  ADD COLUMN IF NOT EXISTS vector_generated_at TIMESTAMP,
  ADD COLUMN IF NOT EXISTS last_vector_update TIMESTAMP;

-- Step 2: Create index for vector similarity search (requires pgvector extension)
-- Note: Ensure pgvector extension is installed first
CREATE EXTENSION IF NOT EXISTS vector;

-- Convert FLOAT8[] to vector type for efficient similarity search
ALTER TABLE cultural_profiles 
  ADD COLUMN IF NOT EXISTS cultural_vector_indexed vector(384);

-- Create index for fast similarity search
CREATE INDEX IF NOT EXISTS idx_cultural_vector_similarity 
  ON cultural_profiles 
  USING ivfflat (cultural_vector_indexed vector_cosine_ops)
  WITH (lists = 100);

-- Step 3: Create migration tracking table
CREATE TABLE IF NOT EXISTS cultural_migration_status (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(255) NOT NULL,
  migration_phase VARCHAR(50) NOT NULL,
  enum_data_backup JSONB,
  free_form_data JSONB,
  vector_data JSONB,
  migration_started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  migration_completed_at TIMESTAMP,
  rollback_available BOOLEAN DEFAULT TRUE,
  status VARCHAR(50) DEFAULT 'pending',
  error_message TEXT,
  UNIQUE(user_id)
);

-- Step 4: Create pattern discovery table
CREATE TABLE IF NOT EXISTS cultural_patterns (
  id SERIAL PRIMARY KEY,
  pattern_id VARCHAR(255) UNIQUE NOT NULL,
  pattern_name VARCHAR(255),
  pattern_description TEXT,
  centroid_vector FLOAT8[384],
  centroid_vector_indexed vector(384),
  member_count INTEGER DEFAULT 0,
  avg_similarity_score DECIMAL(3,2),
  discovered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  pattern_metadata JSONB,
  is_active BOOLEAN DEFAULT TRUE
);

-- Create index for pattern centroids
CREATE INDEX IF NOT EXISTS idx_pattern_centroid_similarity 
  ON cultural_patterns 
  USING ivfflat (centroid_vector_indexed vector_cosine_ops)
  WITH (lists = 10);

-- Step 5: Create location context table for Trace 2
CREATE TABLE IF NOT EXISTS location_contexts (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(255),
  content_id VARCHAR(255),
  raw_location_text TEXT,
  neighborhood TEXT,
  city TEXT,
  region TEXT,
  country TEXT,
  location_vector FLOAT8[384],
  location_vector_indexed vector(384),
  extracted_patterns TEXT[],
  confidence_score DECIMAL(3,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_location_user (user_id),
  INDEX idx_location_content (content_id)
);

-- Create index for location vector similarity
CREATE INDEX IF NOT EXISTS idx_location_vector_similarity 
  ON location_contexts 
  USING ivfflat (location_vector_indexed vector_cosine_ops)
  WITH (lists = 50);

-- Step 6: Create A/B testing configuration table
CREATE TABLE IF NOT EXISTS ab_test_config (
  id SERIAL PRIMARY KEY,
  test_name VARCHAR(255) NOT NULL,
  test_group VARCHAR(50) NOT NULL, -- 'control' (enum) or 'treatment' (ML)
  user_id VARCHAR(255) NOT NULL,
  enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  UNIQUE(test_name, user_id)
);

-- Step 7: Create performance metrics table
CREATE TABLE IF NOT EXISTS cultural_system_metrics (
  id SERIAL PRIMARY KEY,
  metric_type VARCHAR(100) NOT NULL, -- 'vector_generation', 'similarity_search', 'pattern_discovery'
  operation_id VARCHAR(255),
  user_id VARCHAR(255),
  duration_ms INTEGER,
  success BOOLEAN,
  error_message TEXT,
  metadata JSONB,
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_metrics_type_time (metric_type, recorded_at)
);

-- Step 8: Add trigger to update vector when text fields change
CREATE OR REPLACE FUNCTION update_vector_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_vector_update = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_vector_timestamp
  BEFORE UPDATE OF heritage_description, community_affiliations, 
                   generational_identity, cultural_practices, cultural_interests_text
  ON cultural_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_vector_timestamp();

-- Step 9: Create function for cosine similarity calculation
CREATE OR REPLACE FUNCTION cosine_similarity(a FLOAT8[], b FLOAT8[])
RETURNS FLOAT AS $$
DECLARE
  dot_product FLOAT := 0;
  norm_a FLOAT := 0;
  norm_b FLOAT := 0;
  i INTEGER;
BEGIN
  IF array_length(a, 1) != array_length(b, 1) THEN
    RETURN NULL;
  END IF;
  
  FOR i IN 1..array_length(a, 1) LOOP
    dot_product := dot_product + (a[i] * b[i]);
    norm_a := norm_a + (a[i] * a[i]);
    norm_b := norm_b + (b[i] * b[i]);
  END LOOP;
  
  IF norm_a = 0 OR norm_b = 0 THEN
    RETURN 0;
  END IF;
  
  RETURN dot_product / (sqrt(norm_a) * sqrt(norm_b));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Step 10: Create view for migration monitoring
CREATE OR REPLACE VIEW cultural_migration_dashboard AS
SELECT 
  COUNT(*) FILTER (WHERE migration_status = 'enum_only') as enum_only_users,
  COUNT(*) FILTER (WHERE migration_status = 'parallel') as parallel_users,
  COUNT(*) FILTER (WHERE migration_status = 'ml_only') as ml_only_users,
  COUNT(*) FILTER (WHERE migration_status = 'completed') as completed_users,
  AVG(profile_richness) as avg_profile_richness,
  COUNT(*) FILTER (WHERE cultural_vector IS NOT NULL) as users_with_vectors,
  COUNT(DISTINCT unnest(discovered_clusters)) as unique_patterns_discovered
FROM cultural_profiles;

-- Step 11: Grant necessary permissions (adjust based on your user setup)
-- GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO your_app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO your_app_user;

-- Migration rollback script (save separately)
/*
-- ROLLBACK SCRIPT - Save this separately for emergency use
ALTER TABLE cultural_profiles 
  DROP COLUMN IF EXISTS heritage_description,
  DROP COLUMN IF EXISTS community_affiliations,
  DROP COLUMN IF EXISTS generational_identity,
  DROP COLUMN IF EXISTS cultural_practices,
  DROP COLUMN IF EXISTS cultural_interests_text,
  DROP COLUMN IF EXISTS cultural_vector,
  DROP COLUMN IF EXISTS cultural_vector_indexed,
  DROP COLUMN IF EXISTS discovered_clusters,
  DROP COLUMN IF EXISTS profile_richness,
  DROP COLUMN IF EXISTS migration_status,
  DROP COLUMN IF EXISTS vector_generated_at,
  DROP COLUMN IF EXISTS last_vector_update;

DROP TABLE IF EXISTS cultural_migration_status;
DROP TABLE IF EXISTS cultural_patterns;
DROP TABLE IF EXISTS location_contexts;
DROP TABLE IF EXISTS ab_test_config;
DROP TABLE IF EXISTS cultural_system_metrics;
DROP VIEW IF EXISTS cultural_migration_dashboard;
DROP FUNCTION IF EXISTS update_vector_timestamp();
DROP FUNCTION IF EXISTS cosine_similarity(FLOAT8[], FLOAT8[]);
DROP INDEX IF EXISTS idx_cultural_vector_similarity;
DROP INDEX IF EXISTS idx_pattern_centroid_similarity;
DROP INDEX IF EXISTS idx_location_vector_similarity;
*/
