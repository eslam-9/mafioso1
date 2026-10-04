import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    );

    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser(token);
    if (userError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }
    const userId = user.id;

    const { roomId, storyId, gameMode } = await req.json();

    if (!roomId || !storyId || !gameMode) {
      return new Response(JSON.stringify({ error: 'roomId, storyId, and gameMode are required' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Verify caller is host
    const { data: room, error: roomError } = await supabaseAdmin
      .from('rooms')
      .select('host_id, status')
      .eq('id', roomId)
      .single();

    if (roomError || !room) {
      return new Response(JSON.stringify({ error: 'Room not found' }), { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }
    if (room.host_id !== userId) {
      return new Response(JSON.stringify({ error: 'Only the host can select a game' }), { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }
    if (room.status !== 'waiting') {
      return new Response(JSON.stringify({ error: 'Cannot change game after starting' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    // Fetch the story to count suspects — this becomes the required player count
    const { data: story, error: storyError } = await supabaseAdmin
      .from('community_stories')
      .select('story_json')
      .eq('id', storyId)
      .single();

    if (storyError || !story) {
      return new Response(JSON.stringify({ error: 'Story not found' }), { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    let storyJson = story.story_json;
    if (typeof storyJson === 'string') {
      storyJson = JSON.parse(storyJson);
    }

    const suspects = storyJson.suspects ?? [];
    if (suspects.length < 2) {
      return new Response(JSON.stringify({ error: 'Story must have at least 2 suspects' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    const requiredPlayers = suspects.length;

    // Update room with story, game mode, and required player count
    const { error: updateError } = await supabaseAdmin
      .from('rooms')
      .update({
        selected_story_id: storyId,
        game_mode: gameMode,
        required_players: requiredPlayers,
      })
      .eq('id', roomId);

    if (updateError) {
      throw updateError;
    }

    return new Response(JSON.stringify({ success: true, requiredPlayers }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});
