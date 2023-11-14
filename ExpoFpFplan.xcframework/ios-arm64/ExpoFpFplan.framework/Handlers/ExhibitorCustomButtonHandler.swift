import Foundation
import WebKit

//@available(iOS 13.0, *)
class ExhibitorCustomButtonHandler : NSObject, WKScriptMessageHandler {
    
    private let handler: ((_ event: FloorPlanCustomButtonEvent) -> Void)
    
    public init(_ handler: ((_ event: FloorPlanCustomButtonEvent) -> Void)!) {
        self.handler = handler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let json = body as? String{
                let decoder = JSONDecoder()
                
                guard let event = try? decoder.decode(FloorPlanCustomButtonEvent.self, from: json.data(using: .utf8)!) else {
                    return
                }
                
                self?.handler(event)
            }
        }
    }
}
