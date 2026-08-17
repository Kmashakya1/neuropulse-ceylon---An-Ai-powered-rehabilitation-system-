const store = require("../store/users");

/** Reads `Authorization: Bearer <token>` and attaches the user, or 401s. */
function requireAuth(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7).trim() : "";

  if (!token) {
    return res.status(401).json({ error: "missing_token" });
  }

  const user = store.userForToken(token);
  if (!user) {
    // Covers both a token we never issued and one that logout has revoked.
    return res.status(401).json({ error: "invalid_token" });
  }

  req.token = token;
  req.user = user;
  next();
}

module.exports = requireAuth;
