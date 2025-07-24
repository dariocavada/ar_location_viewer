# **Camera Distortion Corrections – AR Location Viewer**

## **Identified and Resolved Issues**

### 1. **Unrealistic Field of View (FOV)**

**Issue**: The plugin used a fixed FOV value of 58°, which did not reflect actual mobile device parameters.

**Solution**:

* Implemented a dynamic base FOV of 65° for modern devices
* Automatically calculated vertical FOV based on aspect ratio
* Adjusted FOV based on camera resolution when available
* Reduced FOV by 25% in portrait mode

### 2. **Camera Resolution and Aspect Ratio**

**Issue**: Use of `ResolutionPreset.max` caused distortion and performance issues.

**Solution**:

* Switched to `ResolutionPreset.high` to balance quality and performance
* Implemented `FittedBox` with `BoxFit.cover` to preserve correct proportions
* Proper handling of camera preview dimensions

### 3. **Distortion at Field of View Extremes**

**Issue**: Objects at the edges of the field of view appeared distorted.

**Solution**:

* Implemented lens distortion correction
* Calculated `normalizedAngle` to detect edge elements
* Applied quadratic correction: `deltaAngle * (1.0 + 0.1 * normalizedAngle²)`

### 4. **Architecture Improvements**

**Additions**:

* Added `onCameraInitialized` callback for camera controller access
* Passed `CameraController` to the AR viewer for more accurate calculations
* Dynamic FOV calculation based on real camera data

## **File Changes**

### `ar_camera.dart`

* Added `onCameraInitialized` callback
* Implemented `FittedBox` to correct aspect ratio
* Changed resolution from `max` to `high`

### `ar_viewer.dart`

* New `cameraController` parameter
* Improved FOV calculation using realistic values
* Implemented lens distortion correction
* Adaptive FOV based on orientation and device

### `ar_location_widget.dart`

* Integrated new camera callback
* Passed controller to AR viewer

## **FOV Values Used**

| Orientation | Base FOV        | Calculation                       |
| ----------- | --------------- | --------------------------------- |
| Landscape   | 65° horizontal  | vFov calculated from aspect ratio |
| Portrait    | 48.75° vertical | hFov calculated from aspect ratio |

## **Recommended Tests**

1. **Orientation**: Test device rotation
2. **Distances**: Verify accuracy at different distances (near/far)
3. **Angles**: Check object placement at field of view extremes
4. **Devices**: Test on devices with various resolutions and aspect ratios

## **Technical Notes**

* Distortion correction uses a quadratic factor (0.1), adjustable as needed
* Base FOV of 65° is optimized for modern smartphones
* Reducing to `ResolutionPreset.high` improves performance while maintaining acceptable quality

