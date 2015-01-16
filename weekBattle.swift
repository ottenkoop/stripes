//
//  weekBattle.swift
//  Stripes
//
//  Created by Koop Otten on 15/01/15.
//  Copyright (c) 2015 KoDev. All rights reserved.
//


class weekBattle: PFObject {
    
    class func newBattle(newGame : PFObject) {
        var weekBattle = PFObject(className:"weekBattle")
        
        weekBattle["userFullName"] = PFUser.currentUser()["fullName"]
        weekBattle["user2FullName"] = newGame["user2FullName"]
        weekBattle["user"] = PFUser.currentUser()
        weekBattle["user2"] = newGame["user2"]
        weekBattle["userPoints"] = 0
        weekBattle["user2Points"] = 0
        weekBattle["currentGame"] = newGame
        weekBattle["userOnTurn"] = newGame["userOnTurn"]
        
        weekBattle.saveInBackgroundWithBlock({(succeeded: Bool!, err: NSError!) -> Void in
            if succeeded != nil {
                NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
            }
        })

    }
}