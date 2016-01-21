//
//  User.swift
//  Tiles-swift
//
//  Created by Koop Otten on 27/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class User: PFObject {
    
    class func requestFaceBookLoggedInUserInfo() {
        FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: true, completionHandler: { (session:FBSession!, state:FBSessionState, error:NSError!) -> Void in
            if (error==nil){
                FBRequest.requestForMe().startWithCompletionHandler({ (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                    
                    if (error==nil) {
                        let userInfo = result as! NSDictionary
                        let currentUser = PFUser.currentUser()!
                        
                        print(userInfo)
//
                        currentUser["email"] = userInfo.objectForKey("email") as! String
                        currentUser["fullName"] = userInfo.objectForKey("name") as! String
                        currentUser["fbId"] = userInfo.objectForKey("id") as! String
                        currentUser["gender"] = userInfo.objectForKey("gender") as! String
                        currentUser.saveInBackground()
                    } else {
                        print("error facebook info")
                    }
                })
            }
        })
    }
    
    class func updateUserFullName() {
        let user = PFUser.currentUser()!
        
        user["fullName"] = user["username"]
        PFUser.currentUser()!["fullName"] = user["username"]
        
        user.saveEventually()
        PFUser.currentUser()!.saveEventually()
    }
    
    class func findUser (opponentName : String) -> PFQuery {
        let opponentUser = PFUser.query()
        opponentUser!.whereKey("fullName", equalTo: "\(opponentName)")
        
        return opponentUser!
    }
    
    class func resetLookingForGame() {
        PFUser.currentUser()!.setObject(false, forKey: "lookingForGame")
        PFUser.currentUser()!.saveInBackground()
    }

}