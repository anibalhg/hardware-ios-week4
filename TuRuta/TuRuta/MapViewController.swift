import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate{
    

    @IBOutlet weak var map: MKMapView!
    
    private let locationManager = CLLocationManager()
    private var didFirstLocation = false
    private var lastLocation : CLLocation?
    private var distanceTraveled = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.zoomEnabled = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            NSLog("Location services are not enabled");
        }

    }


    @IBAction func mapTypeChanged(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            map.mapType = MKMapType.Standard
        case 1:
            map.mapType = MKMapType.Satellite
        case 2:
            map.mapType = MKMapType.Hybrid
        default:
            break;
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            map.showsUserLocation = true
        }
        else {
            locationManager.stopUpdatingLocation()
            map.showsUserLocation = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = manager.location!.coordinate
        let lat = coordinate.latitude
        let lng = coordinate.longitude
        if !didFirstLocation {
            map.centerCoordinate = coordinate
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500)
            map.setRegion(region, animated: true)
            let pin = MKPointAnnotation()
            pin.title = "\(lat),\(lng)"
            pin.subtitle = "Punto de inicio"
            pin.coordinate = coordinate
            map.addAnnotation(pin)
            didFirstLocation = true
            distanceTraveled = 0.0
            lastLocation = manager.location
        }
        else {
            let distance = manager.location?.distanceFromLocation(lastLocation!)
            if distance >= 50.0 {
                distanceTraveled += distance!
                let pin = MKPointAnnotation()
                let distanceMts = String(format: "%.2f", distanceTraveled)
                pin.title = "\(lat),\(lng)"
                pin.subtitle = "\(distanceMts) metros"
                pin.coordinate = coordinate
                map.addAnnotation(pin)
                lastLocation = manager.location
            }
        }
    }
}

