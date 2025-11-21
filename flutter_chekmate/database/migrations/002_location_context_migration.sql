-- Migration: Geographic Classification System Evolution - Trace 2
-- Purpose: Add location context fields for ML-driven geographic pattern discovery
-- Date: November 20, 2025
-- Version: 1.0.0

-- Step 1: Add location context to cultural profiles
ALTER TABLE cultural_profiles
  ADD COLUMN IF NOT EXISTS location_latitude DECIMAL(10, 8),
  ADD COLUMN IF NOT EXISTS location_longitude DECIMAL(11, 8),
  ADD COLUMN IF NOT EXISTS location_neighborhood VARCHAR(255),
  ADD COLUMN IF NOT EXISTS location_city VARCHAR(255),
  ADD COLUMN IF NOT EXISTS location_state VARCHAR(255),
  ADD COLUMN IF NOT EXISTS location_country VARCHAR(255),
  ADD COLUMN IF NOT EXISTS location_postal_code VARCHAR(20),
  ADD COLUMN IF NOT EXISTS location_description TEXT,
  ADD COLUMN IF NOT EXISTS location_keywords TEXT[],
  ADD COLUMN IF NOT EXISTS location_extracted_at TIMESTAMP;

-- Step 2: Create discovered location patterns table
CREATE TABLE IF NOT EXISTS discovered_location_patterns (
  id SERIAL PRIMARY KEY,
  pattern_id VARCHAR(255) UNIQUE NOT NULL,
  location VARCHAR(255) NOT NULL,
  user_count INTEGER NOT NULL,
  common_themes TEXT[],
  centroid_vector FLOAT8[384],
  centroid_vector_indexed vector(384),
  discovered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  confidence_score DECIMAL(3,2),
  pattern_metadata JSONB
);

-- Step 3: Create location-based content classification table
CREATE TABLE IF NOT EXISTS content_location_context (
  id SERIAL PRIMARY KEY,
  content_id VARCHAR(255) NOT NULL,
  creator_id VARCHAR(255),
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  neighborhood VARCHAR(255),
  city VARCHAR(255),
  state VARCHAR(255),
  country VARCHAR(255),
  postal_code VARCHAR(20),
  location_description TEXT,
  location_keywords TEXT[],
  cultural_vector FLOAT8[384],
  cultural_vector_indexed vector(384),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_content_location (content_id),
  INDEX idx_creator_location (creator_id),
  INDEX idx_location_city (city),
  INDEX idx_location_country (country)
);

-- Step 4: Create indexes for location-based queries
CREATE INDEX IF NOT EXISTS idx_cultural_profiles_location_city 
  ON cultural_profiles(location_city);

CREATE INDEX IF NOT EXISTS idx_cultural_profiles_location_country 
  ON cultural_profiles(location_country);

CREATE INDEX IF NOT EXISTS idx_cultural_profiles_location_keywords 
  ON cultural_profiles USING GIN(location_keywords);

CREATE INDEX IF NOT EXISTS idx_cultural_profiles_location_coords 
  ON cultural_profiles(location_latitude, location_longitude);

-- Step 5: Create index for location pattern vector similarity
CREATE INDEX IF NOT EXISTS idx_location_pattern_vector_similarity 
  ON discovered_location_patterns 
  USING ivfflat (centroid_vector_indexed vector_cosine_ops)
  WITH (lists = 20);

-- Step 6: Create index for content location vector similarity
CREATE INDEX IF NOT EXISTS idx_content_location_vector_similarity 
  ON content_location_context 
  USING ivfflat (cultural_vector_indexed vector_cosine_ops)
  WITH (lists = 50);

-- Step 7: Create location clustering statistics table
CREATE TABLE IF NOT EXISTS location_clustering_stats (
  id SERIAL PRIMARY KEY,
  clustering_run_id VARCHAR(255) NOT NULL,
  total_profiles INTEGER NOT NULL,
  clusters_discovered INTEGER NOT NULL,
  avg_cluster_size DECIMAL(10,2),
  min_cluster_size INTEGER,
  max_cluster_size INTEGER,
  avg_similarity_score DECIMAL(3,2),
  processing_time_ms INTEGER,
  algorithm_used VARCHAR(50),
  parameters JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 8: Create function to calculate location-based similarity
CREATE OR REPLACE FUNCTION calculate_location_similarity(
  lat1 DECIMAL(10, 8),
  lon1 DECIMAL(11, 8),
  lat2 DECIMAL(10, 8),
  lon2 DECIMAL(11, 8)
)
RETURNS DECIMAL(3,2) AS $$
DECLARE
  distance_km DECIMAL(10,2);
  max_distance_km CONSTANT DECIMAL := 100.0; -- Maximum distance for similarity
BEGIN
  -- Calculate distance using Haversine formula
  distance_km := 6371 * acos(
    cos(radians(lat1)) * cos(radians(lat2)) * 
    cos(radians(lon2) - radians(lon1)) + 
    sin(radians(lat1)) * sin(radians(lat2))
  );
  
  -- Convert distance to similarity score (0-1)
  IF distance_km >= max_distance_km THEN
    RETURN 0.0;
  ELSE
    RETURN 1.0 - (distance_km / max_distance_km);
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Step 9: Create view for location pattern analytics
CREATE OR REPLACE VIEW location_pattern_analytics AS
SELECT 
  dlp.location,
  dlp.user_count,
  dlp.confidence_score,
  array_length(dlp.common_themes, 1) as theme_count,
  dlp.discovered_at,
  COUNT(DISTINCT clc.content_id) as content_count,
  AVG(calculate_location_similarity(
    clc.latitude, clc.longitude,
    cp.location_latitude, cp.location_longitude
  )) as avg_location_cohesion
FROM discovered_location_patterns dlp
LEFT JOIN content_location_context clc ON clc.city = dlp.location
LEFT JOIN cultural_profiles cp ON cp.location_city = dlp.location
WHERE dlp.is_active = TRUE
GROUP BY dlp.location, dlp.user_count, dlp.confidence_score, 
         dlp.common_themes, dlp.discovered_at;

-- Step 10: Create trigger to update location pattern stats
CREATE OR REPLACE FUNCTION update_location_pattern_stats()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_updated = CURRENT_TIMESTAMP;
  
  -- Recalculate user count if needed
  IF TG_OP = 'UPDATE' THEN
    SELECT COUNT(DISTINCT user_id) INTO NEW.user_count
    FROM cultural_profiles
    WHERE location_city = NEW.location;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_location_pattern_stats
  BEFORE UPDATE ON discovered_location_patterns
  FOR EACH ROW
  EXECUTE FUNCTION update_location_pattern_stats();

-- Step 11: Create materialized view for fast location-based matching
CREATE MATERIALIZED VIEW IF NOT EXISTS location_cultural_summary AS
SELECT 
  location_city as city,
  location_state as state,
  location_country as country,
  COUNT(*) as user_count,
  AVG(profile_richness) as avg_profile_richness,
  array_agg(DISTINCT unnest(location_keywords)) as all_keywords,
  percentile_cont(0.5) WITHIN GROUP (ORDER BY location_latitude) as median_lat,
  percentile_cont(0.5) WITHIN GROUP (ORDER BY location_longitude) as median_lon
FROM cultural_profiles
WHERE location_city IS NOT NULL
GROUP BY location_city, location_state, location_country;

-- Create index on materialized view
CREATE INDEX IF NOT EXISTS idx_location_summary_city 
  ON location_cultural_summary(city);

-- Step 12: Grant permissions (adjust based on your user setup)
-- GRANT SELECT, INSERT, UPDATE ON discovered_location_patterns TO your_app_user;
-- GRANT SELECT, INSERT, UPDATE ON content_location_context TO your_app_user;
-- GRANT SELECT, INSERT, UPDATE ON location_clustering_stats TO your_app_user;
-- GRANT SELECT ON location_pattern_analytics TO your_app_user;
-- GRANT SELECT ON location_cultural_summary TO your_app_user;

-- Migration rollback script (save separately)
/*
-- ROLLBACK SCRIPT - Save this separately for emergency use
ALTER TABLE cultural_profiles 
  DROP COLUMN IF EXISTS location_latitude,
  DROP COLUMN IF EXISTS location_longitude,
  DROP COLUMN IF EXISTS location_neighborhood,
  DROP COLUMN IF EXISTS location_city,
  DROP COLUMN IF EXISTS location_state,
  DROP COLUMN IF EXISTS location_country,
  DROP COLUMN IF EXISTS location_postal_code,
  DROP COLUMN IF EXISTS location_description,
  DROP COLUMN IF EXISTS location_keywords,
  DROP COLUMN IF EXISTS location_extracted_at;

DROP TABLE IF EXISTS discovered_location_patterns;
DROP TABLE IF EXISTS content_location_context;
DROP TABLE IF EXISTS location_clustering_stats;
DROP VIEW IF EXISTS location_pattern_analytics;
DROP MATERIALIZED VIEW IF EXISTS location_cultural_summary;
DROP FUNCTION IF EXISTS calculate_location_similarity(DECIMAL, DECIMAL, DECIMAL, DECIMAL);
DROP FUNCTION IF EXISTS update_location_pattern_stats();
DROP TRIGGER IF EXISTS trigger_update_location_pattern_stats ON discovered_location_patterns;
*/
