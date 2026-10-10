// supabase/functions/_shared/rate_limit.ts

import { SupabaseClient } from "npm:@supabase/supabase-js@2";

export interface RateLimitCheckParams {
  supabase: SupabaseClient;
  phoneHash: string;
  deviceHash: string;
  ipHash: string;
  actionPrefix: "SUBMIT" | "TRACK";
}

export function extractClientIp(req: Request): string {
  const forwarded = req.headers.get("x-forwarded-for");
  if (forwarded) {
    const firstHop = forwarded.split(",")[0].trim();
    if (firstHop) return firstHop;
  }
  return (
    req.headers.get("cf-connecting-ip") ??
    req.headers.get("x-real-ip") ??
    "127.0.0.1"
  );
}

/**
 * Checks rate limits against submission_attempt_log.
 * Returns { allowed: true } or { allowed: false, reason: string }.
 */
export async function checkRateLimit(
  params: RateLimitCheckParams
): Promise<{ allowed: boolean; reason?: string }> {
  const { supabase, phoneHash, deviceHash, ipHash, actionPrefix } = params;
  const now = new Date();

  if (actionPrefix === "SUBMIT") {
    const limitPhone10m = parseInt(Deno.env.get("RATE_LIMIT_PHONE_10M") ?? "1", 10);
    const limitPhone24h = parseInt(Deno.env.get("RATE_LIMIT_PHONE_24H") ?? "3", 10);
    const limitDevice24h = parseInt(Deno.env.get("RATE_LIMIT_DEVICE_24H") ?? "5", 10);
    const limitIp24h = parseInt(Deno.env.get("RATE_LIMIT_IP_24H") ?? "10", 10);

    const tenMinAgo = new Date(now.getTime() - 10 * 60 * 1000).toISOString();
    const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString();

    // 1. Phone check 10 min
    const { count: phone10mCount } = await supabase
      .from("submission_attempt_log")
      .select("*", { count: "exact", head: true })
      .like("action", "SUBMIT_%")
      .eq("phone_hash", phoneHash)
      .gte("created_at", tenMinAgo);

    if ((phone10mCount ?? 0) >= limitPhone10m) {
      return { allowed: false, reason: "Phone submission rate limit exceeded (10m window)" };
    }

    // 2. Phone check 24h
    const { count: phone24hCount } = await supabase
      .from("submission_attempt_log")
      .select("*", { count: "exact", head: true })
      .like("action", "SUBMIT_%")
      .eq("phone_hash", phoneHash)
      .gte("created_at", twentyFourHoursAgo);

    if ((phone24hCount ?? 0) >= limitPhone24h) {
      return { allowed: false, reason: "Phone submission rate limit exceeded (24h window)" };
    }

    // 3. Device check 24h
    const { count: device24hCount } = await supabase
      .from("submission_attempt_log")
      .select("*", { count: "exact", head: true })
      .like("action", "SUBMIT_%")
      .eq("device_hash", deviceHash)
      .gte("created_at", twentyFourHoursAgo);

    if ((device24hCount ?? 0) >= limitDevice24h) {
      return { allowed: false, reason: "Device submission rate limit exceeded (24h window)" };
    }

    // 4. IP check 24h
    const { count: ip24hCount } = await supabase
      .from("submission_attempt_log")
      .select("*", { count: "exact", head: true })
      .like("action", "SUBMIT_%")
      .eq("ip_hash", ipHash)
      .gte("created_at", twentyFourHoursAgo);

    if ((ip24hCount ?? 0) >= limitIp24h) {
      return { allowed: false, reason: "IP submission rate limit exceeded (24h window)" };
    }
  } else if (actionPrefix === "TRACK") {
    const limitIp1h = parseInt(Deno.env.get("RATE_LIMIT_TRACK_IP_1H") ?? "30", 10);
    const limitDevice1h = parseInt(Deno.env.get("RATE_LIMIT_TRACK_DEVICE_1H") ?? "20", 10);
    const limitPhone1h = parseInt(Deno.env.get("RATE_LIMIT_TRACK_PHONE_1H") ?? "10", 10);

    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000).toISOString();

    // 1. Phone check 1h
    const { count: phoneCount } = await supabase
      .from("submission_attempt_log")
      .select("*", { count: "exact", head: true })
      .eq("action", "TRACK_BY_PHONE")
      .eq("phone_hash", phoneHash)
      .gte("created_at", oneHourAgo);

    if ((phoneCount ?? 0) >= limitPhone1h) {
      return { allowed: false, reason: "Phone tracking rate limit exceeded (1h window)" };
    }

    // 2. Device check 1h
    const { count: deviceCount } = await supabase
      .from("submission_attempt_log")
      .select("*", { count: "exact", head: true })
      .eq("action", "TRACK_BY_PHONE")
      .eq("device_hash", deviceHash)
      .gte("created_at", oneHourAgo);

    if ((deviceCount ?? 0) >= limitDevice1h) {
      return { allowed: false, reason: "Device tracking rate limit exceeded (1h window)" };
    }

    // 3. IP check 1h
    const { count: ipCount } = await supabase
      .from("submission_attempt_log")
      .select("*", { count: "exact", head: true })
      .eq("action", "TRACK_BY_PHONE")
      .eq("ip_hash", ipHash)
      .gte("created_at", oneHourAgo);

    if ((ipCount ?? 0) >= limitIp1h) {
      return { allowed: false, reason: "IP tracking rate limit exceeded (1h window)" };
    }
  }

  return { allowed: true };
}

/**
 * Logs an attempt to submission_attempt_log using service role client.
 */
export async function logAttempt(
  supabase: SupabaseClient,
  params: {
    action: string;
    phoneHash: string;
    deviceHash: string;
    ipHash: string;
    outcome: "SUCCESS" | "REJECTED" | "DUPLICATE_SUPPRESSED";
    reason?: string;
  }
): Promise<void> {
  try {
    await supabase.from("submission_attempt_log").insert({
      action: params.action,
      phone_hash: params.phoneHash,
      device_hash: params.deviceHash,
      ip_hash: params.ipHash,
      outcome: params.outcome,
      reason: params.reason ?? null,
    });
  } catch (err) {
    console.error("Failed to write to submission_attempt_log:", err);
  }
}
