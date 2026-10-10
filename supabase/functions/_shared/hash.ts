// supabase/functions/_shared/hash.ts

const HASH_PEPPER = Deno.env.get("HASH_PEPPER") ?? "ns-pepper-default-secret-salt";

/**
 * Computes a SHA-256 peppered hex hash of the given value.
 * Raw values (IP, device_id, phone) are never stored in plain text.
 */
export async function hashWithPepper(value: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(`${value}:${HASH_PEPPER}`);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}
