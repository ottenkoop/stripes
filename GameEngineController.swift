import UIKit

class GameEngineController: UIViewController {

    var gameObject : [PFObject] = []
    private var playField = UIView (frame: CGRectZero)
    
    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    private var playFieldHeight : CGFloat = 0
    private var playFieldWidth : CGFloat = 0

    private var rowsAmount: [Int] = []
    private var squaresAmount: [Int] = []
    
    private var allRows : [UIView] = []
    private var allSquares : [UIView] = []
    private var allStripes : [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()

        self.view.addSubview(playField)
        
        addPlayFieldPosition()
    
        buildUpGame()
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
            playFieldHeight = screenHeight - 100
            playFieldWidth = (screenWidth / 2) + 100

            playField.centerInContainerOnAxis(.CenterY)
            playField.constrainToSize(CGSizeMake(playFieldWidth, playFieldHeight))
            playField.pinAttribute(.Left, toAttribute: .Left, ofItem: self.view, withConstant: 10)
        }
    }

    func buildUpGame() {
        setGrid()
        loadPlayedStripes()

        addGrid (rowsAmount, sqauresAmount: squaresAmount)
    }
    
    func setGrid() {
        var gridInt : Int = gameObject[0]["grid"] as Int
        
        0.upTo(gridInt - 1, { self.rowsAmount += [$0] })
        0.upTo(gridInt - 1, { self.squaresAmount += [$0] })
    }
    
    func loadPlayedStripes () {
        var game = gameObject[0]
        
        var playedStripesQuery = searchModule.findPlayedStripes(game)

        playedStripesQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                println(objects)
                
                for object in objects {
                    self.setPlayedStripe(object)
                }
                
            } else {
                let alert = UIAlertView(title: "Connection Failed", message: "There seems to be an error with your internet connection.", delegate: self, cancelButtonTitle: "Try Again")
                alert.show()
                
                println("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    func setPlayedStripe (stripe : AnyObject) {
        var rowIndex : Int = stripe["rowIdx"] as Int
        var squareIndex : Int = stripe["squareIdx"] as Int
        var stripeIndex : Int = stripe["stripeIdx"] as Int
        
        var playedStripe : UIButton = allRows[rowIndex].subviews[squareIndex].subviews[stripeIndex] as UIButton
        
        if stripe["user"] as PFUser == PFUser.currentUser() {
            playedStripe.backgroundColor = UIColor.greenColor()
        } else {
            playedStripe.backgroundColor = UIColor.redColor()
        }
        
        selectDoubleHiddenStripe(playedStripe)
        
        playedStripe.selected = true
        playedStripe.userInteractionEnabled = false
        
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
            
            stripe.addTarget(self, action: "stripePressed:", forControlEvents: .TouchUpInside)
        }
        
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
            stripe.constrainToSize(CGSizeMake(stripeWidth, 10))
            stripe.pinAttribute(.Left, toAttribute: .Left, ofItem: square)
            stripe.pinAttribute(.Top, toAttribute: .Top, ofItem: square)
        } else if stripe.tag == 1 {
            stripe.constrainToSize(CGSizeMake(10, stripeHeight))
            stripe.pinAttribute(.Right, toAttribute: .Right, ofItem: square)
            stripe.pinAttribute(.Top, toAttribute: .Top, ofItem: square)
        } else if stripe.tag == 2 {
            stripe.constrainToSize(CGSizeMake(stripeWidth, 10))
            stripe.pinAttribute(.Left, toAttribute: .Left, ofItem: square)
            stripe.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: square)
        } else if stripe.tag == 3 {
            stripe.constrainToSize(CGSizeMake(10, stripeHeight))
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
        }
    }
    
    func stripePressed (stripe: UIButton!) {
        
        if stripe.backgroundColor == UIColor.greenColor() {
            stripe.backgroundColor == UIColor.whiteColor()
        } else {
            stripe.backgroundColor = UIColor.greenColor()
        }

        stripe.selected = true
        
        // Find and select the hidden double stripe.
        // function used for for detecting if square has 4 stripes selected.
        selectDoubleHiddenStripe(stripe)
        checkIfSquareIsFull(stripe)
        
        for stripe in allStripes {
            stripe.userInteractionEnabled = false
        }
        
        stripe.userInteractionEnabled = true
    }
    
    func selectDoubleHiddenStripe(stripe : UIButton) {
        var squareOfStripeTag = stripe.superview!.tag
        var rowOfStripe = stripe.superview!.superview!
        
        if squareOfStripeTag > 0 {
            if stripe.tag == 3 {
                var doubleStripe: UIButton = rowOfStripe.subviews[squareOfStripeTag - 1].subviews[1] as UIButton
            
                doubleStripe.selected = true
                checkIfSquareIsFull(doubleStripe)
            }
        }
        
        if rowOfStripe.tag > 0 {
            if stripe.tag == 0 {
                var doubleStripe: UIButton = allRows[rowOfStripe.tag - 1].subviews[squareOfStripeTag].subviews[2] as UIButton

                doubleStripe.selected = true
                
                checkIfSquareIsFull(doubleStripe)
            }
        }
    }
    
    func checkIfSquareIsFull(stripe : UIButton) {
        var square = stripe.superview!
        var selectedStripesInSquare = 0
        var gameId = gameObject[0].objectId
        
        for stripe in square.subviews as [UIButton] {
            if stripe.selected {
                selectedStripesInSquare += 1
            }
        }
        
        if selectedStripesInSquare == 4 {
            square.backgroundColor = UIColor.yellowColor()
            
            Game.userScoredAPoint(gameObject[0])
            squareHandler.addSquareAndRelationToUser(gameObject[0].objectId, squareIndex: square.tag, rowIndex: square.superview!.tag )
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return Int(UIInterfaceOrientationMask.LandscapeRight.rawValue)
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
        }
        
        return 0
    }
}

