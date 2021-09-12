//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 05/09/2021.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonLogin: CommomButton!
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldEmail.delegate = self
        textFieldPassword.delegate = self
        textFieldEmail.text = ""
        textFieldPassword.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if return is pressed resign first responder to hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func loginTapped(_ sender: Any) {
        
        //close the keyboard
        textFieldPassword.resignFirstResponder()
        
        let email = actualInput(for: textFieldEmail)
        let password = actualInput(for: textFieldPassword)
        switch (email.isEmpty, password.isEmpty) {
        case (true, true):
            showErrorAlert( "Required Fileds!", "Please enter email & password")
        case (true, _):
            showErrorAlert( "Required Fileds!", "Please enter email")
        case (_, true):
            showErrorAlert( "Required Fileds!", "Please enter password")
        default:
            setLoggingIn(true)
            UdacityClient.createSessionId(email: textFieldEmail.text!, password: textFieldPassword.text!, completion: handleSessionResponse(success:error:))
        }
    }
    
    
    @IBAction func signUpViaWebsite(_ sender: Any) {
        
        //direct to udacity website
        UIApplication.shared.open(UdacityClient.Endpoints.signUp.url, options: [:], completionHandler: nil)
    }
    
    // MARK: - Private methods
    
    func actualInput(for textField: UITextField) -> String {
        let text = textField.text ?? ""
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func setLoggingIn(_ loggingIn:Bool) {
        
        loggingIn ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        textFieldEmail.isEnabled = !loggingIn
        textFieldPassword.isEnabled = !loggingIn
        buttonLogin.isEnabled = !loggingIn
        buttonSignUp.isEnabled = !loggingIn
    }
    
    func handleSessionResponse(success: Bool, error:Error?) {
        
        setLoggingIn(false)
        if success {
            
            self.performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            showErrorAlert("Login Failed", error?.localizedDescription ?? "")
        }
    }
}

