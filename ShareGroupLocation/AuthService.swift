//
//  AuthService.swift
//  ShareGroupLocation
//
//  Created by Khanh Trung on 11/23/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

struct AuthService {
    
    // 1 - Signup user
    func signUp(email: String, password: String, userName: String, mobileNumber: String, pictureData: NSData!,
                completion: @escaping (Error?) -> Void) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, createUserError) in
            if createUserError != nil {
                print(createUserError!.localizedDescription)
                completion(createUserError)
                return
            }
            
            // 2 - Set Auth user info if no error
            StorageService().setUserInfo(user: user, password: password, userName: userName,
                                         mobileNumber: mobileNumber, pictureData: pictureData) {(setUserInfoError: Error?) in
                                            if setUserInfoError != nil {
                                                print(setUserInfoError!.localizedDescription)
                                                completion(setUserInfoError)
                                                return
                                            }
                                            
                                            // 3 - Save user info to Firebase DB if no error
                                            DataService().saveUserInfo(user: user, password: password, userName: userName,
                                                                       mobileNumber: mobileNumber) {(setUserInfoError: Error?) in
                                                                        if setUserInfoError != nil {
                                                                            print(setUserInfoError!.localizedDescription)
                                                                            completion(setUserInfoError)
                                                                            return
                                                                        }
                                                                        
                                                                        print("User info saved successfully")
                                                                        // 4 - Log user in
                                                                        self.logIn(email: (user?.email!)!, password: password) {(loginError: Error?) in
                                                                            if loginError != nil {
                                                                                print(loginError!.localizedDescription)
                                                                                completion(loginError)
                                                                                return
                                                                            }
                                                                        }
                                            }
            }
        })
    }
    
    // 1 - Signup user
    func signUp2(email: String, password: String, userName: String,
                 completion: @escaping (FIRUser?, Error?) -> Void) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, createUserError) in
            if user != nil {
                print(" ----------- signUp2 ----------- ")
                completion(user, nil)
            }
            
            if createUserError != nil {
                print(createUserError!.localizedDescription)
                completion(nil, createUserError)
                return
            }
            
            print(" ----------- signUp2 ----------- ")
            // Return Auth user if no error
            completion(user, nil)
        }
        )}
    
    
    // 4 - Login user in
    func logIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                if let user = user {
                    print("Firebase Logged IN with EMAIL/PASWORD method: \(user.displayName!)")
                    AuthUser.currentAuthUser = AuthUser(authUserData: user)
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login()
                }
            }
            else {
                print(error!.localizedDescription)
                completion(error)
            }
        })
    }
    
    // 5 - Reset password
    func ResetPassword(forEmail: String, completion: @escaping (Error?) -> Void) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: forEmail, completion: { (error) in
            if error == nil {
                let result = "An email with information on how to reset your password has been sent to you."
                print(result)
                completion(nil)
            } else {
                print(error!.localizedDescription)
                completion(error)
            }
        })
    }
}
