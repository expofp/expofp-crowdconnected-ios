import Foundation
import WebKit

//@available(iOS 13.0, *)
class MessageHandler : NSObject, WKScriptMessageHandler {
    private let handler: (_ message: String?) -> Void
    
    public init(_ handler: ((_ message: String?) -> Void)!) {
        self.handler = handler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let content = body as? String {
                self?.handler(content)
            }
            else {
                self?.handler(nil)
            }
        }
    }
}
