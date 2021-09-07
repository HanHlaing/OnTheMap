//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 07/09/2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: -Variables/Constants
    
    var annotations = [MKPointAnnotation]()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getStudentLocations()
    }
    
    // MARK: - Actions
    
    @IBAction func refreshMap(_ sender: Any) {
        getStudentLocations()
    }
    
    // MARK: - Private methods
    
    func getStudentLocations(){
        activityIndicator.startAnimating()
        // fetch student locations from server
        UdacityClient.getStudentLocation(singleStudent: false, completion: handleStudentLocationsResponse(data:error:))
    }
    
    
    func handleStudentLocationsResponse(data: [StudentInformation]?, error:Error?) {
        
        activityIndicator.stopAnimating()
        guard let data = data else {
            showErrorAlert("Error in getting locations", error?.localizedDescription ?? "")
            return
        }
        // stored data in StudentInformationModel
        StudentInformationModel.studentData = data
        // display pins on map
        displyPinsOnMapView()
    }
    
    func displyPinsOnMapView() {
        
        // clear annotations
        annotations.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        // add student annotations in map view
        for val in StudentInformationModel.studentData {
            annotations.append(val.getMapAnnotation())
        }
        mapView.addAnnotations(annotations)
    }
    
    func showErrorAlert(_ title: String, _ messageBody: String) {
        
        let alertVC = UIAlertController(title: title, message: messageBody, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    
    // MARK: - Delegate methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            guard let annotation = view.annotation else {
                return
            }
            guard var subtitle = annotation.subtitle else {
                return
            }
            if subtitle!.isValidURL {
                if subtitle!.starts(with: "www") {
                    subtitle! = "https://" + subtitle!
                }
                let url = URL(string: subtitle!)
                UIApplication.shared.open(url!)
            } else {
                
                showErrorAlert("No URL", "There's no URL to open")
            }
        }
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        _ = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
    }
}

// MARK: - Extensions

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

extension StudentInformation  {
    func getMapAnnotation() -> MKPointAnnotation {
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        mapAnnotation.title = "\(firstName) \(lastName)"
        mapAnnotation.subtitle = "\(mediaURL)"
        
        return mapAnnotation
    }
}
