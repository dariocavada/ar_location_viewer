import 'package:flutter/material.dart';
import 'package:ar_location_viewer/ar_location_viewer.dart';
import 'package:geolocator/geolocator.dart';
import 'annotation_viewer.dart';
import 'annotations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Annotation> annotations = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ArLocationWidget(
          annotations: annotations,
          showDebugInfoSensor: false,
          annotationViewerBuilder: (context, annotation) {
            return AnnotationViewer(
              key: ValueKey(annotation.uid),
              annotation: annotation as Annotation,
            );
          },
          onLocationChange: (Position position) {
            Future.delayed(const Duration(seconds: 5), () {
              annotations =
                  fakeAnnotation(position: position, numberMaxPoi: 50);
              setState(() {});
            });
          },
        ),
      ),
    );
  }
}
