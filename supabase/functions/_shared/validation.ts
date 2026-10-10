// supabase/functions/_shared/validation.ts

export interface ValidationResult {
  valid: boolean;
  reason?: string;
  normalizedPhone?: string;
  sanitizedName?: string;
  sanitizedNote?: string;
}

/**
 * Normalizes and validates Indian phone numbers.
 * Must be 10 digits, start with 6-9, and not match sequential or identical digit patterns.
 */
export function validatePhone(phone: unknown): { valid: boolean; normalized?: string; reason?: string } {
  if (typeof phone !== "string") {
    return { valid: false, reason: "Phone must be a string" };
  }

  // Strip country code, spaces, hyphens and any non-numeric character
  let clean = phone.replace(/\D/g, "");
  if (clean.length > 10 && clean.startsWith("91")) {
    clean = clean.slice(2);
  } else if (clean.length > 10) {
    clean = clean.slice(-10);
  }

  if (clean.length !== 10) {
    return { valid: false, reason: "Phone must be exactly 10 digits" };
  }

  // Indian mobile numbers must start with 6, 7, 8, or 9
  if (!/^[6-9]/.test(clean)) {
    return { valid: false, reason: "Phone number must start with 6, 7, 8, or 9" };
  }

  // Reject all identical digits (e.g. 9999999999, 8888888888)
  if (/^(\d)\1{9}$/.test(clean)) {
    return { valid: false, reason: "Phone cannot consist of repeated single digit" };
  }

  // Reject common sequential patterns
  const sequences = [
    "1234567890",
    "0123456789",
    "9876543210",
    "0987654321",
  ];
  if (sequences.includes(clean)) {
    return { valid: false, reason: "Phone cannot be a sequential digit series" };
  }

  return { valid: true, normalized: clean };
}

/**
 * Strips ASCII control characters except newline and tab.
 */
export function stripControlCharacters(str: string): string {
  // Removes control chars 0x00-0x08, 0x0B-0x0C, 0x0E-0x1F, 0x7F
  return str.replace(/[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]/g, "").trim();
}

/**
 * Sanitizes name and note.
 */
export function sanitizeText(
  value: unknown,
  maxLength: number
): { valid: boolean; sanitized?: string; reason?: string } {
  if (value === undefined || value === null || value === "") {
    return { valid: true, sanitized: undefined };
  }

  if (typeof value !== "string") {
    return { valid: false, reason: "Expected string value" };
  }

  const cleaned = stripControlCharacters(value);
  if (cleaned.length > maxLength) {
    return { valid: false, reason: `Length exceeds maximum of ${maxLength}` };
  }

  return { valid: true, sanitized: cleaned };
}
