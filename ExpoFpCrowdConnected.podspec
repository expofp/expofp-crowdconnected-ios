Pod::Spec.new do |spec|
  spec.name               = "ExpoFpCrowdConnected"
  spec.version            = "3.0.0"
  spec.platform           = :ios, '13.0'
  spec.summary            = "Fplan Library for iOS apps"
  spec.description        = "Library for displaying expo plans"
  spec.homepage           = "https://www.expofp.com"
  spec.documentation_url  = "https://github.com/expofp/expofp-sdk-ios"
  spec.license            = { :type => "MIT" }
  spec.author                = { 'ExpoFP' => 'support@expofp.com' }
  spec.source             = { :git => 'https://github.com/expofp/expofp-crowdconnected-ios.git', :tag => "#{spec.version}" }
  spec.swift_version      = "5"

  # Supported deployment targets
  spec.ios.deployment_target  = "13.0"

  # Published binaries
  spec.ios.vendored_frameworks = "xcframework/ExpoFpCrowdConnected.xcframework"

  # Add here any resources to be exported.
  spec.dependency 'ExpoFpCommon', '~> 3.0.0'
  spec.dependency 'CrowdConnectedIPS', '~> 1.3.2'
  spec.dependency 'CrowdConnectedCore', '~> 1.3.2'
  spec.dependency 'CrowdConnectedGeo', '~> 1.3.2'

end
