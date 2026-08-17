import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config.dart';
import 'feedback.dart';
import 'frame_envelope.dart';

/// Drives a live exercise session: camera frames out, feedback in.
///
/// Two rules govern the sending side:
///
///  * Throttle to [targetFps]. MediaPipe on the server is slower than the camera,
///    so an unthrottled stream builds a backlog and the patient sees feedback for
///    a movement they finished seconds ago.
///  * Never queue. If a send is still outstanding when the next frame arrives,
///    drop the new frame. The freshest pose is the only one worth showing, and a
///    queue converts a temporary slowdown into permanent lag.
class PoseSession extends ChangeNotifier {
  PoseSession({
    required this.exercise,
    // Falls back only if somehow reached without a session; every real entry
    // point is behind sign-in.
    this.patient = 'unknown',
    this.lang = 'en',
    this.targetFps = 10,
    this.onFall,
  });

  final String exercise;
  final String patient;
  final String lang;
  final int targetFps;
  final VoidCallback? onFall;

  CameraController? _camera;
  WebSocketChannel? _socket;
  StreamSubscription<dynamic>? _incoming;

  bool _connected = false;
  bool _inFlight = false;
  bool _closed = false;
  int _lastSentMs = 0;
  int _sent = 0;
  int _dropped = 0;
  DateTime? _startedAt;

  PoseFeedback? _feedback;
  String? _error;
  bool _fallReported = false;

  bool get connected => _connected;
  bool get ready => _camera?.value.isInitialized ?? false;
  CameraController? get camera => _camera;
  PoseFeedback? get feedback => _feedback;
  String? get error => _error;
  int get framesSent => _sent;
  int get framesDropped => _dropped;

  int get _minIntervalMs => (1000 / targetFps).round();

  Future<void> start() async {
    try {
      await _openSocket();
      await _openCamera();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _openSocket() async {
    final uri = frameSessionUri(
      exercise: exercise,
      patient: patient,
      lang: lang,
    );
    final socket = WebSocketChannel.connect(uri);
    _socket = socket;

    _incoming = socket.stream.listen(
      _onMessage,
      onError: (Object e) {
        _error = 'connection error';
        _connected = false;
        notifyListeners();
      },
      onDone: () {
        _connected = false;
        notifyListeners();
      },
      cancelOnError: false,
    );

    await socket.ready;
    _connected = true;
    _startedAt = DateTime.now();
    notifyListeners();
  }

  void _onMessage(dynamic raw) {
    if (raw is! String) {
      return;
    }
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    // A rejected frame must not be mistaken for feedback.
    if (json.containsKey('error')) {
      _error = json['error'].toString();
      notifyListeners();
      return;
    }
    // Handshake, not feedback.
    if (json['ready'] == true) {
      return;
    }

    _inFlight = false;
    _feedback = PoseFeedback.fromJson(json);

    if (_feedback!.fall && !_fallReported) {
      _fallReported = true;
      onFall?.call();
    }
    notifyListeners();
  }

  Future<void> _openCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('no camera on this device');
    }

    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      front,
      // Low is enough: measured on the reference clips, 320x240 colour detects a
      // pose as reliably as 640x480 (96% vs 93% of frames), and a smaller frame
      // is a smaller upload.
      ResolutionPreset.low,
      enableAudio: false,
      // One contiguous plane, so no per-pixel work happens in Dart.
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await controller.initialize();
    _camera = controller;
    notifyListeners();

    await controller.startImageStream(_onCameraFrame);
  }

  void _onCameraFrame(CameraImage image) {
    if (_closed || !_connected || _socket == null) {
      return;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - _lastSentMs < _minIntervalMs) {
      return;
    }
    if (_inFlight) {
      // Server hasn't answered the previous frame yet: skip rather than queue.
      _dropped++;
      return;
    }

    final bytes = nv21Bytes(image);
    if (bytes == null) {
      _error = 'camera did not provide NV21 on this device';
      notifyListeners();
      return;
    }

    _lastSentMs = nowMs;
    _inFlight = true;
    _sent++;

    _socket!.sink.add(
      buildEnvelope(
        // Elapsed time since the session opened, so the server sees a monotonic
        // device clock without depending on wall-clock agreement.
        timestampMs: nowMs - (_startedAt?.millisecondsSinceEpoch ?? nowMs),
        pixelFormat: PixelFormat.nv21,
        width: image.width,
        height: image.height,
        data: bytes,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    _closed = true;
    await _incoming?.cancel();
    await _socket?.sink.close();
    final camera = _camera;
    _camera = null;
    if (camera != null) {
      if (camera.value.isStreamingImages) {
        await camera.stopImageStream();
      }
      await camera.dispose();
    }
    super.dispose();
  }
}
