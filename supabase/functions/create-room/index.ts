import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 1. Verify caller Auth (JWT)
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    // Initialize Supabase client with Service Role key for database operations,
    // but first verify the user JWT.
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

    // Read payload
    const { name, password, maxPlayers = 8, displayName = 'Host' } = await req.json();

    if (!name || name.trim() === '') {
      return new Response(JSON.stringify({ error: 'Room name is required' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    // 2. Initialize Service Role client to bypass RLS for inserting the room
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 3. Generate a unique 6-digit code with retry logic
    const generateCode = () => Math.floor(100000 + Math.random() * 900000).toString();
    
    let roomCode = '';
    let insertedRoom = null;
    let retries = 5;

    while (retries > 0) {
      roomCode = generateCode();
      
      // We will let postgres hash the password if provided, but since we are inserting from deno,
      // we can use a raw SQL query via RPC, or just pass the password to an RPC function, OR
      // we can let the client insert the room without password hash and then call an RPC to hash it.
      // Wait, we have pgcrypto. We can use an RPC function to insert the room securely.
      // Alternatively, insert directly using supabaseAdmin if we have an RPC:
      // Let's call an RPC to insert room with password hash.
      
      const { data, error } = await supabaseAdmin.rpc('create_room_with_code', {
        p_code: roomCode,
        p_name: name,
        p_host_id: userId,
        p_password: password || null,
        p_max_players: maxPlayers
      });

      if (error) {
        if (error.code === '23505') { // Unique violation
          retries--;
          continue;
        } else {
          throw error;
        }
      }

      insertedRoom = data; // Assuming RPC returns the room id
      break;
    }

    if (!insertedRoom) {
      return new Response(JSON.stringify({ error: 'Could not generate a unique room code. Try again.' }), { status: 503, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    const roomId = insertedRoom;

    // 4. Insert the host into room_members
    const { error: memberError } = await supabaseAdmin.from('room_members').insert({
      room_id: roomId,
      user_id: userId,
      display_name: displayName
    });

    if (memberError) {
      // Cleanup room if member insert fails
      await supabaseAdmin.from('rooms').delete().eq('id', roomId);
      throw memberError;
    }

    // 5. Return success
    return new Response(JSON.stringify({ roomId, code: roomCode }), {
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
