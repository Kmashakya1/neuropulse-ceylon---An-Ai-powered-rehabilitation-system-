import cv2
import mediapipe.tasks.python as mp_python
pose = mp_pose.Pose(
    static_image_mode=False,
    model_complexity=0,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5
)

# =====================================
# LOAD EXERCISE VIDEO
# =====================================

exercise_video = cv2.VideoCapture(
    "assets/videos/exercises/5 Exercises for Stroke Recovery.mp4"
)

# =====================================
# OPEN LIVE CAMERA
# =====================================

camera = cv2.VideoCapture(0)

# =====================================
# CHECK VIDEO
# =====================================

if not exercise_video.isOpened():
    print("ERROR: Exercise video not found")
    exit()

if not camera.isOpened():
    print("ERROR: Camera not working")
    exit()

# =====================================
# VARIABLES
# =====================================

rep_count = 0
arm_up = False

# =====================================
# MAIN LOOP
# =====================================

while True:

    # =====================================
    # READ VIDEO FRAME
    # =====================================

    video_success, video_frame = exercise_video.read()

    # RESTART VIDEO IF FINISHED

    if not video_success:

        exercise_video.set(
            cv2.CAP_PROP_POS_FRAMES,
            0
        )

        video_success, video_frame = exercise_video.read()

    # =====================================
    # READ CAMERA FRAME
    # =====================================

    cam_success, cam_frame = camera.read()

    if not cam_success:
        break

    # =====================================
    # FLIP CAMERA
    # =====================================

    cam_frame = cv2.flip(cam_frame, 1)

    # =====================================
    # RESIZE
    # =====================================

    video_frame = cv2.resize(
        video_frame,
        (640,480)
    )

    cam_frame = cv2.resize(
        cam_frame,
        (640,480)
    )

    # =====================================
    # CONVERT TO RGB
    # =====================================

    video_rgb = cv2.cvtColor(
        video_frame,
        cv2.COLOR_BGR2RGB
    )

    cam_rgb = cv2.cvtColor(
        cam_frame,
        cv2.COLOR_BGR2RGB
    )

    # =====================================
    # DETECT POSE
    # =====================================

    video_results = pose.process(video_rgb)

    cam_results = pose.process(cam_rgb)

    # =====================================
    # DRAW VIDEO SKELETON
    # =====================================

    if video_results.pose_landmarks:

        mp_draw.draw_landmarks(
            video_frame,
            video_results.pose_landmarks,
            mp_pose.POSE_CONNECTIONS,
            mp_draw.DrawingSpec(
                color=(0,255,0),
                thickness=2,
                circle_radius=2
            ),
            mp_draw.DrawingSpec(
                color=(255,0,0),
                thickness=2
            )
        )

    # =====================================
    # DRAW CAMERA SKELETON
    # =====================================

    if cam_results.pose_landmarks:

        mp_draw.draw_landmarks(
            cam_frame,
            cam_results.pose_landmarks,
            mp_pose.POSE_CONNECTIONS,
            mp_draw.DrawingSpec(
                color=(0,255,0),
                thickness=2,
                circle_radius=2
            ),
            mp_draw.DrawingSpec(
                color=(255,0,0),
                thickness=2
            )
        )

        landmarks = cam_results.pose_landmarks.landmark

        # =====================================
        # LEFT ARM LANDMARKS
        # =====================================

        shoulder = landmarks[
            mp_pose.PoseLandmark.LEFT_SHOULDER
        ]

        elbow = landmarks[
            mp_pose.PoseLandmark.LEFT_ELBOW
        ]

        wrist = landmarks[
            mp_pose.PoseLandmark.LEFT_WRIST
        ]

        # =====================================
        # ARM RAISE DETECTION
        # =====================================

        if wrist.y < shoulder.y:

            if not arm_up:

                rep_count += 1
                arm_up = True

        else:

            arm_up = False

        # =====================================
        # AI FEEDBACK
        # =====================================

        if wrist.y < shoulder.y:

            feedback = "Correct Movement"
            color = (0,255,0)

        elif wrist.y < elbow.y:

            feedback = "Raise Arm Higher"
            color = (0,255,255)

        else:

            feedback = "Incorrect Position"
            color = (0,0,255)

        # =====================================
        # DISPLAY FEEDBACK
        # =====================================

        cv2.putText(
            cam_frame,
            feedback,
            (20,50),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            color,
            3
        )

        cv2.putText(
            cam_frame,
            f"Reps: {rep_count}",
            (20,100),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (255,255,255),
            3
        )

    # =====================================
    # TITLES
    # =====================================

    cv2.putText(
        video_frame,
        "REFERENCE EXERCISE",
        (20,40),
        cv2.FONT_HERSHEY_SIMPLEX,
        1,
        (255,255,255),
        3
    )

    cv2.putText(
        cam_frame,
        "LIVE PATIENT TRACKING",
        (20,40),
        cv2.FONT_HERSHEY_SIMPLEX,
        1,
        (255,255,255),
        3
    )

    # =====================================
    # COMBINE BOTH SCREENS
    # =====================================

    combined = cv2.hconcat([
        video_frame,
        cam_frame
    ])

    # =====================================
    # SHOW WINDOW
    # =====================================

    cv2.imshow(
        "NeuroPulse AI Rehabilitation",
        combined
    )

    # =====================================
    # PRESS Q TO EXIT
    # =====================================

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# =====================================
# RELEASE EVERYTHING
# =====================================

exercise_video.release()
camera.release()

cv2.destroyAllWindows()