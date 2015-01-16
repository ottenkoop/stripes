//class selectedStripe: PFObject {
//    dynamic var stripeId = ""
//    
//}

class Game: PFObject {
    
    class func addGame(opponentName : String, grid : Int) {
        var game = PFObject(className:"Game")
        var board = Board(dimension: grid)
        
        var opponentUser = PFUser.query()
        opponentUser.whereKey("fullName", equalTo: "\(opponentName)")
        var user = opponentUser.findObjects()
        
        game["user"] = PFUser.currentUser()
        game["user2"] = user.first
        game["userPoints"] = 0
        game["opponentPoints"] = 0
        game["userSpecialsLeft"] = 2
        game["opponentSpecialsLeft"] = 2
        game["userFullName"] = PFUser.currentUser()["fullName"]
        game["user2FullName"] = opponentName
        game["userOnTurn"] = PFUser.currentUser()
        game["grid"] = grid
        game["allScoredSquares"] = []
        game["userBoard"] = []
        game["opponentBoard"] = []
        game["lastStripe"] = []
        game["finished"] = false

        game.saveInBackgroundWithBlock({(succeeded: Bool!, err: NSError!) -> Void in
            if succeeded != nil {
                weekBattle.newBattle(game)
            }
        })
    }
    
    class func saveSquare(game : PFObject, squaresArray : NSArray, userPoints : Int, oppPoints : Int, userBoard : Board, oppBoard : Board) -> PFObject {
        var newArrayToSave : [AnyObject] = []
        var userBoardArray = userBoard.toString(userBoard.board)
        var opponentBoardArray = oppBoard.toString(oppBoard.board)
    
        if game["user"].objectId == PFUser.currentUser().objectId {
            game["userPoints"] = userPoints
            game["opponentPoints"] = oppPoints
            
            game["userBoard"] = userBoardArray as [[Int]]
            game["opponentBoard"] = opponentBoardArray as [[Int]]
        } else {
            game["opponentPoints"] = userPoints
            game["userPoints"] = oppPoints
            
            game["opponentBoard"] = userBoardArray as [[Int]]
            game["userBoard"] = opponentBoardArray as [[Int]]
        }
        
        for square in game["allScoredSquares"] as NSArray {
            newArrayToSave += [square]
        }
        
        for newSquare in squaresArray as NSArray {
            newArrayToSave += [newSquare]
        }
        
        game["allScoredSquares"] = newArrayToSave
        
        return game
    }
    
    class func createSquareObject(rowIndex : Int, squareIndex : Int) -> NSObject {
        var objectToReturn = [String: AnyObject]()
        
        objectToReturn["rowIndex"] = rowIndex
        objectToReturn["squareIndex"] = squareIndex
        objectToReturn["userId"] = PFUser.currentUser().objectId
        
        return objectToReturn
    }
    
    class func updateUserGameBoardAndSwitchUserTurn(game : PFObject, weekBattle : PFObject, userBoard : Board, oppBoard : Board, lastStripe : UIButton) -> PFObject {
        var lastStripeObject = stripeHandler.createStripeObject(lastStripe.superview!.superview!.tag, squareIndex: lastStripe.superview!.tag, stripeIndex: lastStripe.tag)
        
        var userBoardArray = userBoard.toString(userBoard.board)
        var oppBoardArray = oppBoard.toString(oppBoard.board)
        var opponentUser = PFUser()
        var firstStripe = Bool()

        if game["userBoard"] as NSObject == [] {
            firstStripe = true
        } else {
            firstStripe = false
        }

        if game["user"].objectId == PFUser.currentUser().objectId {
            game["userBoard"] = userBoardArray as [[Int]]
            game["opponentBoard"] = oppBoardArray as [[Int]]
            opponentUser = game["user2"] as PFUser
        } else {
            game["opponentBoard"] = userBoardArray as [[Int]]
            game["userBoard"] = oppBoardArray as [[Int]]
            opponentUser = game["user"] as PFUser
        }
        
        game["lastStripe"] = [lastStripeObject]
        weekBattle["userOnTurn"] = opponentUser
        
        if firstStripe {
            pushNotificationHandler.sendNewGameNotification(opponentUser as PFUser)
        } else {
            pushNotificationHandler.sendUserTurnNotification(opponentUser as PFUser)
        }
        
        game.saveInBackgroundWithBlock(nil)
        
        return weekBattle
    }
    
    class func gameFinished(game : PFObject) -> PFObject {
        if game["user"].objectId == PFUser.currentUser().objectId {
            game["userOnTurn"] = game["user2"]
            game["finished"] = true
            game["lastStripe"] = []
        } else {
            game["userOnTurn"] = game["user"]
            game["finished"] = true
            game["lastStripe"] = []
        }
        
        return game
    }
}
