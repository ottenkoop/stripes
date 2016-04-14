//
//  weekBattle.swift
//  Stripes
//
//  Created by Koop Otten on 15/01/15.
//  Copyright (c) 2015 KoDev. All rights reserved.
//


class weekBattle: PFObject {
    
    class func newBattle(newGame : PFObject) {
        let weekBattle = PFObject(className:"weekBattle")
        
        weekBattle["userFullName"] = PFUser.currentUser()!["fullName"]
        weekBattle["user2FullName"] = newGame["user2FullName"]
        weekBattle["user"] = PFUser.currentUser()
        weekBattle["user2"] = newGame["user2"]
        weekBattle["userPoints"] = 0
        weekBattle["user2Points"] = 0
        weekBattle["currentGame"] = newGame
        weekBattle["userOnTurn"] = newGame["userOnTurn"]
        weekBattle["battleFinished"] = false
        
        weekBattle.saveInBackground()
        NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
        
//        weekBattle.saveInBackgroundWithBlock({(succeeded: Bool, err: NSError!) -> Void in
//            if succeeded {
//                NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
//            }
//        })
    }
    
    class func resetWeekBattle(weekBattle : PFObject, game: PFObject) {
//        _ = resetGame(3, game: game)
        
        weekBattle["userPoints"] = 0
        weekBattle["user2Points"] = 0
        weekBattle["userOnTurn"] = PFUser.currentUser()
        
        
        weekBattle.saveInBackgroundWithBlock {
            (succeeded: Bool, err: NSError?) -> Void in
            if succeeded {
                NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
            }
        }
    }
}