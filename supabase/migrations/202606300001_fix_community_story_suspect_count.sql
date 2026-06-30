BEGIN;

-- Backward-compatible production migration:
-- * does not delete community stories or ratings;
-- * preserves the existing content-hash uniqueness contract;
-- * preserves string-encoded story_json used by released app versions.

-- The story JSON is the source of truth. Add the column for installations
-- created from the original schema, without preserving the unsafe zero default.
ALTER TABLE public.community_stories
    ADD COLUMN IF NOT EXISTS suspect_count SMALLINT;

ALTER TABLE public.community_stories
    ALTER COLUMN suspect_count DROP DEFAULT;

-- Stop with an actionable error instead of converting malformed historical
-- stories into another invalid count.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM public.community_stories AS stories
        CROSS JOIN LATERAL (
            SELECT CASE jsonb_typeof(stories.story_json)
                WHEN 'string' THEN (stories.story_json #>> '{}')::JSONB
                WHEN 'object' THEN stories.story_json
                ELSE NULL
            END AS payload
        ) AS normalized
        WHERE jsonb_typeof(normalized.payload -> 'suspects')
                  IS DISTINCT FROM 'array'
           OR jsonb_array_length(normalized.payload -> 'suspects')
                  NOT BETWEEN 4 AND 6
    ) THEN
        RAISE EXCEPTION
            'Cannot migrate community_stories: story_json.suspects must contain 4 to 6 items';
    END IF;
END;
$$;

UPDATE public.community_stories
SET suspect_count = jsonb_array_length(
    (
        CASE jsonb_typeof(story_json)
            WHEN 'string' THEN (story_json #>> '{}')::JSONB
            ELSE story_json
        END
    ) -> 'suspects'
)
WHERE suspect_count IS DISTINCT FROM jsonb_array_length(
    (
        CASE jsonb_typeof(story_json)
            WHEN 'string' THEN (story_json #>> '{}')::JSONB
            ELSE story_json
        END
    ) -> 'suspects'
);

CREATE OR REPLACE FUNCTION public.derive_community_story_suspect_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
    payload JSONB;
    derived_count INTEGER;
BEGIN
    IF jsonb_typeof(NEW.story_json) = 'string' THEN
        payload := (NEW.story_json #>> '{}')::JSONB;
    ELSE
        payload := NEW.story_json;
    END IF;

    IF jsonb_typeof(payload -> 'suspects') IS DISTINCT FROM 'array' THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514',
            MESSAGE = 'story_json.suspects must be an array';
    END IF;

    derived_count := jsonb_array_length(payload -> 'suspects');
    IF derived_count NOT BETWEEN 4 AND 6 THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514',
            MESSAGE = 'story_json.suspects must contain 4 to 6 items';
    END IF;

    NEW.suspect_count := derived_count;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS derive_community_story_suspect_count
    ON public.community_stories;
DROP TRIGGER IF EXISTS zzzz_enforce_community_story_suspect_count
    ON public.community_stories;
-- PostgreSQL executes equivalent triggers alphabetically. The zzzz prefix
-- ensures this compatibility trigger corrects values written by legacy
-- suspect-count triggers before constraints are evaluated.
CREATE TRIGGER zzzz_enforce_community_story_suspect_count
BEFORE INSERT OR UPDATE OF story_json, suspect_count
ON public.community_stories
FOR EACH ROW
EXECUTE FUNCTION public.derive_community_story_suspect_count();

ALTER TABLE public.community_stories
    ALTER COLUMN suspect_count SET NOT NULL;

ALTER TABLE public.community_stories
    DROP CONSTRAINT IF EXISTS community_stories_suspect_count_check;
ALTER TABLE public.community_stories
    ADD CONSTRAINT community_stories_suspect_count_check
    CHECK (suspect_count BETWEEN 4 AND 6);

-- Keep the view contract used by the Flutter community-library mapper and
-- server-side count filter. Recreate it because PostgreSQL cannot safely
-- reorder or rename existing view columns with CREATE OR REPLACE VIEW.
DROP VIEW IF EXISTS public.community_stories_with_ratings;
CREATE VIEW public.community_stories_with_ratings AS
WITH rating_stats AS (
    SELECT
        story_id,
        COUNT(*)::INT AS total_votes,
        AVG(rating)::NUMERIC AS avg_rating
    FROM public.story_ratings
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
    ROUND(
        (5.0 * 3.0 + COALESCE(r.avg_rating, 0) * COALESCE(r.total_votes, 0))
        / (5.0 + COALESCE(r.total_votes, 0)),
        2
    )::FLOAT AS bayesian_rating,
    s.language_code,
    s.suspect_count
FROM public.community_stories AS s
LEFT JOIN rating_stats AS r ON r.story_id = s.id;

GRANT SELECT ON public.community_stories_with_ratings TO anon, authenticated;

COMMIT;
