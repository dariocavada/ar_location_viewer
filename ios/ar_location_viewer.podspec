#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ar_location_viewer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ar_location_viewer'
  s.version          = '4.0.0'
  s.summary          = 'Augmented reality viewer for geolocated points of interest.'
  s.description      = <<-DESC
Flutter plugin that combines camera, device orientation, and heading data to display
augmented-reality annotations for geolocated points of interest.
                       DESC
  s.homepage         = 'https://github.com/dariocavada/ar_location_viewer'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Dario Cavada' => 'dario.cavada@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'ar_location_viewer/Sources/ar_location_viewer/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
