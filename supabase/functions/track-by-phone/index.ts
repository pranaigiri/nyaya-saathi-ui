// supabase/functions/track-by-phone/index.ts

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { hashWithPepper } from "../_shared/hash.ts";
import { validatePhone } from "../_shared/validation.ts";
import { getServiceRoleClient } from "../_shared/supabase_client.ts";
import { checkRateLimit, logAttempt, extractClientIp } from "../_shared/rate_limit.ts";

interface TrackRequestBody {
  phone?: unknown;
  device_id?: unknown;
}

function errorResponse(code: "INVALID_INPUT" | "RATE_LIMITED" | "TRY_AGAIN", status = 400) {
  return new Response(JSON.stringify({ error: code }), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function successResponse(applications: unknown[]) {
  return new Response(JSON.stringify({ applications: applications ?? [] }), {
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

  let body: TrackRequestBody;
  try {
    body = await req.json();
  } catch (_) {
    return errorResponse("INVALID_INPUT", 400);
  }

  const rawDevice = typeof body.device_id === "string" ? body.device_id : "unknown-device";
  const deviceHash = await hashWithPepper(rawDevice);

  // Validate phone format
  const phoneValidation = validatePhone(body.phone);
  if (!phoneValidation.valid || !phoneValidation.normalized) {
    const rawPhone = typeof body.phone === "string" ? body.phone : "unknown-phone";
    const phoneHash = await hashWithPepper(rawPhone);
    await logAttempt(supabase, {
      action: "TRACK_BY_PHONE",
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: phoneValidation.reason ?? "Invalid phone format",
    });
    // Return empty list so we never leak format errors or whether a phone exists
    return successResponse([]);
  }

  const cleanPhone = phoneValidation.normalized;
  const phoneHash = await hashWithPepper(cleanPhone);

  // Check rate limits: IP (30/h), device (20/h), phone (10/h)
  const rateLimitResult = await checkRateLimit({
    supabase,
    phoneHash,
    deviceHash,
    ipHash,
    actionPrefix: "TRACK",
  });

  if (!rateLimitResult.allowed) {
    await logAttempt(supabase, {
      action: "TRACK_BY_PHONE",
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: rateLimitResult.reason,
    });
    return errorResponse("RATE_LIMITED", 429);
  }

  try {
    // Call track_applications_by_phone SECURITY DEFINER RPC
    const { data, error } = await supabase.rpc("track_applications_by_phone", {
      p_phone: cleanPhone,
    });

    if (error) {
      console.error("track_applications_by_phone RPC error:", error);
      await logAttempt(supabase, {
        action: "TRACK_BY_PHONE",
        phoneHash,
        deviceHash,
        ipHash,
        outcome: "REJECTED",
        reason: error.message,
      });
      return errorResponse("TRY_AGAIN", 500);
    }

    await logAttempt(supabase, {
      action: "TRACK_BY_PHONE",
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "SUCCESS",
    });

    // Returns uniform structure: empty array if none found, array of objects if found
    return successResponse(data ?? []);
  } catch (err) {
    console.error("Unhandled track error:", err);
    await logAttempt(supabase, {
      action: "TRACK_BY_PHONE",
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: "Internal server error",
    });
    return errorResponse("TRY_AGAIN", 500);
  }
});
