Pod::Spec.new do |spec|
  spec.name               = "ExpoFpCrowdConnected"
  spec.version            = "5.1.4"
  spec.platform           = :ios, '14.0'
  spec.summary            = "ExpoFP-CrowdConnected location provider"
  spec.description        = "CrowdConnected location provider for ExpoFP SDK"
  spec.homepage           = "https://www.expofp.com"
  spec.documentation_url  = "https://github.com/expofp/expofp-crowdconnected-ios"
  spec.license            = { :type => "MIT", :file => "LICENSE.md" }
  spec.author             = { 'ExpoFP' => 'support@expofp.com' }
  spec.source             = { :git => 'https://github.com/expofp/expofp-crowdconnected-ios.git', :tag => "#{spec.version}" }
  spec.swift_version      = "5"

  # Supported deployment targets
  spec.ios.deployment_target  = "14.0"

  # Add here any resources to be exported.
  spec.dependency 'CrowdConnectedShared', '2.2.1'
  spec.dependency 'CrowdConnectedCore', '2.2.1'
  spec.dependency 'CrowdConnectedIPS', '2.2.1'
  spec.dependency 'CrowdConnectedCoreBluetooth', '2.2.1'
  spec.dependency 'CrowdConnectedGeo', '2.2.1'
  spec.dependency 'ExpoFP', '~> 5.4.2'

end
