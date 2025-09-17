import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:camera/camera.dart';

import 'ar_location_viewer.dart';

/// Signature for a function that creates a widget for a given annotation,
typedef AnnotationViewerBuilder = Widget Function(
    BuildContext context, ArAnnotation annotation);

typedef ChangeLocationCallback = void Function(Position position);

class ArViewer extends StatefulWidget {
  const ArViewer({
    super.key,
    required this.annotations,
    required this.annotationViewerBuilder,
    required this.frame,
    required this.onLocationChange,
    this.annotationWidth = 200,
    this.annotationHeight = 75,
    this.maxVisibleDistance = 1500,
    this.showDebugInfoSensor = true,
    this.paddingOverlap = 5,
    this.yOffsetOverlap,
    this.tooFarAnnotationsMessage = 'No annotations visible',
    required this.minDistanceReload,
    this.cameraController,
  });

  final List<ArAnnotation> annotations;
  final AnnotationViewerBuilder annotationViewerBuilder;
  final double annotationWidth;
  final double annotationHeight;

  final double maxVisibleDistance;

  final Size frame;

  final ChangeLocationCallback onLocationChange;

  final bool showDebugInfoSensor;

  final double paddingOverlap;
  final double? yOffsetOverlap;
  final double minDistanceReload;
  final CameraController? cameraController;
  final String tooFarAnnotationsMessage;

  @override
  State<ArViewer> createState() => _ArViewerState();
}

class _ArViewerState extends State<ArViewer> {
  ArStatus arStatus = ArStatus();

  Position? position;

  @override
  void initState() {
    ArSensorManager.instance.init();
    super.initState();
  }

  @override
  void dispose() {
    ArSensorManager.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return StreamBuilder(
      stream: ArSensorManager.instance.arSensor,
      builder: (context, data) {
        if (data.hasData) {
          if (data.data != null) {
            final arSensor = data.data!;
            if (arSensor.location == null) {
              return loading();
            }
            _calculateFOV(arSensor.orientation, width, height);
            _updatePosition(arSensor.location!);
            final deviceLocation = arSensor.location!;
            final annotations = _filterAndSortArAnnotation(
                widget.annotations, arSensor, deviceLocation);
            _transformAnnotation(annotations);

            // Check if annotations are empty and handle the case
            var showAnnotationTooFar = false;
            if (annotations.isEmpty) {
              if (widget.annotations.isEmpty == false) {
                showAnnotationTooFar = true;
              }
            }

            return Stack(
              children: [
                if (kDebugMode && widget.showDebugInfoSensor)
                  Positioned(
                    bottom: 0,
                    child: debugInfo(context, arSensor),
                  ),
                Stack(
                    children: annotations.map(
                  (e) {
                    return Positioned(
                      left: e.arPosition.dx,
                      top: e.arPosition.dy + height * 0.5,
                      child: Transform.translate(
                        offset: Offset(0, e.arPositionOffset.dy),
                        child: SizedBox(
                          width: widget.annotationWidth,
                          height: widget.annotationHeight,
                          child: widget.annotationViewerBuilder(context, e),
                        ),
                      ),
                    );
                  },
                ).toList()),
                if (showAnnotationTooFar)
                  Center(
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Text(
                          widget.tooFarAnnotationsMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
        }
        return loading();
      },
    );
  }

  Widget debugInfo(BuildContext context, ArSensor? arSensor) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude  : ${arSensor?.location?.latitude}',
                style: const TextStyle(
                  color: Colors.black,
                )),
            Text('Longitude : ${arSensor?.location?.longitude}',
                style: const TextStyle(
                  color: Colors.black,
                )),
            Text('Pitch     : ${arSensor?.pitch}',
                style: const TextStyle(color: Colors.black)),
            Text('Heading   : ${arSensor?.heading}',
                style: const TextStyle(
                  color: Colors.black,
                )),
          ],
        ),
      ),
    );
  }

  Widget loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void _calculateFOV(
      NativeDeviceOrientation orientation, double width, double height) {
    double hFov = 0;
    double vFov = 0;

    // FOV più realistico basato su dispositivi tipici
    // iPhone: ~65° orizzontale, Android varia da 60-75°
    double baseFOv = 65.0;

    // Se disponibile, usa i dati reali della fotocamera
    if (widget.cameraController != null &&
        widget.cameraController!.value.isInitialized) {
      try {
        // Prova ad ottenere FOV reale se disponibile nel futuro
        // Per ora usa valori più precisi basati sulla risoluzione
        final previewSize = widget.cameraController!.value.previewSize!;

        // Considera l'orientamento per calcolare l'aspect ratio corretto
        double aspectRatio;
        if (orientation == NativeDeviceOrientation.landscapeLeft ||
            orientation == NativeDeviceOrientation.landscapeRight) {
          // In landscape, inverti le dimensioni del preview
          aspectRatio = previewSize.height / previewSize.width;
        } else {
          // In portrait, usa le dimensioni normali
          aspectRatio = previewSize.width / previewSize.height;
        }

        // Adatta il FOV in base all'aspect ratio della fotocamera
        baseFOv = 60.0 + (aspectRatio - 0.75) * 20.0; // Adattamento dinamico
        baseFOv = baseFOv.clamp(55.0, 75.0); // Limita a valori ragionevoli
      } catch (e) {
        // Fallback ai valori di default
        baseFOv = 65.0;
      }
    }

    // Calcola l'aspect ratio dello schermo attuale
    final screenAspectRatio = width / height;

    if (orientation == NativeDeviceOrientation.landscapeLeft ||
        orientation == NativeDeviceOrientation.landscapeRight) {
      hFov = baseFOv;
      // Calcola vFov basato sull'aspect ratio reale dello schermo
      vFov =
          (2 * atan(tan((hFov / 2).toRadians) / screenAspectRatio)).toDegrees;
    } else {
      // In modalità portrait, il FOV verticale è tipicamente minore
      vFov = baseFOv * 0.75; // Ridotto per modalità portrait
      hFov =
          (2 * atan(tan((vFov / 2).toRadians) * screenAspectRatio)).toDegrees;
    }

    arStatus.hFov = hFov;
    arStatus.vFov = vFov;
    arStatus.hPixelPerDegree = hFov > 0 ? (width / hFov) : 0;
    arStatus.vPixelPerDegree = vFov > 0 ? (height / vFov) : 0;
  }

  List<ArAnnotation> _visibleAnnotations(
      List<ArAnnotation> annotations, double heading) {
    final degreesDeltaH = arStatus.hFov;
    return annotations.where((ArAnnotation annotation) {
      final delta = ArMath.deltaAngle(heading, annotation.azimuth);
      final isVisible = delta.abs() < degreesDeltaH;
      annotation.isVisible = isVisible;
      return annotation.isVisible;
    }).toList();
  }

  List<ArAnnotation> _calculateDistanceAndBearingFromUser(
      List<ArAnnotation> annotations,
      Position deviceLocation,
      ArSensor arSensor) {
    return annotations.map((e) {
      final annotationLocation = e.position;
      e.azimuth = Geolocator.bearingBetween(
          deviceLocation.latitude,
          deviceLocation.longitude,
          annotationLocation.latitude,
          annotationLocation.longitude);
      e.distanceFromUser = Geolocator.distanceBetween(
          deviceLocation.latitude,
          deviceLocation.longitude,
          annotationLocation.latitude,
          annotationLocation.longitude);

      // Miglioramento: correggi la distorsione agli estremi del FOV
      final deltaAngle = ArMath.deltaAngle(e.azimuth, arSensor.heading);
      final normalizedAngle = deltaAngle / (arStatus.hFov / 2);

      // Applica una correzione per la distorsione delle lenti
      final correctedDeltaAngle =
          deltaAngle * (1.0 + 0.1 * normalizedAngle * normalizedAngle);

      final dy = arSensor.pitch * arStatus.vPixelPerDegree;
      final dx = correctedDeltaAngle * arStatus.hPixelPerDegree;

      e.arPosition = Offset(dx, dy);
      return e;
    }).toList();
  }

  List<ArAnnotation> _filterAndSortArAnnotation(List<ArAnnotation> annotations,
      ArSensor arSensor, Position deviceLocation) {
    List<ArAnnotation> temps = _calculateDistanceAndBearingFromUser(
        annotations, deviceLocation, arSensor);
    temps = annotations
        .where(
            (element) => element.distanceFromUser < widget.maxVisibleDistance)
        .toList();
    temps = _visibleAnnotations(temps, arSensor.heading);
    return temps;
  }

  void _transformAnnotation(List<ArAnnotation> annotations) {
    annotations.sort((a, b) => (a.distanceFromUser < b.distanceFromUser)
        ? -1
        : ((a.distanceFromUser > b.distanceFromUser) ? 1 : 0));

    for (final ArAnnotation annotation in annotations) {
      var i = 0;
      while (i < annotations.length) {
        final annotation2 = annotations[i];
        if (annotation.uid == annotation2.uid) {
          break;
        }
        final collision =
            intersects(annotation, annotation2, widget.annotationWidth);
        if (collision) {
          annotation.arPositionOffset = Offset(
              0,
              annotation2.arPositionOffset.dy -
                  ((widget.yOffsetOverlap ?? widget.annotationHeight) +
                      widget.paddingOverlap));
        }
        i++;
      }
    }
  }

  bool intersects(
      ArAnnotation annotation1, ArAnnotation annotation2, double width) {
    return (annotation2.arPosition.dx >= annotation1.arPosition.dx &&
            annotation2.arPosition.dx <= (annotation1.arPosition.dx + width)) ||
        (annotation1.arPosition.dx >= annotation2.arPosition.dx &&
            annotation1.arPosition.dx <= (annotation2.arPosition.dx + width));
  }

  void _updatePosition(Position newPosition) {
    if (position == null) {
      widget.onLocationChange(newPosition);
      position = newPosition;
    } else {
      final distance = Geolocator.distanceBetween(position!.latitude,
          position!.longitude, newPosition.latitude, newPosition.longitude);
      if (distance > widget.minDistanceReload) {
        widget.onLocationChange(newPosition);
        widget.onLocationChange(newPosition);
        position = newPosition;
      }
    }
  }
}
