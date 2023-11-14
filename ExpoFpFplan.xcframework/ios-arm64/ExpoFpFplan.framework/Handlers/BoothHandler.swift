import Foundation
import WebKit

//@available(iOS 13.0, *)
class BoothHandler : NSObject, WKScriptMessageHandler {
    
    private let handler: ((_ event: FloorPlanBoothClickEvent) -> Void)
    
    public init(_ handler: ((_ event: FloorPlanBoothClickEvent) -> Void)!) {
        self.handler = handler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let json = body as? String{
                let decoder = JSONDecoder()
                
                guard let event = try? decoder.decode(FloorPlanBoothClickEvent.self, from: json.data(using: .utf8)!) else {
                    return
                }
                
                self?.handler(event)
            }
        }
    }
}
