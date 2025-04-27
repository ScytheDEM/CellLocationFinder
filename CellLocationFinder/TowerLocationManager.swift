import Foundation
import CoreLocation

class TowerLocationManager {
    static let shared = TowerLocationManager()
    private init() {}
    
    var towerCoordinate: CLLocationCoordinate2D?
}
