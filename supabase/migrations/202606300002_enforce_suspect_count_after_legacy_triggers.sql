BEGIN;

-- Hotfix for databases that already ran the first migration while retaining
-- an older trigger that overwrites suspect_count. No rows are deleted and the
-- existing table, uniqueness rules, RLS policies, and JSON storage stay intact.
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
CREATE TRIGGER zzzz_enforce_community_story_suspect_count
BEFORE INSERT OR UPDATE OF story_json, suspect_count
ON public.community_stories
FOR EACH ROW
EXECUTE FUNCTION public.derive_community_story_suspect_count();

-- Replace only the failing count check, inside this transaction, so both its
-- definition and the final trigger value are known to accept 4, 5, and 6.
ALTER TABLE public.community_stories
    DROP CONSTRAINT IF EXISTS community_stories_suspect_count_check;

-- Repair historical zero or stale values while accepting both the released
-- app's JSONB-string shape and a direct JSONB object.
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

ALTER TABLE public.community_stories
    ADD CONSTRAINT community_stories_suspect_count_check
    CHECK (suspect_count BETWEEN 4 AND 6);

-- Abort atomically if any row could not be repaired. A failed transaction
-- leaves production data and definitions exactly as they were.
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
        WHERE stories.suspect_count IS DISTINCT FROM
              jsonb_array_length(normalized.payload -> 'suspects')
    ) THEN
        RAISE EXCEPTION
            'Suspect-count hotfix verification failed; transaction rolled back';
    END IF;
END;
$$;

COMMIT;
