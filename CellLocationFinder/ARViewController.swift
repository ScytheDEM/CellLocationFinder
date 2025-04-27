import UIKit
import RealityKit
import ARKit
import CoreLocation

class ARViewController: BaseViewController, CLLocationManagerDelegate {

    private var arView: ARView!
    private let locationManager = CLLocationManager()

    private var userLocation: CLLocation?
    private var userHeading: Double = 0.0

    private var waypointAnchor: AnchorEntity!
    private var waypointEntity: ModelEntity!

    private var arrowImageView: UIImageView!
    private var hapticTriggered = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupARView()
        setupLocationManager()
        setupArrowOverlay()
        addWaypoint()
    }

    // MARK: - AR Setup
    private func setupARView() {
        arView = ARView(frame: view.bounds)
        arView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(arView, at: 0) // insert at bottom behind everything

        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading
        arView.session.run(config)
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    private func setupArrowOverlay() {
        arrowImageView = UIImageView(image: UIImage(systemName: "arrow.up.circle.fill"))
        arrowImageView.tintColor = .systemOrange
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            arrowImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arrowImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            arrowImageView.widthAnchor.constraint(equalToConstant: 70),
            arrowImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func addWaypoint() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            let sphereMesh = MeshResource.generateSphere(radius: 0.2)
            let sphereMaterial = SimpleMaterial(color: .systemBlue, isMetallic: true)

            self.waypointEntity = ModelEntity(mesh: sphereMesh, materials: [sphereMaterial])

            self.waypointAnchor = AnchorEntity(world: SIMD3<Float>(0, 0, -3)) // 3 meters ahead
            self.waypointAnchor.addChild(self.waypointEntity)

            self.arView.scene.addAnchor(self.waypointAnchor)
        }
    }

    // MARK: - Location Updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        userHeading = newHeading.trueHeading
        updateUI()
    }

    // MARK: - Update UI
    private func updateUI() {
        guard let waypointEntity = waypointEntity,
              let towerCoordinate = TowerLocationManager.shared.towerCoordinate,
              let userLocation = userLocation,
              let arrowImageView = arrowImageView else {
            return
        }

        let bearingToTower = getBearingBetweenTwoPoints(
            lat1: userLocation.coordinate.latitude,
            lon1: userLocation.coordinate.longitude,
            lat2: towerCoordinate.latitude,
            lon2: towerCoordinate.longitude
        )

        let difference = angleDifference(bearingToTower, userHeading)

        // Rotate arrow
        let rotationAngle = CGFloat((bearingToTower - userHeading) * .pi / 180)
        UIView.animate(withDuration: 0.2) {
            arrowImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }

        // Change dot and arrow color based on alignment
        if difference < 10 {
            waypointEntity.model?.materials = [SimpleMaterial(color: .systemGreen, isMetallic: true)]
            
            UIView.animate(withDuration: 0.3) {
                arrowImageView.tintColor = .systemGreen
            }
            
            if !hapticTriggered {
                triggerHaptic()
                hapticTriggered = true
            }
        } else {
            waypointEntity.model?.materials = [SimpleMaterial(color: .systemBlue, isMetallic: true)]
            
            UIView.animate(withDuration: 0.3) {
                arrowImageView.tintColor = .systemOrange
            }
            
            hapticTriggered = false
        }
    }

    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // MARK: - Math Helpers
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
