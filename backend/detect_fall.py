from ultralytics import YOLO
import cv2
import requests
import time

# Load trained model
model = YOLO("models/best.pt")

# Open webcam
cap = cv2.VideoCapture(0)

# Prevent duplicate alerts
last_alert_time = 0
ALERT_COOLDOWN = 30

# Require longer FALL detection
fall_counter = 0
FALL_THRESHOLD = 120

# Class mapping
class_names = {
    0: "FALL",
    1: "STANDING",
    2: "SITTING"
}

while True:

    success, frame = cap.read()

    if not success:
        print("Camera Error")
        break

    # Run detection
    results = model(frame, conf=0.70)

    result = results[0]

    # Draw boxes
    annotated = result.plot()

    detected_fall = False

    if len(result.boxes) > 0:

        for box in result.boxes:

            cls_id = int(box.cls[0])
            confidence = float(box.conf[0])

            label = class_names.get(
                cls_id,
                f"class{cls_id}"
            )

            print(
                f"Detected: {label} ({confidence:.2f})"
            )

            if label == "FALL":
                detected_fall = True

    # Count consecutive FALL detections
    if detected_fall:

        fall_counter += 1

        print(
            f"Fall Counter: {fall_counter}/{FALL_THRESHOLD}"
        )

    else:

        if fall_counter > 0:
            print("Fall Counter Reset")

        fall_counter = 0

    # Trigger alert only after sustained FALL
    if fall_counter >= FALL_THRESHOLD:

        current_time = time.time()

        if (
            current_time - last_alert_time
            > ALERT_COOLDOWN
        ):

            try:

                response = requests.post(
                    "http://10.127.253.26:5000/api/alerts",
                    json={
                        "patient": "John",
                        "status": "Fall Detected"
                    },
                    timeout=5
                )

                print("🚨 FALL ALERT SENT")
                print(response.json())

                last_alert_time = current_time

            except Exception as e:

                print(
                    "❌ Alert Error:",
                    e
                )

            # Reset counter
            fall_counter = 0

    cv2.imshow(
        "NeuroPulse Fall Detection",
        annotated
    )

    # Press Q to quit
    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

cap.release()
cv2.destroyAllWindows()