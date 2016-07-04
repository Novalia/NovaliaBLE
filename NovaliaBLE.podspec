#
# Be sure to run `pod lib lint NovaliaBLE.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NovaliaBLE"
  s.version          = "0.1.5"
  s.summary          = "For connecting to and using a Novalia BLE device."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
This CocoaPod provides the ability to connecting to and use a Novalia BLE device.
                       DESC

  s.homepage         = "https://github.com/tirami/NovaliaBLE"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Andrew Sage" => "andrew@tirami.co.uk" }
  s.source           = { :git => "https://github.com/tirami/NovaliaBLE.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/symboticaandrew'

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.module_name = 'NovaliaBLE'

  s.source_files = 'Pod/Classes/**/*'
  #s.resource_bundles = {
#  'NovaliaBLE' => ['Pod/Assets/*.png']
# }

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
