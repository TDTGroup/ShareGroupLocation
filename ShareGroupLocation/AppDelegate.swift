//
//  AppDelegate.swift
//  ShareGroupLocation
//
//  Created by Duy Huynh Thanh on 11/12/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import Contacts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var contactStore = CNContactStore()
    
    override init() {
        super.init()
        // Use Firebase library to configure APIs
        FIRApp.configure()
        
    }
    
    func login() {
        if AuthUser.currentAuthUser != nil {
            print("HAS CURRENT USER \(AuthUser.currentAuthUser?.uid)")
            /*let userProfileStoryBoard = UIStoryboard(name: "UserProfile", bundle: nil)
            let userProfileVC = userProfileStoryBoard.instantiateViewController(withIdentifier: "UserProfileVC")
            
            self.window?.rootViewController = userProfileVC
            self.window?.makeKeyAndVisible()
            */
            
            let userProfileStoryBoard = UIStoryboard(name: "TabBar", bundle: nil)
            let userProfileVC = userProfileStoryBoard.instantiateViewController(withIdentifier: "TabBarController")
            
            self.window?.rootViewController = userProfileVC
            self.window?.makeKeyAndVisible()
            
        } else {
            print("HAS NO CURRENT USER")
            let PreLoginVC = UIStoryboard(name: "Login_Signup", bundle: nil).instantiateViewController(withIdentifier: "PreLoginVC")
            self.window?.rootViewController = PreLoginVC
            self.window?.makeKeyAndVisible()
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        login()
        
        // Facebook Delegate
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google Delegate
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Open URL for Google
        GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        // Open URL for Facebook
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    static func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}



extension AppDelegate: GIDSignInDelegate {
    // The sign-in flow has finished and was successful if |error| is |nil|.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Error logging in with Google user account: \(error.localizedDescription)")
            return
        }
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { ( user: FIRUser?, error:Error?) in
            if error != nil{
                print("Error logging in with Google user account: \(error)")
                return
            }
            guard let uid = user?.uid else { return }
            print("Firebase Logged IN with Google account: \(uid)")
            AuthUser.currentAuthUser = AuthUser(authUserData: (FIRAuth.auth()?.currentUser)!)
            
            // Create an instance of the storyboard's initial view controller.
            let userProfileVC:UIViewController = UIStoryboard(name: "TabBar", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
            // Display the new view controller.
            //self.present(userProfileVC, animated: true, completion: nil)
            self.window?.rootViewController = userProfileVC
            self.window?.makeKeyAndVisible()
        })
    }
    
    // Finished disconnecting |user| from the app successfully if |error| is |nil|.
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        // Perform any operations when the user disconnects from app here.
        // ...
        
        AuthUser.currentAuthUser = nil
        print("Google logged OUT")
    }
}
