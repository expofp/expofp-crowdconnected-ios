//
//  ExpoFpCrowdConnectedLocationProvider.swift
//  ExpoFpCrowdConnected
//
//  Created by Nikita Kolesnikov on 21.05.2025.
//  Copyright © 2025 ExpoFP. All rights reserved.
//

import CoreLocation
import CrowdConnectedCore
import CrowdConnectedCoreBluetooth
import CrowdConnectedGeo
import CrowdConnectedIPS
import CrowdConnectedShared
import ExpoFP
import Foundation

public final class ExpoFpCrowdConnectedLocationProvider:
    NSObject,
    CLLocationManagerDelegate,
    CrowdConnectedDelegate,
    IExpoFpLocationProvider {

    // MARK: - Properties

    public weak var expoFpLocationProviderDelegate: ExpoFpLocationProviderDelegate?
    public private(set) var deviceID: DeviceID?
    public private(set) var isLocationUpdating = false
    public private(set) var settings: ExpoFpCrowdConnectedLocationProviderSettings

    private let ccLocationManager = CrowdConnected.shared
    private let clLocationManager = CLLocationManager()
    private var timeoutTask: Task<Void, Error>?

    private var position = ExpoFpPosition() {
        didSet {
            guard isLocationUpdating else { return }
            expoFpLocationProviderDelegate?.positionDidChange(position)
        }
    }

    private var deviceIdDescription: String {
        deviceID.map { "Device ID: \($0). " } ?? ""
    }

    // MARK: - Construction

    public init(settings: ExpoFpCrowdConnectedLocationProviderSettings) {
        self.settings = settings
        super.init()

        ccLocationManager.delegate = self
        clLocationManager.delegate = self

        switch settings.navigationType {
        case .all:
            CrowdConnectedGeo.activate()
            CrowdConnectedIPS.activate()
        case .geo:
            CrowdConnectedGeo.activate()
        case .ips:
            CrowdConnectedIPS.activate()
        }

        if settings.isBluetoothEnabled {
            CrowdConnectedCoreBluetooth.activate()
        }
    }

    // MARK: - Methods

    /// Apply new settings.
    /// If location is updating, method will automatically stop and start location updates with new settings
    /// - Parameter settings: Settings for ExpoFpCrowdConnectedLocationProvider initialization.
    public func updateSettings(_ settings: ExpoFpCrowdConnectedLocationProviderSettings) {
        self.settings = settings

        if isLocationUpdating {
            stopUpdatingLocation()
            startUpdatingLocation()
        }
    }

    public func startUpdatingLocation() {
        guard !isLocationUpdating else { return }
        isLocationUpdating = true
        requestPermission()
        startCrowdConnected()
    }

    public func stopUpdatingLocation() {
        stopTimeoutTask()
        ccLocationManager.stop()
        clLocationManager.stopUpdatingHeading()
        isLocationUpdating = false
    }

    public func didUpdateLocation(_ locations: [Location]) {
        guard let location = locations.last,
              let navType = ExpoFpCrowdConnectedNavigationType(rawValue: location.type)
        else { return }

        position = switch navType {
        case .ips:
            ExpoFpPosition(
                x: location.pixelCoordinates?.xPixels,
                y: location.pixelCoordinates?.yPixels,
                z: .index(location.floor),
                angle: position.angle
            )
        default:
            ExpoFpPosition(
                z: .index(location.floor),
                angle: position.angle,
                lat: location.latitude,
                lng: location.longitude
            )
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard position != ExpoFpPosition() else { return }
        position = position.updateHeading(newHeading: newHeading.trueHeading)
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if clLocationManager.authorizationStatus != .notDetermined {
            requestPermission()
        }

        let errorMessage: String? = switch manager.authorizationStatus {
        case .denied: "Authorization status: Denied."
        case .restricted: "Authorization status: Restricted."
        default: nil
        }

        errorMessage.map {
            let message = deviceIdDescription + $0
            return expoFpLocationProviderDelegate?.errorOccurred(.locationProviderError(message: message), from: .crowdConnected)
        }
    }

    // MARK: - Private Methods

    private func requestPermission() {
        if clLocationManager.authorizationStatus == .notDetermined ||
            (clLocationManager.authorizationStatus == .authorizedWhenInUse && settings.trackingMode.isAllowedInBackground) {

            settings.trackingMode.isAllowedInBackground
            ? clLocationManager.requestAlwaysAuthorization()
            : clLocationManager.requestWhenInUseAuthorization()
        }
    }

    private func startCrowdConnected() {
        startTimeoutTask()

        ccLocationManager.start(
            credentials: settings.credentials,
            trackingMode: settings.trackingMode
        ) { [weak self, settings, deviceIdDescription] deviceID, result in

            self?.stopTimeoutTask()

            if deviceID != nil {
                self?.deviceID = deviceID
            }

            switch result {
            case .alreadyRunning, .success:
                if settings.isHeadingEnabled {
                    self?.clLocationManager.startUpdatingHeading()
                }

                if settings.trackingMode.isAllowedInBackground {
                    self?.ccLocationManager.activateSDKBackgroundRefresh()
                }

                settings.aliases.forEach(CrowdConnected.shared.setAlias)

            case .missingAppKey, // will crash the app
                    .missingToken, // will crash the app
                    .missingSecret, // will crash the app
                    .deviceRegistrationFailed,
                    .noModulesAreActive, // will crash the app
                    .missingBluetoothPermissionItem, // will crash the app
                    .missingWhileInUseLocationPermissionItem, // will crash the app
                    .missingAlwaysLocationPermissionItem, // will crash the app
                    .missingLocationBackgroundModeItem, // will crash the app
                    .missingBluetoothBackgroundModeItem: // will crash the app
                self?.stopUpdatingLocation()

                let error = ExpoFpError.locationProviderError(message: deviceIdDescription + result.description)
                self?.expoFpLocationProviderDelegate?.errorOccurred(error, from: .crowdConnected)

            @unknown default:
                self?.stopUpdatingLocation()

                let error = ExpoFpError.locationProviderError(message: deviceIdDescription + "@unknown start result!")
                self?.expoFpLocationProviderDelegate?.errorOccurred(error, from: .crowdConnected)
            }
        }
    }

    private func startTimeoutTask() {
        timeoutTask?.cancel()

        timeoutTask = Task { [weak self, deviceIdDescription] in
            try await Task.sleep(nanoseconds: 65 * 1_000_000_000) // 65 seconds
            guard !Task.isCancelled else { return }

            let error = ExpoFpError.locationProviderError(message: deviceIdDescription + "Start Timeout!")
            self?.expoFpLocationProviderDelegate?.errorOccurred(error, from: .crowdConnected)

            self?.stopUpdatingLocation()
            self?.startUpdatingLocation()
        }
    }

    private func stopTimeoutTask() {
        timeoutTask?.cancel()
        timeoutTask = nil
    }
}
