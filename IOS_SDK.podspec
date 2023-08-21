#
# Be sure to run `pod lib lint IOS_SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'skeps_financing_sdk'
  s.version          = '1.0.2'
  s.summary          = 'This is IOS KIT, a resusable component. To utilize it you camn install it by pod install.'
  s.swift_version = '4.2'
  s.license = 'MIT'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'This is IOS KIT, a resusable component. To utilize it you camn install it by pod install. It is open source lib'

  s.homepage         = 'https://github.com/skeps-org/ios-kit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'devtushar220' => 'dev.tushar@skeps.com' }
  s.source           = { :git => 'https://github.com/skeps-org/ios-kit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '16.0'

  s.source_files = 'IOS_SDK/Classes/**/*'
  s.ios.source_files   = 'IOS_SDK/Classes/**/*'
  s.osx.source_files   = 'IOS_SDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'IOS_SDK' => ['IOS_SDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
