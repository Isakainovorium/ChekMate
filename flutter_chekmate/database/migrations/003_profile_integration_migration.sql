-- Migration: User Profile Integration - Trace 3
-- Purpose: Add free-form cultural profile fields for ML-driven matching
-- Date: November 20, 2025
-- Version: 1.0.0

-- Step 1: Add cultural profile fields to users table
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS heritage_description TEXT,
  ADD COLUMN IF NOT EXISTS community_affiliations TEXT[],
  ADD COLUMN IF NOT EXISTS generational_identity TEXT,
  ADD COLUMN IF NOT EXISTS cultural_practices TEXT[],
  ADD COLUMN IF NOT EXISTS cultural_interests TEXT[], -- Now free-form text!
  ADD COLUMN IF NOT EXISTS regional_influence TEXT,
  ADD COLUMN IF NOT EXISTS cultural_vector FLOAT8[384],
  ADD COLUMN IF NOT EXISTS cultural_vector_indexed vector(384),
  ADD COLUMN IF NOT EXISTS discovered_clusters TEXT[],
  ADD COLUMN IF NOT EXISTS affinity_scores JSONB,
  ADD COLUMN IF NOT EXISTS last_vector_update TIMESTAMP,
  ADD COLUMN IF NOT EXISTS profile_richness DECIMAL(3,2),
  ADD COLUMN IF NOT EXISTS profile_migration_status VARCHAR(20) DEFAULT 'legacy',
  ADD COLUMN IF NOT EXISTS legacy_interests TEXT[], -- Keep old enum values during migration
  ADD COLUMN IF NOT EXISTS profile_completeness DECIMAL(3,2);

-- Step 2: Create cultural profiles table (for separate storage if needed)
CREATE TABLE IF NOT EXISTS cultural_profiles (
  id SERIAL PRIMARY KEY,
  profile_id VARCHAR(255) UNIQUE NOT NULL,
  user_id VARCHAR(255) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  heritage_description TEXT,
  community_affiliations TEXT[],
  generational_identity TEXT,
  cultural_practices TEXT[],
  cultural_interests TEXT[],
  regional_influence TEXT,
  cultural_vector FLOAT8[384],
  cultural_vector_indexed vector(384),
  discovered_clusters TEXT[],
  affinity_scores JSONB,
  last_vector_update TIMESTAMP,
  profile_richness DECIMAL(3,2) DEFAULT 0.0,
  profile_migration_status VARCHAR(20) DEFAULT 'free_form',
  legacy_interests TEXT[],
  profile_completeness DECIMAL(3,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_cultural_profile_user (user_id),
  INDEX idx_cultural_profile_richness (profile_richness),
  INDEX idx_cultural_profile_status (profile_migration_status)
);

-- Step 3: Create profile migration tracking table
CREATE TABLE IF NOT EXISTS profile_migration_tracking (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(255) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  migration_started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  migration_completed_at TIMESTAMP,
  original_interests TEXT[],
  converted_interests TEXT[],
  vector_generated BOOLEAN DEFAULT FALSE,
  richness_before DECIMAL(3,2),
  richness_after DECIMAL(3,2),
  migration_status VARCHAR(50),
  error_message TEXT,
  INDEX idx_migration_user (user_id),
  INDEX idx_migration_status (migration_status)
);

-- Step 4: Create cultural affinity scores table
CREATE TABLE IF NOT EXISTS cultural_affinity_scores (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(255) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_user_id VARCHAR(255) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  affinity_score DECIMAL(3,2) NOT NULL,
  vector_similarity DECIMAL(3,2),
  interest_overlap DECIMAL(3,2),
  community_overlap DECIMAL(3,2),
  calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, target_user_id),
  INDEX idx_affinity_user (user_id),
  INDEX idx_affinity_target (target_user_id),
  INDEX idx_affinity_score (affinity_score DESC)
);

-- Step 5: Create discovered cultural clusters table
CREATE TABLE IF NOT EXISTS discovered_cultural_clusters (
  id SERIAL PRIMARY KEY,
  cluster_id VARCHAR(255) UNIQUE NOT NULL,
  cluster_name VARCHAR(255),
  cluster_description TEXT,
  centroid_vector FLOAT8[384],
  centroid_vector_indexed vector(384),
  member_count INTEGER DEFAULT 0,
  common_interests TEXT[],
  common_communities TEXT[],
  common_practices TEXT[],
  avg_profile_richness DECIMAL(3,2),
  confidence_score DECIMAL(3,2),
  discovered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  metadata JSONB
);

-- Step 6: Create cluster membership table
CREATE TABLE IF NOT EXISTS cluster_memberships (
  id SERIAL PRIMARY KEY,
  cluster_id VARCHAR(255) REFERENCES discovered_cultural_clusters(cluster_id) ON DELETE CASCADE,
  user_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
  similarity_to_centroid DECIMAL(3,2),
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(cluster_id, user_id),
  INDEX idx_membership_cluster (cluster_id),
  INDEX idx_membership_user (user_id)
);

-- Step 7: Create indexes for vector similarity search
CREATE INDEX IF NOT EXISTS idx_cultural_profile_vector_similarity 
  ON cultural_profiles 
  USING ivfflat (cultural_vector_indexed vector_cosine_ops)
  WITH (lists = 100);

CREATE INDEX IF NOT EXISTS idx_user_cultural_vector_similarity 
  ON users 
  USING ivfflat (cultural_vector_indexed vector_cosine_ops)
  WITH (lists = 100);

CREATE INDEX IF NOT EXISTS idx_cluster_centroid_similarity 
  ON discovered_cultural_clusters 
  USING ivfflat (centroid_vector_indexed vector_cosine_ops)
  WITH (lists = 20);

-- Step 8: Create function to calculate profile richness
CREATE OR REPLACE FUNCTION calculate_profile_richness(
  heritage_desc TEXT,
  communities TEXT[],
  generation TEXT,
  practices TEXT[],
  interests TEXT[]
)
RETURNS DECIMAL(3,2) AS $$
DECLARE
  richness DECIMAL(3,2) := 0.0;
  text_score DECIMAL(3,2);
BEGIN
  -- Heritage description (25% weight)
  IF heritage_desc IS NOT NULL AND LENGTH(heritage_desc) > 0 THEN
    text_score := LEAST(1.0, LENGTH(heritage_desc) / 200.0);
    richness := richness + (0.25 * text_score);
  END IF;
  
  -- Community affiliations (20% weight)
  IF communities IS NOT NULL AND array_length(communities, 1) > 0 THEN
    richness := richness + (0.20 * LEAST(1.0, array_length(communities, 1) / 5.0));
  END IF;
  
  -- Generational identity (15% weight)
  IF generation IS NOT NULL AND LENGTH(generation) > 0 THEN
    text_score := LEAST(1.0, LENGTH(generation) / 100.0);
    richness := richness + (0.15 * text_score);
  END IF;
  
  -- Cultural practices (20% weight)
  IF practices IS NOT NULL AND array_length(practices, 1) > 0 THEN
    richness := richness + (0.20 * LEAST(1.0, array_length(practices, 1) / 5.0));
  END IF;
  
  -- Cultural interests (20% weight)
  IF interests IS NOT NULL AND array_length(interests, 1) > 0 THEN
    richness := richness + (0.20 * LEAST(1.0, array_length(interests, 1) / 5.0));
  END IF;
  
  RETURN LEAST(1.0, richness);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Step 9: Create trigger to update profile richness
CREATE OR REPLACE FUNCTION update_profile_richness()
RETURNS TRIGGER AS $$
BEGIN
  NEW.profile_richness := calculate_profile_richness(
    NEW.heritage_description,
    NEW.community_affiliations,
    NEW.generational_identity,
    NEW.cultural_practices,
    NEW.cultural_interests
  );
  
  -- Calculate completeness
  NEW.profile_completeness := (
    CASE WHEN NEW.heritage_description IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN array_length(NEW.community_affiliations, 1) > 0 THEN 1 ELSE 0 END +
    CASE WHEN NEW.generational_identity IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN array_length(NEW.cultural_practices, 1) > 0 THEN 1 ELSE 0 END +
    CASE WHEN array_length(NEW.cultural_interests, 1) > 0 THEN 1 ELSE 0 END +
    CASE WHEN NEW.regional_influence IS NOT NULL THEN 1 ELSE 0 END
  ) / 6.0;
  
  NEW.updated_at := CURRENT_TIMESTAMP;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_cultural_profile_richness
  BEFORE INSERT OR UPDATE ON cultural_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_richness();

CREATE TRIGGER trigger_update_user_profile_richness
  BEFORE UPDATE ON users
  FOR EACH ROW
  WHEN (
    OLD.heritage_description IS DISTINCT FROM NEW.heritage_description OR
    OLD.community_affiliations IS DISTINCT FROM NEW.community_affiliations OR
    OLD.generational_identity IS DISTINCT FROM NEW.generational_identity OR
    OLD.cultural_practices IS DISTINCT FROM NEW.cultural_practices OR
    OLD.cultural_interests IS DISTINCT FROM NEW.cultural_interests
  )
  EXECUTE FUNCTION update_profile_richness();

-- Step 10: Create view for profile analytics
CREATE OR REPLACE VIEW cultural_profile_analytics AS
SELECT 
  u.id as user_id,
  u.display_name,
  u.profile_richness,
  u.profile_completeness,
  u.profile_migration_status,
  array_length(u.community_affiliations, 1) as community_count,
  array_length(u.cultural_interests, 1) as interest_count,
  array_length(u.cultural_practices, 1) as practice_count,
  array_length(u.discovered_clusters, 1) as cluster_count,
  CASE 
    WHEN u.cultural_vector IS NOT NULL THEN TRUE 
    ELSE FALSE 
  END as has_vector,
  u.last_vector_update,
  u.created_at,
  u.updated_at
FROM users u
WHERE u.cultural_interests IS NOT NULL 
   OR u.legacy_interests IS NOT NULL;

-- Step 11: Create materialized view for interest patterns
CREATE MATERIALIZED VIEW IF NOT EXISTS interest_patterns AS
SELECT 
  interest,
  COUNT(*) as user_count,
  AVG(profile_richness) as avg_richness
FROM users u, unnest(u.cultural_interests) as interest
WHERE interest IS NOT NULL
GROUP BY interest
HAVING COUNT(*) >= 5
ORDER BY user_count DESC;

-- Create index on materialized view
CREATE INDEX IF NOT EXISTS idx_interest_patterns_count 
  ON interest_patterns(user_count DESC);

-- Step 12: Grant permissions (adjust based on your user setup)
-- GRANT SELECT, INSERT, UPDATE ON cultural_profiles TO your_app_user;
-- GRANT SELECT, INSERT, UPDATE ON profile_migration_tracking TO your_app_user;
-- GRANT SELECT, INSERT, UPDATE ON cultural_affinity_scores TO your_app_user;
-- GRANT SELECT, INSERT, UPDATE ON discovered_cultural_clusters TO your_app_user;
-- GRANT SELECT, INSERT, UPDATE ON cluster_memberships TO your_app_user;
-- GRANT SELECT ON cultural_profile_analytics TO your_app_user;
-- GRANT SELECT ON interest_patterns TO your_app_user;

-- Migration rollback script (save separately)
/*
-- ROLLBACK SCRIPT - Save this separately for emergency use
ALTER TABLE users 
  DROP COLUMN IF EXISTS heritage_description,
  DROP COLUMN IF EXISTS community_affiliations,
  DROP COLUMN IF EXISTS generational_identity,
  DROP COLUMN IF EXISTS cultural_practices,
  DROP COLUMN IF EXISTS cultural_interests,
  DROP COLUMN IF EXISTS regional_influence,
  DROP COLUMN IF EXISTS cultural_vector,
  DROP COLUMN IF EXISTS cultural_vector_indexed,
  DROP COLUMN IF EXISTS discovered_clusters,
  DROP COLUMN IF EXISTS affinity_scores,
  DROP COLUMN IF EXISTS last_vector_update,
  DROP COLUMN IF EXISTS profile_richness,
  DROP COLUMN IF EXISTS profile_migration_status,
  DROP COLUMN IF EXISTS legacy_interests,
  DROP COLUMN IF EXISTS profile_completeness;

DROP TABLE IF EXISTS cultural_profiles CASCADE;
DROP TABLE IF EXISTS profile_migration_tracking CASCADE;
DROP TABLE IF EXISTS cultural_affinity_scores CASCADE;
DROP TABLE IF EXISTS discovered_cultural_clusters CASCADE;
DROP TABLE IF EXISTS cluster_memberships CASCADE;
DROP VIEW IF EXISTS cultural_profile_analytics;
DROP MATERIALIZED VIEW IF EXISTS interest_patterns;
DROP FUNCTION IF EXISTS calculate_profile_richness(TEXT, TEXT[], TEXT, TEXT[], TEXT[]);
DROP FUNCTION IF EXISTS update_profile_richness();
DROP TRIGGER IF EXISTS trigger_update_cultural_profile_richness ON cultural_profiles;
DROP TRIGGER IF EXISTS trigger_update_user_profile_richness ON users;
*/
