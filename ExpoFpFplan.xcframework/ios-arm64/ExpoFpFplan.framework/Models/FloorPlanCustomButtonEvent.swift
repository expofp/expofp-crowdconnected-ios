import Foundation

///Custom button click event params
public struct FloorPlanCustomButtonEvent : Decodable {
    ///External ID
    public let externalId: String
    
    ///Number
    public let buttonNumber: Int
    
    ///URL
    public let buttonUrl: String
}
