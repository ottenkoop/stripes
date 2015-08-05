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
    private var GameHandler = gameHandler(gameBoardV: gameView(gameControl: UIViewController()), localBoard: Board(dimension: 0), uBoard: Board(dimension: 0), oppBoard: Board(dimension: 0), weekB: [AnyObject](), dimension: 0, submitButton: UIButton())

    var userTurn = false
    var gameObject = PFObject(className: "currentGame")
    var weekBattleObject : [PFObject] = []
    
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
        addSubmitBtn()
        addSpecialsBtn()
//        GameHandler.checkifGameIsFinished()
//        gameHasFinished()
    }
    
    func setCurrentGameVariables() {
        gameObject = Game.currentGame()
        gridDimension = gameObject["grid"] as! Int
        
        
        // TODO: Get userOnTurn from gameObject.
        userTurn = gameObject["userOnTurn"] as! PFUser == PFUser.currentUser()
    }
    
    func buildGame() {
        gameBoardView.addGameBoard()
        gameBoardView.addScoreBoard()
        
        localGameBoard = Board(dimension: gridDimension)
        userBoard = Board(dimension: gridDimension)
        opponentBoard = Board(dimension: gridDimension)
        
        GameHandler = gameHandler(gameBoardV: gameBoardView, localBoard: localGameBoard, uBoard: userBoard, oppBoard: opponentBoard, weekB: weekBattleObject, dimension: gridDimension, submitButton: submitBtn)
        
        loadSquaresFromBackEnd()

        for (rowIndex, row) in enumerate(userBoard.board) {
            addRow(rowIndex, row: row)
        }
        
        loadScoredSquares()
        selectLastPlayedStripe()
    }

    func loadSquaresFromBackEnd() {
        if gameObject["user"].objectId == PFUser.currentUser().objectId {
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
        
        for (squareIndex, square) in enumerate(row) {
            addSquare(rowIndex, squareIndex: squareIndex, square: square as! Square)
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
    
    func stripePressed(stripe : UIButton) {
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
        var finishBtn = UIButton()
        finishBtn.addTarget(self, action: "gameFinished:", forControlEvents: .TouchUpInside)
        
        2.0.waitSecondsAndDo({
            if self.gameBoardView.userPoints > self.gameBoardView.opponentPoints {
                finishBtn.tag = 1
            } else if self.gameBoardView.userPoints < self.gameBoardView.opponentPoints {
                finishBtn.tag = 2
            } else {
                finishBtn.tag = 3
            }
            
            finishScreen().openPopup(self.view, finishBtn: finishBtn)
        })
    }
    
    func checkIfTimesUp() {
        var lastUpdate : NSDate = weekBattleObject[0].updatedAt as NSDate
        var dateNow = NSDate()
        
        if weekBattleObject[0]["battleFinished"] as! Bool == true {
            //      TODO: ENABLE. TIME NOT WORKING IN SIMU. lastUpdate.dateAtStartOfWeek().dateByAddingDays(1).isEarlierThanDate(dateNow) && weekBattleObject[0]["userOnTurn"].objectId == PFUser.currentUser().objectId {
            var btns : [UIButton] = []

            if weekBattleObject[0]["user"].objectId == PFUser.currentUser().objectId {
                btns = weekBattleFinished().openPopup(self, uPoints : weekBattleObject[0]["userPoints"] as! Int, oppPoints : weekBattleObject[0]["user2Points"] as! Int, oppName: weekBattleObject[0]["user2FullName"] as! NSString)
            } else {
                btns = weekBattleFinished().openPopup(self, uPoints : weekBattleObject[0]["user2Points"] as! Int, oppPoints : weekBattleObject[0]["userPoints"] as! Int, oppName: weekBattleObject[0]["userFullName"] as! NSString)
            }
            
            btns[0].addTarget(self, action: "yesBtnClicked", forControlEvents: .TouchUpInside)
            btns[1].addTarget(self, action: "noBtnClicked", forControlEvents: .TouchUpInside)
        }
    }
    
    func yesBtnClicked() {
        if weekBattleObject[0]["battleFinished"] as! Bool == true {
            weekBattle.resetWeekBattle(weekBattleObject[0], game: gameObject)
            weekBattleObject[0]["battleFinished"] = false
        } else {
            weekBattle.resetGame(3, game: gameObject)
            weekBattleObject[0]["battleFinished"] = true
            
            if weekBattleObject[0]["user"].objectId == PFUser.currentUser().objectId {
                weekBattleObject[0]["userOnTurn"] = weekBattleObject[0]["user2"]
            } else {
                weekBattleObject[0]["userOnTurn"] = weekBattleObject[0]["user"]
            }
            pushNotificationHandler.restartBattleNotification(weekBattleObject[0])
        }
        
        weekBattleObject[0].saveInBackgroundWithBlock({(succeeded: Bool, err: NSError!) -> Void in
            if succeeded {
                self.gameObject.saveEventually()
                NSNotificationCenter.defaultCenter().postNotificationName("popViewController", object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
            }
        })
        
    }
    
    func noBtnClicked() {
        gameObject.deleteEventually()
        weekBattleObject[0].deleteInBackgroundWithBlock(nil)
        
        NSNotificationCenter.defaultCenter().postNotificationName("popViewController", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)

        popViewController()
        
    }
    
    func gameFinished(button : UIButton!) {
        GameHandler.gameFinished(button)
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameHasFinished", name: "gameHasFinished", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "popViewController", name: "popViewController", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        SVProgressHUD.dismiss()
        checkIfTimesUp()
    }
}
