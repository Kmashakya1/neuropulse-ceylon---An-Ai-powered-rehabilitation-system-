#!/usr/bin/env node
/**
 * Adds an account to data/users.json.
 *
 * The seed list in store/users.js only runs when that file does not yet exist,
 * so once the service has started once, this is how new accounts are made — the
 * secrets are stored as scrypt hashes and cannot be hand-written into the JSON.
 *
 *   node tools/add-user.js --role patient --username asela --name "Asela Jayasuriya" --pin 4321
 *   node tools/add-user.js --role physio --email nayana@neuropulse.lk --name "Dr. Nayana" --password secret123
 *
 * Optional for patients: --age 60 --stroke ischemic
 */
const fs = require("fs");
const path = require("path");

const { hashSecret } = require("../auth/secrets");

const USERS_FILE = path.join(__dirname, "..", "data", "users.json");
const ROLES = ["patient", "caregiver", "physio"];

function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i += 2) {
    const flag = argv[i];
    if (!flag.startsWith("--")) {
      throw new Error(`expected a --flag, got "${flag}"`);
    }
    const value = argv[i + 1];
    if (value === undefined) throw new Error(`${flag} needs a value`);
    out[flag.slice(2)] = value;
  }
  return out;
}

function fail(message) {
  console.error(`\nadd-user: ${message}\n`);
  console.error("Usage:");
  console.error(
    '  node tools/add-user.js --role patient --username <name> --name "<full name>" --pin 1234'
  );
  console.error(
    '  node tools/add-user.js --role physio --email <addr> --name "<full name>" --password <secret>'
  );
  process.exit(1);
}

const args = (() => {
  try {
    return parseArgs(process.argv.slice(2));
  } catch (error) {
    return fail(error.message);
  }
})();

const role = args.role;
if (!ROLES.includes(role)) fail(`--role must be one of ${ROLES.join(", ")}`);
if (!args.name) fail("--name is required");

const isPatient = role === "patient";
const secret = isPatient ? args.pin : args.password;

if (isPatient) {
  if (!args.username) fail("patients need --username");
  if (!/^\d{4}$/.test(String(secret || ""))) {
    fail("patients need --pin as exactly four digits");
  }
} else {
  if (!args.email) fail("staff need --email");
  if (!secret || String(secret).length < 8) {
    fail("staff need --password of at least 8 characters");
  }
}

const users = (() => {
  try {
    return JSON.parse(fs.readFileSync(USERS_FILE, "utf8"));
  } catch {
    fail(
      `cannot read ${USERS_FILE}. Start the server once so the seed accounts are created.`
    );
  }
})();

const username = (args.username || "").trim().toLowerCase();
const email = (args.email || "").trim().toLowerCase();

// Both are used as login keys, so a duplicate would make one account
// unreachable rather than merely being untidy.
if (username && users.some((u) => (u.username || "").toLowerCase() === username)) {
  fail(`username "${username}" is already taken`);
}
if (email && users.some((u) => (u.email || "").toLowerCase() === email)) {
  fail(`email "${email}" is already taken`);
}

const id = `${role}-${username || email.split("@")[0]}`;
if (users.some((u) => u.id === id)) fail(`id "${id}" is already taken`);

const record = {
  id,
  role,
  name: args.name,
  secretHash: hashSecret(secret),
};
if (username) record.username = username;
if (email) record.email = email;
if (isPatient) {
  if (args.age) record.age = Number(args.age);
  if (args.stroke) record.strokeType = args.stroke;
}

// Write the hash last so a validation failure above never leaves a half-written
// account behind.
users.push(record);
fs.writeFileSync(USERS_FILE, JSON.stringify(users, null, 2), "utf8");

console.log(`\nCreated ${role} "${args.name}"`);
console.log(`  sign in with  ${isPatient ? username : email}`);
console.log(`  ${isPatient ? "PIN" : "password"}           ${secret}`);
console.log("\nRestart the server so it picks up the new account.\n");
