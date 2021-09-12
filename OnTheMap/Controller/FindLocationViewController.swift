//
//  FindLocationViewController.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 10/09/2021.
//

import UIKit
import CoreLocation

class FindLocationViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Outlets
    
    @IBOutlet weak var textFieldLocation: UITextField!
    @IBOutlet weak var textFieldURL: UITextField!
    @IBOutlet weak var buttonFind: CommomButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: -Variables/Constants
    
    let identifierAddPin = "addPin"
    var studentArray: [StudentInformation]!
    var updatePin: Bool!
    var mediaUrl: String = " "
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldLocation.delegate = self
        textFieldURL.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if return is pressed resign first responder to hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == identifierAddPin {
            let controller = segue.destination as! AddPinViewController
            let locationDetails = sender as!  (String, CLLocationCoordinate2D)
            controller.location = locationDetails.0
            controller.coordinate = locationDetails.1
            controller.updatePin = updatePin
            controller.studentArray = studentArray
            
            print("prepare URL: \(mediaUrl)")
            controller.url = mediaUrl
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        
        //close the keyboard
        textFieldURL.resignFirstResponder()
        
        guard let location = textFieldLocation.text else { return }
        
        if location == "" {
            showErrorAlert("Wrong location name", "Enter location name to find place on map")
        } else {
            
            guard let urlText = textFieldURL.text else { return }
            guard urlText != "" else {
                showErrorAlert("Empty website link", "You must provide a url.")
                return
            }
            // var mediaUrl: String
            if urlText.isValidURL {
                mediaUrl = urlText.prefix(7).lowercased().contains("http:/wwww/") || urlText.prefix(8).lowercased().contains("https://") ? urlText : "https://" + urlText
                
                print(URL(string: mediaUrl)!)
                findLocation(location)
            } else {
                showErrorAlert("Invalid URL", "You must provide a valid url.")
            }
        }
        
    }
    
    // MARK: - Private methods
    
    func findLocation(_ location: String) {
        
        setGeoCodingStatus(true)
        CLGeocoder().geocodeAddressString(location) { (placemark, error) in
            
            guard error == nil else {
                self.showErrorAlert("Failed", "Can not find spot: \(location)")
                return
            }
            let coordinate = placemark?.first!.location!.coordinate
            self.setGeoCodingStatus(false)
            self.performSegue(withIdentifier: self.identifierAddPin, sender: (location, coordinate))
        }
    }
    
    func setGeoCodingStatus(_ geocoding: Bool) {
        
        geocoding ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
}
