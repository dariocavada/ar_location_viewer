import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'ar_location_viewer.dart';

class ArLocationWidget extends StatefulWidget {
  const ArLocationWidget({
    super.key,
    required this.annotations,
    required this.annotationViewerBuilder,
    required this.onLocationChange,
    this.annotationWidth = 200,
    this.annotationHeight = 75,
    this.maxVisibleDistance = 1500,
    this.frame,
    this.showDebugInfoSensor = true,
    this.paddingOverlap = 5,
    this.yOffsetOverlap,
    this.accessory,
    this.minDistanceReload = 50,
    this.tooFarAnnotationsMessage = 'No annotations visible',
  });

  ///List of POIs
  final List<ArAnnotation> annotations;

  ///Function given context and annotation
  ///return widget for annotation view
  final AnnotationViewerBuilder annotationViewerBuilder;

  ///Annotation view width
  final double annotationWidth;

  ///Annotation view height
  final double annotationHeight;

  ///Max distance marker visible
  final double maxVisibleDistance;

  final Size? frame;

  ///Callback when location change
  final ChangeLocationCallback onLocationChange;

  ///Show debug info sensor in debug mode
  final bool showDebugInfoSensor;

  ///Padding when marker overlap
  final double paddingOverlap;

  ///Offset overlap y
  final double? yOffsetOverlap;

  ///accessory
  final Widget? accessory;

  ///Min distance reload
  final double minDistanceReload;

  ///Message when annotations are too far
  final String tooFarAnnotationsMessage;

  @override
  State<ArLocationWidget> createState() => _ArLocationWidgetState();
}

class _ArLocationWidgetState extends State<ArLocationWidget> {
  bool initCam = false;
  CameraController? cameraController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ArCamera(
          onCameraError: (String error) {
            initCam = false;
            setState(() {});
          },
          onCameraSuccess: () {
            initCam = true;
            setState(() {});
          },
          onCameraInitialized: (CameraController controller) {
            cameraController = controller;
          },
        ),
        if (initCam)
          ArViewer(
            annotations: widget.annotations,
            annotationViewerBuilder: widget.annotationViewerBuilder,
            frame: widget.frame ?? const Size(100, 75),
            onLocationChange: widget.onLocationChange,
            annotationWidth: widget.annotationWidth,
            annotationHeight: widget.annotationHeight,
            maxVisibleDistance: widget.maxVisibleDistance,
            showDebugInfoSensor: widget.showDebugInfoSensor,
            paddingOverlap: widget.paddingOverlap,
            yOffsetOverlap: widget.yOffsetOverlap,
            minDistanceReload: widget.minDistanceReload,
            cameraController: cameraController,
            tooFarAnnotationsMessage: widget.tooFarAnnotationsMessage,
          ),
        if (widget.accessory != null) widget.accessory!
      ],
    );
  }
}
