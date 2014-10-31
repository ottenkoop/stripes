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
}
