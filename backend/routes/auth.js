const express = require("express");

const { verifySecret } = require("../auth/secrets");
const requireAuth = require("../middleware/requireAuth");
const store = require("../store/users");

const router = express.Router();

const STAFF_ROLES = ["caregiver", "physio"];

/**
 * Rate limiting, keyed by account rather than by IP.
 *
 * A 4-digit PIN is only 10,000 guesses, and the whole point of the PIN keypad is
 * that a patient does not have to type a password. Without a lockout that trade
 * would be indefensible, so wrong attempts back off: five strikes and the
 * account is closed for a minute.
 */
const ATTEMPT_LIMIT = 5;
const LOCKOUT_MS = 60 * 1000;
const attempts = new Map();

function lockedFor(key) {
  const record = attempts.get(key);
  if (!record || record.count < ATTEMPT_LIMIT) return 0;
  const remaining = record.until - Date.now();
  if (remaining <= 0) {
    attempts.delete(key);
    return 0;
  }
  return remaining;
}

function recordFailure(key) {
  const record = attempts.get(key) || { count: 0, until: 0 };
  record.count += 1;
  record.until = Date.now() + LOCKOUT_MS;
  attempts.set(key, record);
}

function signIn(res, user) {
  const token = store.createSession(user.id);
  res.json({ token, user: store.publicUser(user) });
}

// Patient sign-in: a typed username plus a 4-digit PIN.
router.post("/login/patient", (req, res) => {
  const { username, pin } = req.body || {};

  if (!username || !pin) {
    return res.status(400).json({ error: "missing_credentials" });
  }

  const key = String(username).trim().toLowerCase();
  const wait = lockedFor(key);
  if (wait > 0) {
    return res
      .status(429)
      .json({ error: "too_many_attempts", retryAfterMs: wait });
  }

  const user = store.findByUsername(key);

  // Identical response whether the username is unknown or the PIN is wrong, so
  // this cannot be used to discover which accounts exist.
  if (!user || user.role !== "patient" || !verifySecret(pin, user.secretHash)) {
    recordFailure(key);
    return res.status(401).json({ error: "invalid_credentials" });
  }

  attempts.delete(key);
  signIn(res, user);
});

// Staff sign-in: email plus password, for caregivers and physiotherapists.
router.post("/login/staff", (req, res) => {
  const { email, password } = req.body || {};

  if (!email || !password) {
    return res.status(400).json({ error: "missing_credentials" });
  }

  const key = String(email).trim().toLowerCase();
  const wait = lockedFor(key);
  if (wait > 0) {
    return res
      .status(429)
      .json({ error: "too_many_attempts", retryAfterMs: wait });
  }

  const user = store.findByEmail(email);

  if (
    !user ||
    !STAFF_ROLES.includes(user.role) ||
    !verifySecret(password, user.secretHash)
  ) {
    recordFailure(key);
    return res.status(401).json({ error: "invalid_credentials" });
  }

  attempts.delete(key);
  signIn(res, user);
});

// Same rules as tools/add-user.js, applied to self-service sign-up. Usernames
// are login keys typed on a phone, so they are kept short and lowercase.
const USERNAME_RE = /^[a-z0-9][a-z0-9._-]{2,19}$/;
const PIN_RE = /^\d{4}$/;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PASSWORD_MIN = 8;

// Patient sign-up: username, 4-digit PIN and a display name. Signs the new
// account in immediately — a patient should never have to type the PIN twice
// in a row to start using the app.
router.post("/register/patient", (req, res) => {
  const { username, pin, name, age, strokeType } = req.body || {};

  const key = String(username || "").trim().toLowerCase();
  const fullName = String(name || "").trim();

  if (!key || !fullName || !pin) {
    return res.status(400).json({ error: "missing_fields" });
  }
  if (!USERNAME_RE.test(key)) {
    return res.status(400).json({ error: "invalid_username" });
  }
  if (!PIN_RE.test(String(pin))) {
    return res.status(400).json({ error: "invalid_pin" });
  }
  // Registration necessarily reveals whether a username exists; that is fine
  // here because usernames are not secret, only PINs are.
  if (store.findByUsername(key)) {
    return res.status(409).json({ error: "username_taken" });
  }

  const parsedAge = Number(age);
  const user = store.createUser({
    role: "patient",
    username: key,
    name: fullName,
    secret: String(pin),
    age: Number.isFinite(parsedAge) && parsedAge > 0 ? parsedAge : undefined,
    strokeType: strokeType ? String(strokeType) : undefined,
  });

  signIn(res, user);
});

// Staff sign-up: caregivers and physiotherapists, with email and password.
router.post("/register/staff", (req, res) => {
  const { email, password, name, role } = req.body || {};

  const key = String(email || "").trim().toLowerCase();
  const fullName = String(name || "").trim();

  if (!key || !fullName || !password || !role) {
    return res.status(400).json({ error: "missing_fields" });
  }
  if (!STAFF_ROLES.includes(role)) {
    return res.status(400).json({ error: "invalid_role" });
  }
  if (!EMAIL_RE.test(key)) {
    return res.status(400).json({ error: "invalid_email" });
  }
  if (String(password).length < PASSWORD_MIN) {
    return res.status(400).json({ error: "password_too_short" });
  }
  if (store.findByEmail(key)) {
    return res.status(409).json({ error: "email_taken" });
  }

  const user = store.createUser({
    role,
    email: key,
    name: fullName,
    secret: String(password),
  });

  signIn(res, user);
});

/** Confirms a restored token is still good, and refreshes the cached profile. */
router.get("/me", requireAuth, (req, res) => {
  res.json({ user: store.publicUser(req.user) });
});

// Revokes the token server-side, so a stolen one is dead the moment the real
// user logs out.
router.post("/logout", requireAuth, (req, res) => {
  store.destroySession(req.token);
  res.json({ success: true });
});

module.exports = router;
