import Foundation
import WebKit

class FestMoreDetailsClickHandler : NSObject, WKScriptMessageHandler {
    
    private let handler: ((_ id: String) -> Void)
    
    public init(_ handler: ((_ id: String) -> Void)!) {
        self.handler = handler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let json = body as? String{
                let decoder = JSONDecoder()
                
                guard let event = try? decoder.decode(FestMoreDetailsClickEvent.self, from: json.data(using: .utf8)!) else {
                    return
                }
                
                self?.handler(event.id)
            }
        }
    }
}
