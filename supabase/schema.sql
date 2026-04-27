-- =============================================================
-- Mafioso Community Story Library — Supabase Schema
-- Run this once in the Supabase SQL Editor
-- =============================================================

-- 1. Community Stories table
--    Each story is identified by a SHA-256 content_hash to prevent duplicates.
CREATE TABLE IF NOT EXISTS community_stories (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_hash        TEXT NOT NULL UNIQUE,
    title               TEXT NOT NULL,
    intro               TEXT NOT NULL DEFAULT '',
    crime_description   TEXT NOT NULL DEFAULT '',
    twist               TEXT NOT NULL DEFAULT '',
    killer_name         TEXT NOT NULL DEFAULT '',
    story_json          JSONB NOT NULL,
    uploaded_by_device  TEXT NOT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast deduplication check on upsert
CREATE INDEX IF NOT EXISTS idx_community_stories_content_hash
    ON community_stories (content_hash);

-- 2. Story Ratings table
--    One row per (story, device) pair — upsert on conflict updates the rating.
CREATE TABLE IF NOT EXISTS story_ratings (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    story_id    UUID NOT NULL REFERENCES community_stories(id) ON DELETE CASCADE,
    device_id   TEXT NOT NULL,
    rating      SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    rated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (story_id, device_id)
);

CREATE INDEX IF NOT EXISTS idx_story_ratings_story_id
    ON story_ratings (story_id);

-- 3. View: community_stories_with_ratings
--    Bayesian average rating to prevent 1-vote stories from dominating.
--    Formula: (C * m + sum_ratings) / (C + total_votes)
--    where C = 5 (minimum votes to matter), m = 3.0 (global prior mean)
CREATE OR REPLACE VIEW community_stories_with_ratings AS
WITH rating_stats AS (
    SELECT
        story_id,
        COUNT(*)::INT        AS total_votes,
        AVG(rating)::NUMERIC AS avg_rating
    FROM story_ratings
    GROUP BY story_id
)
SELECT
    s.id,
    s.content_hash,
    s.title,
    s.intro,
    s.crime_description,
    s.twist,
    s.killer_name,
    s.story_json,
    s.uploaded_by_device,
    s.created_at,
    COALESCE(r.total_votes, 0)::INT AS total_votes,
    -- Bayesian average: converges toward 3.0 until 5+ votes arrive
    ROUND(
        (5.0 * 3.0 + COALESCE(r.avg_rating, 0) * COALESCE(r.total_votes, 0))
        / (5.0 + COALESCE(r.total_votes, 0)),
        2
    )::FLOAT AS bayesian_rating
FROM community_stories s
LEFT JOIN rating_stats r ON r.story_id = s.id;

-- 4. Row Level Security (RLS)
--    All users are anonymous — allow read for all, insert/update by anyone.
ALTER TABLE community_stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE story_ratings     ENABLE ROW LEVEL SECURITY;

-- Anyone can read community stories
CREATE POLICY "public_read_stories"  ON community_stories FOR SELECT USING (true);
-- Anyone can upload a story
CREATE POLICY "public_insert_stories" ON community_stories FOR INSERT WITH CHECK (true);

-- Anyone can read ratings
CREATE POLICY "public_read_ratings"  ON story_ratings FOR SELECT USING (true);
-- Anyone can add/update their own device's rating
CREATE POLICY "public_insert_ratings" ON story_ratings FOR INSERT WITH CHECK (true);
CREATE POLICY "public_update_ratings" ON story_ratings FOR UPDATE USING (true);
