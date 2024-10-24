#
# Be sure to run `pod lib lint CSUCoordinatedPresentation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'CSUCoordinatedPresentation'
    s.version          = '1.1.4'
    s.summary          = 'Library created to improve navigation and presentation in SwiftUI.'
  
    s.description      = "Library created to improve navigation and presentation in SwiftUI."
  
    s.homepage         = 'https://github.com/pelekon/SwiftUI-CoordinatedPresentation'
    s.license          = { :type => 'MIT' }
    s.author           = { 'Bartłomiej Bukowiecki' => 'pelekon@gmail.com' }
    s.source           = { :git => 'https://github.com/pelekon/SwiftUI-CoordinatedPresentation.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '14.0'
    s.swift_version = '5.9'
    s.module_name = "CSUCoordinatedPresentation"
  
    s.source_files = 'Sources/CSUCoordinatedPresentation/**/*'
    s.framework = "SwiftUI"
  end
