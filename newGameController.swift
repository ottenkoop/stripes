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
    private var GameHandler = gameHandler(gameBoardV: gameView(gameControl: UIViewController(), dimension: 0, gameObj: [AnyObject]()), localBoard: Board(dimension: 0), uBoard: Board(dimension: 0), oppBoard: Board(dimension: 0), gameObj: [AnyObject](), dimension: 0, submitButton: UIButton())

    var userTurn : Bool = false
    var gameObject : [PFObject] = []
    
    var gridDimension : Int = 0
    internal var localGameBoard = Board(dimension: 0)
    var userBoard = Board(dimension: 0)
    var opponentBoard = Board(dimension: 0)
    
    var submitBtn = UIButton()
    
    var stripeToSubmit : UIButton = UIButton()
    var doubleStripeToSubmit : UIButton = UIButton()
    var scoredSquaresArray : [UIView] = []
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gameBackground")!)

        addObservers()
        gridDimension = gameObject[0]["grid"] as Int
        gameBoardView = gameView(gameControl: self, dimension: gridDimension, gameObj: gameObject)
        
        buildGame()
        addSubmitBtn()
        GameHandler.checkifGameIsFinished()
    }
    
    func buildGame() {
        gameBoardView.addGameBoard()
        gameBoardView.addScoreBoard()
        
        localGameBoard = Board(dimension: gridDimension)
        userBoard = Board(dimension: gridDimension)
        opponentBoard = Board(dimension: gridDimension)
        
        GameHandler = gameHandler(gameBoardV: gameBoardView, localBoard: localGameBoard, uBoard: userBoard, oppBoard: opponentBoard, gameObj: gameObject, dimension: gridDimension, submitButton: submitBtn)
        
        loadSquaresFromBackEnd()

        for (rowIndex, row) in enumerate(userBoard.board) {
            addRow(rowIndex, row: row)
        }
        
        loadScoredSquares()
        selectLastPlayedStripe()
    }
    
    func loadSquaresFromBackEnd() {
        if gameObject[0]["user"].objectId == PFUser.currentUser().objectId {
            userBoard.loadSquareFromBackend(gameObject[0]["userBoard"] as [[Int]])
            opponentBoard.loadSquareFromBackend(gameObject[0]["opponentBoard"] as [[Int]])
        } else {
            userBoard.loadSquareFromBackend(gameObject[0]["opponentBoard"] as [[Int]])
            opponentBoard.loadSquareFromBackend(gameObject[0]["userBoard"] as [[Int]])
        }
        
        localGameBoard.loadSquareFromBackend(gameObject[0]["userBoard"] as [[Int]])
        localGameBoard.loadSquareFromBackend(gameObject[0]["opponentBoard"] as [[Int]])
    }
    
    func loadScoredSquares () {
        gameBoardView.giveColorToScoredSquares()
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
            
            if userTurn == false {
                stripe.userInteractionEnabled = false
            }
            
            gameBoardView.colorSelectedStripes(rowIndex, squareIdx: squareIndex, stripe: stripe, boardObject: userBoard, userBoard: true)
            gameBoardView.colorSelectedStripes(rowIndex, squareIdx: squareIndex, stripe: stripe, boardObject: opponentBoard, userBoard: false)
        }
        
        gameBoardView.hideDoubleStripes()
    }
    
    func selectLastPlayedStripe() {
        gameBoardView.selectLastPlayedStripe()
    }
    
    func stripePressed(stripe : UIButton!) {
        var oldStripe = stripeToSubmit
        var oldDoubleStripe = doubleStripeToSubmit
        
        doubleStripeToSubmit = UIButton()
        stripeToSubmit = stripe
        scoredSquaresArray = []
        
        var doubleStripe = gameBoardView.selectDoubleStripe(stripeToSubmit)
        
        gameBoardView.selectCurrentStripe(stripe, oldStripe: oldStripe, doubleStripe: doubleStripe, oldDoubleStripe: oldDoubleStripe, submitBtn: submitBtn)
        
        checkIfUserIsAboutToScoreAPoint(stripeToSubmit)
        
        if doubleStripe.superview != nil {
            checkIfUserIsAboutToScoreAPoint(doubleStripe)
            doubleStripeToSubmit = doubleStripe
        }
    }
    
    func checkIfUserIsAboutToScoreAPoint(stripe : UIButton) {
        if localGameBoard.board[stripe.superview!.superview!.tag][stripe.superview!.tag].isSquareGettingSelected(gameBoardView.position[stripe]!) {
            scoredSquaresArray += [stripe.superview!]
        }
    }
    
    func addSubmitBtn() {
        gameBoardView.addSubmitBtn(submitBtn)
        submitBtn.addTarget(self, action: "submitStripe", forControlEvents: .TouchUpInside)
    }
    
    func submitStripe() {
        gameBoardView.stylingWhenSubmittingStripe(submitBtn)
        
        if scoredSquaresArray.count > 0 {
            NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "placeStripeAndSavePoint", userInfo: nil, repeats: false)
        } else {
            NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "placeStripeAndSwitchUserTurn", userInfo: nil, repeats: false)
        }
    }
    
    func placeStripeAndSavePoint() {
        GameHandler.placeStripeAndSavePoint(stripeToSubmit, doubleStripeToSubmit: doubleStripeToSubmit, scoredSquares : scoredSquaresArray)
        stripeToSubmit = UIButton()
        doubleStripeToSubmit = UIButton()
    }
    
    func placeStripeAndSwitchUserTurn() {
        GameHandler.placeStripeAndSwitchUserTurn(stripeToSubmit, doubleStripeToSubmit: doubleStripeToSubmit)
    }
    
    func popViewController() {        
        self.navigationController?.popViewControllerAnimated(true)
        loadingView().hideActivityIndicator(self.view)

        self.navigationController?.navigationBarHidden = false
    }
    
    func gameHasFinished() {
        if gameBoardView.userPoints > gameBoardView.opponentPoints {
            var winBtn = finishScreen().gameDidFinishWithCurrentUserWinner(self, userTurn: userTurn)
            winBtn.tag = 1
            winBtn.addTarget(self, action: "gameFinished:", forControlEvents: .TouchUpInside)
        } else if gameBoardView.userPoints < gameBoardView.opponentPoints {
            var lostBtn = finishScreen().gameDidFinishWithOpponentWinner(self, userTurn: userTurn)
            lostBtn.tag = 2
            lostBtn.addTarget(self, action: "gameFinished:", forControlEvents: .TouchUpInside)
        } else {
            var drawBtn = finishScreen().gameDidFinishDraw(self, userTurn: userTurn)
            drawBtn.tag = 3
            drawBtn.addTarget(self, action: "gameFinished:", forControlEvents: .TouchUpInside)
        }
    }
    
    func gameFinished(button : UIButton!) {
        GameHandler.gameFinished(button)
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameHasFinished", name: "gameHasFinished", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "popViewController", name: "popViewController", object: nil)
    }
}
