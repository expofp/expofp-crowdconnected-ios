import Foundation
import ExpoFpCommon

public extension FplanView {
    /**
     Set a callback that is called after the plan is initialized.
     
     **Parameters:**
     - callback: Callback
     */
    func onFpReady(_ callback: @escaping () -> Void) -> FplanView {
        self.state.fplanUiKitView.setOnFpReadyCallback(callback)
        return self
    }
    
    /**
     Sets a callback that is called when a plan initialization error occurs.
     
     **Parameters:**
     - callback: Callback
     */
    func onFpError(_ callback: @escaping (_ errorCode: Int, _ description: String) -> Void) -> FplanView {
        self.state.fplanUiKitView.setOnFpErrorCallback(callback)
        return self
    }
    
    /**
     Set a callback that is called after selecting a booth on the plan.
     
     **Parameters:**
     - callback: Callback
     */
    func onBoothClick(_ callback: @escaping (_ id: String?, _ name: String?) -> Void) -> FplanView {
        self.state.fplanUiKitView.setOnBoothClickCallback(callback)
        return self
    }
    
    /**
     Set a callback that is called after the route is built.
     
     **Parameters:**
     - callback: Callback
     */
    func onBuildDirection(_ callback: @escaping (_ direction: Direction?) -> Void) -> FplanView {
        self.state.fplanUiKitView.setOnBuildDirectionCallback(callback)
        return self
    }
    
    /**
     Set a callback that is called after receiving a message from the plan.
     
     **Parameters:**
     - callback: Callback
     */
    func onMessageReceived(_ callback: @escaping (_ message: String?) -> Void) -> FplanView {
        self.state.fplanUiKitView.setOnMessageReceivedCallback(callback)
        return self
    }
    
    /**
     Set a callback that is called after details is open.
     
     **Parameters:**
     - callback: Callback
     */
    func onDetailsClick(_ callback: @escaping (_ details: Details?) -> Void) -> FplanView {
        self.state.fplanUiKitView.setOnDetailsClickCallback(callback)
        return self
    }
    
    /**
     Set a callback that is called after custom button is click.
     
     **Parameters:**
     - callback: Callback
     */
    func onExhibitorCustomButtonClick(_ callback: @escaping (_ externalId: String, _ buttonNumber: Int, _ buttonUrl: String) -> Void) -> FplanView {
        self.state.fplanUiKitView.setOnExhibitorCustomButtonClickCallback(callback)
        return self
    }
    
    /**
     Set a callback that is called after more details button(on festival) is click.
     
     **Parameters:**
     - callback: Callback
     */
    func onFestMoreDetailsClick(_ callback: @escaping (_ id: String) -> Void) -> FplanView {
        self.state.fplanUiKitView.setOnFestMoreDetailsClickCallback(callback)
        return self
    }
    
    /**
     Set a callback that is called after directions button(on festival) is click.
     
     **Parameters:**
     - callback: Callback
     */
    func onFestDirectionsClick(_ callback: @escaping (_ id: String, _ url: String) -> Void) -> FplanView {
        self.state.fplanUiKitView.setOnFestDirectionsClick(callback)
        return self
    }
    
    /**
     Starts the plan loading process.
     
     **Parameters:**
     - url: Plan URL
     */
    func load(_ url: String){
        self.state.fplanUiKitView.load(url)
    }
    
    /**
     Starts the plan loading process.
     
     **Parameters:**
     - url: Plan URL.
     - locationProvider: Сoordinate provider.
     */
    func load(_ url: String, locationProvider: LocationProvider? = nil) {
        self.state.fplanUiKitView.load(url, locationProvider: locationProvider)
    }
    
    /**
     Start the plan loading process.
     
     **Parameters:**
     - url: Plan URL.
     - locationProvider: Сoordinate provider.
     - configuration: Plan config.
     */
    func load(_ url: String, locationProvider: LocationProvider? = nil, loadingTimeout: Double, configuration: Configuration? = nil) {
        self.state.fplanUiKitView.load(url, locationProvider: locationProvider,
                                       loadingTimeout: loadingTimeout, configuration: configuration)
    }
    
    /**
     Start the plan loading process.
     
     **Parameters:**
     - url: Plan URL.
     - useGlobalLocationProvider: Flag indicating whether to use the global coordinate provider.
     */
    func load(_ url: String, useGlobalLocationProvider: Bool = false) {
        self.state.fplanUiKitView.load(url, useGlobalLocationProvider: useGlobalLocationProvider)
    }
    
    /**
     Start the plan loading process.
     
     **Parameters:**
     - url: Plan URL.
     - useGlobalLocationProvider: Flag indicating whether to use the global coordinate provider.
     - configuration: Plan config.
     */
    func load(_ url: String, useGlobalLocationProvider: Bool = false, loadingTimeout: Double, configuration: Configuration? = nil) {
        self.state.fplanUiKitView.load(url, useGlobalLocationProvider: useGlobalLocationProvider,
                                       loadingTimeout: loadingTimeout, configuration: configuration)
    }
    
    /**
     Start the plan loading process.
     
     **Parameters:**
     - url: Plan URL.
     - settings: Plan settings.
     - offlineZipFilePath: Path to the offline version of the plan. The offline version of the plan will open with a poor or no Internet connection.
     */
    func load(_ url: String, settings: Settings, offlineZipFilePath: String? = nil) {
        self.state.fplanUiKitView.load(url, settings: settings, offlineZipFilePath: offlineZipFilePath)
    }
    
    func openZip(_ zipFilePath: String, params: String? = nil) {
        self.state.fplanUiKitView.openZip(zipFilePath, params: params)
    }
    
    func openZip(_ zipFilePath: String, params: String? = nil, locationProvider: LocationProvider? = nil) {
        self.state.fplanUiKitView.openZip(zipFilePath, params: params, locationProvider: locationProvider)
    }
    
    func openZip(_ zipFilePath: String, params: String? = nil, locationProvider: LocationProvider? = nil, loadingTimeout: Double, configuration: Configuration? = nil) {
        self.state.fplanUiKitView.openZip(zipFilePath, params: params, locationProvider: locationProvider,
                                          loadingTimeout: loadingTimeout, configuration: configuration)
    }
    
    func openZip(_ zipFilePath: String, params: String? = nil, useGlobalLocationProvider: Bool = false) {
        self.state.fplanUiKitView.openZip(zipFilePath, params: params, useGlobalLocationProvider: useGlobalLocationProvider)
    }
    
    func openZip(_ zipFilePath: String, params: String? = nil, useGlobalLocationProvider: Bool = false, loadingTimeout: Double, configuration: Configuration? = nil) {
        self.state.fplanUiKitView.openZip(zipFilePath, params: params, useGlobalLocationProvider: useGlobalLocationProvider,
                                          loadingTimeout: loadingTimeout, configuration: configuration)
    }
    
    func openZip(_ zipFilePath: String, params: String? = nil, settings: Settings) {
        self.state.fplanUiKitView.openZip(zipFilePath, params: params, settings: settings)
    }
    
    /**
     Stop fplan.
     */
    func destoy() {
        self.state.fplanUiKitView.destoy()
    }
    
    /**
     Select a exhibitor on the floor plan.
     
     **Parameters:**
     - exhibitorName: Exhibitor name
     */
    func selectExhibitor(_ exhibitorName: String?){
        self.state.fplanUiKitView.selectExhibitor(exhibitorName)
    }
    
    /**
     Select a booth on the floor plan.
     
     **Parameters:**
     - boothName: Booth name
     */
    func selectBooth(_ boothName: String?){
        self.state.fplanUiKitView.selectBooth(boothName)
    }
    
    /**
     Start the process of building a route from one booth to another.
     After the route is built, the buildDirectionAction callback is called.
     
     **Parameters:**
     - route: Route info
     */
    func selectRoute(_ route: Route?){
        self.state.fplanUiKitView.selectRoute(route)
    }
    
    /**
     Set a blue-dot point.
     
     **Parameters:**
     - position: Coordinates.
     - focus: True - focus the floor plan display on the passed coordinates.
     */
    func setCurrentPosition(_ position: BlueDotPoint?, _ focus: Bool = false){
        self.state.fplanUiKitView.setCurrentPosition(position, focus)
    }
    
    /**
     Clear the floor plan
     */
    func clear() {
        self.state.fplanUiKitView.clear()
    }
}
