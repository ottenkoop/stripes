//class selectedStripe: PFObject {
//    dynamic var stripeId = ""
//    
//}

class Game: PFObject {
    
    class func addGame(opponentName : String, grid : Int) -> PFObject {
        var game = PFObject(className:"Game")
        
        var opponentUser = PFUser.query()
        opponentUser.whereKey("fullName", equalTo: "\(opponentName)")
        var user = opponentUser.findObjects()
        
        game["user"] = PFUser.currentUser()
        game["user2"] = user.first
        game["grid"] = grid
        game["userPoints"] = 0
        game["user2Points"] = 0
        game["userFullName"] = PFUser.currentUser()["fullName"]
        game["user2FullName"] = opponentName
        game["userOnTurn"] = user.first
        game["allStripes"] = []
        game["allScoredSquares"] = []
        
        game.saveEventually()
        
        return game
    }
    
    class func addPointAndScoredSquareToUser(game : PFObject, rowIndex : Int, squareIndex : Int) {
        var squareObject = createSquareObject(rowIndex, squareIndex: squareIndex)
        var newArrayToSubmit : [AnyObject] = []
        
        if game["user"].objectId == PFUser.currentUser().objectId {
            var userPoints : Int = game["userPoints"] as Int
            userPoints += 1
            
            game["userPoints"] = userPoints
        } else {
            var user2Points : Int = game["user2Points"] as Int
            user2Points += 1
            
            game["user2Points"] = user2Points
        }
        
        for alreadyScoredSquares in game["allScoredSquares"] as NSArray {
            newArrayToSubmit += [alreadyScoredSquares]
        }
        
        newArrayToSubmit += [squareObject]
        
        game["allScoredSquares"] = newArrayToSubmit
        
        game.saveEventually()
    }
    
    class func createSquareObject(rowIndex : Int, squareIndex : Int) -> NSObject {
        var objectToReturn = [String: AnyObject]()
        
        objectToReturn["rowIndex"] = rowIndex
        objectToReturn["squareIndex"] = squareIndex
        objectToReturn["userId"] = PFUser.currentUser().objectId
        
        return objectToReturn
    }
    
    class func switchTurnToOtherUser(game : PFObject) -> PFObject {
        if game["user"].objectId == PFUser.currentUser().objectId {
            game["userOnTurn"] = game["user2"]
        } else {
            game["userOnTurn"] = game["user"]
        }
    
        return game
    }
}
