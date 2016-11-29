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
            FIRAuth.auth()?.signIn(with: credential, completion: { ( user: FIRUser?, error:Error?) in
                if error != nil{
                    print("Error logging in with Facebook user account: \(error)")
                    return
                }
                
                guard let uid = user?.uid else { return }
                print("Firebase Logged IN with FB account: \(uid)")
                AuthUser.currentAuthUser = AuthUser(authUserData: user!)
                
                // Create an instance of the storyboard's initial view controller.
                let userProfileVC:UIViewController = UIStoryboard(name: "TabBar", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
                // Display the new view controller.
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
