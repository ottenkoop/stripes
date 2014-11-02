//class selectedStripe: PFObject {
//    dynamic var stripeId = ""
//    
//}

class Game: PFObject {
    
    class func addGame(opponentName : String, grid : Int) -> PFObject {
        var opponentQuery : PFQuery = User.findUser("\(opponentName)")
        
        var user = opponentQuery.findObjects()
        
        var game = PFObject(className:"Game")
        
        game["user"] = PFUser.currentUser()
        game["user2"] = user.first
        game["grid"] = grid
        
        game.saveInBackgroundWithBlock ({
            (succeeded: Bool!, err: NSError!) -> Void in
            println(err)
        })
        
        return game
    }
    
    class func userScoredAPoint(game : PFObject) {
        if PFUser.currentUser() == game["user"] as PFUser {
            var userPoints : Int = game["userPoints"] as Int
            userPoints += 1
            
            game["userPoints"] = userPoints
        } else {
            var user2Points : Int = game["user2Points"] as Int
            user2Points += 1
            
            game["user2Points"] = user2Points
        }
        
        game.saveInBackgroundWithBlock ({(succeeded: Bool!, err: NSError!) -> Void in println(succeeded) })
    }
}
