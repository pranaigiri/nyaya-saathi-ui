// supabase/functions/_shared/supabase_client.ts

import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2";

export function getServiceRoleClient(): SupabaseClient {
  const url = Deno.env.get("SUPABASE_URL");
  if (!url) {
    throw new Error("SUPABASE_URL environment variable is required");
  }

  const key =
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
    Deno.env.get("SERVICE_ROLE_KEY");

  if (!key) {
    throw new Error("SUPABASE_SERVICE_ROLE_KEY environment variable is required");
  }

  return createClient(url, key, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
}
