import UIKit
import CoreLocation

class CompassViewController: BaseViewController, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private var directionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDirectionLabel()
        setupLocationManager()
    }

    private func setupDirectionLabel() {
        directionLabel = UILabel()
        directionLabel.textAlignment = .center
        directionLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        directionLabel.textColor = .white
        directionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(directionLabel)

        NSLayoutConstraint.activate([
            directionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            directionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard let towerCoordinate = TowerLocationManager.shared.towerCoordinate,
              let userLocation = userLocation else { return }

        let bearingToTower = getBearingBetweenTwoPoints(
            lat1: userLocation.coordinate.latitude,
            lon1: userLocation.coordinate.longitude,
            lat2: towerCoordinate.latitude,
            lon2: towerCoordinate.longitude
        )

        let deviceHeading = newHeading.trueHeading
        let difference = angleDifference(bearingToTower, deviceHeading)

        if difference < 10 {
            directionLabel.text = "✅ Tower Ahead!"
            directionLabel.textColor = .systemGreen
        } else {
            directionLabel.text = "🔄 Keep Turning (\(Int(difference))°)"
            directionLabel.textColor = .systemRed
        }
    }

    private func getBearingBetweenTwoPoints(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let lat1 = lat1 * .pi / 180
        let lon1 = lon1 * .pi / 180
        let lat2 = lat2 * .pi / 180
        let lon2 = lon2 * .pi / 180
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x) * 180 / .pi
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    private func angleDifference(_ angle1: Double, _ angle2: Double) -> Double {
        let diff = abs(angle1 - angle2).truncatingRemainder(dividingBy: 360)
        return diff > 180 ? 360 - diff : diff
    }
}
