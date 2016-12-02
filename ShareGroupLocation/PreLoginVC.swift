//
//  PreLoginVC.swift
//  ShareGroupLocation
//
//  Created by Khanh Trung on 11/22/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import Firebase
import ImageLoader

class PreLoginVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onFBSignInButtonTapped(_ sender: UIButton) {
        FBSDKLoginManager().logIn(withReadPermissions:  ["email", "public_profile"], from: self){
            (result: FBSDKLoginManagerLoginResult?, err: Error?) in
            if err != nil {
                print("Custom Facebook log in failed: \(err?.localizedDescription)")
                return
            }
            if let tokenString = result?.token?.tokenString {
                print("Custom Facebook Logged IN")
                print("\(tokenString)")
                self.getFBUserData()
                return
            }
            print("Custom Facebook Log in cancelled")
        }
    }
    
    @IBAction func onGGSignInButtonTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func getFBUserData(){
        if let fbAccessToken = FBSDKAccessToken.current() {
            
            guard let tokenString = fbAccessToken.tokenString else { return }
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: tokenString)
            
            excuteSignUpFlow(credential: credential, completion: { (error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
            })
            
            FIRAuth.auth()?.signIn(with: credential, completion: { ( user: FIRUser?, error:Error?) in
                if error != nil{
                    print("Error logging in with Facebook user account: \(error)")
                    return
                }
                
                print("----------- FB ULR: \(user?.photoURL)")
                
                guard let uid = user?.uid else { return }
                print("Firebase Logged IN with FB account: \(uid)")
                AuthUser.currentAuthUser = AuthUser(authUserData: user!)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            })
            
            FBSDKGraphRequest(
                graphPath: "/me",
                parameters: ["fields" : "id, name, email, first_name, last_name, picture.type(large)"]).start(completionHandler: { (connection, result, error) in
                    if error != nil {
                        print("Failed to start graph request: \(error)")
                        //self.displayErrorMessage(messageText: error!.localizedDescription)
                        return
                    }
                    print(result!)
                })
        }
    }
    
    @IBAction func unWindToPreLogin(storyboard: UIStoryboardSegue) {
        
    }
}

extension PreLoginVC: FBSDKLoginButtonDelegate {
    
    // Sent to the delegate when the button was used to login.
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error.localizedDescription)
            return
        }
        print("Logged IN")
        getFBUserData()
    }
    
    // Sent to the delegate when the button was used to logout.
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        AuthUser.currentAuthUser = nil
        print("Logged OUT")
    }
}

extension PreLoginVC: GIDSignInUIDelegate {
    
}

extension PreLoginVC {
    func excuteSignUpFlow(credential: FIRAuthCredential, completion: @escaping (Error?) -> Void) {
        var authUser: FIRUser!
        
        FIRAuth.auth()?.signIn(with: credential, completion: { ( user: FIRUser?, signInError:Error?) in
            if signInError != nil{
                print(signInError!.localizedDescription)
                completion(signInError)
                return
            }
            
            if user != nil {
                authUser = user!
                print(" => => \(authUser.uid)")
                DataService().REF_USERS.child(user!.uid)
                    .observeSingleEvent(of: .value) {(snapshot: FIRDataSnapshot) in
                        
                        print(" => => \(snapshot.value)")
                        
                        // If user has no record in DB
                        if (snapshot.childrenCount == 0) {
                            
                            print("------ FB has no user profile")
                            
                            let imageView = UIImageView()
                            imageView.load.request(with: user!.photoURL!, onCompletion: { _ in
                                
                                print("------ request request request request")
                                
                                if imageView.image == nil {
                                    print("=> => => => uiimage nil")
                                } else {
                                    print("=> => => => uiimage NOT nil")
                                }
                                /*
                                // Resize image before upload
                                let resizedPicture = self.ResizeImage(image: imageView.image!, targetSize: CGSize(width: 200.0, height: 200.0))
                                let pictureData = UIImageJPEGRepresentation(resizedPicture, 0.95)
                                
                                // 2 - Set Auth user info if no error
                                print("2 ------ BEGIN OF: -- setUserInfo")
                                StorageService().setUserInfo(user: authUser, userName: user!.displayName!, pictureData: pictureData as NSData!) {
                                    (setUser: FIRUser?, setUserInfoError: Error?) in
                                    if setUserInfoError != nil {
                                        print(setUserInfoError!.localizedDescription)
                                        return completion(setUserInfoError)
                                    }
                                    
                                    if setUser != nil {
                                        // Auth user now has photoURL from storage
                                        authUser = setUser
                                        
                                        // 3 - Save user info to Firebase DB if no error
                                        print("3 ------ BEGIN OF: -- saveUserInfo")
                                        DataService().saveUserInfo(user: authUser, mobileNumber: "") {(saveUserInfoError: Error?) in
                                            if saveUserInfoError != nil {
                                                print(saveUserInfoError!.localizedDescription)
                                                completion(saveUserInfoError)
                                            }
                                            
                                            // 4 - Log user in if no error
                                            print("4 ------ BEGIN OF: -- logIn")
                                            //                            AuthService().logIn(email: (authUser?.email!)!, password: password) {(loginError: Error?) in
                                            //                                if loginError != nil {
                                            //                                    print(loginError!.localizedDescription)
                                            //                                    completion(loginError)
                                            //                                }
                                            //                            }
                                            guard let uid = user?.uid else { return }
                                            print("Firebase Logged IN with FB account: \(uid)")
                                            AuthUser.currentAuthUser = AuthUser(authUserData: user!)
                                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                            appDelegate.login()
                                            completion(nil)
                                            print("4 ------ END OF: -- logIn")
                                        }
                                    }
                                    print("3 ------ END OF: -- saveUserInfo")
                                }
                                print("2 ------ END OF: -- setUserInfo")*/
                            })
                            return
                        }
                        
                        if (snapshot.childrenCount > 0) {
                            print("------ FB HASSSS user profile")
                            // 4 - Log user in if no error
                            print("4 ------ BEGIN OF: -- logIn")
                            //                            AuthService().logIn(email: (authUser?.email!)!, password: password) {(loginError: Error?) in
                            //                                if loginError != nil {
                            //                                    print(loginError!.localizedDescription)
                            //                                    completion(loginError)
                            //                                }
                            //                            }
                            guard let uid = user?.uid else { return }
                            print("Firebase Logged IN with FB account: \(uid)")
                            AuthUser.currentAuthUser = AuthUser(authUserData: user!)
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.login()
                            
                            print("4 ------ END OF: -- logIn")
                            completion(nil)
                        }
                        
                        
                }
            }
        })
        print("1 ------ END OF: -- signUp")
    }
}
