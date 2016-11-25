//
//  HelpVC.swift
//  ShareGroupLocation
//
//  Created by Tran Khanh Trung on 11/25/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import FirebaseAuth

enum ErrorMessageType: String {
    case InvalidEmailError = "This email cannot be used. Please ensure that the spelling is correct.",
    InvalidPasswordError = "Password cannot be empty. Please ensure that password is provided."
}

class HelpVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// Put this piece of code anywhere you like
extension UIViewController {
    
    func signOutOverride() {
        try! FIRAuth.auth()!.signOut()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.login()
    }
    
    // Hide keyboard when tap around
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Display error message
    func displayErrorMessage(messageText: String) {
        let alertController = UIAlertController(title: "Oops!", message: messageText, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    // Display error message type
    func displayErrorMessage(messageType: ErrorMessageType) {
        let alertController = UIAlertController(title: "Oops!", message: messageType.rawValue, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // Display alert
    func displayAlert(title: String, text: String, actionTitle: String) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // Resize image
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height:size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
