//
//  UserProfileVC.swift
//  ShareGroupLocation
//
//  Created by Tran Khanh Trung on 11/25/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserProfileVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onLogOutButtonTapped(_ sender: Any) {
        //        try! FIRAuth.auth()?.signOut()
        //        GIDSignIn.sharedInstance().signOut()
        //        FBSDKLoginManager().logOut()
        AuthUser.currentAuthUser = nil
        signOutOverride()
    }
}
