//
//  DataService.swift
//  ShareGroupLocation
//
//  Created by Tran Khanh Trung on 11/11/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

// URL of our Firebase database
let DB_BASE = FIRDatabase.database().reference()

struct DataService {
    // Singleton
    static let ds = DataService()
    
    //DB references
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GROUPS = DB_BASE.child("groups")
    private var _MESSAGES = DB_BASE.child("messages")
    private var _REF_LOCATIONS = DB_BASE.child("locations")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_GROUPS: FIRDatabaseReference {
        return _REF_GROUPS
    }
    
    var REF_MESSAGES: FIRDatabaseReference {
        return _MESSAGES
    }
    
    var REF_LOCATIONS: FIRDatabaseReference {
        return _REF_LOCATIONS
    }
    
    func createFirebaseDbUser(uid: String, userData: Dictionary<String, Any>) {
        // when creating a user, it will create uid, and update the child values with the userData we pass in
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    // 3 - Add User Info to Firebase Database, then log in
    func saveUserInfo(user: FIRUser!, mobileNumber: String,
                       completion: @escaping (Error?) -> Void){
        
        let userInfo = [USER_NAME: user.displayName as AnyObject,
                        USER_EMAIL: user.email as AnyObject,
                        USER_MOBILE_NUMBER: mobileNumber as AnyObject,
                        USER_PIC_URL: String(describing: user.photoURL!) as AnyObject]
        
        print("3.1 ------ BEGIN OF: -- setValue")
        REF_USERS.child(user.uid).setValue(userInfo) { (error, ref) in
            if error != nil {
                print(error!.localizedDescription)
                completion(error)
            }
            completion(nil)
        }
        print("3.1 ------ END OF: -- setValue")
    }
}
