import Foundation

///Current position point on floor plan
public struct BlueDotPoint : Decodable, Equatable{
    
    ///X coordinate
    public let x: Double?
    
    ///Y coordinate
    public let y: Double?
    
    ///Floor
    public let z: String?
    
    ///Direction
    public let angle: Double?
    
    ///Latitude
    public let latitude: Double?
    
    ///Longitude
    public let longitude: Double?

    /**
     This function initializes the Point struct.
      
     **Parameters:**
     - x: X coordinate
     - y: Y coordinate
     - z: Floor
     - angle: Direction
     - latitude: Latitude
     - longitude: Longitude
     */
    public init(x: Double? = nil, y: Double? = nil, z: String? = nil, angle: Double? = nil, latitude: Double? = nil, longitude: Double? = nil){
        self.x = x
        self.y = y
        self.z = z
        self.angle = angle
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public static func == (p1: BlueDotPoint, p2: BlueDotPoint) -> Bool {
        return p1.x == p2.x && p1.y == p2.y && p1.z == p2.z && p1.angle == p2.angle
            && p1.latitude == p2.latitude && p1.longitude == p2.longitude
    }
}
