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
        if (AuthUser.currentAuthUser != nil){
            print("HAS CURRENT USER \(AuthUser.currentAuthUser?.uid)")
            
            //UserController().getUsers()
            //UserController().getUserByGroupID(groupID: "222")
            //            let groups = GroupController().getGroupByUserID2(userID: FIRAuth.auth()!.currentUser!.uid)
            //            print("AFTER GET GROUPS: group count: \(groups.count)")
            //
            //GroupController().getGroupByUserID(userID: FIRAuth.auth()!.currentUser!.uid)
            
            //UserController().checkContactExist(mobileNumber: "111111")
            
            //UserController().setObserveUserLocation()
            
            // for location test: BEGIN
            userLocationRef = DataService().REF_USERS.child("\(getCurrentUserUid())/\(USER_LOCATION)")
            // set observe everytime view appear (while viewdidload only excutes once)
            setObserveUserLocation()
            // for location test: END
            
            return
        }
        
        print("HAS NO CURRENT USER")
        signOutOverride()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        //getGroupByCurrentUser()
    }
    
    // === TRUNG: BEGIN =============================
    
    var userLocationRef: FIRDatabaseReference!
    
//    override func viewWillAppear(_ animated: Bool) {
//        userLocationRef = DataService().REF_USERS.child("\(getCurrentUserUid())/\(USER_LOCATION)")
//        // set observe everytime view appear (while viewdidload only excutes once)
//        setObserveUserLocation()
//    }

    override func viewWillDisappear(_ animated: Bool) {
        // remove listener when view not appear
        userLocationRef.removeAllObservers()
    }
    
    // set observe for user location
    func setObserveUserLocation() {
        userLocationRef
            .observe(.value) {(locationSnapshot: FIRDataSnapshot) in
                if locationSnapshot.childrenCount > 0 {
                    let newLocation = Location(snapshot: locationSnapshot)
                    print("---- user location: lat: \(newLocation.location_Latitude) -  long: \(newLocation.location_Longitude)")
                    print(locationSnapshot)
                } else {
                    print("location nil")
                }
        }
    }
    
    // === TRUNG: END =============================
    
    @IBAction func onLogOutButtonTapped(_ sender: Any) {
        AuthUser.currentAuthUser = nil
        signOutOverride()
    }
    
    @IBAction func onImageViewTapGesture(_ sender: UITapGestureRecognizer) {
        print("open image picker")
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

extension UserProfileVC: UINavigationControllerDelegate {
    
}
