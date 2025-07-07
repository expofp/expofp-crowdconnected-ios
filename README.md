<img src="https://expofp.com/template/img/site-header-logo-inverse.png" width="350"/>

[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ExpoFpCrowdConnected.svg)](https://cocoapods.org/pods/ExpoFpCrowdConnected)
[![Platform](https://img.shields.io/badge/Platforms-%20iOS%20|%20iPadOS-lightgrey.svg)](https://github.com/expofp/expofp-crowdconnected-ios)

**ExpoFpCrowdConnected** is a wrapper around [CrowdConnected Location Provider](https://github.com/CrowdConnected), made for **ExpoFP** floor plans.<br>
This package includes the latest version of [ExpoFP SDK](https://github.com/expofp/expofp-sdk-ios).<br>
Also you can take [CrowdConnected SDK](https://github.com/CrowdConnected) and create your own wrapper to use with [ExpoFP SDK](https://github.com/expofp/expofp-sdk-ios) after confirming it to `IExpoFpLocationProvider` protocol following the [documentation](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/setup-navigation) or the example in this package.

## Setup

### Activate GPS/IPS option:
![image](https://github.com/user-attachments/assets/65658895-cd91-4a66-936d-c7e9bf8ffd82)

### Add permissions to Info.plist:

```xml
<key>UIBackgroundModes</key>
<array>
<string>location</string>
</array>

<key>NSLocationAlwaysUsageDescription</key>
<string>Platform location requested for better indoor positioning experience.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Platform location requested for better indoor positioning experience.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Platform location requested for better indoor positioning experience.</string>
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/expofp/expofp-crowdconnected-ios", from: "5.0.0"),
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
> Warning: CocoaPods [will be deprecated soon](https://blog.cocoapods.org/CocoaPods-Specs-Repo/)

```swift
target 'MyApp' do
    pod 'ExpoFpCrowdConnected', '~> 5.0.0'
end
```

## Quick Guide

```swift
let settings = ExpoFpCrowdConnectedLocationProviderSettings(
    appKey: "YourAppKey",
    token: "YourToken",
    secret: "YourSecret",
    navigationType: ExpoFpCrowdConnectedNavigationType = .ips, // or .geo or .all
    isAllowInBackground: false, // or true if NSLocationAlwaysUsageDescription added
    isHeadingEnabled: false, // or true if settings allowed
    aliases: ["AliasKey": "AliasValue"]
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

When a plan appers it will call [startUpdatingLocation()](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/iexpofplocationprovider/startupdatinglocation()) and start updating the location automatically.<br>
When a plan disappears it will call [stopUpdatingLocation()](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/iexpofplocationprovider/stopupdatinglocation()) **if location provider is not set as Global**.<br>
You also can manually start and stop your location provider using these methods.

Use our full documentation to [setup global location provider](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/setup-navigation#Setup-location-provider-as-Global) and
[listen location updates](https://expofp.github.io/expofp-sdk-ios/documentation/expofp/setup-navigation#Listen-location-updates-manually).