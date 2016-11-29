//
//  GroupsViewController.swift
//  ShareGroupLocation
//
//  Created by Duy Huynh Thanh on 11/12/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MBProgressHUD

class GroupsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var groupList = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        if let authUser = FIRAuth.auth()?.currentUser {
            print("group view controller: \(authUser.uid)")
            print("\(AuthUser.currentAuthUser?.displayName)")
            loadListGroup()
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
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        DataService().REF_GROUPS.observe(.value, with: { (snapshot) in
            var newGroups = [Group]()
            for group in snapshot.children {
                let newGroup = Group(snapshot: group as! FIRDataSnapshot)
                newGroups.insert(newGroup, at: 0)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            self.groupList = newGroups
            self.tableView.reloadData()
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}

extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupViewCell") as! GroupViewCell
        if groupList.count > 0 {
            let group = groupList[indexPath.row]
            cell.groupName.text = group.groupName
            
        }
        
        
        return cell
    }
    
}
