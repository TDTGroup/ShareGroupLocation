//
//  UserProfileVC.swift
//  ShareGroupLocation
//
//  Created by Tran Khanh Trung on 11/25/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserProfileVC: UIViewController {
    
    @IBOutlet weak var userImageView: CustomizableImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    
    let pickerController = UIImagePickerController()
    
    override func viewWillAppear(_ animated: Bool) {
        if (AuthUser.currentAuthUser != nil){ //FIRAuth.auth()?.currentUser == nil) {
            print("HAS CURRENT USER \(AuthUser.currentAuthUser?.uid)")
            return
            
        }
        
        //            let alertControler = UIAlertController(title: "Oops!", message: "HAS NO CURRENT USER", preferredStyle: .alert)
        //            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        //            alertControler.addAction(defaultAction)
        //            self.present(alertControler, animated: true, completion: nil)
        print("HAS NO CURRENT USER")
        signOutOverride()
        
        
        //        DispatchQueue.main.async {
        //            DispatchQueue.main.async(execute: { () -> Void in
        //
        //                let viewController:UIViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
        //                self.present(viewController, animated: true, completion: nil)
        //            })
        //        }
    }
    
    func getUser() {
        
        var users = [User]()
        
        var userRef = DataService().REF_USERS
        
        userRef.observe(.value) { (snapshot: FIRDataSnapshot) in
            //            for child in snapshot.children {
            //
            //                let newUser = User(snapshot: child as! FIRDataSnapshot)
            //                users.append(newUser)
            //                print(newUser.email)
            //
            //                let snapshotChild = child as! FIRDataSnapshot
            //                let childRef = snapshotChild.ref
            //
            //                print("get group")
            //                childRef.child("groups").observe(.value) {(childSnapshot: FIRDataSnapshot) in
            //                    let childData = childSnapshot.value as? Dictionary<String, AnyObject>
            //                    print(childData)
            //                }
            //            }
            //            print(users.count)
            
            print("get group count")
            userRef.queryOrdered(byChild: "groups/111").queryEqual(toValue: "TRUE").observe(.value) {(childSnapshot: FIRDataSnapshot) in
                if let childData = childSnapshot.value as? Dictionary<String, AnyObject>{
                    print("---- group count: \(childData.count)")
                    //print(childData)
                } else {
                    print("group count nil")
                }
            }
        }
    }
    
    func getGroupByCurrentUser(){
        var groupRef = DataService().REF_GROUPS
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        getUser()
    }
    
    @IBAction func onLogOutButtonTapped(_ sender: Any) {
        //        try! FIRAuth.auth()?.signOut()
        //        GIDSignIn.sharedInstance().signOut()
        //        FBSDKLoginManager().logOut()
        AuthUser.currentAuthUser = nil
        signOutOverride()
    }
    
    @IBAction func onImageViewTapGesture(_ sender: UITapGestureRecognizer) {
        print("open image picker")
        
        //let pickerController = UIImagePickerController()
        //pickerController.delegate = self
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
}

extension UserProfileVC: UIImagePickerControllerDelegate {
    
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
