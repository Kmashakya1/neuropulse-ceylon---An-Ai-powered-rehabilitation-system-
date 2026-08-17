const crypto = require("crypto");

// scrypt from Node's own crypto, not bcrypt. bcrypt needs a native build step,
// which is exactly the kind of thing that broke the React Native build on this
// machine. scrypt is memory-hard, ships with Node, and needs no toolchain.
const KEY_LENGTH = 64;

/** `scrypt$<salt hex>$<derived key hex>` — salt travels with the hash. */
function hashSecret(plain) {
  const salt = crypto.randomBytes(16);
  const derived = crypto.scryptSync(String(plain), salt, KEY_LENGTH);
  return `scrypt$${salt.toString("hex")}$${derived.toString("hex")}`;
}

/**
 * Compare in constant time. A plain `===` on the hex strings leaks how many
 * leading characters matched, which is enough to brute-force a 4-digit PIN one
 * digit at a time.
 */
function verifySecret(plain, stored) {
  if (typeof stored !== "string") return false;

  const [scheme, saltHex, keyHex] = stored.split("$");
  if (scheme !== "scrypt" || !saltHex || !keyHex) return false;

  let expected;
  let actual;
  try {
    expected = Buffer.from(keyHex, "hex");
    actual = crypto.scryptSync(
      String(plain),
      Buffer.from(saltHex, "hex"),
      expected.length
    );
  } catch {
    return false;
  }

  return (
    expected.length === actual.length &&
    crypto.timingSafeEqual(expected, actual)
  );
}

function newToken() {
  return crypto.randomBytes(32).toString("hex");
}

module.exports = { hashSecret, verifySecret, newToken };
