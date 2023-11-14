import Foundation

///Direction  button click event params
public struct FestDirectionsClickEvent : Decodable {
    ///ID
    public let id: String
    
    ///URL
    public let url: String
}
