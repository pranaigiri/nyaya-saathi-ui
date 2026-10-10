// supabase/functions/_shared/app_check.ts

/**
 * Verifies a Firebase App Check token if enabled.
 * If FIREBASE_APP_CHECK_ENABLED is false or unset, verification is skipped.
 */
export async function verifyAppCheckToken(
  token: unknown
): Promise<{ valid: boolean; reason?: string }> {
  const isEnabled = Deno.env.get("FIREBASE_APP_CHECK_ENABLED") === "true";
  if (!isEnabled) {
    return { valid: true };
  }

  if (typeof token !== "string" || !token.trim()) {
    return { valid: false, reason: "Missing App Check token" };
  }

  const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
  if (!projectId) {
    console.error("FIREBASE_APP_CHECK_ENABLED is true but FIREBASE_PROJECT_ID is not configured");
    return { valid: false, reason: "App Check server configuration missing" };
  }

  try {
    // Call Firebase App Check REST API to verify token
    const verifyUrl = `https://firebaseappcheck.googleapis.com/v1beta/projects/${projectId}:verifyAppCheckToken`;
    const response = await fetch(verifyUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        appCheckToken: token,
      }),
    });

    if (!response.ok) {
      return { valid: false, reason: "Invalid or expired App Check token" };
    }

    return { valid: true };
  } catch (err) {
    console.error("Error verifying App Check token:", err);
    return { valid: false, reason: "App Check verification failure" };
  }
}
