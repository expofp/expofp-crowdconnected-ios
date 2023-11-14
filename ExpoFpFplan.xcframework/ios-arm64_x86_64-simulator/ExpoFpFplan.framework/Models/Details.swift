import Foundation

///Information about opened details panel
public struct Details : Decodable {
    
    ///Id
    public let id: Int
    
    ///Type: "booth" | "exhibitor" | "route"
    public let type: String
    
    ///Name
    public let name: String
    
    ///External Id
    public let externalId: String
}
