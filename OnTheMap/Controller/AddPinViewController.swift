//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 09/09/2021.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: -Variables/Constants
    
    var location: String!
    var coordinate: CLLocationCoordinate2D!
    var updatePin: Bool!
    var url: String!
    var studentArray: [StudentInformation]!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard coordinate != nil else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        addPinOnMap(coordinate: coordinate)
    }
    
    // MARK: - Actions
    
    @IBAction func tapFinish(_ sender: Any) {
        
        // Get login student user information
        UdacityClient.getUserData(completion: handleStudentDataResponse(userData:error:))
    }
    
    // MARK: - Private methods
    
    func handleStudentDataResponse(userData: UserDataResponse?, error:Error?) {
        
        guard let userData = userData else {
            return
        }
        activityIndicator.startAnimating()
        let locationRequest = PostLocationRequest(uniqueKey: userData.key, firstName: userData.firstName, lastName: userData.lastName, mapString: self.location, mediaURL: url, latitude: Double(self.coordinate.latitude), longitude: Double(self.coordinate.longitude))
        self.updatePin ? updatePin(postLocationData: locationRequest) : addPin(postLocationData: locationRequest)
    }
    
    // Add pin for new login
    func addPin(postLocationData: PostLocationRequest) {
        
        UdacityClient.postStudentLoaction(postLocation: postLocationData, completion: handleAddPinResponse(userData:error:))
    }
    
    func handleAddPinResponse(userData: PostLocationResponse?, error:Error?) {
        
        activityIndicator.stopAnimating()
        if error != nil {
            showErrorAlert( "Can't post new pin", "Error message :\n\(error?.localizedDescription ?? "can't post")")
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // Update pin for existing login
    func updatePin(postLocationData: PostLocationRequest) {
        if studentArray.isEmpty { return }
        
        UdacityClient.putStudentLocation(objectID: studentArray[0].objectID, postLocation: postLocationData, completion: handleUpdatePinResponse(success:error:))
    }
    
    func handleUpdatePinResponse(success: Bool, error:Error?) {
        
        activityIndicator.stopAnimating()
        if error != nil {
            showErrorAlert( "Can't update pin", "Error message :\n\(error?.localizedDescription ?? "can't post")")
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // Show pin on map
    func addPinOnMap(coordinate: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = location
        
        let mapRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(mapRegion, animated: true)
            self.mapView.regionThatFits(mapRegion)
        }
    }
    
}
