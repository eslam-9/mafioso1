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

    const { code, password, displayName = 'Player' } = await req.json();

    if (!code) {
      return new Response(JSON.stringify({ error: 'Room code is required' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Verify room code and password via RPC
    const { data: roomId, error: joinError } = await supabaseAdmin.rpc('join_room_with_password', {
      p_code: code,
      p_password: password || null
    });

    if (joinError) {
      return new Response(JSON.stringify({ error: joinError.message }), { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    // Insert user into room_members, or if already exists, just return success
    const { error: memberError } = await supabaseAdmin.from('room_members').insert({
      room_id: roomId,
      user_id: userId,
      display_name: displayName,
      is_online: true
    });

    if (memberError) {
      // 23505 is unique violation (user is already in room)
      if (memberError.code !== '23505') {
        throw memberError;
      }
      
      // If already a member, we might want to update their is_online status
      await supabaseAdmin.from('room_members').update({ is_online: true }).match({ room_id: roomId, user_id: userId });
    }

    // Fetch basic room details to return
    const { data: roomDetails } = await supabaseAdmin.from('rooms').select('id, code, name, status, selected_story_id, game_mode, host_id, max_players').eq('id', roomId).single();

    return new Response(JSON.stringify({ roomId, roomDetails }), {
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
