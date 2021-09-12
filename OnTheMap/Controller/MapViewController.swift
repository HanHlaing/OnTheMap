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
    
    let identifierFindLocation = "findLocation"
    var annotations = [MKPointAnnotation]()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getStudentLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshMap(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == identifierFindLocation {

            if let destinationVC = segue.destination as? FindLocationViewController {
                let updateStudentInfo = sender as? (Bool, [StudentInformation])
                destinationVC.updatePin = updateStudentInfo?.0
                destinationVC.studentArray = updateStudentInfo?.1
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func refreshMap(_ sender: Any) {
        getStudentLocations()
    }
    
    @IBAction func addNewPin(_ sender: Any) {
        checkAndAddPin()
    }
    // MARK: - Private methods
    
    func checkAndAddPin() {
        activityIndicator.startAnimating()
        // fetch login student location from server
        UdacityClient.getStudentLocation(singleStudent: true, completion: handleStudentLocationsResponse(singleStudent:data:error:))
    }
    
    func getStudentLocations() {
        activityIndicator.startAnimating()
        // fetch student locations from server
        UdacityClient.getStudentLocation(singleStudent: false, completion: handleStudentLocationsResponse(singleStudent:data:error:))
    }
    
    func handleStudentLocationsResponse(singleStudent:Bool,data: [StudentInformation]?, error:Error?) {
        
        activityIndicator.stopAnimating()
        if let error = error {
            showErrorAlert("Error in getting locations", error.localizedDescription )
        } else {
            
            if singleStudent {
                
                // check existing user or newly login
                if let data = data {
                    showAddPinConfirmAlert(data: data)
                } else {
                    self.performSegue(withIdentifier: identifierFindLocation,  sender: (false, []))
                }
            } else {
                
                if let data = data {
                    // stored data in StudentInformationModel
                    StudentInformationModel.studentData = data
                    // display pins on map
                    displyPinsOnMapView()
                } else {
                    showErrorAlert("No data!", "There is not data to display")
                }
            }
        }
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

