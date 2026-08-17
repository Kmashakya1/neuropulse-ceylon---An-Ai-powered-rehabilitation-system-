const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/auth", require("./routes/auth"));
app.use("/api/alerts", require("./routes/alerts"));

app.get("/", (req, res) => {
  res.send("NeuroPulse Backend Running");
});

// Bound to every interface, not just loopback: a phone on the same Wi-Fi has to
// reach this, and the default would only serve the host machine.
const PORT = 5000;
const HOST = "0.0.0.0";

app.listen(PORT, HOST, () => {
  console.log(`Server Running On ${HOST}:${PORT}`);
});