//
//  DataModel.swift
//  Checklists
//
//  Created by Shehab Saqib on 22/11/2015.
//  Copyright © 2015 Shehab Saqib. All rights reserved.
//

import Foundation

class DataModel {
    var lists = [Checklist]()
    
    var indexOfSelectedChecklist: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        } set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
        }
    }
    
    init() {
        loadChecklists()
        registerDefaults()
        handleFirstTime()
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    func dateFilePath() -> String {
        return (documentsDirectory() as NSString) .appendingPathComponent("Checklists.plist")
    }
    
    func saveChecklists() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(lists, forKey: "Checklists")
        archiver.finishEncoding()
        data.write(toFile: dateFilePath(), atomically: true)
    }
    
    func loadChecklists() {
        // 1
        let path = dateFilePath()
        //2
        if FileManager.default.fileExists(atPath: path) {
            //3
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                lists = unarchiver.decodeObject(forKey: "Checklists") as! [Checklist]
                unarchiver.finishDecoding()
                sortChecklists()
            }
        }
    }
    
    func sortChecklists() {
        lists.sort(by: {checklist1, checklist2 in return checklist1.name.localizedStandardCompare(checklist2.name) == .orderedAscending})
    }
    
    func registerDefaults() {
        let dictionary = ["ChecklistIndex": -1, "FirstTime": true, "ChecklistItemID": 0] as [String : Any]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        if firstTime {
            let checklist = Checklist(name: "List")
            lists.append(checklist)
            indexOfSelectedChecklist = 0
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
    }
    
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return itemID
    }
}
