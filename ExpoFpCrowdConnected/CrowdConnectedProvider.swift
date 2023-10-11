import Foundation
import ExpoFpCommon
import CrowdConnectedCore
import CrowdConnectedIPS
import CrowdConnectedGeo
import CrowdConnectedShared
import CoreLocation

public class CrowdConnectedProvider : NSObject, CLLocationManagerDelegate, LocationProvider, CrowdConnectedDelegate {
    private let settings: Settings
    private let locationManager = CLLocationManager()
    
    private var started = false
    //private var ccStarted = false
    private var inBackground = false
    private var lDelegate: ExpoFpCommon.LocationProviderDelegate? = nil
    
    public var delegate: ExpoFpCommon.LocationProviderDelegate? {
        get { lDelegate }
        set(newDelegate) {
            lDelegate = newDelegate
            self.requestPermission()
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
    
    public func start(_ inBackground: Bool) {
        if(self.started){
            return
        }
        
        print("[CrowdConnectedProvider] start")
        
        self.started = true
        self.inBackground = inBackground
        startAsync(inBackground)
    }
    
    public func stop() {
        if(!self.started){
            return
        }
        
        print("[CrowdConnectedProvider] stop")
        
        self.started = false
        stopAsync()
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if(manager.authorizationStatus == .notDetermined){
            self.requestPermission()
        }
        else if((manager.authorizationStatus == .authorizedAlways
                    || manager.authorizationStatus == .authorizedWhenInUse)
                && manager.accuracyAuthorization == .reducedAccuracy){
            print("[CrowdConnectedProvider] The provider requires 'accuracyAuthorization' permission to work.")
        }
    }
    
    private func startAsync(_ inBackground: Bool){
        //ccStarted = true
        
        DispatchQueue.main.async { [weak self] in
            
            if(self == nil){
                return
            }
            
            self?.locationManager.delegate = self
            CrowdConnected.shared.delegate = self

            switch self!.settings.mode {
            case .IPS_ONLY:
                print("[CrowdConnectedProvider] CrowdConnectedIPS activate")
                CrowdConnectedIPS.activate()
                break
            case .IPS_AND_GPS:
                print("[CrowdConnectedProvider] CrowdConnectedGeo activate")
                CrowdConnectedGeo.activate()
                print("[CrowdConnectedProvider] CrowdConnectedIPS activate")
                CrowdConnectedIPS.activate()
                break
            case .GPS_ONLY:
                print("[CrowdConnectedProvider] CrowdConnectedGeo activate")
                CrowdConnectedGeo.activate()
                break
            }
            
            print("[CrowdConnectedProvider] CrowdConnected start")
            CrowdConnected.shared.start(appKey: self!.settings.appKey, token: self!.settings.token, secret: self!.settings.secret) { deviceId, error in
                if(CrowdConnected.shared.isSuccessfullyRunning && !self!.started){
                    self?.stopAsync()
                }
                else if(CrowdConnected.shared.isSuccessfullyRunning){
                    print("[CrowdConnectedProvider] CrowdConnected is connected: \(CrowdConnected.shared.isSuccessfullyRunning)")
                    //print("[CrowdConnectedProvider] CrowdConnected, deviceId: \(deviceId!)")
                    //CrowdConnected.shared.delegate = self
                    for (aliasKey, aliasValue) in self!.settings.aliases {
                        CrowdConnected.shared.setAlias(key: aliasKey, value: aliasValue)
                    }
                    
                    self?.requestPermission()
                }
            }
            //self.requestPermission()
        }
    }
    
    private func stopAsync(){
        //ccStarted = false
        DispatchQueue.main.async { [weak self] in
            self?.locationManager.delegate = nil
            
            if(CrowdConnected.shared.delegate === self){
                CrowdConnected.shared.delegate = nil
                CrowdConnected.shared.stop()
            }
        }
    }
    
    private func requestPermission(){
        if(started && delegate != nil){
            DispatchQueue.main.async{ [weak self] in
                
                if(self == nil){
                    return
                }
                
                if(self!.inBackground){
                    print("[CrowdConnectedProvider] request 'AlwaysAuthorization' permission")
                    self?.locationManager.requestAlwaysAuthorization()
                }
                else{
                    print("[CrowdConnectedProvider] request 'WhenInUseAuthorization' permission")
                    self?.locationManager.requestWhenInUseAuthorization()
                }
            }
        }
    }
}

