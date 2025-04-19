#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zkemail_flutter_package.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'zkemail_flutter_package'
  s.version          = '0.1.0'
  s.summary          = 'Flutter plugin for zkEmail using Mopro.'
  s.description      = <<-DESC
A Flutter plugin for zkEmail using Mopro, enabling mobile proving with zkEmail proof generation and verification.
                       DESC
  s.homepage         = 'https://zkmopro.org/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mopro' => 'hello@zkmopro.org' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'ZKEmailSwift', '~> 0.2.6'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'zkemail_flutter_package_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
