//
//  ResetPasswordVC.swift
//  ShareGroupLocation
//
//  Created by Khanh Trung on 11/22/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit

class ResetPasswordVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func onResetButtonTapped(_ sender: CustomizableButton) {
        
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for valid email
        if !Help().isValidEmail(testStr: finalEmail) {
            displayErrorMessage(messageType: .InvalidEmailError)
            return
        }
        
        AuthService().ResetPassword(forEmail: finalEmail) {(error: Error?) in
            if error != nil {
                self.displayErrorMessage(messageText: error!.localizedDescription)
                return
            }
            self.displayAlert(title: "Reset your password",
                              text: "Email sent. Please check for the password reset link.",
                              actionTitle: "OK")
        }
    }
    
    func triggerCancelAction() {
        print("touch cancel")
        cancelButton.sendActions(for: .touchUpInside)
    }
}
