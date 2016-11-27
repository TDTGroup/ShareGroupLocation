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
    func setUserInfo(user: FIRUser!, userName: String, pictureData: NSData!,
                      completion: @escaping (FIRUser?, Error?) -> Void){
        
        let imagePath = "\(user.uid)/userProfilePic.jpg"
        let imageRef = REF_USER_PROFILE_PIC.child(imagePath)
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        print("2.1 ------ BEGIN OF: -- imageRef.put")
        imageRef.put(pictureData as Data, metadata: metaData) { (newMetaData, error) in
            if error != nil {
                
                // Error uploading user profile picture to Firebase storage
                print(error!.localizedDescription)
                return completion(nil, error)
            }
            
            
            // Update Auth user profile picture
            let changeRequest = user.profileChangeRequest()
            changeRequest.displayName = userName
            if let photoURL = newMetaData!.downloadURL() {
                changeRequest.photoURL = photoURL
            }
            
            print("2.2 ------ BEGIN OF: -- changeRequest.commitChanges")
            changeRequest.commitChanges(completion: { (error) in
                if error != nil {
                    // Error updating Auth user profile
                    print(error!.localizedDescription)
                    completion(nil, error)
                }
                
                print("NO ERROR HERE: commitChanges")
                // Update OK
                completion(user, nil)
                
            })
            print("2.2 ------ END OF: -- changeRequest.commitChanges")
            
        }
        print("2.1 ------ END OF: -- imageRef.put")
    }
}


