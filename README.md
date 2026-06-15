<img src="https://expofp.com/template/img/site-header-logo-inverse.png" width="350"/>

[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ExpoFpCrowdConnected.svg)](https://cocoapods.org/pods/ExpoFpCrowdConnected)
[![Platform](https://img.shields.io/badge/Platforms-%20iOS%20|%20iPadOS-lightgrey.svg)](https://github.com/expofp/expofp-crowdconnected-ios)

**ExpoFpCrowdConnected** is a wrapper around [CrowdConnected Location Provider](https://github.com/crowdconnected/crowdconnected-sdk-swift-spm), made for **ExpoFP** floor plans.<br>
This package includes the latest version of [ExpoFP SDK](https://github.com/expofp/expofp-sdk-ios).<br>
Also you can take [CrowdConnected SDK](https://github.com/crowdconnected/crowdconnected-sdk-swift-spm) and create your own wrapper to use with [ExpoFP SDK](https://github.com/expofp/expofp-sdk-ios) following the [CrowdConnected documentation](https://customer.support.crowdconnected.com/servicedesk/customer/article/3098935297) and this package as an example.

## Setup

### Activate GPS/IPS option at [app.expofp.com](https://app.expofp.com) -> Settings -> Floor Plan:
![image](https://github.com/user-attachments/assets/65658895-cd91-4a66-936d-c7e9bf8ffd82)

### Add permissions to Info.plist:

#### If SDK is started in `.foreground` mode:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>YOUR DESCRIPTIVE TEXT HERE</string>
```

#### If SDK is started in `.background` mode:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>

<key>NSLocationWhenInUseUsageDescription</key>
<string>YOUR DESCRIPTIVE TEXT HERE</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>YOUR DESCRIPTIVE TEXT HERE</string>
```

#### If SDK bluetooth positioning is enabled:
```xml
<key>UIBackgroundModes</key>
<array>
	<string>bluetooth-central</string>
</array>

<key>NSBluetoothAlwaysUsageDescription</key>
<string>YOUR DESCRIPTIVE TEXT HERE</string>
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/expofp/expofp-crowdconnected-ios", from: "5.3.0"),
]
```

and add it to your target’s dependencies

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "ExpoFpCrowdConnected", package: "expofp-crowdconnected-ios"),
    ]
),
```

### CocoaPods
> Warning: CocoaPods [is deprecated](https://blog.cocoapods.org/CocoaPods-Specs-Repo/), the last compatible version is 5.1.5 (CrowdConnected v2.3.0).

```swift
target 'MyApp' do
    pod 'ExpoFpCrowdConnected', '~> 5.1.5'
end
```

## Quick Guide

```swift
let settings = try ExpoFpCrowdConnectedLocationProviderSettings(
    appKey: "YourAppKey",
    clientId: "YourClientId",
    clientSecret: "YourClientSecret",
    modules: [.geo, .ips, .coreBluetooth],
    trackingMode: .background, // or .foreground if background location updates not required
    isHeadingEnabled: true // or false if not required
)

let locationProvider = ExpoFpCrowdConnectedLocationProvider(settings: settings)

let presenter = ExpoFpPlan.createPlanPresenter(
    with: .expoKey("YourExpoKey"),
    locationProvider: locationProvider
)
```

Or set to `presenter` after initialization

```swift
presenter.setLocationProvider(locationProvider)
```

When a plan appears it will call [startUpdatingLocation()](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/iexpofplocationprovider/startupdatinglocation()) and start updating the location automatically.<br>
When a plan disappears it will call [stopUpdatingLocation()](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/iexpofplocationprovider/stopupdatinglocation()) **if location provider is not set as Global**.<br>
You also can manually start and stop your location provider using these methods.

Use our full documentation to [setup global location provider](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/setup-navigation#Setup-location-provider-as-Global) or
[listen location updates manually](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/setup-navigation#Listen-location-updates-manually).
