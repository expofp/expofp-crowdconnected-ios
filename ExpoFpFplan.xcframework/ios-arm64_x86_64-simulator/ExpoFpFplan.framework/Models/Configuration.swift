import Foundation

///Fplan configuration
public struct Configuration : Codable {
    
    ///URL index.html for Android version
    public let androidHtmlUrl: String?
    
    ///URL index.html for iOS version
    public let iosHtmlUrl: String?
    
    ///URL zip archive
    public let zipArchiveUrl: String?
    
    ///The date after which the component will connect to the location provider
    public let enablePositioningAfter: Date?
    
    ///The date after which the component will not connect to the location provider
    public let disablePositioningAfter: Date?
    
    public init(androidHtmlUrl: String?, iosHtmlUrl: String?, zipArchiveUrl: String?, enablePositioningAfter: Date?, disablePositioningAfter: Date?) {
        self.androidHtmlUrl = androidHtmlUrl
        self.iosHtmlUrl = iosHtmlUrl
        self.zipArchiveUrl = zipArchiveUrl
        self.enablePositioningAfter = enablePositioningAfter
        self.disablePositioningAfter = disablePositioningAfter
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.androidHtmlUrl = try container.decodeIfPresent(String.self, forKey: .androidHtmlUrl)
        self.iosHtmlUrl = try container.decodeIfPresent(String.self, forKey: .iosHtmlUrl)
        self.zipArchiveUrl = try container.decodeIfPresent(String.self, forKey: .zipArchiveUrl)
        self.enablePositioningAfter = try container.decodeIfPresent(Date.self, forKey: .enablePositioningAfter)
        self.disablePositioningAfter = try container.decodeIfPresent(Date.self, forKey: .disablePositioningAfter)
    }
}
