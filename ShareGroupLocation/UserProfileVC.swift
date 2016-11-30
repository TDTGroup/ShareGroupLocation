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
import MBProgressHUD
import ImageLoader

class UserProfileVC: UIViewController {
    
    @IBOutlet weak var userImageView: CustomizableImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    
    let pickerController = UIImagePickerController()
    var userProfileRef: FIRDatabaseReference!
    
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
            
            
            UserController().UpdateUserLocation(userID: "s4poiMlIxwOHIoRnLzifKaN3MHC3", lat: "111", long: "222")
            
            return
        }
        
        print("HAS NO CURRENT USER")
        signOutOverride()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        //getGroupByCurrentUser()
        
        
        userProfileRef = DataService().REF_USERS.child("\(getCurrentUserUid())")
        // Get user Profile
        setObserveUserProfile()
    }
    
    // set observe for user profile
    func setObserveUserProfile() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        userProfileRef
            .observeSingleEvent(of: .value) {(profileSnapshot: FIRDataSnapshot) in
                if profileSnapshot.childrenCount > 0 {
                    let user = User(snapshot: profileSnapshot)
                    let profilePicURL =  URL(string: user.profilePicUrl)
                    
                    self.usernameTextField.text = user.userName
                    self.emailTextField.text = user.email
                    self.passwordTextField.text = "********"
                    self.mobileNumberTextField.text = user.mobileNumber
                    if user.profilePicUrl != nil {
                        self.userImageView.load.request(with: profilePicURL!, onCompletion: { (image, error, nil) in
                            MBProgressHUD.hide(for: self.view, animated: true)
                            if error !=  nil {
                                print("Error downloading profile picture")
                                self.displayErrorMessage(messageText: error!.localizedDescription)
                            }
                        })
                    } else {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                    
                } else {
                    print("profile nil")
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
        }
    }
    
    // === TRUNG: BEGIN =============================
    
    var userLocationRef: FIRDatabaseReference!
    
    override func viewWillDisappear(_ animated: Bool) {
        // remove listener when view not appear
        userLocationRef.removeAllObservers()
        //userProfileRef.removeAllObservers()
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
    
    @IBAction func onUpdateButton(_ sender: CustomizableButton) {
        self.view.endEditing(true)
        
        let userName = usernameTextField.text!
        
        // Check for valid userName
        if userName.isEmpty {
            displayErrorMessage(messageType: .InvalidUserNameError)
            return
        }
        
        // Resize image before upload
        let resizedPicture = self.ResizeImage(image: userImageView.image!, targetSize: CGSize(width: 200.0, height: 200.0))
        let pictureData = UIImageJPEGRepresentation(resizedPicture, 0.70)
        
        // Upload profile pic to storage -> update user record in DB
        excuteUpdateUserFlow(userName: userName,
                             mobileNumber: mobileNumberTextField.text!,
                             pictureData: pictureData as NSData!) {(error: Error?) in
                                
                                if error != nil {
                                    print("HAS ERROR HERE")
                                    self.displayErrorMessage(messageText: error!.localizedDescription)
                                }
        }
    }
    
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

extension UserProfileVC {
    func excuteUpdateUserFlow(userName: String, mobileNumber: String, pictureData: NSData!,
                              completion: @escaping (Error?) -> Void) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        var authUser = FIRAuth.auth()?.currentUser
        
        // 2 - Set Auth user info if no error
        print("2 ------ BEGIN OF: -- setUserInfo")
        StorageService().setUserInfo(user: authUser, userName: userName, pictureData: pictureData){
            (setUser: FIRUser?, setUserInfoError: Error?) in
            if setUserInfoError != nil {
                print(setUserInfoError!.localizedDescription)
                completion(setUserInfoError)
            }
            
            if setUser != nil {
                // Auth user now has photoURL from storage
                authUser = setUser
                
                // 3 - Save user info to Firebase DB if no error
                print("3 ------ BEGIN OF: -- saveUserInfo")
                DataService().saveUserInfo(user: authUser, mobileNumber: mobileNumber) {(saveUserInfoError: Error?) in
                    if saveUserInfoError != nil {
                        print(saveUserInfoError!.localizedDescription)
                        completion(saveUserInfoError)
                    }
                    MBProgressHUD.hide(for: self.view, animated: true)
                    print("------ FINISHED UPDATE USER")
                    self.displayAlert(title: "Update Profile",
                                      text: "Your profile has been successfully updated.",
                                      actionTitle: "OK")
                }
            }
            print("3 ------ END OF: -- saveUserInfo")
        }
        print("2 ------ END OF: -- setUserInfo")
    }
}

