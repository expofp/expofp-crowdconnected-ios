//
//  ExpoFpCrowdConnectedNavigationType.swift
//  ExpoFpCrowdConnected
//
//  Created by Nikita Kolesnikov on 21.05.2025.
//  Copyright © 2025 ExpoFP. All rights reserved.
//

public struct ExpoFpCrowdConnectedLocationProviderSettings {

    public let appKey: String
    public let token: String
    public let secret: String
    public let navigationType: ExpoFpCrowdConnectedNavigationType
    public let isAllowedInBackground: Bool
    public let isHeadingEnabled: Bool
    public let aliases: [String: String]

    public init(
        appKey: String,
        token: String,
        secret: String,
        navigationType: ExpoFpCrowdConnectedNavigationType = .ips,
        isAllowInBackground: Bool = false,
        isHeadingEnabled: Bool = false,
        aliases: [String: String] = [:]
    ) {
        self.appKey = appKey
        self.token = token
        self.secret = secret
        self.navigationType = navigationType
        self.isAllowedInBackground = isAllowInBackground
        self.isHeadingEnabled = isHeadingEnabled
        self.aliases = aliases
    }
}
