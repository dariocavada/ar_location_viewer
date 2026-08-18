# ar_location_viewer

Augmented reality for geolocation.
Inspired [HDAugmentedReality](https://github.com/DanijelHuis/HDAugmentedReality)


Is an upgraded version of:
https://pub.dev/packages/ar_location_view

## Requirements

* Flutter 3.44 or newer (Flutter 3.47 stable is used for verification)
* Dart 3.12 or newer
* Android API 24 or newer, compiling against Android SDK 37
* iOS 13 or newer

The iOS plugin supports both Swift Package Manager and CocoaPods. Swift Package
Manager is the primary integration used by the example app.


## Demo

![ArLocationView](./demo.gif)

## Description

ArLocationViewer is designed to used in areas with large concentration of static POIs.
Where primary goal is the visibility of all POIs.

**Remark:** Altitudes of POIs are disregarded


### Features
* Automatic vertical stacking of annotations views
* Tracks user movement and updates visible annotations
* Fully customisable annotation view
* Supports all rotations


### Basic usage
Look at the example

### For iOS
ArLocationViewer uses the device camera and location. Add usage descriptions to
your app's `Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Your location is used to position nearby points of interest.</string>
<key>NSCameraUsageDescription</key>
<string>The camera is used to display the augmented-reality view.</string>
```

If your app requests background or always-on location access, also add the
corresponding `NSLocationAlwaysAndWhenInUseUsageDescription` key.

### For Android
The plugin manifest declares camera, coarse/fine location, and
`HIGH_SAMPLING_RATE_SENSORS`; these permissions are merged automatically into
the consuming app. Runtime camera and location permissions are requested by the
plugin.

Create class extend ArAnnotation

```dart
class Annotation extends ArAnnotation {
  final AnnotationType type;
  
  Annotation({required super.uid, required super.position, required this.type});
}
```

Create a widget for Annotation view for example
```dart

class AnnotationView extends StatelessWidget {
  const AnnotationView({
    Key? key,
    required this.annotation,
  }) : super(key: key);

  final Annotation annotation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
              child: typeFactory(annotation.type),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    annotation.type.toString().substring(15),
                    maxLines: 1,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${annotation.distanceFromUser.toInt()} m',
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget typeFactory(AnnotationType type) {
    IconData iconData = Icons.ac_unit_outlined;
    Color color = Colors.teal;
    switch (type) {
      case AnnotationType.pharmacy:
        iconData = Icons.local_pharmacy_outlined;
        color = Colors.red;
        break;
      case AnnotationType.hotel:
        iconData = Icons.hotel_outlined;
        color = Colors.green;
        break;
      case AnnotationType.library:
        iconData = Icons.library_add_outlined;
        color = Colors.blue;
        break;
    }
    return Icon(
      iconData,
      size: 40,
      color: color,
    );
  }
}
```

## License

ArLocationViewer is released under the MIT license.
