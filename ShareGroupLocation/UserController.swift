//
//  UserController.swift
//  ShareGroupLocation
//
//  Created by Tran Khanh Trung on 11/30/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserController {
    // MARK: GET FUNCTIONS
    // Get all user data
    func getUsers() {
        
        var users = [User]()
        DataService().REF_USERS.observe(.value) { (snapshot: FIRDataSnapshot) in
            for child in snapshot.children {
                
                let newUser = User(snapshot: child as! FIRDataSnapshot)
                users.append(newUser)
                print(newUser.email)
                
                let snapshotChild = child as! FIRDataSnapshot
                let childRef = snapshotChild.ref
                childRef.child("groups").observe(.value) {(childSnapshot: FIRDataSnapshot) in
                    if let childData = childSnapshot.value as? Dictionary<String, AnyObject> {
                        print(childData)
                    }
                }
            }
            print(users.count)
        }
    }
    
    // Get user by group ID
    func getUserByGroupID(groupID: String) {
        print("get group count")
        let userRef = DataService().REF_USERS
        userRef.queryOrdered(byChild: "groups/\(groupID)")
            .queryEqual(toValue: "TRUE")
            .observe(.value) {(childSnapshot: FIRDataSnapshot) in
                if let childData = childSnapshot.value as? Dictionary<String, AnyObject>{
                    print("---- user for group \(groupID): \(childData.count)")
                    print(childData)
                } else {
                    print("group count nil")
                }
        }
    }
    
    // check existance of mobile number
    func checkContactExist(mobileNumber: String) {
        print("check mobile number exist")
        let userRef = DataService().REF_USERS
        
        userRef.queryOrdered(byChild: "\(USER_MOBILE_NUMBER)")
            .queryEqual(toValue: mobileNumber)
            .observeSingleEvent(of: .value) {(snapshot: FIRDataSnapshot) in
                print("exist count: \(snapshot.childrenCount)")
                for userSnapshot in snapshot.children {
                    let newUser = User(snapshot: userSnapshot as! FIRDataSnapshot)
                    print(newUser.userName)
                }
        }
    }
    
    // set observe for user location
    func setObserveUserLocation() {
        
        let currentUserID = "test1"
        
        DataService().REF_USERS.child("\(currentUserID)/\(USER_LOCATION)")
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
    
    
    // MARK: ADD FUNCTIONS
    // Add user to Firebase DB
    func addToDatabase(user: User) {
        if user.dictData == nil {
            return
        }
        
        let usersNodeRef = DataService.ds.REF_USERS
        let userKey = usersNodeRef.childByAutoId().key
        let childUpdate = ["\(userKey)": user.dictData]
        usersNodeRef.updateChildValues(childUpdate)
    }
    
    // Update user to Firebase DB
    func UpdateToDatabase(user: User) {
        let usersNodeRef = DataService.ds.REF_USERS
        let userKey = usersNodeRef.child(user.userKey)
        let childUpdate = ["\(userKey)": user.dictData]
        usersNodeRef.updateChildValues(childUpdate)
    }
    
//    // 3 - Add User Info to Firebase Database, then log in
//    func UpdateToDatabase(user: User!
//                      completion: @escaping (Error?) -> Void){
//        
//        let userInfo = [USER_NAME: user.userName as AnyObject,
//                        USER_EMAIL: user.email as AnyObject,
//                        USER_MOBILE_NUMBER: user.mobileNumber as AnyObject,
//                        USER_PIC_URL: String(describing: user.photoURL!) as AnyObject]
//        
//        print("3.1 ------ BEGIN OF: -- setValue")
//        REF_USERS.child(user.uid).setValue(userInfo) { (error, ref) in
//            if error != nil {
//                print(error!.localizedDescription)
//                completion(error)
//            }
//            completion(nil)
//        }
//        print("3.1 ------ END OF: -- setValue")
//    }
}
