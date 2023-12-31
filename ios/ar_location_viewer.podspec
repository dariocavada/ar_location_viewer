#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ar_location_viewer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ar_location_viewer'
  s.version          = '0.0.2'
  s.summary          = 'Plugins For Ar Location Viewer'
  s.description      = <<-DESC
Plugins For Ar Location Viewer
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dario Cavada' => 'dario.cavada@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
