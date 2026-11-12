// supabase/functions/_shared/captcha.ts

import { hashWithPepper } from "./hash.ts";

export interface CaptchaChallenge {
  question: string;
  token: string;
}

/**
 * Generates a signed, lightweight math challenge that expires in 5 minutes.
 * Requires no external network calls, 100% self-contained and tamper-proof.
 */
export async function generateCaptchaChallenge(): Promise<CaptchaChallenge> {
  const a = Math.floor(Math.random() * 12) + 3; // 3 to 14
  const b = Math.floor(Math.random() * 9) + 2; // 2 to 10
  const sum = a + b;
  const exp = Date.now() + 5 * 60 * 1000; // 5 minutes validity
  const payload = `${a}:${b}:${sum}:${exp}`;
  const sig = await hashWithPepper(`captcha:${payload}`);
  const token = btoa(`${payload}:${sig}`);

  return {
    question: `${a} + ${b} = ?`,
    token,
  };
}

/**
 * Validates a submitted captcha token and solution against the HMAC signature and expiry.
 */
export async function verifyCaptchaSolution(
  token: unknown,
  solution: unknown
): Promise<{ valid: boolean; reason?: string }> {
  if (typeof token !== "string" || !token.trim()) {
    return { valid: false, reason: "Missing verification token" };
  }
  if (solution === undefined || solution === null || String(solution).trim() === "") {
    return { valid: false, reason: "Missing verification answer" };
  }

  let decoded = "";
  try {
    decoded = atob(token.trim());
  } catch (_) {
    return { valid: false, reason: "Malformed verification token" };
  }

  const parts = decoded.split(":");
  if (parts.length !== 5) {
    return { valid: false, reason: "Invalid verification token structure" };
  }

  const [aStr, bStr, sumStr, expStr, sig] = parts;
  const payload = `${aStr}:${bStr}:${sumStr}:${expStr}`;
  const expectedSig = await hashWithPepper(`captcha:${payload}`);
  if (sig !== expectedSig) {
    return { valid: false, reason: "Verification token signature mismatch" };
  }

  const exp = parseInt(expStr, 10);
  if (isNaN(exp) || Date.now() > exp) {
    return { valid: false, reason: "Verification challenge expired" };
  }

  const cleanAns = String(solution).trim();
  if (cleanAns !== sumStr) {
    return { valid: false, reason: "Incorrect verification answer" };
  }

  return { valid: true };
}

