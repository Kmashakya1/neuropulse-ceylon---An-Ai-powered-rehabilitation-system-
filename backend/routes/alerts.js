const express = require("express");

const router = express.Router();

// TEMPORARY TEST ALERT
let latestAlert = {
patient: "John",
status: "Fall Detected",
time: new Date().toISOString()
};

// POST alert from Python
router.post("/", (req, res) => {

console.log("🚨 FALL ALERT RECEIVED");
console.log(req.body);

latestAlert = {
patient: req.body.patient || "John",
status: req.body.status || "Fall Detected",
time: new Date().toISOString()
};

res.json({
success: true,
message: "Emergency Alert Sent"
});

});

// GET latest alert
router.get("/latest", (req, res) => {

res.json(latestAlert);

});

// Test route
router.get("/test", (req, res) => {

res.json({
success: true,
message: "Alerts Route Working"
});

});

module.exports = router;
