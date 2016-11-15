//
//  LoginViewController.swift
//  ShareGroupLocation
//
//  Created by Duy Huynh Thanh on 11/12/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import Firebase

import UIKit

class LoginViewController: UIViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Facebook sign in button
        //addFBLoginButton()
        // Add Google sign in button
        //addGGLoginButton()
        
        // Add Custom Facebook sign in button
        addCustomFBLoginButton()
        
        // Add Custom Google sign in button
        addCustomGGLoginButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // Add Facebook sign in button
    fileprivate func addFBLoginButton() {
        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width-32, height: 50)
        view.addSubview(fbLoginButton)
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email", "public_profile"]
    }
    
    // Add Custom Facebook sign in button
    func addCustomFBLoginButton() {
        let customFBLoginButton = UIButton(type: .custom)
        customFBLoginButton.frame = CGRect(x: 65, y: 583, width: 64, height: 64)
        customFBLoginButton.setImage(#imageLiteral(resourceName: "facebook"), for: .normal)
        view.addSubview(customFBLoginButton)
        customFBLoginButton.addTarget(self, action: #selector(handleCustomFBLogginButton), for: .touchUpInside)
    }
    
    func handleCustomFBLogginButton() {
        FBSDKLoginManager().logIn(withReadPermissions:  ["email", "public_profile"], from: self)
        { (result: FBSDKLoginManagerLoginResult?, err: Error?) in
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
    
    // Add Google sign in button
    fileprivate func addGGLoginButton() {
        let ggLoginButton = GIDSignInButton()
        ggLoginButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width-32, height: 50)
        view.addSubview(ggLoginButton)
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Setup
        ggLoginButton.style = .wide
        ggLoginButton.colorScheme = .light
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    // Add Custom Google sign in button
    func addCustomGGLoginButton() {
        let customGGLoginButton = UIButton(type: .custom)
        customGGLoginButton.frame = CGRect(x: 245, y: 583, width: 64, height: 64)
        customGGLoginButton.setImage(#imageLiteral(resourceName: "google.png"), for: .normal)
        view.addSubview(customGGLoginButton)
        customGGLoginButton.addTarget(self, action: #selector(handleCustomGGLogginButton), for: .touchUpInside)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func handleCustomGGLogginButton() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func getFBUserData(){
        if let fbAccessToken = FBSDKAccessToken.current() {
            
            guard let tokenString = fbAccessToken.tokenString else { return }
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: tokenString)
            FIRAuth.auth()?.signIn(with: credential, completion: { ( user: FIRUser?, error:Error?) in
                if error != nil{
                    print("Error logging in with Facebook user account: \(error)")
                    return
                }
                
                guard let uid = user?.uid else { return }
                print("Firebase Logged IN with FB account: \(uid)")
                AuthUser.currentAuthUser = AuthUser(authUserData: user!)
                
                // [1] Create a new "UserProfile" instance.
                let userProfileStoryBoard = UIStoryboard(name: "UserProfile", bundle: nil)
                
                // [2] Create an instance of the storyboard's initial view controller.
                let userProfileVC = userProfileStoryBoard.instantiateViewController(withIdentifier: "UserProfile") as UIViewController
                
                // [3] Display the new view controller.
                self.present(userProfileVC, animated: true, completion: nil)
            })
            
            FBSDKGraphRequest(
                graphPath: "/me",
                parameters: ["fields" : "id, name, email, first_name, last_name, picture.type(large)"]).start(completionHandler: { (connection, result, error) in
                    if error != nil {
                        print("Failed to start graph request: \(error)")
                        return
                    }
                    print(result!)
                })
        }
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    
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

extension LoginViewController: GIDSignInUIDelegate {
    
}


