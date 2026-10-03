import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";
import { AccessToken } from "npm:livekit-server-sdk@2.1.2";

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

    // Verify room membership
    const { data: member, error: memberError } = await supabaseAdmin
      .from('room_members')
      .select('display_name')
      .eq('room_id', roomId)
      .eq('user_id', userId)
      .single();

    if (memberError || !member) {
      return new Response(JSON.stringify({ error: 'Not a member of this room' }), { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    const { data: room, error: roomError } = await supabaseAdmin
      .from('rooms')
      .select('code')
      .eq('id', roomId)
      .single();

    if (roomError || !room) {
      return new Response(JSON.stringify({ error: 'Room not found' }), { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    const livekitRoomName = `mafioso_${room.code}`;
    
    // Create LiveKit token
    const apiKey = Deno.env.get('LIVEKIT_API_KEY');
    const apiSecret = Deno.env.get('LIVEKIT_API_SECRET');
    
    if (!apiKey || !apiSecret) {
      return new Response(JSON.stringify({ error: 'LiveKit credentials missing on server' }), { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    const at = new AccessToken(apiKey, apiSecret, {
      identity: userId,
      name: member.display_name,
      ttl: 4 * 60 * 60, // 4 hours
    });
    
    at.addGrant({ roomJoin: true, room: livekitRoomName });
    
    const token = await at.toJwt();

    return new Response(JSON.stringify({ token, room: livekitRoomName }), {
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
