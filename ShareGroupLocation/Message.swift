//
//  Message.swift
//  ShareGroupLocation
//
//  Created by Khanh Trung on 11/15/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import Foundation
import FirebaseDatabase

let MESSAGE_GROUPS = "groups"
let MESSAGE_TEXT = "text"
let MESSAGE_SENDER = "sender"
let MESSAGE_DATE = "date"
let MESSAGE_TIME = "time"

class Message {
    private var _messageRef: FIRDatabaseReference!
    
    private(set) var groups: [String]!
    
    // uid
    private(set) var messageKey: String!
    private(set) var messageText: String!
    private(set) var messageSender: String!
    private(set) var messageDate: Date!
    private(set) var messageTime: String!
    
    init(text: String, sender: String, date: Date, time: String) {
        self.messageText = text
        self.messageSender = sender
        self.messageDate = date
        self.messageTime = time
    }
    
    init(messageKey: String, userData: Dictionary<String, AnyObject>) {
        self.messageKey = messageKey
        
        if let messageText = userData[MESSAGE_TEXT] as? String {
            self.messageText = messageText
        }
        
        if let messageSender = userData[MESSAGE_SENDER] as? String {
            self.messageSender = messageSender
        }
        if let messageDate = userData[MESSAGE_DATE] as? Date {
            self.messageDate = messageDate
        }
        
        if let messageTime = userData[MESSAGE_TIME] as? String {
            self.messageTime = messageTime
        }
        
        _messageRef = DataService.ds.REF_MESSAGES.child(messageKey)
    }
}
