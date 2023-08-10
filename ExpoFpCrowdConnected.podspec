Pod::Spec.new do |spec|
  spec.name               = "ExpoFpCrowdConnected"
  spec.version            = "4.2.5"
  spec.platform           = :ios, '14.0'
  spec.summary            = "ExpoFP-CrowdConnected location provider"
  spec.description        = "CrowdConnected location provider for ExpoFP SDK"
  spec.homepage           = "https://www.expofp.com"
  spec.documentation_url  = "https://expofp.github.io/expofp-mobile-sdk/ios-sdk"
  spec.license            = { :type => "MIT" }
  spec.author                = { 'ExpoFP' => 'support@expofp.com' }
  spec.source             = { :git => 'https://github.com/expofp/expofp-crowdconnected-ios.git', :tag => "#{spec.version}" }
  spec.swift_version      = "5"

  # Supported deployment targets
  spec.ios.deployment_target  = "14.0"

  # Published binaries
  spec.ios.vendored_frameworks = "xcframework/ExpoFpCrowdConnected.xcframework"

  # Add here any resources to be exported.
  spec.dependency 'ExpoFpCommon', '4.2.5'
  spec.dependency 'AWSKinesis', '~> 2.28.2'
  spec.dependency 'CrowdConnectedIPS', '~> 1.5.2'
  spec.dependency 'CrowdConnectedCore', '~> 1.5.2'
  spec.dependency 'CrowdConnectedGeo', '~> 1.5.2'

end
