// supabase/functions/_shared/rate_limit.ts

import { SupabaseClient } from "npm:@supabase/supabase-js@2";

export interface RateLimitCheckParams {
  supabase: SupabaseClient;
  phoneHash: string;
  deviceHash: string;
  ipHash: string;
  actionPrefix: "SUBMIT" | "TRACK";
  mode?: "QUICK_CALLBACK" | "FULL";
}

export interface RateLimitResult {
  allowed: boolean;
  requireCaptcha?: boolean;
  reason?: string;
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
 * Returns { allowed: true } or { allowed: false, requireCaptcha?: boolean, reason?: string }.
 */
export async function checkRateLimit(
  params: RateLimitCheckParams
): Promise<RateLimitResult> {
  const { supabase, phoneHash, deviceHash, ipHash, actionPrefix, mode } = params;
  const now = new Date();
  const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString();

  if (actionPrefix === "SUBMIT") {
    // 1. IP check 24h (protects backend against massive distributed flooding)
    const limitIp24h = parseInt(Deno.env.get("RATE_LIMIT_IP_24H") ?? "50", 10);
    const { count: ip24hCount } = await supabase
      .from("submission_attempt_log")
      .select("*", { count: "exact", head: true })
      .like("action", "SUBMIT_%")
      .eq("ip_hash", ipHash)
      .gte("created_at", twentyFourHoursAgo);

    if ((ip24hCount ?? 0) >= limitIp24h) {
      return { allowed: false, reason: "IP submission rate limit exceeded (24h window)" };
    }

    if (mode === "QUICK_CALLBACK") {
      // 2. QUICK_CALLBACK Mode:
      // Allow up to 3 unique phone numbers from a single device identity per 24h.
      // If a user spams random numbers from the same device, require captcha / human verification.
      const { data: previousAttempts } = await supabase
        .from("submission_attempt_log")
        .select("phone_hash")
        .like("action", "SUBMIT_%")
        .eq("device_hash", deviceHash)
        .gte("created_at", twentyFourHoursAgo);

      const uniquePhones = new Set((previousAttempts ?? []).map((r) => r.phone_hash));

      // If submitting a new unique number and device has already submitted 3 or more distinct numbers:
      if (!uniquePhones.has(phoneHash) && uniquePhones.size >= 3) {
        return {
          allowed: false,
          requireCaptcha: true,
          reason: "Device limit of 3 unique numbers reached. Human verification required.",
        };
      }
    } else if (mode === "FULL") {
      // 3. FULL Mode (5-step comprehensive form):
      // No phone rate limits (form already requires detailed legal case information).
      // Backend checks device identity entries to prevent bot endpoint flooding.
      const limitFullDevice24h = parseInt(Deno.env.get("RATE_LIMIT_FULL_DEVICE_24H") ?? "20", 10);
      const { count: fullDeviceCount } = await supabase
        .from("submission_attempt_log")
        .select("*", { count: "exact", head: true })
        .eq("action", "SUBMIT_FULL")
        .eq("device_hash", deviceHash)
        .gte("created_at", twentyFourHoursAgo);

      if ((fullDeviceCount ?? 0) >= limitFullDevice24h) {
        return {
          allowed: false,
          reason: "Device submission limit reached for 5-step applications (24h window).",
        };
      }
    }
  } else if (actionPrefix === "TRACK") {
    const limitIp1h = parseInt(Deno.env.get("RATE_LIMIT_TRACK_IP_1H") ?? "30", 10);
    const limitDevice1h = parseInt(Deno.env.get("RATE_LIMIT_TRACK_DEVICE_1H") ?? "20", 10);
    const limitPhone1h = parseInt(Deno.env.get("RATE_LIMIT_TRACK_PHONE_1H") ?? "10", 10);

    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000).toISOString();

    // 1. Phone / Target check 1h
    const { count: phoneCount } = await supabase
      .from("submission_attempt_log")
      .select("*", { count: "exact", head: true })
      .like("action", "TRACK_%")
      .eq("phone_hash", phoneHash)
      .gte("created_at", oneHourAgo);

    if ((phoneCount ?? 0) >= limitPhone1h) {
      return { allowed: false, reason: "Phone tracking rate limit exceeded (1h window)" };
    }

    // 2. Device check 1h
    const { count: deviceCount } = await supabase
      .from("submission_attempt_log")
      .select("*", { count: "exact", head: true })
      .like("action", "TRACK_%")
      .eq("device_hash", deviceHash)
      .gte("created_at", oneHourAgo);

    if ((deviceCount ?? 0) >= limitDevice1h) {
      return { allowed: false, reason: "Device tracking rate limit exceeded (1h window)" };
    }

    // 3. IP check 1h
    const { count: ipCount } = await supabase
      .from("submission_attempt_log")
      .select("*", { count: "exact", head: true })
      .like("action", "TRACK_%")
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
    outcome: "SUCCESS" | "REJECTED" | "DUPLICATE_SUPPRESSED" | "DUPLICATE_ACTIVE_CALLBACK";
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
