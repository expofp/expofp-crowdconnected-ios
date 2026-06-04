//
//  ExpoFpCrowdConnectedLocationProvider.swift
//  ExpoFpCrowdConnected
//
//  Created by Nikita Kolesnikov on 21.05.2025.
//  Copyright © 2025 ExpoFP. All rights reserved.
//

import CoreLocation
import CrowdConnectedCore
import ExpoFP
import Foundation

public final class ExpoFpCrowdConnectedLocationProvider: NSObject, IExpoFpLocationProvider {

    // MARK: - Properties

    public let id = UUID()
    public weak var expoFpLocationProviderDelegate: (any ExpoFpLocationProviderDelegate)?

    public var isLocationUpdating: Bool { ccLocationManager.isRunning }
    public var deviceID: DeviceID? { ccLocationManager.deviceID }
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
        requestPermission()
        startTimeoutTask()

        ccLocationManager.start(with: settings.configuration)
    }

    public func stopUpdatingLocation() {
        stopTimeoutTask()
        ccLocationManager.stop()
        clLocationManager.stopUpdatingHeading()
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

    private func startTimeoutTask() {
        timeoutTask?.cancel()

        timeoutTask = Task { [weak self] in
            try await Task.sleep(nanoseconds: 65 * 1_000_000_000) // 65 seconds
            guard !Task.isCancelled else { return }

            let error = ExpoFpError.locationProviderError(message: (self?.deviceIdDescription ?? "") + "Start Timeout!")
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

// MARK: - CLLocationManagerDelegate

extension ExpoFpCrowdConnectedLocationProvider: CLLocationManagerDelegate {

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
}

// MARK: - CrowdConnectedDelegate

extension ExpoFpCrowdConnectedLocationProvider: CrowdConnectedDelegate {

    public func locationProvider(_ crowdConnected: CrowdConnected, didStartSuccess deviceId: DeviceID) {
        stopTimeoutTask()

        if settings.isHeadingEnabled {
            clLocationManager.startUpdatingHeading()
        }

        settings.aliases.forEach(ccLocationManager.setAlias)
    }

    public func locationProvider(_ crowdConnected: CrowdConnected, didStartFailure errorCode: ErrorCode) {
        stopUpdatingLocation()

        let error = ExpoFpError.locationProviderError(message: deviceIdDescription + errorCode.description)
        expoFpLocationProviderDelegate?.errorOccurred(error, from: .crowdConnected)
    }

    public func locationProvider(_ crowdConnected: CrowdConnected, didUpdateLocation location: Location) {
        position = location.type == "IPS"
        ? ExpoFpPosition(
            x: location.pixelCoordinates?.xPixels,
            y: location.pixelCoordinates?.yPixels,
            z: .index(location.floor),
            angle: position.angle
        )
        : ExpoFpPosition(
            z: .index(location.floor),
            angle: position.angle,
            lat: location.latitude,
            lng: location.longitude
        )
    }
}
