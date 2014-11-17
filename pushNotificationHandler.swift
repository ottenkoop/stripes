//
//  pushNotificationHandler.swift
//  Stripes
//
//  Created by Koop Otten on 17/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class pushNotificationHandler: PFObject {
    
    class func sendNewGameNotification() {
        
    }
    
    class func sendNewGameNotification(user : PFUser) {
        var query = PFInstallation.query()
        var push = PFPush()
        var userFullName: NSString = PFUser.currentUser()["fullName"] as NSString
        var data : NSDictionary = ["alert": "\(userFullName) has challenged you to play a game!", "badge":"1", "content-available":"1", "sound":"default"]
        
        query.whereKey("channels", equalTo: "gameNotification")
        query.whereKey("user", equalTo: user)
        
        push.setQuery(query)
        push.setData(data)
        push.sendPush(nil)
    }
}