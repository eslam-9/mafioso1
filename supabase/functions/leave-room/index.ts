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

    // Delete the member
    await supabaseAdmin.from('room_members').delete().match({ room_id: roomId, user_id: userId });

    // Host migration logic
    const { data: roomMembers } = await supabaseAdmin.from('room_members').select('user_id').eq('room_id', roomId).order('joined_at', { ascending: true });
    
    if (!roomMembers || roomMembers.length === 0) {
      // Room is empty, delete it
      await supabaseAdmin.from('rooms').delete().eq('id', roomId);
    } else {
      const { data: room } = await supabaseAdmin.from('rooms').select('host_id').eq('id', roomId).single();
      if (room && room.host_id === userId) {
        // Host left, migrate host to the oldest joined member
        await supabaseAdmin.from('rooms').update({ host_id: roomMembers[0].user_id }).eq('id', roomId);
      }
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
