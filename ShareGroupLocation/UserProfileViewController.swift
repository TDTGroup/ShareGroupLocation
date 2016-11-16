//
//  UserProfileViewController.swift
//  ShareGroupLocation
//
//  Created by Khanh Trung on 11/15/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import Firebase

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var mobileNumberTextfield: UITextField!
    @IBOutlet weak var groupTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onUpdateUser(_ sender: UIButton) {
        //close keyboard
        self.view.endEditing(true)
        
        // when the update button is tapped, call post to firebase
        guard let email = emailTextfield.text, email != "" else {
            print("ERROR: Email must be entered")
            return
        }
        self.postToFirebase()
    }
    
    // which will set up the JSON in firebase and set values for the comment, the user who posted it, and post id its for.
    func postToFirebase() {
        
//        let usersNodeRef = DataService.ds.REF_USERS
//        let userKey = usersNodeRef.childByAutoId().key
//        let userData = [ USER_EMAIL: emailTextfield.text,
//                         USER_MOBILE_NUMBER: mobileNumberTextfield.text]
//        let childUpdate = ["\(userKey)": userData]
//        usersNodeRef.updateChildValues(childUpdate)
        
        let newUser = User(userName: "name",
                           email: emailTextfield.text,
                           mobileNumber: mobileNumberTextfield.text,
                           profilePicUrl: "link here",
                           location: "111-333",
                           groups: [groupTextfield.text!, "001", "002"])
        newUser.addToDatabase()
        
        // resetting the inputs for next user
        emailTextfield.text = ""
        mobileNumberTextfield.text = ""
        groupTextfield.text = ""
    }
    
    
    @IBAction func onLogoutButton(_ sender: UIButton) {
        
        try! FIRAuth.auth()?.signOut()
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
        AuthUser.currentAuthUser = nil
        
        //NotificationCenter.default.post(name: Notification.Name(rawValue: (AuthUser.currentAuthUser?.didLogOutNotificationKey)!), object: self)
        signOutOverride()
    }
    
    func signOutOverride() {
        try! FIRAuth.auth()!.signOut()
        //CredentialState.sharedInstance.signedIn = false
        // Set the view to the login screen after signing out
        // [1] Create a new "loginStoryBoard" instance.
        let loginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
        
        // [2] Create an instance of the storyboard's initial view controller.
        let loginVC = loginStoryBoard.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
        
        // [3] Display the new view controller.
        //self.present(loginVC, animated: true, completion: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC
    }
}
