//
//  gameHandler.swift
//  Stripes
//
//  Created by Koop Otten on 27/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class gameHandler {
    private var gameBoardView = gameView(gameControl: UIViewController(), dimension: 0, gameObj: [AnyObject]())
    
    private var submitBtn = UIButton()
    
    var localGameBoard = Board(dimension: 0)
    var userBoard = Board(dimension: 0)
    var opponentBoard = Board(dimension: 0)
    
    var gameObject : [PFObject] = []
    var gridDimension : Int = 0
    
    init (gameBoardV: gameView, localBoard : Board, uBoard : Board, oppBoard : Board, gameObj : [AnyObject], dimension : Int, submitButton : UIButton) {
        gameBoardView = gameBoardV
        
        localGameBoard = localBoard
        userBoard = uBoard
        opponentBoard = oppBoard
        gameObject = gameObj as [PFObject]
        
        gridDimension = dimension
        submitBtn = submitButton
    }
    
    func placeStripeAndSavePoint(stripeToSubmit : UIButton, doubleStripeToSubmit : UIButton, scoredSquares : [UIView]) {
        var rowIndex = stripeToSubmit.superview!.superview!.tag
        var squareIndex = stripeToSubmit.superview!.tag
        var userPointsToSave : Int = gameBoardView.updateUserPoints(scoredSquares.count)
        
        userBoard.placeStripe(rowIndex, y: squareIndex, stripe: gameBoardView.position[stripeToSubmit]!)
        localGameBoard.placeStripe(rowIndex, y: squareIndex, stripe: gameBoardView.position[stripeToSubmit]!)
        
        if doubleStripeToSubmit.superview != nil {
            userBoard.placeStripe(doubleStripeToSubmit.superview!.superview!.tag, y: doubleStripeToSubmit.superview!.tag, stripe: gameBoardView.position[doubleStripeToSubmit]!)
            localGameBoard.placeStripe(doubleStripeToSubmit.superview!.superview!.tag, y: doubleStripeToSubmit.superview!.tag, stripe: gameBoardView.position[doubleStripeToSubmit]!)
        }
        
        gameBoardView.colorSelectedStripes(rowIndex, squareIdx: squareIndex, stripe: stripeToSubmit, boardObject: userBoard, userBoard: true)
        
        // save new userBoard and square
        var squareObjects : [NSObject] = []
        
        for square in scoredSquares {
            gameBoardView.addSquareBackgroundImage(square, content: "fullSquareBlue")
            var squareObjectToSave = Game.createSquareObject(square.superview!.tag, squareIndex: square.tag)
            
            squareObjects += [squareObjectToSave]
        }
        
        var gameToSave = Game.saveSquare(gameObject[0], squaresArray: squareObjects, userPoints: userPointsToSave, userBoard: userBoard)
        
        gameToSave.saveInBackgroundWithBlock({(succeeded: Bool!, err: NSError!) -> Void in
            if succeeded != nil {
                self.gameBoardView.removeStylingWhenSubmit(stripeToSubmit)
                
                self.checkifGameIsFinished()
            }
        })
    }
    
    func placeStripeAndSwitchUserTurn(stripeToSubmit : UIButton, doubleStripeToSubmit : UIButton) {
        userBoard.placeStripe(stripeToSubmit.superview!.superview!.tag, y: stripeToSubmit.superview!.tag, stripe: gameBoardView.position[stripeToSubmit]!)
        
        if doubleStripeToSubmit.superview != nil {
            userBoard.placeStripe(doubleStripeToSubmit.superview!.superview!.tag, y: doubleStripeToSubmit.superview!.tag, stripe: gameBoardView.position[doubleStripeToSubmit]!)
        }
        
        var gameToSave = Game.updateUserGameBoardAndSwitchUserTurn(gameObject[0], userBoard: userBoard, lastStripe: stripeToSubmit)
        
        gameToSave.saveInBackgroundWithBlock({(succeeded: Bool!, err: NSError!) -> Void in
            if succeeded != nil {
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
        if gameObject[0]["finished"] as Bool == true {
            gameObject[0].deleteInBackgroundWithBlock({(succeeded: Bool!, err: NSError!) -> Void in
                if succeeded != nil {
                    NSNotificationCenter.defaultCenter().postNotificationName("popViewController", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
                }
            })
        } else {
            var name: AnyObject! = PFUser.currentUser()["fullName"]

            if button.tag == 1 {
                pushNotificationHandler.gameFinishedNotification(gameObject[0], content: "You lost against \(name)! :( Try again.")
            } else if button.tag == 2 {
                pushNotificationHandler.gameFinishedNotification(gameObject[0], content: "You won against \(name)! Good job!")
            } else {
                pushNotificationHandler.gameFinishedNotification(gameObject[0], content: "It's a draw against \(name)! At least you didn't lose.")
            }
            
            var gameToSave = Game.gameFinished(gameObject[0])
            
            gameToSave.saveInBackgroundWithBlock({(succeeded: Bool!, err: NSError!) -> Void in
                if succeeded != nil {
                    NSNotificationCenter.defaultCenter().postNotificationName("deleteObjectFromYourTurnSection", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("popViewController", object: nil)
                }
            })
        }
    }
}