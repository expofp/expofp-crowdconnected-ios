//
//  ExpoFpCrowdConnectedNavigationType.swift
//  ExpoFpCrowdConnected
//
//  Created by Nikita Kolesnikov on 21.05.2025.
//  Copyright © 2025 ExpoFP. All rights reserved.
//

import CrowdConnectedCore
import ExpoFP

/// Settings for `ExpoFpCrowdConnectedLocationProvider` initialization.
public struct ExpoFpCrowdConnectedLocationProviderSettings {

    /// Authentication credentials: `AppKey`, `Token`, `Secret`.
    ///
    /// For `AppKey` [register here](https://app.crowdconnected.com/register).
    ///
    /// For more information use [Tokens gude](https://customer.support.crowdconnected.com/servicedesk/customer/article/2888139205).
    public let credentials: SDKCredentials

    /// Navigation type to enable.
    public let navigationType: ExpoFpCrowdConnectedNavigationType

    /// Tracking mode: `foregroundOnly` or `foregroundAndBackground`.
    public let trackingMode: LocationTrackingMode

    /// Enables CrowdConnected CoreBluetooth positioning.
    public let isBluetoothEnabled: Bool

    /// Enables 'heading' on the map using build-in native CoreLocation tools.
    public let isHeadingEnabled: Bool

    /// CrowdConnected aliases for deviceID.
    ///
    /// For more information use [Alias guide](https://customer.support.crowdconnected.com/servicedesk/customer/kb/view/2888204977).
    public let aliases: [String: String]

    /// Settings for `ExpoFpCrowdConnectedLocationProvider` initialization.
    /// - Parameters:
    ///   - appKey: Authentication credential `AppKey`. For more information [register here](https://app.crowdconnected.com/register).
    ///   - token: Authentication credential `Token`.
    ///   For more information use [Tokens gude](https://customer.support.crowdconnected.com/servicedesk/customer/article/2888139205).
    ///   - secret: Authentication credential `Secret`.
    ///   For more information use [Tokens gude](https://customer.support.crowdconnected.com/servicedesk/customer/article/2888139205).
    ///   - navigationTypes: Navigation types to enable.
    ///   - trackingMode: Tracking mode: `foregroundOnly` or `foregroundAndBackground`.
    ///   - isHeadingEnabled: Enables 'heading' on the map using build-in native CoreLocation tools.
    ///   - aliases: CrowdConnected aliases for deviceID.
    ///   For more information use [Alias guide](https://customer.support.crowdconnected.com/servicedesk/customer/kb/view/2888204977).
    public init(
        appKey: String,
        token: String,
        secret: String,
        navigationType: ExpoFpCrowdConnectedNavigationType,
        trackingMode: LocationTrackingMode,
        isBluetoothEnabled: Bool,
        isHeadingEnabled: Bool,
        aliases: [String: String] = [:]
    ) throws(ExpoFpError) {

        let appKey = appKey.replacingOccurrences(of: " ", with: "")
        if appKey.isEmpty { throw ExpoFpError.locationProviderError(message: Self.message(for: .missingAppKey)) }

        let token = token.replacingOccurrences(of: " ", with: "")
        if token.isEmpty { throw ExpoFpError.locationProviderError(message: Self.message(for: .missingToken)) }

        let secret = secret.replacingOccurrences(of: " ", with: "")
        if secret.isEmpty { throw ExpoFpError.locationProviderError(message: Self.message(for: .missingSecret)) }

        self.credentials = SDKCredentials(appKey: appKey, token: token, secret: secret)

        try Self.checkLocationPermissions(for: trackingMode)
        self.navigationType = navigationType
        self.trackingMode = trackingMode

        if isBluetoothEnabled { try Self.checkBluetoothPermissions() }
        self.isBluetoothEnabled = isBluetoothEnabled

        self.isHeadingEnabled = isHeadingEnabled
        self.aliases = aliases
    }

    // MARK: - Check Permission Methods

    private static func checkLocationPermissions(for mode: LocationTrackingMode) throws(ExpoFpError) {
        guard checkDescription(for: .locationWhenInUse) else {
            throw ExpoFpError.locationProviderError(message: Self.message(for: .missingWhileInUseLocationPermissionItem))
        }

        guard mode.isAllowedInBackground else { return }

        guard checkDescription(for: .locationAlwaysAndWhenInUse) else {
            throw ExpoFpError.locationProviderError(message: Self.message(for: .missingAlwaysLocationPermissionItem))
        }

        guard checkBackgroundMode(.location) else {
            throw ExpoFpError.locationProviderError(message: Self.message(for: .missingLocationBackgroundModeItem))
        }
    }

    private static func checkBluetoothPermissions() throws(ExpoFpError) {
        guard checkDescription(for: .bluetoothAlwaysUsage) else {
            throw ExpoFpError.locationProviderError(message: Self.message(for: .missingBluetoothPermissionItem))
        }

        guard checkBackgroundMode(.bluetooth) else {
            throw ExpoFpError.locationProviderError(message: Self.message(for: .missingBluetoothBackgroundModeItem))
        }
    }

    private static func message(for result: CrowdConnectedValidationResult) -> String {
        result.description
    }

    private static func checkDescription(for permission: Permission) -> Bool {
        let description = Bundle.main.object(forInfoDictionaryKey: permission.rawValue) as? String
        return description?.isEmpty == false
    }

    private static func checkBackgroundMode(_ mode: BackgroundMode) -> Bool {
        let modes = (Bundle.main.object(forInfoDictionaryKey: BackgroundMode.name) as? [String]) ?? []
        return modes.contains(mode.rawValue)
    }

    private enum BackgroundMode: String {
        case bluetooth = "bluetooth-central"
        case location

        static let name = "UIBackgroundModes"
    }

    private enum Permission: String {
        case bluetoothAlwaysUsage = "NSBluetoothAlwaysUsageDescription"
        case locationWhenInUse = "NSLocationWhenInUseUsageDescription"
        case locationAlwaysAndWhenInUse = "NSLocationAlwaysAndWhenInUseUsageDescription"
    }
}
