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
    
    func UpdateUserLocation(userID: String, lat: String, long: String){
        let usersLocationNodeRef = DataService.ds.REF_USERS.child("\(userID)/\(USER_LOCATION)")
        //let userKey = usersLocationNodeRef.child(user.userKey)
        let childUpdate = ["\(USER_LOCATION_LAT)": lat, "\(USER_LOCATION_LONG)": long]
        usersLocationNodeRef.updateChildValues(childUpdate)
    }
}
