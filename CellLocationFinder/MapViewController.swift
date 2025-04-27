import UIKit
import MapKit

class MapViewController: BaseViewController, MKMapViewDelegate {

    private let mapView = MKMapView()
    private let coordinateButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupCoordinateButton()
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40), // below the banner
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        mapView.addGestureRecognizer(longPress)
    }

    private func setupCoordinateButton() {
        coordinateButton.setTitle("Enter Coordinates", for: .normal)
        coordinateButton.backgroundColor = .systemBlue
        coordinateButton.setTitleColor(.white, for: .normal)
        coordinateButton.layer.cornerRadius = 8
        coordinateButton.translatesAutoresizingMaskIntoConstraints = false
        coordinateButton.addTarget(self, action: #selector(enterCoordinatesTapped), for: .touchUpInside)
        view.addSubview(coordinateButton)

        NSLayoutConstraint.activate([
            coordinateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            coordinateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            coordinateButton.widthAnchor.constraint(equalToConstant: 160),
            coordinateButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            TowerLocationManager.shared.towerCoordinate = coordinate
            
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }

    @objc private func enterCoordinatesTapped() {
        let alert = UIAlertController(title: "Enter Coordinates", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Latitude" }
        alert.addTextField { $0.placeholder = "Longitude" }
        
        alert.addAction(UIAlertAction(title: "Set Tower", style: .default, handler: { _ in
            guard let latText = alert.textFields?[0].text,
                  let lonText = alert.textFields?[1].text,
                  let latitude = Double(latText),
                  let longitude = Double(lonText) else { return }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            TowerLocationManager.shared.towerCoordinate = coordinate
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}
