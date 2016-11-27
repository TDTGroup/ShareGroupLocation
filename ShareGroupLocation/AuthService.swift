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
    func signUp(email: String, password: String, userName: String,
                completion: @escaping (FIRUser?, Error?) -> ()) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, createUserError) in
            if createUserError != nil {
                print(" ----------- signUp3 ERROR ----------- ")
                print(createUserError!.localizedDescription)
                completion(nil, createUserError)
            }
            
            print(" ----------- signUp3 OK ----------- ")
            completion(user, nil)
        }
        )}
    
    
    // 4 - Login user in
    func logIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error!.localizedDescription)
                completion(error)
            }
            
            if let user = user {
                print("Firebase Logged IN with EMAIL/PASWORD method: \(user.displayName!)")
                AuthUser.currentAuthUser = AuthUser(authUserData: user)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                completion(nil)
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
