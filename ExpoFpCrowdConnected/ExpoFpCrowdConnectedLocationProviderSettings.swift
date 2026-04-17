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

    let credentials: Credentials

    /// SDK Configuration containing authentication Credentials and tracking mode.
    public let configuration: Configuration

    /// Navigation type to enable.
    public var modules: [Module] { configuration.modules }

    /// Tracking mode: `foreground` or `background`.
    public var trackingMode: LocationTrackingMode { configuration.trackingMode }

    /// Enables 'heading' on the map using build-in native CoreLocation tools.
    public let isHeadingEnabled: Bool

    /// CrowdConnected aliases for deviceID.
    ///
    /// For more information use [Alias guide](https://customer.support.crowdconnected.com/servicedesk/customer/kb/view/2888204977).
    public let aliases: [String: String]

    /// Settings for `ExpoFpCrowdConnectedLocationProvider` initialization.
    ///
    ///   For more information about credentials use [Credentials gude](https://crowdconnected.atlassian.net/helpcenter/support/article/2888139205).
    ///
    ///   For more information about aliases use [Alias guide](https://customer.support.crowdconnected.com/servicedesk/customer/kb/view/2888204977).
    ///
    /// - Parameters:
    ///   - appKey: Authentication credential `AppKey`.
    ///   - clientId: Authentication credential `clientId`.
    ///   - clientSecret: Authentication credential `clientSecret`.
    ///   - modules: Navigation types to enable.
    ///   - trackingMode: Tracking mode: `foreground` or `background`.
    ///   - isHeadingEnabled: Enables 'heading' on the map using build-in native CoreLocation tools.
    ///   - aliases: CrowdConnected aliases for deviceID.
    public init(
        appKey: String,
        clientId: String,
        clientSecret: String,
        modules: [Module],
        trackingMode: LocationTrackingMode,
        isHeadingEnabled: Bool,
        aliases: [String: String] = [:]
    ) throws(ExpoFpError) {

        let appKey = appKey.replacingOccurrences(of: " ", with: "")
        if appKey.isEmpty { throw ExpoFpError.locationProviderError(message: Self.message(for: .missingAppKey)) }

        let clientId = clientId.replacingOccurrences(of: " ", with: "")
        if clientId.isEmpty { throw ExpoFpError.locationProviderError(message: Self.message(for: .missingToken)) }

        let clientSecret = clientSecret.replacingOccurrences(of: " ", with: "")
        if clientSecret.isEmpty { throw ExpoFpError.locationProviderError(message: Self.message(for: .missingSecret)) }

        self.credentials = Credentials(appKey: appKey, clientId: clientId, clientSecret: clientSecret)

        if modules.isEmpty || (modules.count == 1 && modules.first == .coreBluetooth) {
            throw ExpoFpError.locationProviderError(message: Self.message(for: .noModulesAreActive))
        }

        if modules.contains(where: \.isBluetoothEnabled) { try Self.checkBluetoothPermissions() }

        try Self.checkLocationPermissions(for: trackingMode)

        self.configuration = Configuration(credentials: credentials, modules: modules, trackingMode: trackingMode)

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

    private static func message(for result: ErrorCode) -> String {
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
