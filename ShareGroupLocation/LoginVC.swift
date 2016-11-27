//
//  LoginVC.swift
//  ShareGroupLocation
//
//  Created by Khanh Trung on 11/22/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func onLoginButtonTapped(_ sender: CustomizableButton) {
        self.view.endEditing(true)
        
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!
        
        // Check for valid email
        if !Help().isValidEmail(testStr: finalEmail) {
            displayErrorMessage(messageType: .InvalidEmailError)
            return
        }
        
        // Check for valid password
        if password.isEmpty {
            displayErrorMessage(messageType: .InvalidPasswordError)
            return
        }
        
        AuthService().logIn(email: finalEmail, password: password) {(error: Error?) in
            if error != nil {
                print("HAS ERROR HERE")
                self.displayErrorMessage(messageText: error!.localizedDescription)
            }
        }
    }
}
