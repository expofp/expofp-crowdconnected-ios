import Foundation
import ExpoFpCommon
import CrowdConnectedCore
import CrowdConnectedIPS
import CrowdConnectedGeo
import CrowdConnectedShared
import CoreLocation

public class CrowdConnectedProvider : LocationProvider, CrowdConnectedDelegate {
    
    private let settings: Settings
    private var delegates: [LocationProviderDelegate]
    
    public init(_ settings: Settings){
        self.settings = settings
        self.delegates = []
    }
    
    public func didUpdateLocation(_ locations: [CrowdConnectedCore.Location]) {
        print("++++ CrowdConnectedProvider didUpdateLocation")
        print(locations)
        
        if(!locations.isEmpty){
            let loc = locations.first!
            
            let floor = "\(loc.floor)"
            let angle: Double? = nil
            
            var dloc: ExpoFpCommon.Location? = nil;
            if(loc.type == "IPS" && loc.pixelCoordinates != nil){
                dloc = ExpoFpCommon.Location(x: loc.pixelCoordinates!.xPixels, y: loc.pixelCoordinates!.yPixels, z: floor, angle: angle)
            }
            else if(loc.type == "GEO"){
                dloc = ExpoFpCommon.Location(latitude: loc.latitude, longitude: loc.longitude, angle: angle)
            }
            
            if(dloc != nil) {
                for delegate in self.delegates {
                    delegate.didUpdateLocation(location: dloc!)
                }
            }
        }
    }
    
    public func addDelegate(_ delegate: LocationProviderDelegate) {
        self.delegates.append(delegate)
        
        requestPermissions()
    }
    
    public func removeDelegate(_ delegate: LocationProviderDelegate) {
        self.delegates.remove(at: self.delegates.startIndex)
    }
    
    
    public func start() {
        print("++++ CrowdConnectedProvider start, mode: \(self.settings.mode)")
        
        switch self.settings.mode {
        case .IPS_ONLY:
            CrowdConnectedIPS.activate()
            break
        case .IPS_AND_GPS:
            CrowdConnectedGeo.activate()
            CrowdConnectedIPS.activate()
            break
        case .GPS_ONLY:
            CrowdConnectedGeo.activate()
            break
        }
        
        CrowdConnected.shared.start(appKey: self.settings.appKey, token: self.settings.token, secret: self.settings.secret) { deviceId, error in
            print("++++ CrowdConnectedProvider CrowdConnected.shared.start deviceId: \(deviceId ?? "NaN")")
            if(deviceId != nil && deviceId != ""){
                CrowdConnected.shared.delegate = self
                for (aliasKey, aliasValue) in self.settings.aliases {
                    CrowdConnected.shared.setAlias(key: aliasKey, value: aliasValue)
                }
            }
        }
    }
    
    public func stop() {
        print("++++ CrowdConnectedProvider stop")
        CrowdConnected.shared.delegate = nil
        CrowdConnected.shared.stop()
    }
    
    private func requestPermissions() {
        print("++++ CrowdConnectedProvider requestPermissions")
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
}
