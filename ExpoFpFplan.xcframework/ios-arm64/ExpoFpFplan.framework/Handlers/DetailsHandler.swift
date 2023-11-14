import Foundation
import WebKit

//@available(iOS 13.0, *)
class DetailsHandler : NSObject, WKScriptMessageHandler {
    
    private let handler: (_ details: Details?) -> Void
    
    public init(_ handler: ((_ details: Details?) -> Void)!) {
        self.handler = handler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let json = body as? String{
                let decoder = JSONDecoder()
                
                guard let details = try? decoder.decode(Details.self, from: json.data(using: .utf8)!) else {
                    return
                }
                
                self?.handler(details)
            }
            else {
                self?.handler(nil)
            }
        }
    }
}
