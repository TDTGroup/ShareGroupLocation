//
//  SignUpVC.swift
//  ShareGroupLocation
//
//  Created by Khanh Trung on 11/23/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpVC: UIViewController {
    
    @IBOutlet weak var userImageView: CustomizableImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    
    let pickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func onImageViewTapGesture(_ sender: UITapGestureRecognizer) {
        print("open image picker")
        
        //let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        let alertController = UIAlertController(title: "Add profile picture", message: "Choose from", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            
            // Detect 32–bit, 64-bit iOS simulator.
            #if (arch(i386) || arch(x86_64)) && os(iOS)
                self.pickerController.sourceType = .photoLibrary
            #else // Real device
                self.pickerController.sourceType = .camera
            #endif
            self.present(self.pickerController, animated: true, completion: nil)
        })
        
        let photosLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.pickerController.sourceType = .photoLibrary
            self.present(self.pickerController, animated: true, completion: nil)
        })
        
        let savedPhotosAlbumAction = UIAlertAction(title: "Saved Photos Album", style: .default, handler: { (action) in
            self.pickerController.sourceType = .savedPhotosAlbum
            self.present(self.pickerController, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAlbumAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onSignUpButton(_ sender: CustomizableButton) {
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
        
        // Resize image before upload
        let resizedPicture = self.ResizeImage(image: userImageView.image!, targetSize: CGSize(width: 200.0, height: 200.0))
        let pictureData = UIImageJPEGRepresentation(resizedPicture, 0.70)
        
        AuthService().signUp(email: finalEmail,
                             password: password,
                             userName: usernameTextField.text!,
                             mobileNumber: mobileNumberTextField.text!,
                             pictureData: pictureData as NSData!) {(error: Error?) in
                                self.displayErrorMessage(messageText: error!.localizedDescription)
        }
        
//        // Register Auth user -> upload profile pic to storage -> create user record in DB -> sign user in
//        excuteSignUpUserFlow(email: finalEmail,
//                             password: password,
//                             userName: usernameTextField.text!,
//                             mobileNumber: mobileNumberTextField.text!,
//                             pictureData: pictureData as NSData!) {(error: Error?) in
//                                self.displayErrorMessage(messageText: error!.localizedDescription)
//        }
    }
}


extension SignUpVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage]  as? UIImage{
            self.userImageView.image = image
        } else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.userImageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SignUpVC: UINavigationControllerDelegate {
    
}

extension SignUpVC {
    func excuteSignUpUserFlow(email: String, password: String, userName: String, mobileNumber: String, pictureData: NSData!,
                              completion: @escaping (Error?) -> Void) {
        var authUser: FIRUser!
        
        // 1 Signup user
        AuthService().signUp2(email: email,
                              password: password,
                              userName: userName) {(user: FIRUser?, signUpError: Error?) in
                                if signUpError != nil {
                                    print(signUpError!.localizedDescription)
                                    completion(signUpError)
                                    return
                                }
                                authUser = user!
        }
        
        // 2 - Set Auth user info if no error
        StorageService().setUserInfo2(user: authUser, userName: userName, pictureData: pictureData){
            (user: FIRUser?, setUserInfoError: Error?) in
            if setUserInfoError != nil {
                print(setUserInfoError!.localizedDescription)
                completion(setUserInfoError)
                return
            }
            // Auth user now has photoURL from storage
            authUser = user!
        }
        
        // 3 - Save user info to Firebase DB if no error
        DataService().saveUserInfo2(user: authUser, mobileNumber: mobileNumber) {(saveUserInfoError: Error?) in
            if saveUserInfoError != nil {
                print(saveUserInfoError!.localizedDescription)
                completion(saveUserInfoError)
                return
            }
        }
        
        // 4 - Log user in if no error
        AuthService().logIn(email: (authUser?.email!)!, password: password) {(loginError: Error?) in
            if loginError != nil {
                print(loginError!.localizedDescription)
                completion(loginError)
                return
            }
        }
    }
    
    
}
