//class selectedStripe: PFObject {
//    dynamic var stripeId = ""
//    
//}

var currentGame : PFObject!
var gamesListOverview : [PFObject] = [PFObject]()

class Game: PFObject {
    
    class func addGame(opponent : PFUser, gameWithSpecials : Bool, grid : Int) {
        let game = PFObject(className:"Game")
        
        game["user"] = PFUser.currentUser()
        game["user2"] = opponent
        game["gameWithSpecials"] = gameWithSpecials
        game["userPoints"] = 0
        game["opponentPoints"] = 0
        game["userSpecialsLeft"] = 2
        game["opponentSpecialsLeft"] = 2
        game["userFullName"] = PFUser.currentUser()!["fullName"]
        game["user2FullName"] = opponent["fullName"]
        game["userOnTurn"] = PFUser.currentUser()
        game["grid"] = grid
        game["allScoredSquares"] = []
        game["userBoard"] = []
        game["opponentBoard"] = []
        game["lastStripe"] = []
        game["finished"] = false

        game.saveInBackgroundWithBlock {
            (succeeded: Bool, err: NSError?) -> Void in
            if succeeded {
                NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
            }
        }
    }
    
    class func resetGame(grid : Int, game : PFObject) -> PFObject {
        //        var board = Board(dimension: grid)
        
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
        
        return game
    }
    
    class func saveSquare(game : PFObject, squaresArray : NSArray, userPoints : Int, oppPoints : Int, userBoard : Board, oppBoard : Board) -> PFObject {
        var newArrayToSave : [AnyObject] = []
        let userBoardArray = userBoard.toString(userBoard.board)
        let opponentBoardArray = oppBoard.toString(oppBoard.board)
    
        if game["user"]!.objectId == PFUser.currentUser()!.objectId {
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
        
        for square in game["allScoredSquares"] as! NSArray {
            newArrayToSave += [square]
        }
        
        for newSquare in squaresArray as NSArray {
            newArrayToSave += [newSquare]
        }
        
        game["allScoredSquares"] = newArrayToSave
        
        return game
    }
    
    class func createSquareObject(rowIndex : Int, squareIndex : Int) -> [String : AnyObject] {
        var objectToReturn = [String: AnyObject]()
        
        objectToReturn["rowIndex"] = rowIndex
        objectToReturn["squareIndex"] = squareIndex
        objectToReturn["userId"] = PFUser.currentUser()!.objectId
        
        return objectToReturn
    }
    
    class func updateUserGameBoardAndSwitchUserTurn(game : PFObject, userBoard : Board, oppBoard : Board, lastStripe : UIButton) -> PFObject {
        let lastStripeObject = stripeHandler.createStripeObject(lastStripe.superview!.superview!.tag, squareIndex: lastStripe.superview!.tag, stripeIndex: lastStripe.tag)
        
        let userBoardArray = userBoard.toString(userBoard.board)
        let oppBoardArray = oppBoard.toString(oppBoard.board)
        var opponentUser = PFUser()
        var firstStripe = Bool()

        if game["userBoard"] as! NSObject == [] {
            firstStripe = true
        } else {
            firstStripe = false
        }

        if game["user"]!.objectId == PFUser.currentUser()!.objectId {
            game["userBoard"] = userBoardArray as [[Int]]
            game["opponentBoard"] = oppBoardArray as [[Int]]
            opponentUser = game["user2"] as! PFUser
        } else {
            game["opponentBoard"] = userBoardArray as [[Int]]
            game["userBoard"] = oppBoardArray as [[Int]]
            opponentUser = game["user"] as! PFUser
        }
        
        game["lastStripe"] = [lastStripeObject]
        game["userOnTurn"] = opponentUser
        
        if firstStripe {
            pushNotificationHandler.sendNewGameNotification(opponentUser as PFUser)
        } else {
            pushNotificationHandler.sendUserTurnNotification(opponentUser as PFUser)
        }
        
        return game
    }
    
    class func gameFinished(game : PFObject, uWonGame : Int) -> PFObject {
        if game["user"]!.objectId == PFUser.currentUser()!.objectId {
            game["userOnTurn"] = game["user2"]
            game["finished"] = true
            game["lastStripe"] = []
            
            if uWonGame == 1 {
                var points = game["userPoints"] as! Int
                points += 1
                game["userPoints"] = points
            } else if uWonGame == 2 {
                var points = game["opponentPoints"] as! Int
                points += 1
                game["opponentPoints"] = points
            }
            
        } else {
            game["userOnTurn"] = game["user"]
            game["finished"] = true
            game["lastStripe"] = []
            
            if uWonGame == 1 {
                var points = game["opponentPoints"] as! Int
                points += 1
                game["opponentPoints"] = points
            } else if uWonGame == 2 {
                var points = game["userPoints"] as! Int
                points += 1
                game["userPoints"] = points
            }
        }
        
        return game
    }
    
    class func getOpponentWhichIsNotYetActiveInAnotherGameAgaintUser(usersLookingForGame : NSArray) -> NSArray {
        for opp in usersLookingForGame {
            let gameExists = searchModule.checkIfGameAlreadyExcists(opp as! PFUser)
            
            if !(gameExists) {
                return [opp]
            } else if ((opp as! PFUser == usersLookingForGame.lastObject as! PFUser) && opp as! PFUser == PFUser.currentUser()!) {
                return []
            }
        }
        
        return []
    }
    
}
