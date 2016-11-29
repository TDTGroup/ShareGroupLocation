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
    
    override func viewWillAppear(_ animated: Bool) {
        if (FIRAuth.auth()?.currentUser == nil) {//(AuthUser._currentAuthUser == nil){
            print("HAS NO CURRENT USER")
            
            let alertControler = UIAlertController(title: "Oops!", message: "HAS NO CURRENT USER", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertControler.addAction(defaultAction)
            self.present(alertControler, animated: true, completion: nil)
            
            DispatchQueue.main.async {
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let viewController:UIViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
                    self.present(viewController, animated: true, completion: nil)
                })
            }
            return
        }
        print("HAS CURRENT USER \(AuthUser.currentAuthUser?.uid)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (FIRAuth.auth()?.currentUser == nil) {//(AuthUser._currentAuthUser == nil){
            let alertControler = UIAlertController(title: "Oops!", message: "HAS NO CURRENT USER", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertControler.addAction(defaultAction)
            self.present(alertControler, animated: true, completion: nil)
        }
        
        
        /*
        // ====== DEMO CODE GET GROUPS: BEGIN
        DataService().REF_GROUPS.observe(.value, with: { (snapshot) in
            
            var newGroups = [Group]()
            
            for group in snapshot.children {
                
                let newGroup = Group(snapshot: group as! FIRDataSnapshot)
                newGroups.insert(newGroup, at: 0)
                
            }
            //self.groupsArray = newGroups
            //self.tableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        // ADD GROUP
        
        let newgroupRef = DataService().REF_GROUPS.childByAutoId()
        //newgroupRef.setValue(<#T##value: Any?##Any?#>)
        
        
        // QUERY 
        
        let groupNodeRef = DataService().REF_GROUPS
        //groupNodeRef.queryEqual(toValue: <#T##Any?#>)
        
        
        // ====== DEMO CODE GET GROUPS: END
        
        
        
        // GET USER: BEGIN
        // QUERY
        
        let userNodeRef = DataService().REF_USERS
        userNodeRef.queryOrdered(byChild: "groups")
                    .queryEqual(toValue: "group-001")
        .value(forKey: "user-id")
        
        // GET USER: END
        
        */
        

        
        
        
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
        let airports = ["lat": "12", "long": "13"]
        let newUser = User(userName: "name",
                           email: emailTextfield.text,
                           mobileNumber: mobileNumberTextfield.text,
                           profilePicUrl: "link here",
                           location: airports as NSDictionary?,
                           groups: [groupTextfield.text!:"TRUE", "001":"TRUE", "002":"TRUE"])
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
        signOutOverride()
    }
    
//    func signOutOverride() {
//        try! FIRAuth.auth()!.signOut()
//        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.login()
//    }
}
