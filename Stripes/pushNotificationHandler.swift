//
//  pushNotificationHandler.swift
//  Stripes
//
//  Created by Koop Otten on 17/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

var newGameIsRandom : Bool!

class pushNotificationHandler: PFObject {
    
    class func sendUserTurnNotification(opponent : PFUser) {
        let query = PFInstallation.query()
        let push = PFPush()
        
        var oppName = ""
        let oppFullName = (PFUser.currentUser()!["fullName"] as! NSString).componentsSeparatedByString(" ") as NSArray
//        let oppFullName : NSArray = ["Opponent", "lastName"]
        let lastName = oppFullName.lastObject as! String
        let lastLetter = lastName[lastName.startIndex]
        
        oppName = "\(oppFullName[0]) \(lastLetter)."
        
        let data : NSDictionary = ["alert": "It's your turn against \(oppName)!", "badge":"1", "content-available":"1", "sound":"default"]
        
        query!.whereKey("channels", equalTo: "gameNotification")
        query!.whereKey("user", equalTo: opponent)
        
        push.setQuery(query)
        push.setData(data as [NSObject : AnyObject])
        print(push)
        
        push.sendPushInBackground()
    }
    
    class func sendNewGameNotification(user : PFUser) {
        let query = PFInstallation.query()
        let push = PFPush()
        
        var oppName = ""
        let oppFullName = (PFUser.currentUser()!["fullName"] as! NSString).componentsSeparatedByString(" ") as NSArray
        let lastName = oppFullName.lastObject as! String
        let lastLetter = lastName[lastName.startIndex]
        
        oppName = "\(oppFullName[0]) \(lastLetter)."
        
        let data : NSDictionary = ["alert": "\(oppName) has challenged you to play a game!", "badge":"1", "content-available":"1", "sound":"default", "random-game":"\(newGameIsRandom)"]
        
        query!.whereKey("channels", equalTo: "gameNotification")
        query!.whereKey("user", equalTo: user)
        
        push.setQuery(query)
        push.setData(data as [NSObject : AnyObject])
        push.sendPushInBackground()
    }
    
    class func userResignedGame(game : PFObject) {
        let push = PFPush()
        let query = PFInstallation.query()
        var oppName = ""
        let oppFullName = (PFUser.currentUser()!["fullName"] as! NSString).componentsSeparatedByString(" ") as NSArray
//        let oppFullName : NSArray = ["Opponent", "lastName"]
        let lastName = oppFullName.lastObject as! String
        let lastLetter = lastName[lastName.startIndex]
        
        oppName = "\(oppFullName[0]) \(lastLetter)."
        
        let data : NSDictionary = ["alert": "\(oppName) resigned!", "badge":"0", "content-available":"1", "sound":"default"]
        
        query!.whereKey("channels", equalTo: "gameNotification")
        
        if game["user"]!.objectId == PFUser.currentUser()!.objectId {
            query!.whereKey("user", equalTo: game["user2"]!)
        } else {
            query!.whereKey("user", equalTo: game["user"]!)
        }
        
        push.setQuery(query)
        push.setData(data as [NSObject : AnyObject])
        push.sendPushInBackground()
    }
    
    class func gameFinishedNotification(game : PFObject, content : String) {
        let push = PFPush()
        let query = PFInstallation.query()
        
        let data : NSDictionary = ["alert": "\(content)", "badge":"1", "content-available":"1", "sound":"default"]
        query!.whereKey("channels", equalTo: "gameNotification")
        
        if game["user"]!.objectId == PFUser.currentUser()!.objectId {
            query!.whereKey("user", equalTo: game["user2"]!)
        } else {
            query!.whereKey("user", equalTo: game["user"]!)
        }
        
        push.setQuery(query)
        push.setData(data as [NSObject : AnyObject])
        push.sendPushInBackground()
    }
    
    class func restartBattleNotification(weekBattle : PFObject) {
        let push = PFPush()
        let query = PFInstallation.query()
        
        var oppName = ""
        let oppFullName = (PFUser.currentUser()!["fullName"] as! NSString).componentsSeparatedByString(" ") as NSArray
//        let oppFullName : NSArray = ["Opponent", "lastName"]
        let lastName = oppFullName.lastObject as! String
        let lastLetter = lastName[lastName.startIndex]
        
        oppName = "\(oppFullName[0]) \(lastLetter)."
        
        let data : NSDictionary = ["alert": "\(oppName) is challenging you for another Battle!", "badge":"1", "content-available":"1", "sound":"default"]
        query!.whereKey("channels", equalTo: "gameNotification")
        
        if weekBattle["user"]!.objectId == PFUser.currentUser()!.objectId {
            query!.whereKey("user", equalTo: weekBattle["user2"]!)
        } else {
            query!.whereKey("user", equalTo: weekBattle["user"]!)
        }
        
        push.setQuery(query)
        push.setData(data as [NSObject : AnyObject])
        push.sendPushInBackground()
    }
    
    class func testPushNotification() {
//        let push = PFPush()
        let query = PFInstallation.query()
//
//        let data : NSDictionary = ["alert": "This is a test push", "badge":"1", "content-available":"1", "sound":"default"]
//    
        query!.whereKey("user", equalTo: "Gma8HGEqkj")
//        query!.whereKey("useMasterKey", equalTo: "true")
//        
//        push.setQuery(query)
//        push.setData(data as [NSObject : AnyObject])
//        
//        print(push)
//        print(data)
        print("jeej")
//        print(query.inspe)
//        push.sendPushInBackground()
//        PFCloud.callFunctionInBackground("testPush", withParameters: ["where": query!, "data": "Testing"])
        
        PFCloud.callFunctionInBackground("testPush", withParameters: ["data": "Testing"]){
            (result, error) -> Void in
            if error == nil {
                print(result)
                // status will be 400
                // text will be "Missing Name"
            } else {
                print("error")
                print(error)
                // handle Parse.com's 141s
            }
        }
        
//        PFCloud.callFunctionInBackground("testPush", withParameters: ["message": message],
    }
}