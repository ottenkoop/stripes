import UIKit

class GameEngineController: UIViewController {
    var gameObject : [PFObject] = []
    var userTurn : Bool = false
    
    private var playField = UIView (frame: CGRectZero)
    private var submitBtn = UIButton()
    private var loadingViewContainer = UIView()
    
    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    private var playFieldHeight : CGFloat = 0
    private var playFieldWidth : CGFloat = 0
    
    private var userPointsView = UILabel()
    private var opponentPointsView = UILabel()
    private var userPoints : Int = 0
    private var opponentPoints : Int = 0
    private var openStripes : [UIButton] = []

    private var rowsAmount: [Int] = []
    private var squaresAmount: [Int] = []
    
    private var allRows : [UIView] = []
    private var allSquares : [UIView] = []
    private var allStripes : [UIButton] = []
    
    private var stripeToSubmit : UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()

        self.view.addSubview(playField)
        
        addPlayFieldPosition()
        setUserPoints()
        buildUpGame()
    }
    
    func buildUpGame() {
        determineGrid()
        addSubmitBtn()
        addGrid (rowsAmount, sqauresAmount: squaresAmount)
        
        loadPlayedStripes()
        loadScoredSquares()
        checkifGameIsFinished()
    }
    
    func addPlayFieldPosition() {
        playField.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            
            playFieldHeight = screenHeight - 200
            playFieldWidth = screenWidth - 10

            playField.centerInContainerOnAxis(.CenterX)
            playField.constrainToSize(CGSizeMake(playFieldWidth, playFieldHeight))
            playField.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: self.view, withConstant: -75)
            
        } else {
            println(screenHeight)
            println(screenWidth)
            
            if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
                playFieldHeight = screenHeight - 150
                playFieldWidth = (screenWidth / 2) + 100
            } else {
                playFieldHeight = screenWidth - 150
                playFieldWidth = (screenHeight / 2) + 100
            }
        
            playFieldWidth = (screenWidth / 2) + 150

            playField.centerInContainerOnAxis(.CenterY)
            playField.constrainToSize(CGSizeMake(playFieldWidth, playFieldHeight))
            
            playField.pinAttribute(.Left, toAttribute: .Left, ofItem: self.view, withConstant: 10)
        }
    }

    func determineGrid() {
        var gridInt : Int = gameObject[0]["grid"] as Int
        
        0.upTo(gridInt - 1, { self.rowsAmount += [$0] })
        0.upTo(gridInt - 1, { self.squaresAmount += [$0] })
    }
    
    func reloadPlayedStripes () {
        var game = gameObject[0]

        openStripes.remove(stripeToSubmit)
        
        submitBtn.hidden = true
        stripeToSubmit.userInteractionEnabled = false
        stripeToSubmit.backgroundColor = UIColor.greenColor()
        stripeToSubmit = UIButton()
        
        loadingView().hideActivityIndicator(loadingViewContainer)
        self.navigationController!.navigationBarHidden = false
    }
    
    func addSubmitBtn() {
        submitBtn.setTitle("Play", forState: .Normal)
        submitBtn.backgroundColor = UIColor.colorWithRGBHex(0x5AB103)
        
        self.view.addSubview(submitBtn)
        submitBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        submitBtn.constrainToSize(CGSizeMake(screenWidth - 10, 50))
        submitBtn.centerInContainerOnAxis(.CenterX)
        submitBtn.pinAttribute(.Top, toAttribute: .Bottom, ofItem: playField, withConstant: 10)
        submitBtn.addTarget(self, action: "submitStripe", forControlEvents: .TouchUpInside)
        
        submitBtn.hidden = true
    }
    
    func addGrid (rowsAmount: [Int], sqauresAmount: [Int]) {
        for rowindex in rowsAmount {
            var new_row = addRow(rowindex)

            allRows += [new_row]
            
            addSquares(rowindex)
        }
        
        addRowPosition(allRows)
        hideDoubleStripes()
    
    }
    
    func addRow(rowindex : Int) -> UIView {
        let row = UIView()
        row.tag = rowindex
        
        playField.addSubview(row)
        row.setTranslatesAutoresizingMaskIntoConstraints (false)
        
        var rowHeight : CGFloat =  playFieldHeight / CGFloat(countElements(rowsAmount))
        
        row.constrainToSize(CGSizeMake(playFieldWidth, rowHeight))
        row.centerInContainerOnAxis(.CenterX)
        
        return row
    }
    
    func addRowPosition (allRows : NSArray) {
        for row in allRows {
            if row.tag == 0 {
                row.pinAttribute(.Top, toAttribute: .Top, ofItem: playField)
            } else if row.tag == 1 {
                row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: allRows[0])
            } else if row.tag == 2 {
                row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: allRows[1])
            } else if row.tag == 3 {
                row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: allRows[2])
            } else if row.tag == 4 {
                row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: allRows[3])
            } else if row.tag == 5 {
                row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: allRows[4])
            }
        }
    }
    
    func addSquares (rowindex : Int) {
        for squareIndex in squaresAmount {
            var newSquare = addSquare(squareIndex, rowindex: rowindex)

            allSquares += [newSquare]

        }

        for square in allSquares {
            if square.tag == 0 {
                square.centerInContainerOnAxis(.CenterY)
                square.pinAttribute(.Left, toAttribute: .Left, ofItem: allRows[rowindex])
            } else if square.tag == 1 {
                square.centerInContainerOnAxis(.CenterY)
                square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[0])
            } else if square.tag == 2 {
                square.centerInContainerOnAxis(.CenterY)
                square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[1])
            } else if square.tag == 3 {
                square.centerInContainerOnAxis(.CenterY)
                square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[2])
            } else if square.tag == 4 {
                square.centerInContainerOnAxis(.CenterY)
                square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[3])
            }
            
        }
    }
    
    func addSquare (squareIndex : Int, rowindex : Int) -> UIView {
        let square = UIView ()
        square.tag = squareIndex

        allRows[rowindex].addSubview(square)
        
        square.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var squareWidth : CGFloat = playFieldWidth / CGFloat(countElements(squaresAmount))
        var squareHeight : CGFloat = playFieldHeight / CGFloat(countElements(rowsAmount))
        
        square.constrainToSize(CGSizeMake(squareWidth, squareHeight))
        
        // add 4 buttons
        addStripeButtons(square)
        
        return square
    }
    
    func addStripeButtons(square : UIView) {
        var buttonsPerSquare = [0,1,2,3]
        
        for stripeIndex in buttonsPerSquare {
            var stripe = addStripe(stripeIndex, square: square)
            
            allStripes += [stripe]
            
            // MOET NOG GEOPTIMALISEERD WORDEN.
            if userTurn == true {
                stripe.addTarget(self, action: "stripePressed:", forControlEvents: .TouchUpInside)
            }
        }
        
        openStripes = allStripes
    }
    
    func addStripe (stripeIndex : Int, square : UIView) -> UIButton {
        let stripe = UIButton ()
        
        stripe.tag = stripeIndex
        
        stripe.selected = false
        stripe.layer.borderWidth = 1
        stripe.layer.borderColor = UIColor.blackColor().CGColor
        stripe.backgroundColor = UIColor.whiteColor()
        
        square.addSubview(stripe)
        
        stripe.setTranslatesAutoresizingMaskIntoConstraints(false)
        addStripePosition(stripe, square: square)
        
        return stripe
    }
    
    func addStripePosition(stripe : UIButton, square : UIView) {
        var stripeWidth : CGFloat = playFieldWidth / CGFloat(countElements(squaresAmount))
        var stripeHeight : CGFloat = playFieldHeight / CGFloat(countElements(rowsAmount))
        
        if stripe.tag == 0 {
            stripe.constrainToSize(CGSizeMake(stripeWidth, 20))
            stripe.pinAttribute(.Left, toAttribute: .Left, ofItem: square)
            stripe.pinAttribute(.Top, toAttribute: .Top, ofItem: square)
        } else if stripe.tag == 1 {
            stripe.constrainToSize(CGSizeMake(20, stripeHeight))
            stripe.pinAttribute(.Right, toAttribute: .Right, ofItem: square)
            stripe.pinAttribute(.Top, toAttribute: .Top, ofItem: square)
        } else if stripe.tag == 2 {
            stripe.constrainToSize(CGSizeMake(stripeWidth, 20))
            stripe.pinAttribute(.Left, toAttribute: .Left, ofItem: square)
            stripe.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: square)
        } else if stripe.tag == 3 {
            stripe.constrainToSize(CGSizeMake(20, stripeHeight))
            stripe.pinAttribute(.Left, toAttribute: .Left, ofItem: square)
            stripe.pinAttribute(.Top, toAttribute: .Top, ofItem: square)
        }
    }
    
    func hideDoubleStripes () {
        var squaresArrayToUseHere : [UIView] = allSquares
        
        var buttonsToHide : [UIButton] = []
        var lastRow = allRows.last!

        for square in squaresArrayToUseHere {
            var rightButtonsToHide : UIButton = square.subviews[1] as UIButton
            var bottomButtonsToHide : UIButton = square.subviews[2] as UIButton

            buttonsToHide += [rightButtonsToHide, bottomButtonsToHide]
        }

        for row in allRows {
            var rightButtonsNotToHide : UIButton = row.subviews.last!.subviews[1] as UIButton
            
            buttonsToHide.remove(rightButtonsNotToHide)
            
            if row == allRows.last! {
                for subview in row.subviews{
                    var bottomButtonsNotToHide : UIButton = subview.subviews[2] as UIButton
                    
                    buttonsToHide.remove(bottomButtonsNotToHide)
                }
            }
        }
        
        for button in buttonsToHide {
            button.hidden = true
            
            openStripes.remove(button)
        }
    }
    
    func stripePressed (stripe: UIButton!) {
        
        var oldStripe = stripeToSubmit
        stripeToSubmit = stripe
        
        if stripe != oldStripe {
            oldStripe.backgroundColor = UIColor.whiteColor()
            stripe.backgroundColor = UIColor.colorWithRGBHexWithAlpha(0x5AB103, alpha: 0.7)
            
            oldStripe.selected = false
            stripe.selected = true
        } else if stripe == oldStripe && stripe.selected == false {
            stripe.backgroundColor = UIColor.colorWithRGBHexWithAlpha(0x5AB103, alpha: 0.7)
            stripe.selected = true
            
        } else {
            stripe.backgroundColor = UIColor.whiteColor()
            
            stripe.selected = false
            oldStripe.selected = false
        }
        
        if stripeToSubmit.selected == false  {
            submitBtn.hidden = true
        } else {
            submitBtn.hidden = false
        }

    }
    
    func submitStripe() {
        submitBtn.hidden = true
        loadingViewContainer = loadingView().showActivityIndicator(self.view)
        self.navigationController!.navigationBarHidden = true
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "startSavingStuff", userInfo: nil, repeats: false)
    }
    
    func startSavingStuff() {
        var square = stripeToSubmit.superview!
        var doubleStripe = selectDoubleHiddenStripe(stripeToSubmit)
        var userScoredAPoint = checkIfUserScoredAPoint(stripeToSubmit)
        var userScoredAnotherPoint : Bool = false
        
        if doubleStripe.superview != nil {
            userScoredAnotherPoint = checkIfUserScoredAPoint(doubleStripe)
        } else {
            userScoredAnotherPoint = false
        }
        
        if userScoredAPoint || userScoredAnotherPoint {
            var stripeToSaveQuery = stripeHandler.addNewStripe(square.superview!.tag, squareIndex: square.tag, stripeIndex: stripeToSubmit.tag, game: gameObject[0])
            
            stripeToSaveQuery.saveInBackgroundWithBlock({(succeeded: Bool!, err: NSError!) -> Void in
                if succeeded != nil {
                    self.reloadPlayedStripes()
                    
                    self.checkifGameIsFinished()
                }
            })
            
        } else {
            var gameToUpdate = Game.switchTurnToOtherUserAndSaveStripe(gameObject[0], rowIndex: square.superview!.tag, squareIndex: square.tag, stripeIndex: stripeToSubmit.tag)
            
            gameToUpdate.saveInBackgroundWithBlock({(succeeded: Bool!, err: NSError!) -> Void in
                if succeeded != nil {
                    NSNotificationCenter.defaultCenter().postNotificationName("deleteObjectFromYourTurnSection", object: nil)
                    self.navigationController!.popViewControllerAnimated(true)
                    loadingView().hideActivityIndicator(self.view)
                            
                    self.navigationController!.navigationBarHidden = false
                }
            })
        }
    }
    
    func checkIfUserScoredAPoint(stripe : UIButton) -> Bool {
        
        var square = stripe.superview!
        var selectedStripesInSquare = 0
        
        for stripe in square.subviews as [UIButton] {
            if stripe.selected {
                selectedStripesInSquare += 1
            }
        }
        
        if selectedStripesInSquare == 4 {
            square.backgroundColor = UIColor.greenColor()

            println("PUNTEN +1!!")
            Game.addPointAndScoredSquareToUser(gameObject[0], rowIndex : square.superview!.tag, squareIndex: square.tag)
            
            userPoints += 1
            userPointsView.text = "You: " + "\(userPoints)"
            
            return true
        } else {
            return false
        }
    }

    func setUserPoints() {
        var game = gameObject[0]
        var user1 = game["user"] as PFUser
        var userFullName : NSString = PFUser.currentUser()["fullName"] as NSString
        var opponentFullName : NSString = ""
        
        if user1.objectId == PFUser.currentUser().objectId {
            userPoints = game["userPoints"] as Int
            opponentPoints = game["user2Points"] as Int
            
            opponentFullName = game["user2FullName"] as NSString
        } else {
            userPoints = game["user2Points"] as Int
            opponentPoints = game["userPoints"] as Int
            
            opponentFullName = game["userFullName"] as NSString
        }
        
        userPointsView.text = "You: \(userPoints)"
        opponentPointsView.text = "Opponent: \(opponentPoints)"
        
        styleAndAddLabelPoints([userPointsView, opponentPointsView])
    }
    
    func styleAndAddLabelPoints(labelPointsViews : [UILabel]) {
        
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            for label in labelPointsViews {
                label.textColor = UIColor.blackColor()
                self.view.addSubview(label)
                label.setTranslatesAutoresizingMaskIntoConstraints(false)
                label.textAlignment = .Center
                
                label.font = UIFont(name: label.font.fontName, size: 18)
                
                label.constrainToSize(CGSizeMake(screenWidth / 2, 30))
                label.pinAttribute(.Bottom, toAttribute: .Top, ofItem: playField, withConstant: -20)
            }
            
            self.view.spaceViews(labelPointsViews, onAxis: .Horizontal)
        } else {
            for label in labelPointsViews {
                label.textColor = UIColor.blackColor()
                self.view.addSubview(label)
                label.setTranslatesAutoresizingMaskIntoConstraints(false)
                label.textAlignment = .Center
                
                label.font = UIFont(name: label.font.fontName, size: 25)
                
                label.constrainToSize(CGSizeMake(screenWidth / 2, 100))
                label.pinAttribute(.Right, toAttribute: .Right, ofItem: self.view, withConstant: 10)
                
            }
            
            labelPointsViews[0].centerInContainerOnAxis(.CenterY)
            labelPointsViews[1].pinAttribute(.Top, toAttribute: .Top, ofItem: labelPointsViews[0], withConstant: 50)
        }
    }
    
    func loadPlayedStripes () {
        var game: PFObject = gameObject[0] as PFObject
        var stripesArray = game["allStripes"] as NSArray
    
        for stripe in stripesArray {
            if stripe as NSObject == stripesArray.lastObject! as NSObject {
                setPlayedStripe(stripe, lastObject: true)
            } else {
                setPlayedStripe(stripe, lastObject: false)
            }
        }
    }
    
    func setPlayedStripe(stripe : AnyObject, lastObject : Bool) {
        var rowIndex : Int = stripe["rowIndex"] as Int
        var squareIndex : Int = stripe["squareIndex"] as Int
        var stripeIndex : Int = stripe["stripeIndex"] as Int
        var stripeBelongsToUser : NSString = stripe["userId"] as NSString
    
        var playedStripe : UIButton = allRows[rowIndex].subviews[squareIndex].subviews[stripeIndex] as UIButton
    
        if stripeBelongsToUser == PFUser.currentUser().objectId {
            playedStripe.backgroundColor = UIColor.greenColor()
        } else if lastObject {
            playedStripe.backgroundColor = UIColor.yellowColor()
        } else {
            playedStripe.backgroundColor = UIColor.redColor()
        }
    
        var doublePlayedStripe = selectDoubleHiddenStripe(playedStripe)

        playedStripe.selected = true
        playedStripe.userInteractionEnabled = false

        openStripes.remove(playedStripe)
    }
    
    func selectDoubleHiddenStripe(stripe: UIButton) -> UIButton {
        var squareOfStripeTag = stripe.superview!.tag
        var rowOfStripe = stripe.superview!.superview!
        var doubleStripe = UIButton()

        if squareOfStripeTag > 0 {
            if stripe.tag == 3 {
                var doubleStripe: UIButton = rowOfStripe.subviews[squareOfStripeTag - 1].subviews[1] as UIButton
                doubleStripe.selected = true
                
                return doubleStripe
            }
        }

        if rowOfStripe.tag > 0 {
            if stripe.tag == 0 {
                var doubleStripe: UIButton = allRows[rowOfStripe.tag - 1].subviews[squareOfStripeTag].subviews[2] as UIButton
                doubleStripe.selected = true
                
                return doubleStripe
            }
        }
        
        return UIButton()
    }
    
    func loadScoredSquares () {
        var game: PFObject = gameObject[0] as PFObject

        for squareObject in game["allScoredSquares"] as NSArray {

            var square: UIView = allRows[squareObject["rowIndex"] as Int].subviews[squareObject["squareIndex"] as Int] as UIView

            if squareObject["userId"] as NSString == PFUser.currentUser().objectId {
                square.backgroundColor = UIColor.greenColor()
            } else {
                square.backgroundColor = UIColor.redColor()
            }
        }
    }

    func checkifGameIsFinished() {
        println(openStripes.count)
        
        if openStripes.count == 0 {
            finishGame()
        }
    }
    
    func finishGame() {
        println("game Finished: \(userPoints) - \(opponentPoints)")
        
        if userPoints > opponentPoints {
            finishScreen().gameDidFinishWithCurrentUserWinner(self)
        } else if userPoints > opponentPoints {
            finishScreen().gameDidFinishWithOpponentWinner(self)
        } else {
            println("DRAW")
        }
        
        var button = finishScreen().addContinuButton(self.view)
        button.addTarget(self, action: "continuToGamesScreen", forControlEvents: .TouchUpInside)
    }
    
    func continuToGamesScreen() {
        self.navigationController?.popViewControllerAnimated(true)
        
        // SAVE STATISTICS HERE
        Game.deleteGameAndSendNotification(gameObject[0])
        NSNotificationCenter.defaultCenter().postNotificationName("reloadGameTableView", object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

