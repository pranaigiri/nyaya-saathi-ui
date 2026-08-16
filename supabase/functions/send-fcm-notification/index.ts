import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@^10";

interface NotificationRecord {
  id?: string;
  user_id?: string;
  profile_id?: string;
  body: string;
  title?: string;
  application_id?: string | null;
  type?: string | null;
}

interface WebhookPayload {
  type?: string;
  table?: string;
  record?: NotificationRecord;
  schema?: string;
  // Fallback for direct test invocation
  id?: string;
  user_id?: string;
  profile_id?: string;
  body?: string;
  title?: string;
  application_id?: string | null;
}

interface FcmErrorResponse {
  error?: {
    code?: number;
    message?: string;
    status?: string;
    details?: unknown[];
  };
}

// 1. Resolve Supabase Admin Credentials
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
if (!SUPABASE_URL) {
  throw new Error("SUPABASE_URL environment variable is required");
}

function getServiceRoleKey(): string {
  const directKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (directKey) return directKey;

  const secretKeysRaw = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (secretKeysRaw) {
    try {
      const parsed = JSON.parse(secretKeysRaw);
      if (parsed["default"]) return parsed["default"];
      if (parsed["service_role"]) return parsed["service_role"];
    } catch (_) {
      // Ignore JSON parse error
    }
  }

  throw new Error("SUPABASE_SERVICE_ROLE_KEY environment variable is required");
}

const supabaseAdmin = createClient(SUPABASE_URL, getServiceRoleKey());

// 2. Resolve FCM Service Account Secrets
const FCM_CLIENT_EMAIL = Deno.env.get("FCM_SERVICE_ACCOUNT_CLIENT_EMAIL");
const FCM_PRIVATE_KEY_RAW = Deno.env.get("FCM_SERVICE_ACCOUNT_PRIVATE_KEY");
const FCM_PROJECT_ID = Deno.env.get("FCM_SERVICE_ACCOUNT_PROJECT_ID");

if (!FCM_CLIENT_EMAIL) {
  throw new Error("FCM_SERVICE_ACCOUNT_CLIENT_EMAIL environment variable is required");
}

if (!FCM_PRIVATE_KEY_RAW) {
  throw new Error("FCM_SERVICE_ACCOUNT_PRIVATE_KEY environment variable is required");
}

if (!FCM_PROJECT_ID) {
  throw new Error("FCM_SERVICE_ACCOUNT_PROJECT_ID environment variable is required");
}

function normalizePrivateKey(key: string): string {
  let normalized = key.trim();
  normalized = normalized.replace(/\\n/g, "\n");
  normalized = normalized.replace(/\\r/g, "");
  normalized = normalized.replace(/\r\n/g, "\n");
  return normalized.trim();
}

function validatePrivateKey(key: string): void {
  if (!key.includes("-----BEGIN PRIVATE KEY-----") || !key.includes("-----END PRIVATE KEY-----")) {
    throw new Error("FCM_SERVICE_ACCOUNT_PRIVATE_KEY is not a valid PEM private key");
  }
}

const FCM_PRIVATE_KEY = normalizePrivateKey(FCM_PRIVATE_KEY_RAW);
validatePrivateKey(FCM_PRIVATE_KEY);

// 3. Google Access Token Caching
let cachedAccessToken: string | null = null;
let cachedAccessTokenExpiresAt = 0;

async function getAccessToken(): Promise<string> {
  const now = Date.now();
  if (cachedAccessToken && now < cachedAccessTokenExpiresAt - 60_000) {
    return cachedAccessToken;
  }

  const jwtClient = new JWT({
    email: FCM_CLIENT_EMAIL,
    key: FCM_PRIVATE_KEY,
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });

  const tokens = await new Promise<Awaited<ReturnType<typeof jwtClient.authorize>>>((resolve, reject) => {
    jwtClient.authorize((err, result) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(result);
    });
  });

  const accessToken = tokens?.access_token;
  if (!accessToken) {
    throw new Error("Google authentication succeeded but no access token was returned");
  }

  cachedAccessToken = accessToken;
  cachedAccessTokenExpiresAt = tokens.expiry_date ?? (Date.now() + 50 * 60 * 1000);
  return accessToken;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    },
  });
}

// 4. Send Push Notification via Firebase Cloud Messaging HTTP v1 API
async function sendFcmNotification(fcmToken: string, notification: NotificationRecord): Promise<Response> {
  const accessToken = await getAccessToken();

  const title = notification.title?.trim() || "Application Status Updated";
  const body = notification.body.trim();
  const notificationId = notification.id || "";
  const applicationId = notification.application_id || "";

  const dataPayload: Record<string, string> = {
    notification_id: String(notificationId),
    type: notification.type?.trim() || "application_status_update",
    title: title,
    body: body,
    click_action: "FLUTTER_NOTIFICATION_CLICK",
  };

  if (applicationId) {
    dataPayload.application_id = String(applicationId);
  }

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${encodeURIComponent(FCM_PROJECT_ID!)}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          notification: {
            title,
            body,
          },
          data: dataPayload,
          android: {
            priority: "HIGH",
            notification: {
              channel_id: "high_importance_channel",
              icon: "ic_notification",
              color: "#083ea7",
              sound: "default",
              default_sound: true,
              default_vibrate_timings: true,
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        },
      }),
    }
  );

  const responseText = await response.text();
  let responseData: unknown;

  try {
    responseData = responseText ? JSON.parse(responseText) : {};
  } catch {
    responseData = { raw_response: responseText };
  }

  if (!response.ok) {
    const fcmError = responseData as FcmErrorResponse;
    const errorStatus = fcmError?.error?.status;

    // UNREGISTERED / NOT_FOUND means the FCM token is stale or revoked.
    if (errorStatus === "UNREGISTERED" || errorStatus === "NOT_FOUND") {
      const targetUserId = notification.user_id || notification.profile_id;
      if (targetUserId) {
        await supabaseAdmin
          .from("profiles")
          .update({ fcm_token: null })
          .eq("id", targetUserId);
      }

      return jsonResponse({
        success: false,
        reason: "FCM_TOKEN_INVALID",
        notification_id: notificationId,
      }, 200);
    }

    return jsonResponse({
      success: false,
      reason: "FCM_SEND_FAILED",
      fcm_status: errorStatus ?? null,
      fcm_error_code: fcmError?.error?.code ?? null,
      fcm_message: fcmError?.error?.message ?? null,
      notification_id: notificationId,
    }, response.status);
  }

  return jsonResponse({
    success: true,
    notification_id: notificationId,
    fcm_response: responseData,
  });
}

// 5. Main Request Handler (Deno.serve for Supabase Edge Functions)
Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  let payload: WebhookPayload;
  try {
    payload = await req.json();
  } catch {
    return jsonResponse({ error: "Invalid JSON request body" }, 400);
  }

  // Extract notification from webhook payload or direct POST
  const notification: NotificationRecord = payload.record ?? payload;
  const userId = notification.user_id || notification.profile_id;

  if (!userId) {
    return jsonResponse({ error: "Missing notification user_id" }, 400);
  }

  if (!notification.body || !notification.body.trim()) {
    return jsonResponse({ error: "Notification body is empty" }, 400);
  }

  // Fetch citizen's FCM token from profiles
  const { data: profile, error: profileError } = await supabaseAdmin
    .from("profiles")
    .select("fcm_token")
    .eq("id", userId)
    .maybeSingle();

  if (profileError) {
    console.error("Failed to retrieve user profile:", profileError.message);
    return jsonResponse({ error: "Failed to retrieve user profile" }, 500);
  }

  if (!profile) {
    return jsonResponse({
      success: false,
      reason: "USER_PROFILE_NOT_FOUND",
      notification_id: notification.id,
    }, 200);
  }

  const fcmToken = typeof profile.fcm_token === "string" ? profile.fcm_token.trim() : "";

  if (!fcmToken) {
    return jsonResponse({
      success: false,
      reason: "MISSING_FCM_TOKEN",
      notification_id: notification.id,
    }, 200);
  }

  try {
    return await sendFcmNotification(fcmToken, notification);
  } catch (error) {
    console.error("FCM notification failed:", error instanceof Error ? error.message : String(error));
    return jsonResponse({
      success: false,
      reason: "FCM_NOTIFICATION_ERROR",
      notification_id: notification.id,
    }, 500);
  }
});