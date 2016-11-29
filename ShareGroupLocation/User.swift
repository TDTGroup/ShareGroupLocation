//
//  User.swift
//  ShareGroupLocation
//
//  Created by Tran Khanh Trung on 11/10/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import Foundation
import FirebaseDatabase

let USER_NAME = "user-name"
let USER_EMAIL = "email"
let USER_MOBILE_NUMBER = "mobile-number"
let USER_PIC_URL = "profile-pic"
let USER_LOCATION = "location"
let USER_LOCATION_LONG = "location/long"
let USER_LOCATION_LAT = "location/lat"
let USER_GROUPS = "groups"

class User {
    private var _userRef: FIRDatabaseReference!
    
    // uid
    private(set) var userKey: String!
    private(set) var userName: String!
    private(set) var email: String!
    private(set) var mobileNumber: String!
    private(set) var profilePicUrl: String!
    private(set) var location: String!
    private(set) var location_lat: String!
    private(set) var location_long: String!
    private(set) var groups: [String]!
    
    var dictData: [String:AnyObject]!
    
    init(userName: String?, email: String?, mobileNumber: String?, profilePicUrl: String?, location: String?, groups: [String]?) {
        
        self.dictData = [String:AnyObject]()
        
        if userName != nil {
            self.userName = userName
            dictData[USER_NAME] = userName as AnyObject?
        }
        
        if email != nil {
            self.email = email
            dictData[USER_EMAIL] = email as AnyObject?
        }
        
        if mobileNumber != nil {
            self.mobileNumber = mobileNumber
            dictData[USER_MOBILE_NUMBER] = mobileNumber as AnyObject?
        }
        
        if profilePicUrl != nil {
            self.profilePicUrl = profilePicUrl
            dictData[USER_PIC_URL] = profilePicUrl as AnyObject?
        }
        
        if location != nil {
            self.location = location
            dictData[USER_LOCATION] = location as AnyObject?
        }
        
        if groups != nil {
            self.groups = groups
            dictData[USER_GROUPS] = groups as AnyObject?
        }
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>) {
        dictData = userData
        
        self.userKey = userKey
        
        if let userName = userData[USER_NAME] as? String {
            self.userName = userName
        }
        
        if let email = userData[USER_EMAIL] as? String {
            self.email = email
        }
        if let mobileNumber = userData[USER_MOBILE_NUMBER] as? String {
            self.mobileNumber = mobileNumber
        }
        
        if let profilePicUrl = userData[USER_PIC_URL] as? String {
            self.profilePicUrl = profilePicUrl
        }
        
        if let location = userData[USER_LOCATION] as? String {
            self.location = location
        }
        
        if let groups = userData[USER_GROUPS] as? [String] {
            self.groups = groups
        }
        
        _userRef = DataService.ds.REF_USERS.child(userKey)
    }
    
    func toAnyObject() -> [String: AnyObject] {
        return [USER_NAME: userName as AnyObject,
                USER_EMAIL: email as AnyObject,
                USER_MOBILE_NUMBER: mobileNumber as AnyObject,
                USER_PIC_URL: profilePicUrl as AnyObject,
                USER_LOCATION: location as AnyObject,
                USER_GROUPS: groups as AnyObject
        ]
    }
    
    func addToDatabase() {
        if self.dictData == nil {
            return
        }
        
        let usersNodeRef = DataService.ds.REF_USERS
        let userKey = usersNodeRef.childByAutoId().key
        let childUpdate = ["\(userKey)": self.dictData]
        usersNodeRef.updateChildValues(childUpdate)
    }
    
    init(snapshot: FIRDataSnapshot){
        self.userKey = snapshot.key
        
        let dict = snapshot.value as? Dictionary<String, AnyObject>
        
        if let userName = dict![USER_NAME] as? String {
            self.userName = userName
        }
        
        if let email = dict![USER_EMAIL] as? String {
            self.email = email
        }
        if let mobileNumber = dict![USER_MOBILE_NUMBER] as? String {
            self.mobileNumber = mobileNumber
        }
        
        if let profilePicUrl = dict![USER_PIC_URL] as? String {
            self.profilePicUrl = profilePicUrl
        }
        
        if let location = dict![USER_LOCATION] as? String {
            self.location = location
        }
        
        if let location_lat = dict![USER_LOCATION_LAT] as? String {
            self.location_lat = location_lat
        }
        
        if let location_long = dict![USER_LOCATION_LONG] as? String {
            self.location_long = location_long
        }
        
        if let groups = dict![USER_GROUPS] as? [String] {
            self.groups = groups
        }
        
        _userRef = DataService.ds.REF_USERS.child(userKey)
    }
}
