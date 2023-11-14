import UIKit
import WebKit
import ExpoFpCommon

open class UIFplanView : UIView {
    internal var webView: FSWebView!
    internal var config: Configuration?
    
    internal var focusOnFirstLocation: Bool = false
    internal var settings: Settings?
    
    internal var fpReadyCallback: (() throws -> Void)?
    internal var fpErrorCallback: ((_ errorCode: Int, _ description: String) throws -> Void)?
    internal var selectBoothCallback: ((_ id: String?, _ name: String?) throws -> Void)?
    internal var buildDirectionCallback: ((_ direction: Direction?) throws -> Void)?
    internal var detailsClickCallback: ((_ details: Details?) throws -> Void)?
    internal var exhibitorCustomButtonClickCallback: ((_ externalId: String, _ buttonNumber: Int, _ buttonUrl: String) throws -> Void)?
    internal var messageReceivedCallback: ((_ message: String?) throws -> Void)?
    
    internal var festMoreDetailsClickCallback: ((_ id: String) throws -> Void)?
    internal var festDirectionsClickCallback: ((_ id: String, _ url: String) throws -> Void)?
    
    internal var isFplanReady = false
    internal var isFplanDestroyed = false
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createWebView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createWebView()
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            if(webView.estimatedProgress == 1.0 ){
                DispatchQueue.main.async() { [weak self] in
                    
                    let jsOnFpConfigured = "window.webkit?.messageHandlers?.fpConfiguredHandler?.postMessage(\"FLOOR PLAN CONFIGURED\")"
                    let jsCode = "window.___fp && window.___fp.ready.then(\(jsOnFpConfigured));"
                    self?.webView.evaluateJavaScript(jsCode, completionHandler: nil)
                }
            }
        }
    }
    
    func destroyView() {
        isFplanReady = false
        isFplanDestroyed = true
        
        if let sett = self.settings {
            if var gLocProvider = (sett.useGlobalLocationProvider ? GlobalLocationProvider.getLocationProvider() : nil) {
                gLocProvider.delegate = nil
            }
            
            if var locProvider = sett.locationProvider {
                locProvider.delegate = nil
                locProvider.stop()
            }
        }
        
        self.fpReadyCallback = nil
        self.selectBoothCallback = nil
        self.buildDirectionCallback = nil
        self.messageReceivedCallback = nil
        self.config = nil
        self.settings = nil
        self.focusOnFirstLocation = false
        
        NotificationCenter.default.removeObserver(self)
        
        if let fsWebView = self.webView {
            fsWebView.navigationDelegate = nil
            fsWebView.uiDelegate = nil
            fsWebView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
            fsWebView.configuration.userContentController.removeAllScriptMessageHandlers()
            
            if fsWebView.superview != nil {
                fsWebView.load(URLRequest(url: URL(string: "about:blank")!))
                fsWebView.removeFromSuperview()
            }
            
            self.webView = nil
        }
    }
    
    private func createWebView() {
        let preferences = WKPreferences()
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        preferences.setValue(true, forKey: "offlineApplicationCacheIsEnabled")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        let webView = FSWebView(frame: CGRect.zero, configuration: configuration)
        //webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        webView.frame = bounds
        webView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        
        webView.customUserAgent = "iosWebView"
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        webView.configuration.userContentController.add(FpHandler(fpReady), name: "fpConfiguredHandler")
        webView.configuration.userContentController.add(BoothHandler(selectBooth), name: "boothClickHandler")
        webView.configuration.userContentController.add(DirectionHandler(buildDirection), name: "directionHandler")
        webView.configuration.userContentController.add(DetailsHandler(onDetails), name: "detailsHandler")
        webView.configuration.userContentController.add(ExhibitorCustomButtonHandler(onExhibitorCustomButtonClick), name: "exhibitorCustomButtonClickHandler")
        
        webView.configuration.userContentController.add(MessageHandler(messageReceived), name: "messageHandler")
        
        webView.configuration.userContentController.add(FestMoreDetailsClickHandler(onFestMoreDetailsClick), name: "festMoreDetailsClickHandler")
        webView.configuration.userContentController.add(FestDirectionsClickHandler(onFestDirectionsClick), name: "festDirectionsClickHandler")
        
        addSubview(webView)
        self.webView = webView
    }
    
    private func fpReady(){
        isFplanReady = true
        isFplanDestroyed = false
        
        DispatchQueue.main.async() { [weak self] in
            let jsOnBoothClick = "window.___fp.onBoothClick = e => window.webkit?.messageHandlers?.boothClickHandler?.postMessage(JSON.stringify( {target: {id: e?.target?.id?.toString() ?? null, name: e?.target?.name ?? null }} ))"
            
            let jsOnDirection = "window.___fp.onDirection = e => window.webkit?.messageHandlers?.directionHandler?.postMessage(e != null ? JSON.stringify({from:e.from,to:e.to,distance:e.distance,time:e.time,lines:[]}) : null)"
            
            let jsOnDetails = "window.___fp.onDetails = e => window.webkit?.messageHandlers?.detailsHandler?.postMessage(e != null ? JSON.stringify(e) : null)"
            
            let jsOnExhibitorCustomButtonClick = "(window.___fp.onExhibitorCustomButtonClick = function(e) {e?.preventDefault(); window.webkit?.messageHandlers?.exhibitorCustomButtonClickHandler?.postMessage(e != null ? JSON.stringify(e) : null);})"
            
            let jsOnFestMoreDetailsClick = "window.___fp.onMoreDetailsClick = e => window.webkit?.messageHandlers?.festMoreDetailsClickHandler?.postMessage(e != null ? JSON.stringify({id:e.id}) : null)"
            
            let jsOnFestDirectionsClick = "(window.___fp.onDirectionsClick = function(e) {e?.preventDefault(); window.webkit?.messageHandlers?.festDirectionsClickHandler?.postMessage(e != null ? JSON.stringify({id:e.id,url:e.url}) : null);})"
            
            self?.webView.evaluateJavaScript(jsOnBoothClick, completionHandler: nil)
            self?.webView.evaluateJavaScript(jsOnDirection, completionHandler: nil)
            self?.webView.evaluateJavaScript(jsOnDetails, completionHandler: nil)
            self?.webView.evaluateJavaScript(jsOnExhibitorCustomButtonClick, completionHandler: nil)
            self?.webView.evaluateJavaScript(jsOnFestMoreDetailsClick, completionHandler: nil)
            self?.webView.evaluateJavaScript(jsOnFestDirectionsClick, completionHandler: nil)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            try? self?.fpReadyCallback?();
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if(self == nil){
                return
            }
            
            let enablePositioning = self!.config == nil
            || ((self!.config!.enablePositioningAfter == nil
                 || self!.config!.enablePositioningAfter! < Date())
                && (self!.config!.disablePositioningAfter == nil
                    || self!.config!.disablePositioningAfter! > Date()))
            
            if(enablePositioning){
                if let sett = self!.settings {
                    if var locProvider = sett.locationProvider {
                        locProvider.delegate = self
                        locProvider.start(false)
                    }
                    else if var gLocProvider = (sett.useGlobalLocationProvider ? GlobalLocationProvider.getLocationProvider() : nil) {
                        gLocProvider.delegate = self
                    }
                }
            }
        }
    }
    
    private func onFestMoreDetailsClick(_ id: String){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            try? self?.festMoreDetailsClickCallback?(id)
        }
    }
    
    private func onFestDirectionsClick(_ id: String, _ url: String){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            try? self?.festDirectionsClickCallback?(id, url)
        }
    }
    
    private func selectBooth(_ event: FloorPlanBoothClickEvent){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            try? self?.selectBoothCallback?(event.target.id, event.target.name)
        }
    }
    
    private func buildDirection(_ direction: Direction?){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            try? self?.buildDirectionCallback?(direction)
        }
    }
    
    private func onDetails(_ details: Details?){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            try? self?.detailsClickCallback?(details)
        }
    }
    
    private func onExhibitorCustomButtonClick(_ event: FloorPlanCustomButtonEvent) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            try? self?.exhibitorCustomButtonClickCallback?(event.externalId, event.buttonNumber, event.buttonUrl)
        }
    }
    
    private func messageReceived(_ message: String?){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            try? self?.messageReceivedCallback?(message)
        }
    }
}
