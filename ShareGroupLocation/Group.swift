//
//  Group.swift
//  ShareGroupLocation
//
//  Created by Tran Khanh Trung on 11/11/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

let GROUP_NAME = "group-name"
let GROUP_MEMBER_COUNT = "group-member-count"
let GROUP_CREATED_BY_USER = "group-created-by-user"

let GROUP_MEETING_DESC = "group-meeting-desc"
let GROUP_MEETING_DATE = "group-meeting-date"
let GROUP_MEETING_TIME = "group-meeting-time"
let GROUP_MEETING_LOCATION = "group-meeting-location"
let GROUP_MEETING_MEMBERS = "group-meeting-members"

class Group {
    private var _groupRef: FIRDatabaseReference!
    
    private(set) var groupKey: String!
    private(set) var groupName: String!
    private(set) var groupMemberCount: Int = 0
    private(set) var groupCreatedByUser: String!
    
    private(set) var groupMeeetingDesc: String!
    private(set) var groupMeeetingDate: Date!
    private(set) var groupMeeetingTime: String!
    private(set) var groupMeeetingLocation: String!
    private(set) var groupMeeetingMembers: [String]!
    
    init(groupName: String, groupMemberCount: Int, groupCreatedByUser: String,
         meeetingDesc: String, meeetingDate: Date, meeetingTime: String, meeetingLocation: String, meeetingMembers: [String]) {
        self.groupName = groupName
        self.groupMemberCount = groupMemberCount
        self.groupCreatedByUser = groupCreatedByUser
        
        self.groupMeeetingDesc = meeetingDesc
        self.groupMeeetingDate = meeetingDate
        self.groupMeeetingTime = meeetingTime
        self.groupMeeetingLocation = meeetingLocation
        self.groupMeeetingMembers = meeetingMembers
    }
    
    init(groupKey: String, groupData: Dictionary<String, AnyObject>) {
        self.groupKey = groupKey
        
        if let groupName = groupData[GROUP_NAME] as? String {
            self.groupName = groupName
        }
        
        if let groupMemberCount = groupData[GROUP_MEMBER_COUNT] as? Int {
            self.groupMemberCount = groupMemberCount
        }
        
        if let groupCreatedByUser = groupData[GROUP_CREATED_BY_USER] as? String {
            self.groupCreatedByUser = groupCreatedByUser
        }
        
        if let meeetingDesc = groupData[GROUP_MEETING_DESC] as? String {
            self.groupMeeetingDesc = meeetingDesc
        }
        
        if let meeetingDate = groupData[GROUP_MEETING_DATE] as? Date {
            self.groupMeeetingDate = meeetingDate
        }
        
        if let meeetingTime = groupData[GROUP_MEETING_TIME] as? String {
            self.groupMeeetingTime = meeetingTime
        }
        
        if let meeetingLocation = groupData[GROUP_MEETING_LOCATION] as? String {
            self.groupMeeetingLocation = meeetingLocation
        }
        
        if let meeetingMembers = groupData[GROUP_MEETING_MEMBERS] as? [String] {
            self.groupMeeetingMembers = meeetingMembers
        }
        
        _groupRef = DataService.ds.REF_GROUPS.child(groupKey)
    }
    
    init(snapshot: FIRDataSnapshot){
        self.groupKey = snapshot.key
        
        let dict = snapshot.value as? Dictionary<String, AnyObject>
        
        self.groupName = dict![GROUP_NAME] as? String
        self.groupMemberCount = (dict![GROUP_MEMBER_COUNT] as? Int)!
        self.groupCreatedByUser = dict![GROUP_CREATED_BY_USER] as? String
        self.groupMeeetingDesc = dict![GROUP_MEETING_DESC] as? String
        self.groupMeeetingDate = dict![GROUP_MEETING_DATE] as? Date
        self.groupMeeetingTime = dict![GROUP_MEETING_TIME] as? String
        self.groupMeeetingLocation = dict![GROUP_MEETING_LOCATION] as? String
        self.groupMeeetingMembers = dict![GROUP_MEETING_MEMBERS] as? [String]
        
        _groupRef = snapshot.ref
    }
}
