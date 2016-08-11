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
        let oppFullName = (PFUser.currentUser()!["fullName"] as! NSString).componentsSeparatedByString(" ") as NSArray
        let firstName = oppFullName.firstObject as! String
        
        let message =  "It's your turn against \(firstName)!"
        
        sendPush(message, recipientId: opponent.objectId!)
    }
    
    class func sendNewGameNotification(user : PFUser) {
        let oppFullName = (PFUser.currentUser()!["fullName"] as! NSString).componentsSeparatedByString(" ") as NSArray
        let firstName = oppFullName.firstObject as! String
        
        let message =  "\(firstName) has challenged you to play a game!"
        
        sendPush(message, recipientId: user.objectId!)
    }
    
    class func userResignedGame(game : PFObject) {
        let opp : PFUser = getOpponent(game)
        let oppFullName = (PFUser.currentUser()!["fullName"] as! NSString).componentsSeparatedByString(" ") as NSArray
        let firstName = oppFullName.firstObject as! String
        
        let message =  "\(firstName) resigned!"
        
        sendPush(message, recipientId: opp.objectId!)
    }
    
    class func gameFinishedNotification(game : PFObject, content : String) {
        let message =  "\(content)"
        let opp : PFUser = getOpponent(game)

        sendPush(message, recipientId: opp.objectId!)
    }
    
    class func restartBattleNotification(weekBattle : PFObject) {
        let opp : PFUser = getOpponent(weekBattle)
        let oppFullName = (PFUser.currentUser()!["fullName"] as! NSString).componentsSeparatedByString(" ") as NSArray
        let firstName = oppFullName.firstObject as! String
        
        let message =  "\(firstName) is challenging you for another Battle!"
        
        sendPush(message, recipientId: opp.objectId!)
    }
    
    class func testPushNotification() {
        let message = (PFUser.currentUser()!["fullName"] as! String) + " sends you a test push"
        let recipient : String = "Gma8HGEqkj"
        
        sendTestPush(message, recipientId: recipient)
    }
    
    class func sendPush(message: String, recipientId: String) {
        PFCloud.callFunctionInBackground("push", withParameters: ["message": message, "recipientId": recipientId]){
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
    }
    
    class func sendTestPush(message: String, recipientId: String) {
//        var data : [String: String] = [String: String]()
//        data["message"] = message
//        data["sound"] = "Default"
//        data["recipientId"] = recipientId
//        data["random-game"] = "true"
        
        let params = [
            "data": [
                "message": message,
                "sound":  "Default",
                "reciepientId": recipientId,
                "random-game": "true"
            ]
        ]
        
        print(params)
        
        PFCloud.callFunctionInBackground("testPush", withParameters: ["data": params]){
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
    }
    
    class func getOpponent(game : PFObject) -> PFUser {
        var opponent : PFUser = PFUser()
        if game["user"]!.objectId == PFUser.currentUser()!.objectId {
            opponent = game["user2"]! as! PFUser
        } else {
            opponent = game["user"]! as! PFUser
        }
        
        return opponent
    }
}