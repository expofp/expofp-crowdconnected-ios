source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'

use_frameworks!

def shared_pods
  pod 'ExpoFpCommon', '0.3.2'
  #pod 'ExpoFpCommon', :path => '/Users/vladimir/Xcode projects/expofp-common-ios'

  pod 'AWSKinesis', '2.28.1'
  pod 'CrowdConnectedIPS', '1.4.0'
  pod 'CrowdConnectedGeo', '1.4.0'
  pod 'CrowdConnectedCore', '1.4.0'

end

target 'ExpoFpCrowdConnected' do
  shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['IPHONESIMULATOR_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
