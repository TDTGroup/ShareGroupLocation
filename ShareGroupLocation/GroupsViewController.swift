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
    var groupRef = DataService().REF_GROUPS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        if let authUser = FIRAuth.auth()?.currentUser {
            print("group view controller: \(authUser.uid)")
            print("\(AuthUser.currentAuthUser?.displayName)")
            //loadListGroup()
            checkExistOf(mobileNumber: "111111")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // set observe to display everytime view appear (while viewdidload only excutes once)
        setObserveGroupList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // remove listener when view not appear
        groupRef.removeAllObservers()
    }
    
    @IBAction func createGroup(_ sender: AnyObject) {
        
    }
    
    /*
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
    }*/
    
    // Get all groups of current user
    // !!! Currently cannot clear old data of tableview !!!
    func setObserveGroupList() {
        var newGroups = [Group]()
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        DataService().REF_GROUPS.queryOrdered(byChild: "\(GROUP_MEETING_MEMBERS)/\(getCurrentUserUid())")
            .queryEqual(toValue: GROUP_DUMMY_VALUE) // dummy value: "TRUE"
            .observe(.value, with: {(snapshot) in
                DispatchQueue.main.async {
                    self.groupList = [Group]()
                    self.tableView.reloadData()
                }
                
                for group in snapshot.children {
                    let newGroup = Group(snapshot: group as! FIRDataSnapshot)
                    newGroups.insert(newGroup, at: 0)
                }
                MBProgressHUD.hide(for: self.view, animated: true)
                DispatchQueue.main.async {
                    self.groupList = newGroups
                    self.tableView.reloadData()
                }
            }) {(error) in
                print(error.localizedDescription)
        }
    }
    
    
    // Check existance of mobile number in DB
    func checkExistOf(mobileNumber: String) {
        DataService().REF_USERS.queryOrdered(byChild: "\(USER_MOBILE_NUMBER)")
            .queryEqual(toValue: mobileNumber)
            .observeSingleEvent(of: .value) {(snapshot: FIRDataSnapshot) in
                
                // Exist count for mobile number
                print("Mobile number check exist: Exist count: \(snapshot.childrenCount)")
                
                // print list username who is using that mobile number
                for userSnapshot in snapshot.children {
                    let newUser = User(snapshot: userSnapshot as! FIRDataSnapshot)
                    print(newUser.userName)
                }
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
