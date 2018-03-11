Pod::Spec.new do |s|
  s.name             = 'SuperAlertController'
  s.version          = "1.1.1"
  s.summary          = "An UIAlertController extension."
  s.homepage         = "https://github.com/Meniny/SuperAlertController"
  s.license          = { :type => "MIT", :file => "LICENSE.md" }
  s.author           = 'Elias Abel'
  s.source           = { :git => "https://github.com/Meniny/SuperAlertController.git", :tag => s.version.to_s }
  s.swift_version    = "4.0"
  s.social_media_url = 'https://meniny.cn/'
  s.source_files     = "SuperAlertController/**/*.swift"
  s.requires_arc     = true
  s.ios.deployment_target = "9.0"
  s.description  = "SuperAlertController is an UIAlertController extension."
  s.module_name = 'SuperAlertController'
end
