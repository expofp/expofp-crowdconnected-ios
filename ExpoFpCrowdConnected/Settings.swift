import Foundation

public class Settings {
    
    public let appKey: String
    public let token: String
    public let secret: String
    public let mode: Mode
    public var aliases: [String: String]
    
    public init(_ appKey: String, _ token: String, _ secret: String, _ mode: Mode = Mode.IPS_ONLY, aliases: [String: String] = [:]) {
        self.appKey = appKey
        self.token = token
        self.secret = secret
        self.mode = mode
        self.aliases = aliases
    }
    
    public func addAlias(_ key: String, _ value: String) {
        aliases[key] = value
    }
}
