import Foundation

///Information about the file to be cached
public struct FileInfo : Codable {
    
    ///File name
    public let name: String
    
    ///URL address of the file on the server
    public let serverUrl: String
    
    ///The path to the file in the cache
    public let cachePath: String
    
    ///File version
    public let version: String
    
    public init(name: String, serverUrl: String, cachePath: String, version: String) {
        self.name = name
        self.serverUrl = serverUrl
        self.cachePath = cachePath
        self.version = version
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.serverUrl = try container.decode(String.self, forKey: .serverUrl)
        self.cachePath = try container.decode(String.self, forKey: .cachePath)
        self.version = try container.decode(String.self, forKey: .version)
    }
}
