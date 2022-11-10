Pod::Spec.new do |spec|
  spec.name               = "ExpoFpCrowdConnected"
  spec.version            = "0.3.5"
  spec.platform           = :ios, '14.0'
  spec.summary            = "Fplan Library for iOS apps"
  spec.description        = "Library for displaying expo plans"
  spec.homepage           = "https://www.expofp.com"
  spec.documentation_url  = "https://github.com/expofp/expofp-sdk-ios"
  spec.license            = { :type => "MIT" }
  spec.author                = { 'ExpoFP' => 'support@expofp.com' }
  spec.source             = { :git => 'https://github.com/expofp/expofp-crowdconnected-ios.git', :tag => "#{spec.version}" }
  spec.swift_version      = "5"

  # Supported deployment targets
  spec.ios.deployment_target  = "14.0"

  # Published binaries
  spec.ios.vendored_frameworks = "xcframework/ExpoFpCrowdConnected.xcframework"

  # Add here any resources to be exported.
  spec.dependency 'ExpoFpCommon', '0.3.5'
  spec.dependency 'AWSKinesis', '2.28.2'
  spec.dependency 'CrowdConnectedIPS', '1.4.0'
  spec.dependency 'CrowdConnectedCore', '1.4.0'
  spec.dependency 'CrowdConnectedGeo', '1.4.0'

end
