import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

serve(async (req) => {
  // This function is meant to be called by a scheduled pg_cron job or Supabase cron
  // It shouldn't require CORS since it's internal, but we can return basic text
  try {
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Delete rooms where expires_at is in the past and status is not playing
    // (If a game is playing, maybe give it more time or just delete it anyway since 4h is a long time for one game)
    const { data, error } = await supabaseAdmin
      .from('rooms')
      .delete()
      .lt('expires_at', new Date().toISOString())
      .neq('status', 'playing');

    if (error) {
      throw error;
    }

    return new Response(JSON.stringify({ success: true, deleted: data }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});
