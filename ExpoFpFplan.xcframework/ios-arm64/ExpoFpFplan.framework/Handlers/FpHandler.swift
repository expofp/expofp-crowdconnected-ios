import Foundation
import WebKit

//@available(iOS 13.0, *)
class FpHandler : NSObject, WKScriptMessageHandler {
    private let handler: () -> Void
    
    public init(_ handler: (() -> Void)!) {
        self.handler = handler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.handler()
        }
    }
}
