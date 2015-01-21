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
    
    class func resetGame(grid : Int, game : PFObject) {
        var board = Board(dimension: grid)
        
        game["userBoard"] = []
        game["opponentBoard"] = []
        game["grid"] = grid
        game["lastStripe"] = []
        game["finished"] = false
        game["userPoints"] = 0
        game["opponentPoints"] = 0
        game["userOnTurn"] = PFUser.currentUser()
        game["userSpecialsLeft"] = 2
        game["opponentSpecialsLeft"] = 2
        game["allScoredSquares"] = []
        
//        var game = PFObject(className:"Game")
//        var board = Board(dimension: grid)
//        var opponentUser = PFUser()
//        
//        if weekBattle["user"] as PFUser == PFUser.currentUser() {
//            var opponentUser = weekBattle["user2"] as PFUser
//        } else {
//            var opponentUser = weekBattle["user"] as PFUser
//        }
//
//        game["user"] = PFUser.currentUser()
//        game["user2"] = opponentUser
//        game["userPoints"] = 0
//        game["opponentPoints"] = 0
//        game["userSpecialsLeft"] = 2
//        game["opponentSpecialsLeft"] = 2
//        game["userFullName"] = PFUser.currentUser()["fullName"]
//        game["user2FullName"] = opponentUser["fullName"]
//        game["userOnTurn"] = PFUser.currentUser()
//        game["grid"] = grid
//        game["allScoredSquares"] = []
//        game["userBoard"] = []
//        game["opponentBoard"] = []
//        game["lastStripe"] = []
//        game["finished"] = false
//        
//        
//        game.saveInBackgroundWithBlock(nil)
//        
//        weekBattle["currentGame"] = game
//        weekBattle.saveInBackgroundWithBlock(nil)
    }
}