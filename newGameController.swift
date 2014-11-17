//
//  newGameController.swift
//  Stripes
//
//  Created by Koop Otten on 13/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class newGameController: UIViewController {
    private var gameBoardView = gameView(gameControl: UIViewController(), dimension: 0, gameObj: [AnyObject]())
    private var submitBtn = UIButton()
    var gameObject : [PFObject] = []
    
    var gridDimension : Int = 0
    var userBoard = Board(dimension: 0)
    var opponentBoard = Board(dimension: 0)
    
    var stripeToSubmit : UIButton = UIButton()
    
    var userScoredAPoint : Bool = false
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.whiteColor()
        gridDimension = gameObject[0]["grid"] as Int
        
        gameBoardView = gameView(gameControl: self, dimension: gridDimension, gameObj: gameObject)
        
        buildGame()
        addSubmitBtn()
    }
    
    func buildGame() {
        gameBoardView.addGameBoard()
        userBoard = Board(dimension: gridDimension)
        opponentBoard = Board(dimension: gridDimension)
        
        loadSquaresFromBackEnd()

        for (rowIndex, row) in enumerate(userBoard.board) {
            addRow(rowIndex, row: row)
        }
    }
    
    func loadSquaresFromBackEnd() {
        if gameObject[0]["user"].objectId == PFUser.currentUser().objectId {
            userBoard.loadSquareFromBackend(gameObject[0]["userBoard"] as [[Int]])
            opponentBoard.loadSquareFromBackend(gameObject[0]["opponentBoard"] as [[Int]])
        } else {
            userBoard.loadSquareFromBackend(gameObject[0]["opponentBoard"] as [[Int]])
            opponentBoard.loadSquareFromBackend(gameObject[0]["userBoard"] as [[Int]])
        }
    }
    
    func addRow(rowIndex : Int, row : NSArray) {
        gameBoardView.addRow(rowIndex)
        
        for (squareIndex, square) in enumerate(row) {
            addSquare(rowIndex, squareIndex: squareIndex, square: square as Square)
        }
    }
    
    func addSquare(rowIndex : Int, squareIndex : Int, square : Square) {
        var squareView = gameBoardView.addSquare(rowIndex, squareIndex: squareIndex)
        var buttonsPerSquare = [0,1,2,3]
        
        for stripeIndex in buttonsPerSquare {
            var stripe = gameBoardView.addStripe(stripeIndex, square: squareView)
            
            stripe.addTarget(self, action: "stripePressed:", forControlEvents: .TouchUpInside)
            stripe.tag = stripeIndex
            
            gameBoardView.colorSelectedStripes(rowIndex, squareIdx: squareIndex, stripe: stripe, boardObject: userBoard, userBoard: true)
            gameBoardView.colorSelectedStripes(rowIndex, squareIdx: squareIndex, stripe: stripe, boardObject: opponentBoard, userBoard: false)
        }
        
//        gameBoardView.hideDoubleStripes()
    }
    
    func stripePressed(stripe : UIButton!) {
        var oldStripe = stripeToSubmit
        stripeToSubmit = stripe
        
        var doubleStripe = gameBoardView.selectDoubleStripe(stripeToSubmit)
        
        gameBoardView.currentSelectedStripe(stripe, oldStripe: oldStripe, doubleStripe: doubleStripe)

        checkIfUserIsAboutToScoreAPoint(stripeToSubmit)
        
        if stripeToSubmit.selected == false  {
            submitBtn.hidden = true
        } else {
            submitBtn.hidden = false
        }
    }
    
    func checkIfUserIsAboutToScoreAPoint(stripe : UIButton) {
        var selectedStripesInSquare = 0
        
        for stripe in stripe.superview!.subviews as [UIButton] {
            if stripe.selected {
                selectedStripesInSquare += 1
            }
        }
        
        if selectedStripesInSquare == 4 {
            userScoredAPoint = true
        }
    }
    
    func addSubmitBtn() {
        gameBoardView.addSubmitBtn(submitBtn)
        submitBtn.addTarget(self, action: "submitStripe", forControlEvents: .TouchUpInside)
    }
    
    func submitStripe() {
        gameBoardView.stylingWhenSubmittingStripe(submitBtn)
        userBoard.placeStripe(stripeToSubmit.superview!.superview!.tag, y: stripeToSubmit.superview!.tag, stripe: gameBoardView.position[stripeToSubmit]!)
        

        
        Game.updateUserGameBoard(gameObject[0], userBoard: userBoard)
    }
}
