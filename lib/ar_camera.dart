import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ArCamera extends StatefulWidget {
  const ArCamera({
    super.key,
    required this.onCameraError,
    required this.onCameraSuccess,
    this.onCameraInitialized,
  });

  final Function(String error) onCameraError;
  final Function() onCameraSuccess;
  final Function(CameraController controller)? onCameraInitialized;

  @override
  State<ArCamera> createState() => _ArCameraViewerState();
}

class _ArCameraViewerState extends State<ArCamera> {
  CameraController? controller;

  bool isCameraAuthorize = false;
  bool isCameraInitialize = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() async {
    await controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraAuthorize) {
      return const Center(
        child: Text('Need camera authorization'),
      );
    }
    if (!isCameraInitialize) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (isCameraAuthorize && isCameraInitialize) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _buildCameraPreview(),
      );
    }
    return const Text('Camera error');
  }

  Widget _buildCameraPreview() {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Ottieni le dimensioni dello schermo
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Ottieni le dimensioni del preview della fotocamera
    final previewSize = controller!.value.previewSize!;

    // La fotocamera restituisce sempre dimensioni in portrait (height > width)
    // quindi dobbiamo considerare l'orientamento attuale
    final isLandscape = screenWidth > screenHeight;

    double cameraWidth, cameraHeight;
    if (isLandscape) {
      // In landscape, scambia le dimensioni del preview
      cameraWidth = previewSize.height;
      cameraHeight = previewSize.width;
    } else {
      // In portrait, usa le dimensioni normali
      cameraWidth = previewSize.width;
      cameraHeight = previewSize.height;
    }

    // Calcola le scale per fare fit dello schermo
    final scaleX = screenWidth / cameraWidth;
    final scaleY = screenHeight / cameraHeight;
    final scale = scaleX > scaleY ? scaleX : scaleY;

    return Center(
      child: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: ClipRect(
          child: Transform.scale(
            scale: scale,
            child: Center(
              child: SizedBox(
                width: cameraWidth,
                height: cameraHeight,
                child: CameraPreview(controller!),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      isCameraInitialize = false;
      await _requestCameraAuthorization();
      if (isCameraAuthorize) {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          throw Exception('No cameras available');
        }
        controller = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await controller?.initialize();
        isCameraInitialize = true;
        widget.onCameraSuccess();

        // Notifica il controller inizializzato per calcoli FOV più precisi
        if (widget.onCameraInitialized != null) {
          widget.onCameraInitialized!(controller!);
        }
      }
    } catch (ex) {
      print('Error when camera initialize: $ex');
      widget.onCameraError('On error when camera initialize ');
      isCameraInitialize = false;
    } finally {
      setState(() {});
    }
  }

  Future<void> _requestCameraAuthorization() async {
    var isGranted = await Permission.camera.isGranted;
    if (!isGranted) {
      await Permission.camera.request();
      isGranted = await Permission.camera.isGranted;
      if (!isGranted) {
        widget.onCameraError('Camera need authorization permission');
      } else {
        isCameraAuthorize = true;
        setState(() {});
      }
    } else {
      isCameraAuthorize = true;
      setState(() {});
    }
  }
}
