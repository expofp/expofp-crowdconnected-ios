import Foundation

///Point on floor plan
public struct Point : Decodable, Equatable{
    
    ///X coordinate
    public let x: Int
    
    ///Y coordinate
    public let y: Int
    
    ///Layer
    public let layer: String?
    
    /**
     This function initializes the Point struct.
      
     **Parameters:**
     - x: X coordinate
     - y: Y coordinate
     - layer: Layer
     */
    public init(x: Int, y: Int, layer: String?){
        self.x = x
        self.y = y
        self.layer = layer
    }
    
    public static func == (p1: Point, p2: Point) -> Bool {
        return p1.x == p2.x && p1.y == p2.y && p1.layer == p2.layer
    }
}
