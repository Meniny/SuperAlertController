Pod::Spec.new do |s|
  s.name             = 'SuperAlertController'
  s.version          = "2.0.0"
  s.summary          = "An UIAlertController extension."
  s.homepage         = "https://github.com/Meniny/SuperAlertController"
  s.license          = { :type => "MIT", :file => "LICENSE.md" }
  s.author           = 'Elias Abel'
  s.source           = { :git => "https://github.com/Meniny/SuperAlertController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://meniny.cn/'
  s.source_files     = "SuperAlertController/**/*.swift"
  s.requires_arc     = true
  s.description      = "SuperAlertController is an UIAlertController extension."
  s.module_name      = 'SuperAlertController'

  s.ios.deployment_target = "9.0"
  s.pod_target_xcconfig   = { 'SWIFT_VERSION' => '4.1' }
  s.swift_version         = "4.1"

  s.default_subspecs      = 'Core'

  s.subspec 'Core' do |sp|
    sp.source_files  = 'SuperAlertController/Core/**/*.swift'
    sp.frameworks    = "Foundation", "UIKit"
  end

  s.subspec 'Ext' do |sp|
    sp.dependency      'SuperAlertController/Core'
    sp.source_files  = 'SuperAlertController/Ext/Codes/**/*.swift'
    sp.frameworks    = "Foundation", "UIKit", "AVFoundation", "CoreGraphics", "WebKit"
    sp.resources     = [
      "SuperAlertController/Ext/Resources/Countries.bundle",
      'SuperAlertController/Ext/Resources/ColorPicker.storyboard',
      "SuperAlertController/Ext/Resources/Assets.xcassets"
    ]
  end
end
