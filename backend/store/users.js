const fs = require("fs");
const path = require("path");

const { hashSecret } = require("../auth/secrets");

// The whole persistence layer lives behind this module, so swapping the JSON
// file for the mongoose models already in package.json means rewriting this file
// and nothing else. Routes only ever call the functions exported here.
const DATA_DIR = path.join(__dirname, "..", "data");
const USERS_FILE = path.join(DATA_DIR, "users.json");
const SESSIONS_FILE = path.join(DATA_DIR, "sessions.json");

/**
 * Demo accounts, written on first run only.
 *
 * These are seed credentials for a research demo, not production accounts —
 * they are printed to the console on creation so they can be used, which is
 * precisely why they must be replaced before this is put in front of real
 * patients. Patients sign in with a username and a 4-digit PIN; staff sign in
 * with an email and a password.
 *
 * Add more with `node tools/add-user.js` rather than editing this list — the
 * seed only runs when data/users.json does not already exist.
 */
const SEED = [
  // --- Patients: sign in with a username and a 4-digit PIN ---
  {
    id: "patient-john",
    role: "patient",
    username: "john",
    name: "John Fernando",
    secret: "1234",
    age: 62,
    strokeType: "ischemic",
  },
  {
    id: "patient-nimal",
    role: "patient",
    username: "nimal",
    name: "Nimal Perera",
    secret: "5678",
    age: 64,
    strokeType: "ischemic",
  },
  {
    id: "patient-kamala",
    role: "patient",
    username: "kamala",
    name: "Kamala Silva",
    secret: "2468",
    age: 58,
    strokeType: "haemorrhagic",
  },
  {
    id: "patient-ravi",
    role: "patient",
    username: "ravi",
    name: "Ravi Kumar",
    secret: "1357",
    age: 71,
    strokeType: "ischemic",
  },

  // --- Staff: sign in with an email and a password ---
  {
    id: "caregiver-sarah",
    role: "caregiver",
    username: "sarah",
    name: "Sarah Fernando",
    email: "caregiver@neuropulse.lk",
    secret: "caregiver123",
  },
  {
    id: "caregiver-anoma",
    role: "caregiver",
    username: "anoma",
    name: "Anoma Perera",
    email: "anoma@neuropulse.lk",
    secret: "anoma123",
  },
  {
    id: "physio-jenkins",
    role: "physio",
    username: "jenkins",
    name: "Dr. Sarah Jenkins",
    email: "physio@neuropulse.lk",
    secret: "physio123",
  },
  {
    id: "physio-nuwan",
    role: "physio",
    username: "nuwan",
    name: "Dr. Nuwan Bandara",
    email: "nuwan@neuropulse.lk",
    secret: "nuwan123",
  },
];

function readJson(file, fallback) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch {
    // Missing or corrupt: treat as empty rather than crashing the server on boot.
    return fallback;
  }
}

function writeJson(file, value) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
  fs.writeFileSync(file, JSON.stringify(value, null, 2), "utf8");
}

let users = readJson(USERS_FILE, null);
let sessions = readJson(SESSIONS_FILE, {});

if (!Array.isArray(users) || users.length === 0) {
  users = SEED.map(({ secret, ...rest }) => ({
    ...rest,
    secretHash: hashSecret(secret),
  }));
  writeJson(USERS_FILE, users);

  console.log("\nSeeded demo accounts (change these before real use):");
  for (const seed of SEED) {
    // Patients sign in with the username; staff sign in with the email.
    const who = seed.role === "patient" ? seed.username : seed.email;
    const label = seed.role === "patient" ? "PIN     " : "password";
    console.log(
      `  ${seed.role.padEnd(9)} ${String(who).padEnd(24)} ${label} ` +
        `${String(seed.secret).padEnd(13)} ${seed.name}`
    );
  }
  console.log("");
}

/** Never leave this module with a hash attached. */
function publicUser(user) {
  if (!user) return null;
  const { secretHash, ...safe } = user;
  return safe;
}

function findById(id) {
  return users.find((u) => u.id === id) || null;
}

function findByEmail(email) {
  const wanted = String(email || "").trim().toLowerCase();
  if (!wanted) return null;
  return users.find((u) => (u.email || "").toLowerCase() === wanted) || null;
}

function findByUsername(username) {
  const wanted = String(username || "").trim().toLowerCase();
  if (!wanted) return null;
  return users.find((u) => (u.username || "").toLowerCase() === wanted) || null;
}

/**
 * Adds an account and persists it. Callers are expected to have validated the
 * fields and checked for duplicates already — this only guards the id, which is
 * derived rather than user-supplied.
 */
function createUser({ role, name, username, email, secret, age, strokeType }) {
  const base = `${role}-${username || String(email).split("@")[0]}`;
  let id = base;
  for (let n = 2; findById(id); n += 1) id = `${base}-${n}`;

  const record = { id, role, name, secretHash: hashSecret(secret) };
  if (username) record.username = username;
  if (email) record.email = email;
  if (age != null) record.age = age;
  if (strokeType) record.strokeType = strokeType;

  users.push(record);
  writeJson(USERS_FILE, users);
  return record;
}

function createSession(userId) {
  const { newToken } = require("../auth/secrets");
  const token = newToken();
  sessions[token] = { userId, createdAt: new Date().toISOString() };
  writeJson(SESSIONS_FILE, sessions);
  return token;
}

/**
 * Tokens are opaque and stored server-side rather than self-contained JWTs,
 * specifically so that logout can revoke one. A JWT stays valid until it
 * expires no matter how many times the user presses "log out".
 */
function userForToken(token) {
  const session = sessions[token];
  if (!session) return null;
  return findById(session.userId);
}

function destroySession(token) {
  if (!sessions[token]) return false;
  delete sessions[token];
  writeJson(SESSIONS_FILE, sessions);
  return true;
}

module.exports = {
  publicUser,
  findById,
  findByEmail,
  findByUsername,
  createUser,
  createSession,
  userForToken,
  destroySession,
};
