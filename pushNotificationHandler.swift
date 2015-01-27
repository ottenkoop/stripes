//
//  pushNotificationHandler.swift
//  Stripes
//
//  Created by Koop Otten on 17/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class pushNotificationHandler: PFObject {
    
    class func sendUserTurnNotification(opponent : PFUser) {
        var query = PFInstallation.query()
        var push = PFPush()
        
        var oppName = ""
        var oppFullName = (PFUser.currentUser()["fullName"] as NSString).componentsSeparatedByString(" ") as NSArray
        var lastName = oppFullName.lastObject as String
        var lastLetter = lastName[lastName.startIndex]
        
        oppName = "\(oppFullName[0]) \(lastLetter)."
        
        var data : NSDictionary = ["alert": "It's your turn against \(oppName)!", "badge":"1", "content-available":"1", "sound":"default"]
        
        query.whereKey("channels", equalTo: "gameNotification")
        query.whereKey("user", equalTo: opponent)
        
        push.setQuery(query)
        push.setData(data)
        push.sendPush(nil)
    }
    
    class func sendNewGameNotification(user : PFUser) {
        var query = PFInstallation.query()
        var push = PFPush()
        
        var oppName = ""
        var oppFullName = (PFUser.currentUser()["fullName"] as NSString).componentsSeparatedByString(" ") as NSArray
        var lastName = oppFullName.lastObject as String
        var lastLetter = lastName[lastName.startIndex]
        
        oppName = "\(oppFullName[0]) \(lastLetter)."
        
        var data : NSDictionary = ["alert": "\(oppName) has challenged you to play a game!", "badge":"1", "content-available":"1", "sound":"default"]
        
        query.whereKey("channels", equalTo: "gameNotification")
        query.whereKey("user", equalTo: user)
        
        push.setQuery(query)
        push.setData(data)
        push.sendPush(nil)
    }
    
    class func userResignedGame(game : PFObject) {
        var push = PFPush()
        var query = PFInstallation.query()
        var oppName = ""
        var oppFullName = (PFUser.currentUser()["fullName"] as NSString).componentsSeparatedByString(" ") as NSArray
        var lastName = oppFullName.lastObject as String
        var lastLetter = lastName[lastName.startIndex]
        
        oppName = "\(oppFullName[0]) \(lastLetter)."
        
        var data : NSDictionary = ["alert": "\(oppName) resigned!", "badge":"0", "content-available":"1", "sound":"default"]
        
        query.whereKey("channels", equalTo: "gameNotification")
        
        if game["user"].objectId == PFUser.currentUser().objectId {
            query.whereKey("user", equalTo: game["user2"])
        } else {
            query.whereKey("user", equalTo: game["user"])
        }
        
        push.setQuery(query)
        push.setData(data)
        push.sendPush(nil)
    }
    
    class func gameFinishedNotification(game : PFObject, content : String) {
        var push = PFPush()
        var query = PFInstallation.query()
        
        var data : NSDictionary = ["alert": "\(content)", "badge":"1", "content-available":"1", "sound":"default"]
        query.whereKey("channels", equalTo: "gameNotification")
        
        if game["user"].objectId == PFUser.currentUser().objectId {
            query.whereKey("user", equalTo: game["user2"])
        } else {
            query.whereKey("user", equalTo: game["user"])
        }
        
        push.setQuery(query)
        push.setData(data)
        push.sendPush(nil)
    }
}