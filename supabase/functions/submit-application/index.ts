// supabase/functions/submit-application/index.ts

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { hashWithPepper } from "../_shared/hash.ts";
import { validatePhone, sanitizeText } from "../_shared/validation.ts";
import { getServiceRoleClient } from "../_shared/supabase_client.ts";
import { checkRateLimit, logAttempt, extractClientIp } from "../_shared/rate_limit.ts";
import { verifyAppCheckToken } from "../_shared/app_check.ts";

interface SubmitRequestBody {
  mode?: "QUICK_CALLBACK" | "FULL";
  phone?: unknown;
  name?: unknown;
  district_id?: string | null;
  note?: unknown;
  full_payload?: Record<string, unknown>;
  device_id?: unknown;
  honeypot?: unknown;
  client_elapsed_ms?: unknown;
  app_check_token?: unknown;
}

function errorResponse(code: "INVALID_INPUT" | "RATE_LIMITED" | "TRY_AGAIN", status = 400) {
  return new Response(JSON.stringify({ error: code }), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function successResponse(trackingNumber: string) {
  return new Response(JSON.stringify({ tracking_number: trackingNumber }), {
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

  let body: SubmitRequestBody;
  try {
    body = await req.json();
  } catch (_) {
    return errorResponse("INVALID_INPUT", 400);
  }

  const rawDevice = typeof body.device_id === "string" ? body.device_id : "unknown-device";
  const deviceHash = await hashWithPepper(rawDevice);

  // Fallback phone hash before validation
  const rawPhoneStr = typeof body.phone === "string" ? body.phone : "";
  let phoneHash = await hashWithPepper(rawPhoneStr || "unknown-phone");

  const mode = body.mode === "FULL" ? "FULL" : "QUICK_CALLBACK";
  const actionName = mode === "FULL" ? "SUBMIT_FULL" : "SUBMIT_QUICK";

  // --------------------------------------------------------------------------
  // Check a: Honeypot field must be empty
  // --------------------------------------------------------------------------
  if (body.honeypot !== undefined && body.honeypot !== null && body.honeypot !== "") {
    await logAttempt(supabase, {
      action: actionName,
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: "Honeypot field was filled",
    });
    return errorResponse("INVALID_INPUT");
  }

  // --------------------------------------------------------------------------
  // Check b: client_elapsed_ms minimum threshold
  // --------------------------------------------------------------------------
  const elapsedMs = typeof body.client_elapsed_ms === "number" ? body.client_elapsed_ms : 0;
  const minElapsedQuick = parseInt(Deno.env.get("MIN_ELAPSED_MS_QUICK") ?? "3000", 10);
  const minElapsedFull = parseInt(Deno.env.get("MIN_ELAPSED_MS_FULL") ?? "20000", 10);
  const requiredElapsed = mode === "FULL" ? minElapsedFull : minElapsedQuick;

  if (elapsedMs < requiredElapsed) {
    await logAttempt(supabase, {
      action: actionName,
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: `Client elapsed time too fast (${elapsedMs}ms < ${requiredElapsed}ms)`,
    });
    return errorResponse("INVALID_INPUT");
  }

  // --------------------------------------------------------------------------
  // Check c: Phone validation & anti-fake pattern check
  // --------------------------------------------------------------------------
  const phoneValidation = validatePhone(body.phone);
  if (!phoneValidation.valid || !phoneValidation.normalized) {
    await logAttempt(supabase, {
      action: actionName,
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: phoneValidation.reason ?? "Invalid phone number",
    });
    return errorResponse("INVALID_INPUT");
  }

  const cleanPhone = phoneValidation.normalized;
  phoneHash = await hashWithPepper(cleanPhone);

  // --------------------------------------------------------------------------
  // Check d: Length & format limits on name and note
  // --------------------------------------------------------------------------
  const nameCheck = sanitizeText(body.name, 100);
  if (!nameCheck.valid) {
    await logAttempt(supabase, {
      action: actionName,
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: nameCheck.reason,
    });
    return errorResponse("INVALID_INPUT");
  }

  const noteCheck = sanitizeText(body.note, 1000);
  if (!noteCheck.valid) {
    await logAttempt(supabase, {
      action: actionName,
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: noteCheck.reason,
    });
    return errorResponse("INVALID_INPUT");
  }

  // --------------------------------------------------------------------------
  // Check e: Rate limits
  // --------------------------------------------------------------------------
  const rateLimitResult = await checkRateLimit({
    supabase,
    phoneHash,
    deviceHash,
    ipHash,
    actionPrefix: "SUBMIT",
  });

  if (!rateLimitResult.allowed) {
    await logAttempt(supabase, {
      action: actionName,
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: rateLimitResult.reason,
    });
    return errorResponse("RATE_LIMITED", 429);
  }

  // --------------------------------------------------------------------------
  // Check f: Duplicate suppression (QUICK_CALLBACK within 24h)
  // --------------------------------------------------------------------------
  if (mode === "QUICK_CALLBACK") {
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    const { data: openApp } = await supabase
      .from("legal_aid_application")
      .select("tracking_number")
      .eq("application_mode", "QUICK_CALLBACK")
      .eq("applicant_phone_number", cleanPhone)
      .not("status", "in", '("REJECTED","WITHDRAWN","RESOLVED")')
      .gte("created_at", twentyFourHoursAgo)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (openApp?.tracking_number) {
      await logAttempt(supabase, {
        action: actionName,
        phoneHash,
        deviceHash,
        ipHash,
        outcome: "DUPLICATE_SUPPRESSED",
        reason: "Existing open quick application returned idempotently",
      });
      return successResponse(openApp.tracking_number);
    }
  }

  // --------------------------------------------------------------------------
  // Check g: Firebase App Check token verification
  // --------------------------------------------------------------------------
  const appCheckResult = await verifyAppCheckToken(body.app_check_token);
  if (!appCheckResult.valid) {
    await logAttempt(supabase, {
      action: actionName,
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: appCheckResult.reason ?? "App Check verification failed",
    });
    return errorResponse("INVALID_INPUT");
  }

  // --------------------------------------------------------------------------
  // Caller Identity: resolve user ID if valid JWT is attached
  // --------------------------------------------------------------------------
  let applicantId: string | null = null;
  const authHeader = req.headers.get("Authorization");
  if (authHeader?.startsWith("Bearer ")) {
    const token = authHeader.replace("Bearer ", "").trim();
    try {
      const { data: userData } = await supabase.auth.getUser(token);
      if (userData?.user?.id) {
        applicantId = userData.user.id;
      }
    } catch (_) {
      // Unauthenticated / expired token falls back to anonymous guest
    }
  }

  // --------------------------------------------------------------------------
  // Execution: Call database RPC via service-role client
  // --------------------------------------------------------------------------
  let trackingNumber = "";

  try {
    if (mode === "QUICK_CALLBACK") {
      const { data, error } = await supabase.rpc("create_quick_application", {
        p_phone: cleanPhone,
        p_name: nameCheck.sanitized ?? null,
        p_district_id: body.district_id ?? null,
        p_note: noteCheck.sanitized ?? null,
        p_applicant_id: applicantId,
      });

      if (error || !data || data.length === 0) {
        console.error("create_quick_application RPC error:", error);
        await logAttempt(supabase, {
          action: actionName,
          phoneHash,
          deviceHash,
          ipHash,
          outcome: "REJECTED",
          reason: error?.message ?? "Database insertion failed",
        });
        return errorResponse("TRY_AGAIN", 500);
      }

      trackingNumber = data[0].tracking_number;
    } else {
      // FULL mode
      const fullPayload = body.full_payload ?? {};
      fullPayload.applicant_phone_number = cleanPhone;
      if (applicantId) {
        fullPayload.applicant_id = applicantId;
      }

      const { data, error } = await supabase.rpc("submit_legal_aid_application", {
        p_application: fullPayload,
      });

      if (error || !data) {
        console.error("submit_legal_aid_application RPC error:", error);
        await logAttempt(supabase, {
          action: actionName,
          phoneHash,
          deviceHash,
          ipHash,
          outcome: "REJECTED",
          reason: error?.message ?? "Database insertion failed",
        });
        return errorResponse("TRY_AGAIN", 500);
      }

      trackingNumber = (data as Record<string, unknown>).tracking_number as string;
    }

    await logAttempt(supabase, {
      action: actionName,
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "SUCCESS",
    });

    return successResponse(trackingNumber);
  } catch (err) {
    console.error("Unhandled submit error:", err);
    await logAttempt(supabase, {
      action: actionName,
      phoneHash,
      deviceHash,
      ipHash,
      outcome: "REJECTED",
      reason: "Internal server error",
    });
    return errorResponse("TRY_AGAIN", 500);
  }
});
