//
//  User.swift
//  Tiles-swift
//
//  Created by Koop Otten on 27/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class User: PFObject {
    
    class func addUserToParse(user : FBGraphUser) {
        
        var newUser = PFUser()
        
        newUser.username = "\(user.name)"
        newUser.password = "facebook"
        newUser["userId"] = "\(user.objectID)"
        newUser["faceBookLogin"] = true
        
        newUser.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            if error == nil {
                // Hooray! Let them use the app now.
                
            } else if error.code == 202 {
                PFUser.logInWithUsernameInBackground("\(user.name)", password:"facebook") {
                    (user: PFUser!, error: NSError!) -> Void in
                    if user != nil {
                        // Do stuff after successful login.
                    } else {
                        // The login failed. Check error to see why.
                    }
                }
            } else {
                println(error)
            }
        }
    }
    
    class func requestFaceBookLoggedInUserInfo() {
        var completionHandler = {
            connection, result, error in

            if error == nil {
                PFUser.currentUser().setObject(result.name, forKey: "fullName")
                PFUser.currentUser().saveInBackgroundWithBlock ({
                    (succeeded: Bool!, err: NSError!) -> Void in
                    println(err)
                })
            }

            } as FBRequestHandler
        
        FBRequestConnection.startWithGraphPath(
            "me", completionHandler: completionHandler
        );
    }
    
    class func findUser (opponentName : String) -> PFQuery {
        var opponentUser = PFUser.query()
        opponentUser.whereKey("fullName", equalTo: "\(opponentName)")
        
        return opponentUser
    }
    
    class func userResignedGame(game : PFObject) {
        var query = PFInstallation.query()
        var push = PFPush()
        var userFullName: NSString = PFUser.currentUser()["fullName"] as NSString
        
        var data : NSDictionary = ["alert": "\(userFullName) resigned!", "badge":"0", "content-available":"1", "sound":"default"]
        
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