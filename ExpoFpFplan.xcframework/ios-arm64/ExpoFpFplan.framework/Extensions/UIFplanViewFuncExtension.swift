import Foundation
import WebKit
import ExpoFpCommon
import ZIPFoundation

public extension UIFplanView {
    /**
     Set a callback that is called after the plan is initialized.
     
     **Parameters:**
     - callback: Callback
     */
    func setOnFpReadyCallback(_ callback: @escaping () -> Void){
        self.fpReadyCallback = callback
    }
    
    /**
     Sets a callback that is called when a plan initialization error occurs.
     
     **Parameters:**
     - callback: Callback
     */
    func setOnFpErrorCallback(_ callback: @escaping (_ errorCode: Int, _ description: String) -> Void){
        self.fpErrorCallback = callback
    }
    
    
    /**
     Set a callback that is called after selecting a booth on the plan.
     
     **Parameters:**
     - callback: Callback
     */
    func setOnBoothClickCallback(_ callback: @escaping (_ id: String?, _ name: String?) -> Void){
        self.selectBoothCallback = callback
    }
    
    /**
     Set a callback that is called after the route is built.
     
     **Parameters:**
     - callback: Callback
     */
    func setOnBuildDirectionCallback(_ callback: @escaping (_ direction: Direction?) -> Void){
        self.buildDirectionCallback = callback
    }
    
    /**
     Set a callback that is called after receiving a message from the plan.
     
     **Parameters:**
     - callback: Callback
     */
    func setOnMessageReceivedCallback(_ callback: @escaping (_ message: String?) -> Void){
        self.messageReceivedCallback = callback
    }
    
    /**
     Set a callback that is called after details is open.
     
     **Parameters:**
     - callback: Callback
     */
    func setOnDetailsClickCallback(_ callback: @escaping (_ details: Details?) -> Void){
        self.detailsClickCallback = callback
    }
    
    /**
     Set a callback that is called after custom button is click.
     
     **Parameters:**
     - callback: Callback
     */
    func setOnExhibitorCustomButtonClickCallback(_ callback: @escaping (_ externalId: String, _ buttonNumber: Int, _ buttonUrl: String) -> Void){
        self.exhibitorCustomButtonClickCallback = callback
    }
    
    /**
     Set a callback that is called after more details button(on festival) is click.
     
     **Parameters:**
     - callback: Callback
     */
    func setOnFestMoreDetailsClickCallback(_ callback: @escaping (_ id: String) -> Void){
        self.festMoreDetailsClickCallback = callback
    }
    
    /**
     Set a callback that is called after directions button(on festival) is click.
     
     **Parameters:**
     - callback: Callback
     */
    func setOnFestDirectionsClick(_ callback: @escaping (_ id: String, _ url: String) -> Void){
        self.festDirectionsClickCallback = callback
    }
    
    
    /**
     Starts the plan loading process.
     
     **Parameters:**
     - url: Plan URL
     */
    func load(_ url: String){
        load(url, settings: Settings(locationProvider: nil, useGlobalLocationProvider: false,
                                     focusOnLocation: false, focusOnFirstLocation: false))
    }
    
    /**
     Starts the plan loading process.
     
     **Parameters:**
     - url: Plan URL.
     - locationProvider: Сoordinate provider.
     */
    func load(_ url: String, locationProvider: LocationProvider? = nil) {
        load(url, settings: Settings(locationProvider: locationProvider, useGlobalLocationProvider: false,
                                     focusOnLocation: false, focusOnFirstLocation: false))
    }
    
    /**
     Start the plan loading process.
     
     **Parameters:**
     - url: Plan URL.
     - locationProvider: Сoordinate provider.
     - configuration: Plan config.
     */
    func load(_ url: String, locationProvider: LocationProvider? = nil, loadingTimeout: Double, configuration: Configuration? = nil) {
        load(url, settings: Settings(locationProvider: locationProvider, useGlobalLocationProvider: false,
                                     focusOnLocation: false, focusOnFirstLocation: false,
                                     loadingTimeout: loadingTimeout, configuration: configuration))
    }
    
    /**
     Start the plan loading process.
     
     **Parameters:**
     - url: Plan URL.
     - useGlobalLocationProvider: Flag indicating whether to use the global coordinate provider.
     */
    func load(_ url: String, useGlobalLocationProvider: Bool = false) {
        load(url, settings: Settings(locationProvider: nil, useGlobalLocationProvider: useGlobalLocationProvider,
                                     focusOnLocation: false, focusOnFirstLocation: false))
    }
    
    /**
     Start the plan loading process.
     
     **Parameters:**
     - url: Plan URL.
     - useGlobalLocationProvider: Flag indicating whether to use the global coordinate provider.
     - configuration: Plan config.
     */
    func load(_ url: String, useGlobalLocationProvider: Bool = false, loadingTimeout: Double, configuration: Configuration? = nil) {
        load(url, settings: Settings(locationProvider: nil, useGlobalLocationProvider: useGlobalLocationProvider,
                                     focusOnLocation: false, focusOnFirstLocation: false,
                                     loadingTimeout: loadingTimeout, configuration: configuration))
    }
    
    func openZip(_ zipFilePath: String, params: String? = nil) {
        openZip(zipFilePath, params: params, settings: Settings(locationProvider: nil, useGlobalLocationProvider: false,
                                                                focusOnLocation: false, focusOnFirstLocation: false))
    }
    
    func openZip(_ zipFilePath: String, params: String? = nil, locationProvider: LocationProvider? = nil) {
        openZip(zipFilePath, params: params, settings: Settings(locationProvider: locationProvider, useGlobalLocationProvider: false,
                                                                focusOnLocation: false, focusOnFirstLocation: false))
    }
    
    func openZip(_ zipFilePath: String, params: String? = nil, locationProvider: LocationProvider? = nil, loadingTimeout: Double, configuration: Configuration? = nil) {
        openZip(zipFilePath, params: params, settings: Settings(locationProvider: locationProvider, useGlobalLocationProvider: false,
                                                                focusOnLocation: false, focusOnFirstLocation: false,
                                                                loadingTimeout: loadingTimeout, configuration: configuration))
    }
    
    func openZip(_ zipFilePath: String, params: String? = nil, useGlobalLocationProvider: Bool = false) {
        openZip(zipFilePath, params: params, settings: Settings(locationProvider: nil, useGlobalLocationProvider: useGlobalLocationProvider,
                                                                focusOnLocation: false, focusOnFirstLocation: false))
    }
    
    func openZip(_ zipFilePath: String, params: String? = nil, useGlobalLocationProvider: Bool = false, loadingTimeout: Double, configuration: Configuration? = nil) {
        openZip(zipFilePath, params: params, settings: Settings(locationProvider: nil, useGlobalLocationProvider: useGlobalLocationProvider,
                                                                focusOnLocation: false, focusOnFirstLocation: false,
                                                                loadingTimeout: loadingTimeout, configuration: configuration))
    }
    
    func openZip(_ zipFilePath: String,
                 params: String? = nil,
                 settings: Settings) {
        
        print("[Fplan] Open Zip file:\(zipFilePath), params: \(params ?? "nil")")
        
        DispatchQueue.main.async { [weak self] in
            self?.webView.loadHTMLString(Helper.getLoadingPageHtml(), baseURL: nil)
        }
        
        self.settings = settings
        self.focusOnFirstLocation = settings.focusOnFirstLocation
        self.config = settings.configuration
        
        let zipFileURL = URL(fileURLWithPath: zipFilePath)
        let fplanDirectoryUrl = Helper.getCacheDirectory().appendingPathComponent("fplan/")
        let archivesDirectoryUrl = fplanDirectoryUrl.appendingPathComponent("archives/")
        let archivesDirectoryPath = archivesDirectoryUrl.path
        
        print("[Fplan] Open Zip file, archivesDirectoryPath: \(archivesDirectoryPath)")
        
        let fileManager = FileManager.default
        do {
            if(fileManager.fileExists(atPath: archivesDirectoryPath)){
                try fileManager.removeItem(at: archivesDirectoryUrl)
            }
            
            try fileManager.createDirectory(at: archivesDirectoryUrl, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: zipFileURL, to: archivesDirectoryUrl, progress: nil)
            
            if(fileManager.fileExists(atPath: archivesDirectoryPath)){
                if let items = try? fileManager.contentsOfDirectory(atPath: archivesDirectoryPath) {
                    var fParams = params ?? ""
                    fParams = (fParams.isEmpty || fParams.hasPrefix("?")) ? fParams : "?\(fParams)"
                    fParams = fParams + Helper.getAllowConsentParametr(string: fParams, settings: settings)
                    
                    print("[Fplan] Open Zip file, format params: \(fParams)")
                    
                    let indexUrlBase = archivesDirectoryUrl.appendingPathComponent("\(items[items.startIndex])/index.html")
                    
                    print("[Fplan] Open Zip file, url: \(indexUrlBase.absoluteString)")
                    
                    let indexUrl: URL = URL(string: fParams, relativeTo: indexUrlBase)!
                    
                    DispatchQueue.main.async { [weak self] in
                        let requestUrl = URLRequest(url: indexUrl)
                        self?.webView.load(requestUrl)
                    }
                }
            }
            
        } catch {
            print("[Fplan] Extraction of ZIP archive failed with error:\(error)")
        }
    }
    
    /**
     Stop fplan.
     */
    func destoy() {
        DispatchQueue.main.async { [weak self] in
            self?.destroyView()
            if self?.superview != nil {
                self?.removeFromSuperview()
            }
        }
    }
    
    /**
     Select a exhibitor on the floor plan.
     
     **Parameters:**
     - exhibitorName: Exhibitor name
     */
    func selectExhibitor(_ exhibitorName: String?){
        DispatchQueue.main.async() { [weak self] in
            if(exhibitorName != nil && exhibitorName != "") {
                self?.webView.evaluateJavaScript("window.___fp && window.___fp.selectExhibitor('\(exhibitorName!)');", completionHandler: nil)
            }
            else {
                self?.webView.evaluateJavaScript("window.___fp && window.___fp.selectExhibitor('');", completionHandler: nil)
            }
        }
    }
    
    /**
     Select a booth on the floor plan.
     
     **Parameters:**
     - boothName: Booth name
     */
    func selectBooth(_ boothName: String?){
        DispatchQueue.main.async() { [weak self] in
            if(boothName != nil && boothName != "") {
                self?.webView.evaluateJavaScript("window.___fp && window.___fp.selectBooth('\(boothName!)');", completionHandler: nil)
            }
            else {
                self?.webView.evaluateJavaScript("window.___fp && window.___fp.selectBooth('');", completionHandler: nil)
            }
        }
    }
    
    /**
     Start the process of building a route from one booth to another.
     After the route is built, the buildDirectionAction callback is called.
     
     **Parameters:**
     - route: Route info
     */
    func selectRoute(_ route: Route?){
        if(route != nil) {
            DispatchQueue.main.async() { [weak self] in
                self?.webView.evaluateJavaScript("window.___fp && window.___fp.selectRoute('\(route!.from)', '\(route!.to)', \(route!.exceptInaccessible));", completionHandler: nil)
            }
        }
        else {
            selectBooth(nil)
        }
    }
    
    /**
     Set a blue-dot point.
     
     **Parameters:**
     - position: Coordinates.
     - focus: True - focus the floor plan display on the passed coordinates.
     */
    func setCurrentPosition(_ position: BlueDotPoint?, _ focus: Bool = false){
        if(position != nil) {
            let x = position!.x != nil ? "\(position!.x!)" : "null"
            let y = position!.y != nil ? "\(position!.y!)" : "null"
            
            let z = position!.z != nil ? "'\(position!.z!)'" : "null"
            let angle = position!.angle != nil ? "\(position!.angle!)" : "null"
            
            let lat = position!.latitude != nil ? "\(position!.latitude!)" : "null"
            let lng = position!.longitude != nil ? "\(position!.longitude!)" : "null"
            
            let js =  "window.___fp && window.___fp.selectCurrentPosition({ x: \(x), y: \(y), z: \(z), angle: \(angle), lat: \(lat), lng: \(lng) }, \(focus));"
            
            DispatchQueue.main.async() { [weak self] in
                self?.webView.evaluateJavaScript(js, completionHandler: nil)
            }
        }
        else {
            DispatchQueue.main.async() { [weak self] in
                self?.webView.evaluateJavaScript("window.___fp && window.___fp.selectCurrentPosition(null, false);", completionHandler: nil)
            }
        }
    }
    
    /**
     Clear the floor plan
     */
    func clear() {
        selectBooth(nil)
        selectRoute(nil)
        setCurrentPosition(nil)
    }
    
    func load(_ url: String, settings: Settings, offlineZipFilePath: String? = nil) {
        
        if(!Helper.isValidUrl(url)){
            if let collback = self?.fpErrorCallback {
                DispatchQueue.global(qos: .userInitiated).async {
                    try? collback(NSURLErrorBadURL, "ERROR_BAD_URL")
                }
            }
            return
        }
        
        var formatUrl = (url.starts(with: "https://") ? url : "https://\(url)")
        formatUrl = formatUrl + Helper.getAllowConsentParametr(string: formatUrl, settings: settings)
        
        print("[Fplan] load: \(formatUrl), offlineZipFilePath: \(offlineZipFilePath ?? "")")
        
        isFplanReady = false
        isFplanDestroyed = false
        
        self.settings = settings
        self.focusOnFirstLocation = settings.focusOnFirstLocation
        self.config = settings.configuration
        
        let fileManager = FileManager.default
        let netReachability = NetworkReachability()
        let online = netReachability.checkConnection()
        
        let eventAddress = Helper.getEventAddress(formatUrl)
        let eventUrl = "https://\(eventAddress)"
        
        let fplanConfigUrl = URL(string:"\(eventUrl)/\(Constants.fplanConfigPath)")
        let fplanDirectory = Helper.getCacheDirectory().appendingPathComponent("fplan/")
        let eventDirectory = fplanDirectory.appendingPathComponent("\(eventAddress)/")
        let fplanConfigPath = eventDirectory.appendingPathComponent(Constants.fplanConfigPath)
        
        print("[Fplan] load, format url: \(formatUrl)")

        let params = Helper.getParams(formatUrl)
        
        print("[Fplan] load, format params: \(params)")
        
        if(online){
            Helper.loadConfiguration(settings.configuration, fplanConfigUrl: fplanConfigUrl!){ config in
                self.config = config
                
                try? Helper.saveConfiguration(config, fplanConfigPath: fplanConfigPath)
                
                DispatchQueue.main.async { [weak self] in
                    let requestUrl = URLRequest(url: URL(string: formatUrl)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
                    self?.webView.load(requestUrl)
                }
                
                var zipArchivePath: URL? = nil;
                
                if let zipUrlString = config.zipArchiveUrl,
                   let zipUrl = URL(string: zipUrlString)  {
                    if(zipUrl.lastPathComponent.hasSuffix(".zip")){
                        zipArchivePath = eventDirectory.appendingPathComponent(zipUrl.lastPathComponent)
                        if let zipArchivePathUrl = zipArchivePath {
                            if(!fileManager.fileExists(atPath: zipArchivePathUrl.path)){
                                Helper.downloadFile(zipUrl, zipArchivePathUrl)
                            }
                        }
                    }
                }
                
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: (.now() + settings.loadingTimeout)) { [weak self] in
                    if(self == nil) {
                        return
                    }
                    
                    if(self!.isFplanReady || self!.isFplanDestroyed){
                        return
                    }
                    
                    let newSettings = Settings.getCopy(settings, configuration: config)
                    
                    if(config.zipArchiveUrl != nil && zipArchivePath != nil && fileManager.fileExists(atPath: zipArchivePath!.path)){
                        self?.openZip(zipArchivePath!.path, params: params, settings: newSettings)
                    }
                    else if let zipFilePath = offlineZipFilePath {
                        self?.openZip(zipFilePath, params: params, settings: newSettings)
                    }
                    else if let collback = self?.fpErrorCallback {
                        DispatchQueue.global(qos: .userInitiated).async {
                            try? collback(NSURLErrorTimedOut, "LOADING_TIMEOUT")
                        }
                    }
                }
                
            }
        }
        else {
            let load = { config in
                
                let newSettings = Settings.getCopy(settings, configuration: config)
                
                var zipArchivePath: URL? = nil;
                if let zipUrlString = config.zipArchiveUrl,
                   let zipUrl = URL(string: zipUrlString) {
                    if(zipUrl.lastPathComponent.hasSuffix(".zip")){
                        zipArchivePath = eventDirectory.appendingPathComponent(zipUrl.lastPathComponent)
                    }
                }
                
                if(config.zipArchiveUrl != nil && zipArchivePath != nil && fileManager.fileExists(atPath: zipArchivePath!.path)){
                    self.openZip(zipArchivePath!.path, params: params, settings: newSettings)
                }
                else if let zipFilePath = offlineZipFilePath {
                    self.openZip(zipFilePath, params: params, settings: newSettings)
                }
                else {
                    DispatchQueue.main.async { [weak self] in
                        let requestUrl = URLRequest(url: URL(string: formatUrl)!, cachePolicy: .returnCacheDataDontLoad)
                        self?.webView.load(requestUrl)
                    }
                }
            }
            
            if let config = try? Helper.loadConfiguration(fplanConfigPath: fplanConfigPath) {
                self.config = config
                load(self.config!)
            }
            else {
                print("[Fplan] Offline mode. Failed to read config file from cache.")
                self.config = settings.configuration ?? Helper.getDefaultConfiguration()
                load(self.config!)
            }
        }
    }
}
