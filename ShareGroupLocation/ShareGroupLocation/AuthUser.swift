//
//  AuthUser.swift
//  ShareGroupLocation
//
//  Created by Tran Khanh Trung on 11/10/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import Foundation
import Firebase

class AuthUser {
    
    // 1. Globally define a "special notification key" constant that can be broadcast / tuned in to...
    //let didLogOutNotificationKey = "com.TDTGroup.didLogOutNotificationKey"
    
    static var _currentAuthUser: AuthUser!
    
    private(set) var uid: String!
    private(set) var email: String!
    private(set) var providerID: String!
    private(set) var displayName: String!
    private(set) var photoURL: URL!
    private(set) var description: String!
    private(set) var authUserDict: [String:AnyObject]!
    
    class var currentAuthUser: AuthUser? {
        get{
            if _currentAuthUser == nil{
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentAuthUser") as? Data
                
                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData as Data, options: []) as! Dictionary<String, AnyObject>
                    _currentAuthUser = AuthUser(authUserData: dictionary)
                }
            }
            
            return _currentAuthUser
        }
        set(authUser){
            _currentAuthUser = authUser
            
            let defaults = UserDefaults.standard
            
            if let authUser = authUser {
                let data = try! JSONSerialization.data(withJSONObject: authUser.authUserDict,options: [])
                defaults.set(data, forKey: "currentAuthUser")
            } else  {
                defaults.removeObject(forKey: "currentAuthUser")
            }
            defaults.synchronize()
        }
    }
    
    init(uid: String, email: String, providerID: String, displayName: String, photoURL: URL, description: String) {
        self.uid = uid
        self.email = email
        self.providerID = providerID
        self.displayName = displayName
        self.photoURL = photoURL
        self.description = description
    }
    
    init(authUserData: FIRUser) {
        authUserDict = [String:AnyObject]()
        
        self.uid = authUserData.uid
        authUserDict["uid"] = uid as AnyObject?
        
        if let email = authUserData.providerData.first?.email {
            self.email = email
            authUserDict["email"] = email as AnyObject?
        }
        
        if let providerID = authUserData.providerData.first?.providerID {
            self.providerID = providerID
            authUserDict["providerID"] = providerID as AnyObject?
        }
        
        if let displayName = authUserData.providerData.first?.displayName {
            self.displayName = displayName
            authUserDict["displayName"] = displayName as AnyObject?
        }
        
        if let photoURL = authUserData.providerData.first?.photoURL {
            self.photoURL = photoURL
            authUserDict["photoURL"] = photoURL.absoluteString as AnyObject?
        }
        
        if let description = authUserData.providerData.first?.description {
            self.description = description
            authUserDict["description"] = description as AnyObject?
        }
    }
    
    init(authUserData: Dictionary<String, AnyObject>) {
        self.authUserDict = authUserData
        
        self.uid = authUserData["uid"] as! String
        
        if let email = authUserData["email"] as? String {
            self.email = email
        } else {
            self.email = ""
        }
        
        if let providerID = authUserData["providerID"] as? String {
            self.providerID = providerID
        } else {
            self.providerID = ""
        }
        
        if let displayName = authUserData["displayName"] as? String {
            self.displayName = displayName
        } else {
            self.displayName = ""
        }
        
        if let photoURL = authUserData["photoURL"] as? String {
            self.photoURL = URL(string: photoURL)
        } else {
            self.photoURL = nil
        }
        
        if let description = authUserData["description"] as? String {
            self.description = description
        } else {
            self.description = ""
        }
    }
}
