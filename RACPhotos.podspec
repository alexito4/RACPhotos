#
# Be sure to run `pod lib lint RACPhotos.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RACPhotos"
  s.version          = "0.1.0"
  s.summary          = "A small wrapper of Photos.framework with ReactiveCocoa 3."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
        RACPhotos is a small wrapper of the Photos.framework using ReactiveCocoa 3.
        It let's you declare what you want to do with the Photos library and forget about
        the async APIs and the callback hell.
                       DESC

  s.homepage         = "https://github.com/alexito4/RACPhotos"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Alejandro Martínez" => "alexito4@gmail.com" }
  s.source           = { :git => "https://github.com/alexito4/RACPhotos.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/alexito4'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'RACPhotos' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Photos'
  s.dependency 'ReactiveCocoa', '= 3.0-RC.1'
end
