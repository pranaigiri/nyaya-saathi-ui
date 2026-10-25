// supabase/functions/track-by-id/index.ts

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { hashWithPepper } from "../_shared/hash.ts";
import { getServiceRoleClient } from "../_shared/supabase_client.ts";
import { checkRateLimit, logAttempt, extractClientIp } from "../_shared/rate_limit.ts";

interface TrackByIdRequestBody {
  tracking_number?: unknown;
  phone?: unknown;
  device_id?: unknown;
}

function errorResponse(code: "INVALID_INPUT" | "RATE_LIMITED" | "TRY_AGAIN", status = 400) {
  return new Response(JSON.stringify({ error: code }), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function successResponse(application: unknown) {
  return new Response(JSON.stringify({ application: application ?? null }), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  const corsRes = handleCors(req);
  if (corsRes) return corsRes;

  if (req.method !== "POST") {
    return errorResponse("INVALID_INPUT", 405);
  }

  const supabase = getServiceRoleClient();
  const rawIp = extractClientIp(req);
  const ipHash = await hashWithPepper(rawIp);

  let body: TrackByIdRequestBody;
  try {
    body = await req.json();
  } catch (_) {
    return errorResponse("INVALID_INPUT", 400);
  }

  const rawDevice = typeof body.device_id === "string" ? body.device_id : "unknown-device";
  const deviceHash = await hashWithPepper(rawDevice);

  // Validate tracking_number format
  if (typeof body.tracking_number !== "string" || body.tracking_number.trim().length < 5) {
    return errorResponse("INVALID_INPUT", 400);
  }

  const cleanTracking = body.tracking_number.trim().toUpperCase();
  // Safe tracking pattern (e.g. SK-GTK-26-00034, SK-NAM-26-00001, etc.)
  if (!/^SK-[A-Z0-9\-]{5,25}$/i.test(cleanTracking)) {
    return errorResponse("INVALID_INPUT", 400);
  }

  const trackingHash = await hashWithPepper(cleanTracking);

  // Check rate limits against submission_attempt_log (IP: 30/h, device: 20/h, target: 10/h)
  const rateLimitResult = await checkRateLimit({
    supabase,
    phoneHash: trackingHash,
    deviceHash,
    ipHash,
    actionPrefix: "TRACK",
  });

  if (!rateLimitResult.allowed) {
    await logAttempt(supabase, {
      action: "TRACK_BY_ID",
      phoneHash: trackingHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: rateLimitResult.reason,
    });
    return errorResponse("RATE_LIMITED", 429);
  }

  // Optional phone verification parameter if provided
  const cleanPhone = typeof body.phone === "string" && body.phone.trim().isNotEmpty
    ? body.phone.trim()
    : null;

  try {
    const { data, error } = await supabase.rpc("track_application", {
      p_tracking_number: cleanTracking,
      p_phone_number: cleanPhone,
    });

    if (error) {
      console.error("track_application RPC error in track-by-id:", error);
      await logAttempt(supabase, {
        action: "TRACK_BY_ID",
        phoneHash: trackingHash,
        deviceHash,
        ipHash,
        outcome: "REJECTED",
        reason: error.message,
      });
      return errorResponse("TRY_AGAIN", 500);
    }

    await logAttempt(supabase, {
      action: "TRACK_BY_ID",
      phoneHash: trackingHash,
      deviceHash,
      ipHash,
      outcome: data ? "SUCCESS" : "REJECTED",
      reason: data ? undefined : "Application not found",
    });

    return successResponse(data);
  } catch (err) {
    console.error("Unhandled track-by-id error:", err);
    await logAttempt(supabase, {
      action: "TRACK_BY_ID",
      phoneHash: trackingHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: "Internal server error",
    });
    return errorResponse("TRY_AGAIN", 500);
  }
});
