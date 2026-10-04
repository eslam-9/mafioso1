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

    const { sessionId, eventType, payload } = await req.json();

    if (!sessionId || !eventType) {
      return new Response(JSON.stringify({ error: 'sessionId and eventType are required' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Verify caller is part of this session
    const { data: player, error: playerError } = await supabaseAdmin
      .from('game_players')
      .select('id, is_alive, has_voted')
      .eq('session_id', sessionId)
      .eq('user_id', userId)
      .single();

    if (playerError || !player) {
      return new Response(JSON.stringify({ error: 'Not part of this game session' }), { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    // Process event
    // Example: reveal_clue, cast_vote
    if (eventType === 'reveal_clue') {
      const { clueIndex } = payload;
      // Get session
      const { data: session } = await supabaseAdmin.from('game_sessions').select('revealed_clue_indices').eq('id', sessionId).single();
      const indices = session.revealed_clue_indices || [];
      if (!indices.includes(clueIndex)) {
        indices.push(clueIndex);
        await supabaseAdmin.from('game_sessions').update({ revealed_clue_indices: indices }).eq('id', sessionId);
      }
    } else if (eventType === 'cast_vote') {
      if (!player.is_alive || player.has_voted) {
        return new Response(JSON.stringify({ error: 'Cannot vote' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
      }
      
      await supabaseAdmin.from('game_players').update({ has_voted: true }).eq('id', player.id);
      
      // Real vote resolution should happen when everyone has voted.
      // This is simplified.
    }

    // Insert audit event
    const { error: insertError } = await supabaseAdmin.from('game_events').insert({
      session_id: sessionId,
      user_id: userId,
      event_type: eventType,
      payload: payload
    });

    if (insertError) {
      throw insertError;
    }

    return new Response(JSON.stringify({ success: true }), {
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
