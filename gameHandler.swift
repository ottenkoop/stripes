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
    var weekBattleObject : [PFObject] = []
    var gridDimension : Int = 0
    
    init (gameBoardV: gameView, localBoard : Board, uBoard : Board, oppBoard : Board, weekB : [AnyObject], dimension : Int, submitButton : UIButton) {
        gameBoardView = gameBoardV
        
        localGameBoard = localBoard
        userBoard = uBoard
        opponentBoard = oppBoard
        gameObject = Game.currentGame()
        weekBattleObject = weekB as! [PFObject]
        
        gridDimension = dimension
        submitBtn = submitButton
    }
    
    func placeStripeAndSavePoint(stripeToSubmit : UIButton, doubleStripeToSubmit : UIButton, scoredSquares : [UIView], specialUsed : Bool) {
        var rowIndex = stripeToSubmit.superview!.superview!.tag
        var squareIndex = stripeToSubmit.superview!.tag
        var userIsTakingOverOpponentSquare = false
        
        userBoard.placeStripe(rowIndex, y: squareIndex, stripe: gameBoardView.position[stripeToSubmit]!)
        localGameBoard.placeStripe(rowIndex, y: squareIndex, stripe: gameBoardView.position[stripeToSubmit]!)

        // save new userBoard and square
        var squareObjects : [NSObject] = []
        
        for square in scoredSquares {
            if specialUsed {
                square.subviews[4].removeFromSuperview()

                var squaresBackend = gameObject["allScoredSquares"] as! [[String:AnyObject]]
                
                for (index,scoredSquare) in enumerate(squaresBackend) {
                    if scoredSquare["rowIndex"] as! Int == square.superview!.tag && scoredSquare["squareIndex"] as! Int == square.tag {
                        squaresBackend.removeAtIndex(index)
                    }
                }
             
                gameObject["allScoredSquares"] = squaresBackend
            }
            
            
            var squareObjectToSave = Game.createSquareObject(square.superview!.tag, squareIndex: square.tag)
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
            
            if (gameObject["user"] as! PFUser).objectId == PFUser.currentUser().objectId {
                var specialsLeft = gameObject["userSpecialsLeft"] as! Int
                specialsLeft -= 1
                gameObject["userSpecialsLeft"] = specialsLeft
            } else {
                var specialsLeft = gameObject["opponentSpecialsLeft"] as! Int
                specialsLeft -= 1
                gameObject["opponentSpecialsLeft"] = specialsLeft
            }
        }
        
        var pointsArray = gameBoardView.updateGameBoardPoints(gameObject["allScoredSquares"] as! [AnyObject], newScoredSquaresArray: squareObjects, uBoard : userBoard, oppBoard: opponentBoard)
        
        var gameToSave = Game.saveSquare(gameObject, squaresArray: squareObjects, userPoints: pointsArray[0], oppPoints: pointsArray[1], userBoard: userBoard, oppBoard: opponentBoard)
        
        gameToSave.saveInBackgroundWithBlock({(succeeded: Bool, err: NSError!) -> Void in
            if succeeded {
                self.gameBoardView.removeStylingWhenSubmit(stripeToSubmit, points: squareObjects.count)
                self.checkifGameIsFinished()
            }
        })
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
            
            if (gameObject["user"] as! PFUser).objectId == PFUser.currentUser().objectId {
                var specialsLeft = gameObject["userSpecialsLeft"] as! Int
                specialsLeft -= 1
                gameObject["userSpecialsLeft"] = specialsLeft
            } else {
                var specialsLeft = gameObject["opponentSpecialsLeft"] as! Int
                specialsLeft -= 1
                gameObject["opponentSpecialsLeft"] = specialsLeft
            }
        }
        
        var gameToSave = Game.updateUserGameBoardAndSwitchUserTurn(gameObject, weekBattle: weekBattleObject[0], userBoard: userBoard, oppBoard: opponentBoard, lastStripe: stripeToSubmit)
        
        gameToSave.saveInBackgroundWithBlock({(succeeded: Bool, err: NSError!) -> Void in
            if succeeded {
                NSNotificationCenter.defaultCenter().postNotificationName("popViewController", object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("deleteObjectFromYourTurnSection", object: nil)
            }
        })
    }
    
    func checkifGameIsFinished() {
        if userBoard.isGameFinished(userBoard, opBoard: opponentBoard, dimension: gridDimension) {
            // game finished, send notification to gameController.
            NSNotificationCenter.defaultCenter().postNotificationName("gameHasFinished", object: nil)
        }
    }
    
    func gameFinished(button : UIButton!) {
        if gameObject["finished"] as! Bool == true {
            var nextGrid = [3, 4]
            nextGrid.remove(gameObject["grid"] as! Int)

            weekBattle.resetGame(nextGrid[0] as Int, game: gameObject)
            
            gameObject.saveInBackgroundWithBlock({(succeeded: Bool, err: NSError!) -> Void in
                if succeeded {
                    NSNotificationCenter.defaultCenter().postNotificationName("popViewController", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
                }
            })
            
        } else {
            var oppName = ""
            var oppFullName = (PFUser.currentUser()["fullName"] as! NSString).componentsSeparatedByString(" ") as NSArray
            
            var lastName = oppFullName.lastObject as! String
            var lastLetter = lastName[lastName.startIndex]
            
            oppName = "\(oppFullName[0]) \(lastLetter)."
            
            var userWonGame : Int = 0

            if button.tag == 1 {
                pushNotificationHandler.gameFinishedNotification(gameObject, content: "You lost against \(oppName)! :( Try again.")
                userWonGame = 1
            } else if button.tag == 2 {
                pushNotificationHandler.gameFinishedNotification(gameObject, content: "You won against \(oppName)! Good job!")
                userWonGame = 2
            } else {
                pushNotificationHandler.gameFinishedNotification(gameObject, content: "It's a draw against \(oppName)! At least you didn't lose.")
                userWonGame = 0
            }
            
            weekBattleObject[0].saveInBackgroundWithBlock(nil)
            var gameToSave = Game.gameFinished(gameObject, weekBattle: weekBattleObject[0], uWonGame: userWonGame)
            
            gameToSave.saveInBackgroundWithBlock({(succeeded: Bool, err: NSError!) -> Void in
                if succeeded {
                    NSNotificationCenter.defaultCenter().postNotificationName("deleteObjectFromYourTurnSection", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("popViewController", object: nil)
                }
            })
        }
    }
}