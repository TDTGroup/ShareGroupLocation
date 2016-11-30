//
//  GroupController.swift
//  ShareGroupLocation
//
//  Created by Tran Khanh Trung on 11/30/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GroupController {
    
    // MARK: GET FUNCTIONS
    // Get group list by user id
    func getGroupByUserID(userID: String) {
        let groupRef = DataService().REF_GROUPS
        
        groupRef.queryOrdered(byChild:  "\(GROUP_MEETING_MEMBERS)/\(userID)")
            .queryEqual(toValue: "TRUE")
            .observe(.value) {(childSnapshot: FIRDataSnapshot) in
                
                print("---- current uid: \(userID)")
                if let childData = childSnapshot.value as? Dictionary<String, AnyObject>{
                    print("---- group count: \(childData.count)")
                    print(childData)
                } else {
                    print("group count nil")
                }
        }
    }
    
    func getGroupByUserID2(userID: String) -> [Group] {
        let groupRef = DataService().REF_GROUPS
        var groupsByUserID = [Group]()
        
        groupRef.queryOrdered(byChild: "\(GROUP_MEETING_MEMBERS)/\(userID)")
            .queryEqual(toValue: "TRUE")
            .observe(.value) {(snapshot: FIRDataSnapshot) in
                
                //                if let groupsData = snapshot.value as? Dictionary<String, AnyObject>{
                //                    print("---- group count: \(groupsData.count)")
                //                    print(groupsData)
                //                } else {
                //                    print("group count nil")
                //                }
                
                for group in snapshot.children {
                    let newGroup = Group(snapshot: group as! FIRDataSnapshot)
                    groupsByUserID.append(newGroup)
                }
                
                print("---- group count: \(groupsByUserID.count)")
                print("---- group DATA: \(snapshot)")
        }
        return groupsByUserID
    }
}

