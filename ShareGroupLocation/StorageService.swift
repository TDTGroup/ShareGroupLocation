//
//  StorageService.swift
//  ShareGroupLocation
//
//  Created by Khanh Trung on 11/23/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

// URL of our Firebase Storage
let STORAGE_BASE = FIRStorage.storage().reference()

struct StorageService {
    // Singleton
    static let ds = StorageService()
    
    // Storage references
    private var _REF_BASE = STORAGE_BASE
    private var _REF_USER_PROFILE_PIC = STORAGE_BASE.child("user_profile_pic")
    
    var REF_BASE: FIRStorageReference {
        return _REF_BASE
    }
    
    var REF_USER_PROFILE_PIC: FIRStorageReference {
        return _REF_USER_PROFILE_PIC
    }
    
    // 2 - Save the User Profile Picture to Firebase Storage, Assign to the new user a username and Photo URL
    func setUserInfo(user: FIRUser!, password: String, userName: String, mobileNumber: String, pictureData: NSData!,
                     completion: @escaping (Error?) -> Void){
        
        let imagePath = "\(user.uid)/userProfilePic.jpg"
        let imageRef = REF_USER_PROFILE_PIC.child(imagePath)
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageRef.put(pictureData as Data, metadata: metaData) { (newMetaData, error) in
            if error != nil {
                // Error uploading user profile picture to Firebase storage
                print(error!.localizedDescription)
                completion(error)
                return
            }
            
            // Update Auth user profile picture
            let changeRequest = user.profileChangeRequest()
            changeRequest.displayName = userName
            if let photoURL = newMetaData!.downloadURL() {
                changeRequest.photoURL = photoURL
            }
            
            changeRequest.commitChanges(completion: { (error) in
                if error != nil {
                    // Error updating Auth user profile
                    print(error!.localizedDescription)
                    completion(error)
                    return
                }
            })
        }
    }
    
    // 2 - Save the User Profile Picture to Firebase Storage, Assign to the new user a username and Photo URL
    func setUserInfo2(user: FIRUser!, userName: String, pictureData: NSData!,
                      completion: @escaping (FIRUser?, Error?) -> Void){
        
        let imagePath = "\(user.uid)/userProfilePic.jpg"
        let imageRef = REF_USER_PROFILE_PIC.child(imagePath)
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageRef.put(pictureData as Data, metadata: metaData) { (newMetaData, error) in
            if error != nil {
                // Error uploading user profile picture to Firebase storage
                print(error!.localizedDescription)
                completion(nil, error)
                return
            }
            
            // Update Auth user profile picture
            let changeRequest = user.profileChangeRequest()
            changeRequest.displayName = userName
            if let photoURL = newMetaData!.downloadURL() {
                changeRequest.photoURL = photoURL
            }
            
            changeRequest.commitChanges(completion: { (error) in
                if error != nil {
                    // Error updating Auth user profile
                    print(error!.localizedDescription)
                    completion(nil, error)
                    return
                }
            })
            
            // Update OK
            completion(user, nil)
        }
    }
}


