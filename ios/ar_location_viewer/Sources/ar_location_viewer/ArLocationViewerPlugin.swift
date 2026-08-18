import CoreLocation
import CoreMotion
import Flutter
import simd
import UIKit

public final class ArLocationViewerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, CLLocationManagerDelegate {
  private var eventSink: FlutterEventSink?
  private let locationManager = CLLocationManager()
  private let motionManager = CMMotionManager()

  private init(channel: FlutterEventChannel) {
    super.init()
    locationManager.delegate = self
    locationManager.headingFilter = 0.1
    channel.setStreamHandler(self)

    motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
    motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
  }

  deinit {
    locationManager.stopUpdatingHeading()
    motionManager.stopDeviceMotionUpdates()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterEventChannel(
      name: "pie/ar_viewer_location",
      binaryMessenger: registrar.messenger()
    )
    _ = ArLocationViewerPlugin(channel: channel)
  }

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    locationManager.startUpdatingHeading()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    locationManager.stopUpdatingHeading()
    return nil
  }

  public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    guard newHeading.headingAccuracy > 0 else {
      return
    }

    var headingForCameraMode = newHeading.trueHeading

    if let attitude = motionManager.deviceMotion?.attitude {
      let rotationY = double3x3(rows: [
        simd_double3(0, 0, 1),
        simd_double3(0, 1, 0),
        simd_double3(-1, 0, 0),
      ])
      let rotationZ = double3x3(rows: [
        simd_double3(0, -1, 0),
        simd_double3(1, 0, 0),
        simd_double3(0, 0, 1),
      ])
      let rotation = double3x3(rows: [
        simd_double3(attitude.rotationMatrix.m11, attitude.rotationMatrix.m12, attitude.rotationMatrix.m13),
        simd_double3(attitude.rotationMatrix.m21, attitude.rotationMatrix.m22, attitude.rotationMatrix.m23),
        simd_double3(attitude.rotationMatrix.m31, attitude.rotationMatrix.m32, attitude.rotationMatrix.m33),
      ])
      let transformedRotation = rotationZ * rotationY * rotation
      let yaw = atan2(transformedRotation[0, 1], transformedRotation[1, 1]) + Double.pi / 2
      headingForCameraMode =
        (yaw + Double.pi * 2).truncatingRemainder(dividingBy: Double.pi * 2) * 180 / Double.pi
    }

    eventSink?([newHeading.trueHeading, headingForCameraMode, newHeading.headingAccuracy])
  }
}
