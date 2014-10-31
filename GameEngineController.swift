import UIKit

class GameEngineController: UIViewController {

    internal var gameID : String = ""
    private var playField = UIView (frame: CGRectZero)
    
    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    private var playFieldHeight : CGFloat = 0
    private var playFieldWidth : CGFloat = 0

    let rowsAmount: [Int] = [0,1,2]
    let squaresAmount: [Int] = [0,1,2]
    
    private var allRows : [UIView] = []
    private var allSquares : [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()

        self.view.addSubview(playField)
        
        addPlayFieldPosition()
        
        findGame()

        
        // println(gameID)

        // maak van int een array.
        //        var legeArray : [Int] = []
        //        0.upTo(squaresAmount - 1, {legeArray += [$0]})
        //
        //        println(legeArray)
        
    }
    
    func findGame() {
        
        
        
        showScreen()
    }
    
    func addPlayFieldPosition() {
        playField.setTranslatesAutoresizingMaskIntoConstraints(false)
        playField.backgroundColor = UIColor.redColor()
        
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

    func showScreen() {
        
//        Game.addGame()
        
        addGrid (rowsAmount, sqauresAmount: squaresAmount)
        
        var rowIndex : Int = 1
        var squareIndex : Int = 2
        var buttonIndex : Int = 0
        
        findStripe(rowIndex, squareIndex: squareIndex, buttonIndex: buttonIndex)
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
            
//            newSquare.pinAttribute(.Top, toAttribute: .Top, ofItem: allRows[rowindex])
        }

        for square in allSquares {
            if square.tag == 0 {
                square.backgroundColor = UIColor.greenColor()
                square.centerInContainerOnAxis(.CenterY)
                square.pinAttribute(.Left, toAttribute: .Left, ofItem: allRows[rowindex])
            } else if square.tag == 1 {
                square.backgroundColor = UIColor.yellowColor()
                square.centerInContainerOnAxis(.CenterY)
                square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[0])
            } else if square.tag == 2 {
                square.backgroundColor = UIColor.orangeColor()
                square.centerInContainerOnAxis(.CenterY)
                square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[1])
            } else if square.tag == 3 {
                square.backgroundColor = UIColor.orangeColor()
                square.centerInContainerOnAxis(.CenterY)
                square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[2])
            } else if square.tag == 4 {
                square.backgroundColor = UIColor.orangeColor()
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
            
            stripe.addTarget(self, action: "stripePressed:", forControlEvents: .TouchUpInside)
        }
        
    }
    
    func addStripe (stripeIndex : Int, square : UIView) -> UIButton {
        let stripe = UIButton ()
        
        stripe.tag = stripeIndex
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
    
    func stripePressed (stripe: UIButton!) {
        println(stripe.tag)
        
        stripe.backgroundColor = UIColor.greenColor()
        
        stripe.userInteractionEnabled = false
        
//        stripe.hidden = true
    }
    
    func findStripe (rowIndex : Int, squareIndex : Int, buttonIndex : Int) {
        var button : AnyObject = allRows[0].subviews[0].subviews[0]

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

