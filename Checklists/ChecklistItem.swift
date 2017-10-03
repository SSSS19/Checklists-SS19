//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Shehab Saqib on 11/11/2015.
//  Copyright © 2015 Shehab Saqib. All rights reserved.
//

import Foundation
import UIKit

class ChecklistItem: NSObject, NSCoding {
    var text = ""
    var checked = false
    var dueDate = Date()
    var shouldRemind = false
    var itemID: Int
    
    func toggleChecked() {
        checked = !checked
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: "Text")
        aCoder.encode(checked, forKey: "Checked")
        aCoder.encode(dueDate, forKey: "DueDate")
        aCoder.encode(shouldRemind, forKey: "ShouldRemind")
        aCoder.encode(itemID, forKey: "ItemID")
    }
    
    required init?(coder aDecoder:NSCoder) {
        text = aDecoder.decodeObject(forKey: "Text") as! String
        checked = aDecoder.decodeBool(forKey: "Checked")
        dueDate = aDecoder.decodeObject(forKey: "DueDate") as! Date
        shouldRemind = aDecoder.decodeBool(forKey: "ShouldRemind")
        itemID = aDecoder.decodeInteger(forKey: "ItemID")
        super.init()
    }
    
    override init() {
        itemID = DataModel.nextChecklistItemID()
        super.init()
    }
    
    init(text: String, checked: Bool, itemID: Int) {
        self.text = text
        self.checked = checked
        self.itemID = itemID
        super.init()
    }
    
    func scheduleNotification() {
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification {
            print("Found an existing notification \(notification)")
            UIApplication.shared.cancelLocalNotification(notification)
        }
        if shouldRemind && dueDate.compare(Date()) != .orderedAscending {
            let localNotification = UILocalNotification()
            localNotification.fireDate = dueDate
            localNotification.timeZone = TimeZone.current
            localNotification.alertBody = text
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.userInfo = ["ItemID": itemID]
            
            UIApplication.shared.scheduleLocalNotification(localNotification)
            
            print("Scheduled Notification \(localNotification) for itemID \(itemID)")
        }
    }
    
    func notificationForThisItem() -> UILocalNotification? {
        let allNotifications = UIApplication.shared.scheduledLocalNotifications!
        
        for notification in allNotifications {
            if let number = notification.userInfo?["ItemID"] as? Int, number == itemID {
                return notification
            }
        }
        return nil
    }
    
    deinit {
        if let notification = notificationForThisItem() {
            print("Removing existing notification \(notification)")
            UIApplication.shared.cancelLocalNotification(notification)
        }
    }
}
