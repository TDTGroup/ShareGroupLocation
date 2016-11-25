//
//  GroupsViewController.swift
//  ShareGroupLocation
//
//  Created by Duy Huynh Thanh on 11/12/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import FirebaseAuth

class GroupsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var groupList = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        if let authUser = FIRAuth.auth()?.currentUser {
            print("\(authUser.uid)")
            
        }
        
        if AuthUser.currentAuthUser != nil {
            print("\(AuthUser.currentAuthUser?.displayName)")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createGroup(_ sender: AnyObject) {
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func loadListGroup() {
        
    }
    
}

extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupViewCell") as! GroupViewCell
        
        return cell
    }
    
}
