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
    
    class func resetGame(grid : Int, game : PFObject) -> PFObject {
        var board = Board(dimension: grid)
        
        game["userBoard"] = []
        game["opponentBoard"] = []
        game["grid"] = grid
        game["lastStripe"] = []
        game["finished"] = false
        game["userPoints"] = 0
        game["opponentPoints"] = 0
//        game["userOnTurn"] = PFUser.currentUser()
        game["userSpecialsLeft"] = 2
        game["opponentSpecialsLeft"] = 2
        game["allScoredSquares"] = []
        
        return game
    }
    
    class func resetWeekBattle(weekBattle : PFObject, game: PFObject) {
        var newGame = resetGame(3, game: game)
        
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