import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No hay cámaras disponibles');
      }

      // Preferir cámara trasera
      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  Future<Uint8List?> captureImage() async {
    if (_controller == null || !_isInitialized) return null;
    try {
      final XFile file = await _controller!.takePicture();
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Error capturando imagen: $e');
      return null;
    }
  }

  Future<void> setFlash(FlashMode mode) async {
    await _controller?.setFlashMode(mode);
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _isInitialized = false;
  }
}