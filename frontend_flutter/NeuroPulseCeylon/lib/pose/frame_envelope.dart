import 'dart:typed_data';

import 'package:camera/camera.dart';

/// Pixel formats understood by the Python service. Must stay in step with
/// ml-service/app/frames.py.
class PixelFormat {
  static const int jpeg = 0;
  static const int nv21 = 2;
}

const int _headerBytes = 13;

/// Builds the binary message the frames endpoint expects:
///
///   [0:8]   uint64 big-endian  capture time in milliseconds
///   [8]     uint8              pixel format
///   [9:11]  uint16 big-endian  width
///   [11:13] uint16 big-endian  height
///   [13:]   pixel data
///
/// A single Uint8List is built and the payload copied in once. Concatenating
/// lists per frame would allocate repeatedly at 10+ frames a second.
Uint8List buildEnvelope({
  required int timestampMs,
  required int pixelFormat,
  required int width,
  required int height,
  required Uint8List data,
}) {
  final out = Uint8List(_headerBytes + data.length);
  final header = ByteData.view(out.buffer, 0, _headerBytes);

  header.setUint64(0, timestampMs, Endian.big);
  header.setUint8(8, pixelFormat);
  header.setUint16(9, width, Endian.big);
  header.setUint16(11, height, Endian.big);

  out.setRange(_headerBytes, out.length, data);
  return out;
}

/// Extracts the NV21 bytes from a camera frame.
///
/// Asking the camera for [ImageFormatGroup.nv21] gives a single contiguous plane,
/// so this is a straight handoff with no per-pixel work in Dart. That matters: a
/// YUV-to-RGB conversion or a JPEG encode in Dart costs tens of milliseconds per
/// frame and will not hold 10fps, which is the whole reason the conversion
/// happens on the server instead.
///
/// Returns null if the camera delivered something other than a single plane,
/// which means the format request was not honoured on this device.
Uint8List? nv21Bytes(CameraImage image) {
  if (image.planes.length != 1) {
    return null;
  }
  return image.planes.first.bytes;
}
