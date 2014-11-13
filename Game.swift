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

        sendNewGameNotification(user[0] as PFUser)
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
        
        game.saveInBackgroundWithBlock(nil)
    }
    
    class func createSquareObject(rowIndex : Int, squareIndex : Int) -> NSObject {
        var objectToReturn = [String: AnyObject]()
        
        objectToReturn["rowIndex"] = rowIndex
        objectToReturn["squareIndex"] = squareIndex
        objectToReturn["userId"] = PFUser.currentUser().objectId
        
        return objectToReturn
    }
    
    class func switchTurnToOtherUserAndSaveStripe(game : PFObject, rowIndex : Int, squareIndex : Int, stripeIndex : Int) -> PFObject {
        var fullName: NSString = PFUser.currentUser()["fullName"] as NSString
        var stripeObject = stripeHandler.createStripeObject(rowIndex, squareIndex: squareIndex, stripeIndex: stripeIndex)

        var query = PFInstallation.query()
        query.whereKey("channels", equalTo: "gameNotification")
        
        if game["user"].objectId == PFUser.currentUser().objectId {
            game["userOnTurn"] = game["user2"]
            query.whereKey("user", equalTo: game["user2"])
        } else {
            game["userOnTurn"] = game["user"]
            query.whereKey("user", equalTo: game["user"])
        }
        
        var newArrayToSubmit : [AnyObject] = []
        
        for alreadyPlayedStripe in game["allStripes"] as NSArray {
            newArrayToSubmit += [alreadyPlayedStripe]
        }
        
        newArrayToSubmit += [stripeObject]
        
        game["allStripes"] = newArrayToSubmit
        
        var push = PFPush()
        var data : NSDictionary = ["alert": "It's your turn against \(fullName)", "badge":"1", "content-available":"1", "sound":"default"]
        
        push.setQuery(query)
        push.setData(data)
        push.sendPush(nil)
    
        return game
    }
    
    class func sendNewGameNotification(user : PFUser) {
        var query = PFInstallation.query()
        var push = PFPush()
        var userFullName: NSString = PFUser.currentUser()["fullName"] as NSString
        var data : NSDictionary = ["alert": "\(userFullName) has challenged you to play a game!", "badge":"1", "content-available":"1", "sound":"default"]
        
        query.whereKey("channels", equalTo: "gameNotification")
        query.whereKey("user", equalTo: user)
        
        push.setQuery(query)
        push.setData(data)
        push.sendPush(nil)
    }
    
    class func deleteGameAndSendNotification(game : PFObject) {
        var query = PFInstallation.query()
        var push = PFPush()
        var userFullName: NSString = PFUser.currentUser()["fullName"] as NSString
        var data : NSDictionary = ["alert": "You lost against \(userFullName)! :( Try again!", "badge":"0", "content-available":"1", "sound":"default"]

        query.whereKey("channels", equalTo: "gameNotification")
        
        if game["user"].objectId == PFUser.currentUser().objectId {
            query.whereKey("user", equalTo: game["user2"])
        } else {
            query.whereKey("user", equalTo: game["user"])
        }

        push.setQuery(query)
        push.setData(data)
        push.sendPush(nil)
        
        game.deleteInBackgroundWithBlock(nil)
    }
    
}
