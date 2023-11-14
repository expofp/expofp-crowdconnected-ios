import Foundation
import ExpoFpCommon

public struct Settings {

    public let locationProvider: LocationProvider?
    
    public let useGlobalLocationProvider: Bool
    
    public let focusOnLocation: Bool
    
    public let focusOnFirstLocation: Bool
    
    public let allowConsent: Bool
    
    public let loadingTimeout: Double
    
    public let configuration: Configuration?
    
    public init() {
        self.init(locationProvider: nil, useGlobalLocationProvider: false, focusOnLocation: false, focusOnFirstLocation: false)
    }
    
    public init(locationProvider: LocationProvider?) {
        self.init(locationProvider: locationProvider, useGlobalLocationProvider: false, focusOnLocation: false, focusOnFirstLocation: false)
    }
    
    public init(locationProvider: LocationProvider?, focusOnLocation: Bool) {
        self.init(locationProvider: locationProvider, useGlobalLocationProvider: false, focusOnLocation: focusOnLocation, focusOnFirstLocation: false)
    }
    
    public init(locationProvider: LocationProvider?, focusOnFirstLocation: Bool) {
        self.init(locationProvider: locationProvider, useGlobalLocationProvider: false, focusOnLocation: false, focusOnFirstLocation: focusOnFirstLocation)
    }
    
    public init(useGlobalLocationProvider: Bool) {
        self.init(locationProvider: nil, useGlobalLocationProvider: useGlobalLocationProvider, focusOnLocation: false, focusOnFirstLocation: false)
    }
    
    public init(useGlobalLocationProvider: Bool, focusOnLocation: Bool) {
        self.init(locationProvider: nil, useGlobalLocationProvider: useGlobalLocationProvider, focusOnLocation: focusOnLocation, focusOnFirstLocation: false)
    }
    
    public init(useGlobalLocationProvider: Bool, focusOnFirstLocation: Bool) {
        self.init(locationProvider: nil, useGlobalLocationProvider: useGlobalLocationProvider, focusOnLocation: false, focusOnFirstLocation: focusOnFirstLocation)
    }
    
    public init(locationProvider: LocationProvider?, useGlobalLocationProvider: Bool, focusOnLocation: Bool, focusOnFirstLocation: Bool) {
        self.init(locationProvider: locationProvider, useGlobalLocationProvider: useGlobalLocationProvider, focusOnLocation: focusOnLocation, focusOnFirstLocation: focusOnFirstLocation, loadingTimeout: 15.0, configuration: nil)
    }

    public init(locationProvider: LocationProvider?, useGlobalLocationProvider: Bool, focusOnLocation: Bool, focusOnFirstLocation: Bool, loadingTimeout: Double ) {
        self.init(locationProvider: locationProvider, useGlobalLocationProvider: useGlobalLocationProvider, focusOnLocation: focusOnLocation,
                  focusOnFirstLocation: focusOnFirstLocation, loadingTimeout: loadingTimeout, configuration: nil)
    }
    
    public init(locationProvider: LocationProvider?, useGlobalLocationProvider: Bool, focusOnLocation: Bool, focusOnFirstLocation: Bool, loadingTimeout: Double, configuration: Configuration?) {
        self.init(locationProvider: locationProvider, useGlobalLocationProvider: useGlobalLocationProvider, focusOnLocation: focusOnLocation,
                  focusOnFirstLocation: focusOnFirstLocation, allowConsent: false, loadingTimeout: loadingTimeout, configuration: configuration)
    }
    
    public init(locationProvider: LocationProvider?, useGlobalLocationProvider: Bool, focusOnLocation: Bool, focusOnFirstLocation: Bool, allowConsent: Bool, loadingTimeout: Double, configuration: Configuration?) {
        
        self.locationProvider = locationProvider
        self.useGlobalLocationProvider = useGlobalLocationProvider
        self.focusOnLocation = focusOnLocation
        self.focusOnFirstLocation = focusOnFirstLocation
        self.allowConsent = allowConsent
        self.loadingTimeout = loadingTimeout
        self.configuration = configuration
    }
    
    public static func getCopy(_ settings: Settings, configuration: Configuration) -> Settings {
        return Settings(locationProvider: settings.locationProvider,
                        useGlobalLocationProvider: settings.useGlobalLocationProvider,
                        focusOnLocation: settings.focusOnLocation,
                        focusOnFirstLocation: settings.focusOnFirstLocation,
                        allowConsent: settings.allowConsent,
                        loadingTimeout: settings.loadingTimeout,
                        configuration: configuration)
    }
}
