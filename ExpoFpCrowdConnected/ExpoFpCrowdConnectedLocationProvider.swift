//
//  ExpoFpCrowdConnectedLocationProvider.swift
//  ExpoFpCrowdConnected
//
//  Created by Nikita Kolesnikov on 21.05.2025.
//  Copyright © 2025 ExpoFP. All rights reserved.
//

import CoreLocation
import CrowdConnectedCore
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

    private let settings: ExpoFpCrowdConnectedLocationProviderSettings
    private let ccLocationManager = CrowdConnected.shared
    private let clLocationManager = CLLocationManager()
    private var isLocationUpdating = false

    private var position = ExpoFpPosition() {
        didSet {
            guard isLocationUpdating else { return }
            expoFpLocationProviderDelegate?.positionDidChange(position)
        }
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

        settings.aliases.forEach(ccLocationManager.setAlias)
        requestPermission()
    }

    // MARK: - Methods

    public func startUpdatingLocation() async throws {
        guard !isLocationUpdating else { return }
        isLocationUpdating = true

        return try await withCheckedThrowingContinuation { [weak self, settings] continuation in
            self?.ccLocationManager.start(
                appKey: settings.appKey,
                token: settings.token,
                secret: settings.secret
            ) { _, errorMessage in

                if let errorMessage {
                    self?.stopUpdatingLocation()
                    continuation.resume(throwing: ExpoFpError.locationProviderError(message: errorMessage))
                } else {
                    if settings.isHeadingEnabled {
                        self?.clLocationManager.startUpdatingHeading()
                    }
                    continuation.resume()
                }
            }
        }
    }

    public func stopUpdatingLocation() {
        isLocationUpdating = false

        ccLocationManager.stop()
        clLocationManager.stopUpdatingHeading()
    }

    public func didUpdateLocation(_ locations: [CrowdConnectedCore.Location]) {
        guard let location = locations.first,
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
        position = ExpoFpPosition(
            x: position.x,
            y: position.y,
            z: position.z,
            angle: newHeading.trueHeading,
            lat: position.lat,
            lng: position.lng
        )
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined ||
            (manager.authorizationStatus == .authorizedWhenInUse && settings.isAllowedInBackground) {
            requestPermission()
        }
    }

    private func requestPermission() {
        settings.isAllowedInBackground
        ? clLocationManager.requestAlwaysAuthorization()
        : clLocationManager.requestWhenInUseAuthorization()
    }
}
