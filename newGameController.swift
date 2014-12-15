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
    var specialsBtn = UIButton()
    var specialUsed : Bool = false
    
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
        addSpecialsBtn()
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
                specialsBtn.hidden = true
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
        if specialUsed {
            gameBoardView.removeSpecialAnimation()
        }
        
        var oldStripe = stripeToSubmit
        var oldDoubleStripe = doubleStripeToSubmit

        scoredSquaresArray = []
        doubleStripeToSubmit = UIButton()
        stripeToSubmit = stripe
        
        var doubleStripe = gameBoardView.selectDoubleStripe(stripeToSubmit)
        
        gameBoardView.selectCurrentStripe(stripe, oldStripe: oldStripe, doubleStripe: doubleStripe, oldDoubleStripe: oldDoubleStripe, submitBtn: submitBtn, specialUsed: specialUsed)
        
        if oldStripe.superview != nil {
            if opponentBoard.board[oldStripe.superview!.superview!.tag][oldStripe.superview!.tag].isStripeSelected(gameBoardView.position[oldStripe]!) != true && specialUsed {
                oldStripe.setImage(UIImage(named: "\(gameBoardView.position[oldStripe]!.rawValue)_stripeBackground"), forState: .Normal)
            }
        }
        
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
    
    func addSpecialsBtn() {
        
        gameBoardView.addSpecialsBtn(specialsBtn)
        specialsBtn.addTarget(self, action: "openSpecials:", forControlEvents: .TouchUpInside)
    }
    
    func openSpecials(button : UIButton!) {
        var specialsBtns = specialsPopup().openPopup(self.view)
        
        specialsBtns[0].addTarget(self, action: "special1Clicked:", forControlEvents: .TouchUpInside)
        specialsBtns[1].addTarget(self, action: "special2Clicked:", forControlEvents: .TouchUpInside)
        specialsBtns[2].addTarget(self, action: "cancelBtnClicked:", forControlEvents: .TouchUpInside)
    }
    
    func special1Clicked(button : UIButton!) {
        if stripeToSubmit.superview != nil {
            stripePressed(stripeToSubmit)
        }
        
        specialUsed = true
        specialsPopup().hidePopup(button)
        gameBoardView.special1BtnClicked(opponentBoard)
    }
    
    func special2Clicked(button : UIButton!) {
        let alert = UIAlertView(title: "", message: "Heb jij een leuk idee voor een special? Laat het me weten!", delegate: self, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    func cancelBtnClicked(button : UIButton!) {
        specialsPopup().hidePopup(button)
    }
    
    func placeStripeAndSavePoint() {
        specialsBtn.removeFromSuperview()
        GameHandler.placeStripeAndSavePoint(stripeToSubmit, doubleStripeToSubmit: doubleStripeToSubmit, scoredSquares : scoredSquaresArray, specialUsed: specialUsed)
        stripeToSubmit = UIButton()
        doubleStripeToSubmit = UIButton()
        gameBoardView.addSpecialsBtn(specialsBtn)
        specialUsed = false
    }
    
    func placeStripeAndSwitchUserTurn() {
        GameHandler.placeStripeAndSwitchUserTurn(stripeToSubmit, doubleStripeToSubmit: doubleStripeToSubmit, specialUsed: specialUsed)
        specialUsed = false
    }
    
    func popViewController() {        
        self.navigationController?.popViewControllerAnimated(true)
        loadingView().hideActivityIndicatorWhenReturning(self.view)

        self.navigationController?.navigationBarHidden = false
    }
    
    func gameHasFinished() {
        2.0.waitSecondsAndDo({
            if self.gameBoardView.userPoints > self.gameBoardView.opponentPoints {
                var winBtn = finishScreen().gameDidFinishWithCurrentUserWinner(self, userTurn: self.userTurn)
                winBtn.tag = 1
                winBtn.addTarget(self, action: "gameFinished:", forControlEvents: .TouchUpInside)
            } else if self.gameBoardView.userPoints < self.gameBoardView.opponentPoints {
                var lostBtn = finishScreen().gameDidFinishWithOpponentWinner(self, userTurn: self.userTurn)
                lostBtn.tag = 2
                lostBtn.addTarget(self, action: "gameFinished:", forControlEvents: .TouchUpInside)
            } else {
                var drawBtn = finishScreen().gameDidFinishDraw(self, userTurn: self.userTurn)
                drawBtn.tag = 3
                drawBtn.addTarget(self, action: "gameFinished:", forControlEvents: .TouchUpInside)
            }
        })
    }
    
    func gameFinished(button : UIButton!) {
        GameHandler.gameFinished(button)
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameHasFinished", name: "gameHasFinished", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "popViewController", name: "popViewController", object: nil)
    }
}
