//
//  Extensions.swift
//  ExpoFpCrowdConnected
//
//  Created by Nikita Kolesnikov on 24.09.2025.
//  Copyright © 2025 ExpoFP. All rights reserved.
//

import CrowdConnectedCore
import ExpoFP

extension LocationTrackingMode {

    var isAllowedInBackground: Bool {
        self == .foregroundAndBackground
    }
}

extension ExpoFpPosition {

    func updateHeading(newHeading: Double?) -> ExpoFpPosition {
        ExpoFpPosition(x: x, y: y, z: z, angle: newHeading, lat: lat, lng: lng)
    }
}
