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
//        TODO: FIX THIS
//        var completionHandler = {(
//            connection, result, error) in
//
//            if error == nil {
//                PFUser.currentUser()!.setObject(result.name, forKey: "fullName")
//                PFUser.currentUser()!.saveInBackground()
//            }
//        }
//        
//        FBRequestConnection.startWithGraphPath(
//            "me", completionHandler: completionHandler
//        );
    }
    
    class func updateUserFullName() {
        var user = PFUser.currentUser()!
        
        user["fullName"] = user["username"]
        PFUser.currentUser()!["fullName"] = user["username"]
        
        user.saveEventually()
        PFUser.currentUser()!.saveEventually()
    }
    
    class func findUser (opponentName : String) -> PFQuery {
        var opponentUser = PFUser.query()
        opponentUser!.whereKey("fullName", equalTo: "\(opponentName)")
        
        return opponentUser!
    }
    
    class func resetLookingForGame() {
        PFUser.currentUser()!.setObject(false, forKey: "lookingForGame")
        PFUser.currentUser()!.saveInBackground()
    }

}