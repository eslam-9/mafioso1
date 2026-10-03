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

    const { roomId } = await req.json();

    if (!roomId) {
      return new Response(JSON.stringify({ error: 'roomId is required' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Verify caller is host
    const { data: room, error: roomError } = await supabaseAdmin
      .from('rooms')
      .select('host_id, status, selected_story_id, game_mode')
      .eq('id', roomId)
      .single();

    if (roomError || !room) {
      return new Response(JSON.stringify({ error: 'Room not found' }), { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }
    if (room.host_id !== userId) {
      return new Response(JSON.stringify({ error: 'Only the host can start the game' }), { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }
    if (room.status !== 'waiting') {
      return new Response(JSON.stringify({ error: 'Game has already started' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }
    if (!room.selected_story_id) {
      return new Response(JSON.stringify({ error: 'No game selected' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    // Get members
    const { data: members, error: membersError } = await supabaseAdmin
      .from('room_members')
      .select('user_id, display_name')
      .eq('room_id', roomId);
      
    if (membersError || !members || members.length < 2) {
      return new Response(JSON.stringify({ error: 'Not enough players' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    // Assign roles logic
    const totalPlayers = members.length;
    let roles = ['killer'];
    if (room.game_mode === 'with_detective') {
      roles.push('detective');
    }
    while (roles.length < totalPlayers) {
      roles.push('innocent');
    }
    
    // Shuffle roles
    roles = roles.sort(() => Math.random() - 0.5);
    
    // Fetch story suspects to assign characters
    const { data: story } = await supabaseAdmin.from('community_stories').select('story_json').eq('id', room.selected_story_id).single();
    
    let storyJson = story.story_json;
    if (typeof storyJson === 'string') {
      storyJson = JSON.parse(storyJson);
    }
    
    const suspects = storyJson.suspects || [];
    let killerSuspect = suspects.find((s: any) => s.name === storyJson.killerName);
    if (!killerSuspect && suspects.length > 0) killerSuspect = suspects[0];
    
    let otherSuspects = suspects.filter((s: any) => s.name !== killerSuspect?.name);
    otherSuspects = otherSuspects.sort(() => Math.random() - 0.5);
    
    // 1. Update room status
    await supabaseAdmin.from('rooms').update({ status: 'starting' }).eq('id', roomId);

    // 2. Insert game session
    const { data: session, error: sessionError } = await supabaseAdmin
      .from('game_sessions')
      .insert({
        room_id: roomId,
        story_id: room.selected_story_id,
        status: 'playing',
        game_state: 'playing',
        phase: 'clues'
      })
      .select('id')
      .single();

    if (sessionError) {
      throw sessionError;
    }

    // 3. Insert players
    let suspectIndex = 0;
    const gamePlayers = members.map((member: any, index: number) => {
      const role = roles[index];
      let charName = null;
      let charBehavior = null;

      if (role === 'killer' && killerSuspect) {
        charName = killerSuspect.name;
        charBehavior = killerSuspect.suspiciousBehavior;
      } else if (role !== 'detective' && suspectIndex < otherSuspects.length) {
        charName = otherSuspects[suspectIndex].name;
        charBehavior = otherSuspects[suspectIndex].suspiciousBehavior;
        suspectIndex++;
      }

      return {
        session_id: session.id,
        user_id: member.user_id,
        display_name: member.display_name,
        role: role,
        story_character_name: charName,
        story_character_behavior: charBehavior,
        is_alive: true,
        has_voted: false
      };
    });

    const { error: playersError } = await supabaseAdmin.from('game_players').insert(gamePlayers);
    if (playersError) {
      throw playersError;
    }

    // 4. Update room to playing
    await supabaseAdmin.from('rooms').update({ status: 'playing' }).eq('id', roomId);

    return new Response(JSON.stringify({ sessionId: session.id }), {
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
