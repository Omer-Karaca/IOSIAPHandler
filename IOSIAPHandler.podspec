#
# Be sure to run `pod lib lint IOSIAPHandler.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IOSIAPHandler'
  s.version          = '0.1.4'
  s.summary          = 'A swift library to handle iOS IAP.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
'A swift library to handle iOS in app purchases'
                       DESC

  s.homepage         = 'https://github.com/Omer-Karaca/IOSIAPHandler'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '95032856' => 'viyateknoloji@gmail.com' }
  s.source           = { :git => 'https://github.com/Omer-Karaca/IOSIAPHandler.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.static_framework = true
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.source_files = 'IAP/**/*.swift'
  #'IOSIAPHandler/Classes/**/*'
  s.platforms = {
    "ios": "14.0"
    }
  # s.resource_bundles = {
  #   'IOSIAPHandler' => ['IOSIAPHandler/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
    s.dependency 'Adjust'#, '~> 4.33'
    s.dependency 'FirebaseAnalytics'#, '~> 10.3'
    s.dependency 'SVProgressHUD'#, '~> 2.2'
    s.dependency 'Alamofire'#, '~> 5.6'
    # s.dependency 'Firebase/RemoteConfig'
    # s.dependency 'Firebase/Core', '~> 10.3'
    # s.dependency 'Firebase/Performance', '~> 10.3'
    # s.dependency 'Firebase/Crashlytics', '~> 10.3'
end
