BEGIN;

-- Enable pgcrypto for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Rooms
CREATE TABLE IF NOT EXISTS public.rooms (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code                CHAR(6) NOT NULL,
    name                TEXT NOT NULL,
    host_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    password_hash       TEXT,
    status              TEXT NOT NULL DEFAULT 'waiting',
    selected_story_id   UUID REFERENCES public.community_stories(id),
    game_mode           TEXT,
    max_players         SMALLINT NOT NULL DEFAULT 8,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at          TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '4 hours')
);

-- Unique code for active rooms
CREATE UNIQUE INDEX IF NOT EXISTS idx_rooms_code_active 
    ON public.rooms(code) 
    WHERE status IN ('waiting', 'starting', 'playing');

CREATE INDEX IF NOT EXISTS idx_rooms_expires_at 
    ON public.rooms(expires_at);

-- Function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_rooms_modtime
    BEFORE UPDATE ON public.rooms
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- 2. Room Members
CREATE TABLE IF NOT EXISTS public.room_members (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id             UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name        TEXT NOT NULL,
    joined_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_online           BOOLEAN NOT NULL DEFAULT true,
    mic_enabled         BOOLEAN NOT NULL DEFAULT false,
    UNIQUE(room_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_room_members_room_id 
    ON public.room_members(room_id);
CREATE INDEX IF NOT EXISTS idx_room_members_user_id 
    ON public.room_members(user_id);

-- 3. Game Sessions
CREATE TABLE IF NOT EXISTS public.game_sessions (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id                 UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    story_id                UUID NOT NULL REFERENCES public.community_stories(id),
    status                  TEXT NOT NULL DEFAULT 'playing',
    current_round           SMALLINT NOT NULL DEFAULT 1,
    phase                   TEXT NOT NULL DEFAULT 'clues',
    revealed_clue_indices   INT[] NOT NULL DEFAULT '{}',
    game_state              TEXT NOT NULL DEFAULT 'playing',
    started_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finished_at             TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_game_sessions_room_id 
    ON public.game_sessions(room_id);

-- 4. Game Players (contains private data)
CREATE TABLE IF NOT EXISTS public.game_players (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id                  UUID NOT NULL REFERENCES public.game_sessions(id) ON DELETE CASCADE,
    user_id                     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name                TEXT NOT NULL,
    role                        TEXT NOT NULL,
    story_character_name        TEXT,
    story_character_behavior    TEXT,
    is_alive                    BOOLEAN NOT NULL DEFAULT true,
    has_voted                   BOOLEAN NOT NULL DEFAULT false,
    UNIQUE(session_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_game_players_session_id 
    ON public.game_players(session_id);

-- Public view for game_players (hides role, character name, character behavior)
CREATE OR REPLACE VIEW public.game_players_public AS
    SELECT id, session_id, user_id, display_name, is_alive, has_voted
    FROM public.game_players;

-- 5. Game Events (Audit Log)
CREATE TABLE IF NOT EXISTS public.game_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES public.game_sessions(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type      TEXT NOT NULL,
    payload         JSONB NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_game_events_session_id 
    ON public.game_events(session_id);
CREATE INDEX IF NOT EXISTS idx_game_events_created_at 
    ON public.game_events(created_at);


-- =============================================================
-- Row Level Security (RLS)
-- =============================================================

ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_events ENABLE ROW LEVEL SECURITY;

-- Rooms
-- Anyone can look up a room by code to join it. Only Edge Functions (Service Role) can insert/update/delete.
CREATE POLICY "public_read_rooms" ON public.rooms 
    FOR SELECT USING (true);

-- =============================================================
-- RPC Functions for Edge Functions
-- =============================================================

CREATE OR REPLACE FUNCTION public.create_room_with_code(
    p_code CHAR(6),
    p_name TEXT,
    p_host_id UUID,
    p_password TEXT,
    p_max_players SMALLINT
) RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_room_id UUID;
    v_password_hash TEXT;
BEGIN
    IF p_password IS NOT NULL AND p_password <> '' THEN
        v_password_hash := crypt(p_password, gen_salt('bf', 8));
    ELSE
        v_password_hash := NULL;
    END IF;

    INSERT INTO public.rooms (code, name, host_id, password_hash, max_players)
    VALUES (p_code, p_name, p_host_id, v_password_hash, p_max_players)
    RETURNING id INTO new_room_id;

    RETURN new_room_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.join_room_with_password(
    p_code CHAR(6),
    p_password TEXT
) RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_room_id UUID;
    v_password_hash TEXT;
    v_status TEXT;
BEGIN
    SELECT id, password_hash, status INTO v_room_id, v_password_hash, v_status
    FROM public.rooms
    WHERE code = p_code AND status IN ('waiting', 'starting');

    IF v_room_id IS NULL THEN
        RAISE EXCEPTION 'Room not found or already started';
    END IF;

    IF v_password_hash IS NOT NULL THEN
        IF p_password IS NULL OR crypt(p_password, v_password_hash) <> v_password_hash THEN
            RAISE EXCEPTION 'Invalid password';
        END IF;
    END IF;

    RETURN v_room_id;
END;
$$;

-- Room Members
-- Room members can see all members of rooms they are in.
CREATE POLICY "room_members_read" ON public.room_members 
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM public.room_members WHERE room_id = public.room_members.room_id
        )
    );
-- Users can update their own online status and mic state
CREATE POLICY "room_members_update_self" ON public.room_members 
    FOR UPDATE USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);
-- Users can leave (delete their own membership)
CREATE POLICY "room_members_delete_self" ON public.room_members 
    FOR DELETE USING (auth.uid() = user_id);

-- Game Sessions
-- Room members can read the game session
CREATE POLICY "game_sessions_read" ON public.game_sessions 
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM public.room_members WHERE room_id = public.game_sessions.room_id
        )
    );

-- Game Players (Private Data)
-- Users can only read their OWN full row (including private role).
CREATE POLICY "game_players_read_own" ON public.game_players 
    FOR SELECT USING (auth.uid() = user_id);

-- Game Players Public View
-- (Views don't have RLS by default, but we should grant access)
GRANT SELECT ON public.game_players_public TO authenticated;
GRANT SELECT ON public.game_players_public TO anon;

-- Game Events
-- Session members can read events
CREATE POLICY "game_events_read" ON public.game_events 
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM public.game_players WHERE session_id = public.game_events.session_id
        )
    );

-- Enable realtime for these tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE public.room_members;
ALTER PUBLICATION supabase_realtime ADD TABLE public.game_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.game_events;

COMMIT;
