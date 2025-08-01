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
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.previewSize!.height,
                height: controller!.value.previewSize!.width,
                child: CameraPreview(controller!),
              ),
            ),
          ),
        ),
      );
    }
    return const Text('Camera error');
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
