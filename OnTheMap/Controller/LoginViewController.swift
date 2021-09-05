//
//  ViewController.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 05/09/2021.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonLogin: LoginButton!
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textFieldEmail.text = ""
        textFieldPassword.text = ""
    }
    
    // MARK: Actions
    
    @IBAction func loginTapped(_ sender: Any) {
        setLoggingIn(true)
    }
    
    
    @IBAction func signUpViaWebsite(_ sender: Any) {
        setLoggingIn(false)
    }
    
    // MARK: Private methods
    
    func setLoggingIn(_ loggingIn:Bool) {
        
        if loggingIn {
            
            activityIndicator.startAnimating()
        } else {
            
            activityIndicator.stopAnimating()
        }
        textFieldEmail.isEnabled = !loggingIn
        textFieldPassword.isEnabled = !loggingIn
        buttonLogin.isEnabled = !loggingIn
        // buttonSignUp.isEnabled = !loggingIn
    }
}

