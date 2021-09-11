//
//  UIViewController+Extension.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 10/09/2021.
//

import Foundation
import UIKit

extension UIViewController{
    
    // MARK: Display Error Message to the User
    
    func showErrorAlert(_ title: String, _ messageBody: String) {
        
        let alertVC = UIAlertController(title: title, message: messageBody, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //show can't be used in navigation controller
        present(alertVC, animated: true, completion: nil)
    }
}
