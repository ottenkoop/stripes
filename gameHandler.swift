//
//  gameHandler.swift
//  Stripes
//
//  Created by Koop Otten on 27/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class gameHandler {
    private var gameBoardView = gameView(gameControl: UIViewController())
    
    private var submitBtn = UIButton()
    
    var localGameBoard = Board(dimension: 0)
    var userBoard = Board(dimension: 0)
    var opponentBoard = Board(dimension: 0)
    
    var gameObject : PFObject = PFObject(className: "currentGame")
    var gridDimension : Int = 0
    
    init (gameBoardV: gameView, localBoard : Board, uBoard : Board, oppBoard : Board, dimension : Int, submitButton : UIButton) {
        gameBoardView = gameBoardV
        
        localGameBoard = localBoard
        userBoard = uBoard
        opponentBoard = oppBoard
        gameObject = Game.currentGame()
        
        gridDimension = dimension
        submitBtn = submitButton
    }
    
    func placeStripeAndSavePoint(stripeToSubmit : UIButton, doubleStripeToSubmit : UIButton, scoredSquares : [UIView], specialUsed : Bool) {
        let rowIndex = stripeToSubmit.superview!.superview!.tag
        let squareIndex = stripeToSubmit.superview!.tag
        let userIsTakingOverOpponentSquare = false
        
        userBoard.placeStripe(rowIndex, y: squareIndex, stripe: gameBoardView.position[stripeToSubmit]!)
        localGameBoard.placeStripe(rowIndex, y: squareIndex, stripe: gameBoardView.position[stripeToSubmit]!)

        // save new userBoard and square
        var squareObjects : [[String : AnyObject]] = [[String : AnyObject]]()
        
        for square in scoredSquares {
            if specialUsed {
                square.subviews[4].removeFromSuperview()

                var squaresBackend = gameObject["allScoredSquares"] as! [[String:AnyObject]]
                
                for (index,scoredSquare) in squaresBackend.enumerate() {
                    if scoredSquare["rowIndex"] as! Int == square.superview!.tag && scoredSquare["squareIndex"] as! Int == square.tag {
                        squaresBackend.removeAtIndex(index)
                    }
                }
             
                gameObject["allScoredSquares"] = squaresBackend
            }
            
            
            let squareObjectToSave = Game.createSquareObject(square.superview!.tag, squareIndex: square.tag)
            squareObjects += [squareObjectToSave]
            gameBoardView.addSquareBackgroundImage(square, content: "fullSquareBlue")
        }
        
        if doubleStripeToSubmit.superview != nil {
            if specialUsed && userIsTakingOverOpponentSquare {
                opponentBoard.removeStripe(doubleStripeToSubmit.superview!.superview!.tag, y: doubleStripeToSubmit.superview!.tag, stripe: gameBoardView.position[doubleStripeToSubmit]!)
            }
            
            userBoard.placeStripe(doubleStripeToSubmit.superview!.superview!.tag, y: doubleStripeToSubmit.superview!.tag, stripe: gameBoardView.position[doubleStripeToSubmit]!)
            localGameBoard.placeStripe(doubleStripeToSubmit.superview!.superview!.tag, y: doubleStripeToSubmit.superview!.tag, stripe: gameBoardView.position[doubleStripeToSubmit]!)
        }
        
        gameBoardView.colorSelectedStripes(rowIndex, squareIdx: squareIndex, stripe: stripeToSubmit, boardObject: userBoard, userBoard: true)
        
        if specialUsed {
            opponentBoard.removeStripe(rowIndex, y: squareIndex, stripe: gameBoardView.position[stripeToSubmit]!)
            
            if (gameObject["user"] as! PFUser).objectId == PFUser.currentUser()!.objectId {
                var specialsLeft = gameObject["userSpecialsLeft"] as! Int
                specialsLeft -= 1
                gameObject["userSpecialsLeft"] = specialsLeft
            } else {
                var specialsLeft = gameObject["opponentSpecialsLeft"] as! Int
                specialsLeft -= 1
                gameObject["opponentSpecialsLeft"] = specialsLeft
            }
        }
        
        var pointsArray = gameBoardView.updateGameBoardPoints(gameObject["allScoredSquares"] as! [[String : AnyObject]], newScoredSquaresArray: squareObjects, uBoard : userBoard, oppBoard: opponentBoard)
        
        let gameToSave = Game.saveSquare(gameObject, squaresArray: squareObjects, userPoints: pointsArray[0], oppPoints: pointsArray[1], userBoard: userBoard, oppBoard: opponentBoard)
        
        gameToSave.saveInBackgroundWithBlock {
            (succes: Bool, err: NSError?) -> Void in
            
            if succes {
                self.gameBoardView.removeStylingWhenSubmit(stripeToSubmit, points: squareObjects.count)
                self.checkifGameIsFinished()
            }
        }
    }
    
    func placeStripeAndSwitchUserTurn(stripeToSubmit : UIButton, doubleStripeToSubmit : UIButton, specialUsed : Bool) {
        userBoard.placeStripe(stripeToSubmit.superview!.superview!.tag, y: stripeToSubmit.superview!.tag, stripe: gameBoardView.position[stripeToSubmit]!)
        
        if doubleStripeToSubmit.superview != nil {
            userBoard.placeStripe(doubleStripeToSubmit.superview!.superview!.tag, y: doubleStripeToSubmit.superview!.tag, stripe: gameBoardView.position[doubleStripeToSubmit]!)
        }
        
        if specialUsed {
            opponentBoard.removeStripe(stripeToSubmit.superview!.superview!.tag, y: stripeToSubmit.superview!.tag, stripe: gameBoardView.position[stripeToSubmit]!)
            
            if doubleStripeToSubmit.superview != nil {
                opponentBoard.removeStripe(doubleStripeToSubmit.superview!.superview!.tag, y: doubleStripeToSubmit.superview!.tag, stripe: gameBoardView.position[doubleStripeToSubmit]!)
            }
            
            if (gameObject["user"] as! PFUser).objectId == PFUser.currentUser()!.objectId {
                var specialsLeft = gameObject["userSpecialsLeft"] as! Int
                specialsLeft -= 1
                gameObject["userSpecialsLeft"] = specialsLeft
            } else {
                var specialsLeft = gameObject["opponentSpecialsLeft"] as! Int
                specialsLeft -= 1
                gameObject["opponentSpecialsLeft"] = specialsLeft
            }
        }
        
        let gameToSave = Game.updateUserGameBoardAndSwitchUserTurn(gameObject, userBoard: userBoard, oppBoard: opponentBoard, lastStripe: stripeToSubmit)
        
        gameToSave.saveInBackgroundWithBlock {
            (succeeded: Bool, err: NSError?) -> Void in
            if succeeded {
                NSNotificationCenter.defaultCenter().postNotificationName("deleteObjectFromYourTurnSection", object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("popViewController", object: nil)
            }
        }
    }
    
    func checkifGameIsFinished() {
        if userBoard.isGameFinished(userBoard, opBoard: opponentBoard, dimension: gridDimension) {
            // game finished, send notification to gameController.
            NSNotificationCenter.defaultCenter().postNotificationName("gameHasFinished", object: nil)
        }
    }
    
    func gameFinished(button : UIButton!) {
        print(gameObject["finished"] as! Bool ? "ja" : "neeeee hoor")
        
        if gameObject["finished"] as! Bool == true {
            var nextGrid = [3, 4]
            nextGrid.removeObject(gameObject["grid"] as! Int)

            Game.resetGame(nextGrid[0] as Int, game: gameObject)
            
            print("true")
            
            
            gameObject.saveInBackgroundWithBlock {
                (succeeded: Bool, err: NSError?) -> Void in
                if succeeded {
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("popViewController", object: nil)
                }
            }
        } else {
            let oppFullName = (PFUser.currentUser()!["fullName"] as! NSString).componentsSeparatedByString(" ") as NSArray
            print(oppFullName.firstObject as! String)
            
            let firstName = oppFullName.firstObject as! String
            
            var userWonGame : Int = 0

            if button.tag == 1 {
                pushNotificationHandler.gameFinishedNotification(gameObject, content: "You lost against \(firstName)! :( Try again.")
                userWonGame = 1
            } else if button.tag == 2 {
                pushNotificationHandler.gameFinishedNotification(gameObject, content: "You won against \(firstName)! Good job!")
                userWonGame = 2
            } else {
                pushNotificationHandler.gameFinishedNotification(gameObject, content: "It's a draw against \(firstName)! At least you didn't lose.")
                userWonGame = 0
            }
        
            let gameToSave = Game.gameFinished(gameObject, uWonGame: userWonGame)
            
            gameToSave.saveInBackgroundWithBlock {
                (succeeded: Bool, err: NSError?) -> Void in
                if succeeded {
                    NSNotificationCenter.defaultCenter().postNotificationName("deleteObjectFromYourTurnSection", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("popViewController", object: nil)
                }
            }
        }
    }
}