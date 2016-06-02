//
//  newGameController.swift
//  Stripes
//
//  Created by Koop Otten on 13/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class gameEngineController: UIViewController {
    private var gameBoardView = gameView(gameControl: UIViewController())
    private var GameHandler = gameHandler(gameBoardV: gameView(gameControl: UIViewController()), localBoard: Board(dimension: 0), uBoard: Board(dimension: 0), oppBoard: Board(dimension: 0), dimension: 0, submitButton: UIButton())

    var userTurn = false
    var gameObject = PFObject(className: "currentGame")
//    var weekBattleObject : [PFObject] = []
    
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

        setCurrentGameVariables()
        addObservers()
        gameBoardView = gameView(gameControl: self)
        
        buildGame()
        addSpecialsBtn()
        addSubmitBtn()
        GameHandler.checkifGameIsFinished()
    }
    
    func setCurrentGameVariables() {
        gameObject = currentGame
        gridDimension = gameObject["grid"] as! Int
        
        userTurn = gameObject["userOnTurn"].objectId! == PFUser.currentUser()!.objectId
    }
    
    func buildGame() {
        gameBoardView.addGameBoard()
        gameBoardView.addScoreBoard()
        
        localGameBoard = Board(dimension: gridDimension)
        userBoard = Board(dimension: gridDimension)
        opponentBoard = Board(dimension: gridDimension)
        
        GameHandler = gameHandler(gameBoardV: gameBoardView, localBoard: localGameBoard, uBoard: userBoard, oppBoard: opponentBoard, dimension: gridDimension, submitButton: submitBtn)
        
        loadSquaresFromBackEnd()

        for (rowIndex, row) in userBoard.board.enumerate() {
            addRow(rowIndex, row: row)
        }
        
        loadScoredSquares()
        selectLastPlayedStripe()
    }

    func loadSquaresFromBackEnd() {
        if gameObject["user"]!.objectId == PFUser.currentUser()!.objectId {
            userBoard.loadSquareFromBackend(gameObject["userBoard"] as! [[Int]])
            opponentBoard.loadSquareFromBackend(gameObject["opponentBoard"] as! [[Int]])
        } else {
            userBoard.loadSquareFromBackend(gameObject["opponentBoard"] as! [[Int]])
            opponentBoard.loadSquareFromBackend(gameObject["userBoard"] as! [[Int]])
        }
        
        localGameBoard.loadSquareFromBackend(gameObject["userBoard"] as! [[Int]])
        localGameBoard.loadSquareFromBackend(gameObject["opponentBoard"] as! [[Int]])
    }
    
    func loadScoredSquares () {
        gameBoardView.giveColorToScoredSquares()
    }
    
    func addRow(rowIndex : Int, row : NSArray) {
        gameBoardView.addRow(rowIndex)
        
        for (squareIndex, square) in row.enumerate() {
            addSquare(rowIndex, squareIndex: squareIndex, square: square as! Square)
        }
    }
    
    func addSquare(rowIndex : Int, squareIndex : Int, square : Square) {
        let squareView = gameBoardView.addSquare(rowIndex, squareIndex: squareIndex)
        let buttonsPerSquare = [0,1,2,3]
        
        for stripeIndex in buttonsPerSquare {
            let stripe = gameBoardView.addStripe(stripeIndex, square: squareView)
            
            stripe.addTarget(self, action: #selector(gameEngineController.stripePressed(_:)), forControlEvents: .TouchUpInside)
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
    
    func stripePressed(stripe : UIButton) {
        if specialUsed {
            gameBoardView.removeSpecialAnimation()
        }
        
        let oldStripe = stripeToSubmit
        let oldDoubleStripe = doubleStripeToSubmit

        scoredSquaresArray = []
        doubleStripeToSubmit = UIButton()
        stripeToSubmit = stripe
        
        let doubleStripe = gameBoardView.selectDoubleStripe(stripeToSubmit)
        
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
        submitBtn.addTarget(self, action: #selector(gameEngineController.submitStripe), forControlEvents: .TouchUpInside)
    }

    func submitStripe() {
        gameBoardView.stylingWhenSubmittingStripe(submitBtn)
        
        if scoredSquaresArray.count > 0 {
            NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(gameEngineController.placeStripeAndSavePoint), userInfo: nil, repeats: false)
        } else {
            NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(gameEngineController.placeStripeAndSwitchUserTurn), userInfo: nil, repeats: false)
        }
    }
    
    func addSpecialsBtn() {
        if (gameObject["gameWithSpecials"]! as! Bool) {
            gameBoardView.addSpecialsBtn(specialsBtn)
            specialsBtn.addTarget(self, action: #selector(gameEngineController.openSpecials(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    func openSpecials(button : UIButton!) {
        let specialsBtns = specialsPopup().openPopup(self.view)
        
        button.userInteractionEnabled = false
        submitBtn.hidden = true
        specialsBtns[0].addTarget(self, action: #selector(gameEngineController.special1Clicked(_:)), forControlEvents: .TouchUpInside)
        specialsBtns[1].addTarget(self, action: #selector(gameEngineController.special2Clicked(_:)), forControlEvents: .TouchUpInside)
        specialsBtns[2].addTarget(self, action: #selector(gameEngineController.cancelBtnClicked(_:)), forControlEvents: .TouchUpInside)
    }
    
    func special1Clicked(button : UIButton!) {
        if stripeToSubmit.superview != nil {
            stripePressed(stripeToSubmit)
            stripeToSubmit = UIButton()
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
        specialsBtn.userInteractionEnabled = true
    }
    
    func placeStripeAndSavePoint() {
        specialsBtn.removeFromSuperview()
        GameHandler.placeStripeAndSavePoint(stripeToSubmit, doubleStripeToSubmit: doubleStripeToSubmit, scoredSquares : scoredSquaresArray, specialUsed: specialUsed)
        stripeToSubmit = UIButton()
        doubleStripeToSubmit = UIButton()
        
        if gameObject["gameWithSpecials"] as! Bool {
            gameBoardView.addSpecialsBtn(specialsBtn)
            specialUsed = false
        }
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
        let finishBtn = UIButton()
        finishBtn.addTarget(self, action: #selector(gameEngineController.gameFinished(_:)), forControlEvents: .TouchUpInside)
        
        1.0.waitSecondsAndDo({
            if self.gameBoardView.userPoints > self.gameBoardView.opponentPoints {
                finishBtn.tag = 1
            } else if self.gameBoardView.userPoints < self.gameBoardView.opponentPoints {
                finishBtn.tag = 2
            } else {
                finishBtn.tag = 3
            }
            
            finishScreen().openPopup(self.view, finishBtn: finishBtn)
        })
        
        if userTurn == false {
            finishBtn.hidden = true
        }
    }
    
    func gameFinished(button : UIButton!) {
        GameHandler.gameFinished(button)
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gameEngineController.gameHasFinished), name: "gameHasFinished", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gameEngineController.popViewController), name: "popViewController", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        SVProgressHUD.dismiss()
    }
}
