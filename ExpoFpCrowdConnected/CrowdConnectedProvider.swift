import Foundation
import ExpoFpCommon
import CrowdConnectedCore
import CrowdConnectedIPS
import CrowdConnectedGeo
import CrowdConnectedShared
import CoreLocation

public class CrowdConnectedProvider : LocationProvider, CrowdConnectedDelegate {
    private let settings: Settings
    
    private var lDelegate: ExpoFpCommon.LocationProviderDelegate? = nil
    
    public var delegate: ExpoFpCommon.LocationProviderDelegate? {
        get { lDelegate }
        set(newDelegate) {
            lDelegate = newDelegate
            requestPermissions()
        }
    }
    
    public init(_ settings: Settings){
        self.settings = settings
    }
    
    public func didUpdateLocation(_ locations: [CrowdConnectedCore.Location]) {
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
                if let dlg = delegate {
                    dlg.didUpdateLocation(location: dloc!)
                }
            }
        }
    }
        
    public func start() {
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
            if(deviceId != nil && deviceId != ""){
                CrowdConnected.shared.delegate = self
                for (aliasKey, aliasValue) in self.settings.aliases {
                    CrowdConnected.shared.setAlias(key: aliasKey, value: aliasValue)
                }
            }
        }
    }
    
    public func stop() {
        CrowdConnected.shared.delegate = nil
        CrowdConnected.shared.stop()
    }
    
    private func requestPermissions() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
}