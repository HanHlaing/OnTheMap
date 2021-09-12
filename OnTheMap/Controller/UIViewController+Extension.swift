//
//  UIViewController+Extension.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 10/09/2021.
//

import Foundation
import UIKit
import MapKit

extension UIViewController {
    
    @IBAction func logout() {
        
        UdacityClient.logout { (success: Bool, error: Error?) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showErrorAlert("Error in getting locations", error?.localizedDescription ?? "")
            }
        }
    }
    
    // MARK: Display Error Message to the User
    
    func showErrorAlert(_ title: String, _ messageBody: String) {
        
        let alertVC = UIAlertController(title: title, message: messageBody, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //show can't be used in navigation controller
        present(alertVC, animated: true, completion: nil)
    }
    
    func showAddPinConfirmAlert(data: [StudentInformation]){
        
        let alertVC = UIAlertController(title: "Warning!", message: "You've already put your pin on the map.\nWould you like to overwrite it?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [unowned self] (_) in
            self.performSegue(withIdentifier: "findLocation",  sender: (true, data))
        }))
        
        alertVC.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}

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
