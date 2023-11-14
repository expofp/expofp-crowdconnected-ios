import Foundation
import WebKit

class FestDirectionsClickHandler : NSObject, WKScriptMessageHandler {
    
    private let handler: ((_ id: String, _ url: String) -> Void)
    
    public init(_ handler: ((_ id: String, _ url: String) -> Void)!) {
        self.handler = handler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let json = body as? String{
                let decoder = JSONDecoder()
                
                guard let event = try? decoder.decode(FestDirectionsClickEvent.self, from: json.data(using: .utf8)!) else {
                    return
                }
                
                self?.handler(event.id, event.url)
            }
        }
    }
}
