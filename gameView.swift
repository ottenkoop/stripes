//
//  GameViewController.swift
//  Stripes
//
//  Created by Koop Otten on 06/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class gameView {
    private var gameController = UIViewController()
    private var gameBoardView = UIView()
    private var gridDimension = 0
    private var gameObject : [AnyObject] = []
    private var loadingContainer = UIView()
    
    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    private var gameBoardViewHeight : CGFloat = 0
    private var gameBoardViewWidth : CGFloat = 0
    
    private var allRows : [UIView] = []
    private var allSquares : [UIView] = []
    
    private var userPointsView = UILabel()
    private var opponentPointsView = UILabel()
    var userPoints : Int = 0
    var opponentPoints : Int = 0
    
    var position = [UIButton: StripeType]()
    
    init (gameControl : UIViewController, dimension : Int, gameObj : [AnyObject]) {
        gameController = gameControl
        gameObject = gameObj
        gridDimension = dimension
    }

    func addGameBoard() {
        gameController.view.addSubview(gameBoardView)
        gameBoardView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        if (UIInterfaceOrientationIsPortrait(gameController.interfaceOrientation)) {
            
            gameBoardViewHeight = screenHeight - 185
            gameBoardViewWidth = screenWidth
            
            gameBoardView.centerInContainerOnAxis(.CenterX)
            gameBoardView.constrainToSize(CGSizeMake(gameBoardViewWidth, gameBoardViewHeight))
            gameBoardView.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: gameController.view, withConstant: -65)
            
        } else {
            if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
                gameBoardViewHeight = screenHeight - 150
                gameBoardViewWidth = (screenWidth / 2) + 100
            } else {
                gameBoardViewHeight = screenWidth - 150
                gameBoardViewWidth = (screenHeight / 2) + 100
            }
            
            gameBoardView.centerInContainerOnAxis(.CenterY)
            gameBoardView.constrainToSize(CGSizeMake(gameBoardViewWidth, gameBoardViewHeight))
            gameBoardView.pinAttribute(.Left, toAttribute: .Left, ofItem: gameController.view, withConstant: 10)
        }
    }
    
    func addScoreBoard () {
        var userFullNameArr = []
        var oppFullNameArr = []
        
        if (gameObject[0]["user"] as PFUser).objectId == PFUser.currentUser().objectId {
            userPoints = gameObject[0]["userPoints"] as Int
            opponentPoints = gameObject[0]["opponentPoints"] as Int
            userFullNameArr = (gameObject[0]["userFullName"] as NSString).componentsSeparatedByString(" ")
            oppFullNameArr = (gameObject[0]["user2FullName"] as NSString).componentsSeparatedByString(" ")
        } else {
            userPoints = gameObject[0]["opponentPoints"] as Int
            opponentPoints = gameObject[0]["userPoints"] as Int
            userFullNameArr = (gameObject[0]["user2FullName"] as NSString).componentsSeparatedByString(" ")
            oppFullNameArr = (gameObject[0]["userFullName"] as NSString).componentsSeparatedByString(" ")
        }
        
        // should be user first name
        userPointsView.text = "\(userFullNameArr[0]): \(userPoints)"
        opponentPointsView.text = "\(oppFullNameArr[0]): \(opponentPoints)"
        
        userPointsView.textColor = UIColor.blueColor()
        opponentPointsView.textColor = UIColor.colorWithRGBHex(0xDA4B4B, alpha: 1.0)

        addScoreBoardPosition([userPointsView, opponentPointsView])
    }
    
    func addScoreBoardPosition(labelPointsViews : [UILabel]) {
        if (UIInterfaceOrientationIsPortrait(gameController.interfaceOrientation)) {
            for label in labelPointsViews {
                gameController.view.addSubview(label)
                label.setTranslatesAutoresizingMaskIntoConstraints(false)
                label.textAlignment = .Center
                label.font = UIFont(name: "SchoolBell", size: 32)
                
                label.constrainToSize(CGSizeMake(screenWidth / 2 - 25, 50))
            }
            
            labelPointsViews[0].pinAttribute(.Bottom, toAttribute: .Top, ofItem: gameBoardView, withConstant: 0)
            labelPointsViews[0].pinAttribute(.Left, toAttribute: .Left, ofItem: gameBoardView, withConstant: 15)
            labelPointsViews[1].pinAttribute(.Bottom, toAttribute: .Top, ofItem: gameBoardView, withConstant: 0)
            labelPointsViews[1].pinAttribute(.Right, toAttribute: .Right, ofItem: gameBoardView, withConstant: -15)
            
        } else {
            for label in labelPointsViews {
                gameController.view.addSubview(label)
                label.setTranslatesAutoresizingMaskIntoConstraints(false)
                label.textAlignment = .Center
                
                label.font = UIFont(name: "SchoolBell", size: 40)
                
                label.constrainToSize(CGSizeMake(screenWidth / 2, 100))
                label.pinAttribute(.Right, toAttribute: .Right, ofItem: gameController.view, withConstant: 20)
            }
            
            labelPointsViews[0].pinAttribute(.Top, toAttribute: .Top, ofItem: gameController.view, withConstant: 200)
            labelPointsViews[1].pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: gameController.view, withConstant: -200)
        }
    }
    
    func addRow(rowindex : Int) {
        let row = UIView()
        row.tag = rowindex
        
        gameBoardView.addSubview(row)
        row.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var plus = Int(6) * Int(gridDimension)
        
        var rowHeight : CGFloat =  gameBoardViewHeight / CGFloat(gridDimension) + CGFloat(plus)
        
        row.constrainToSize(CGSizeMake(gameBoardViewWidth, rowHeight))
        row.centerInContainerOnAxis(.CenterX)
        
        allRows += [row]

        addRowPosition(row, index: rowindex)
    }

    func addRowPosition(row : UIView, index : Int) {
        if index == 0 {
            row.pinAttribute(.Top, toAttribute: .Top, ofItem: gameBoardView)
        } else if index == 1 {
            row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: gameBoardView.subviews[0], withConstant: -30)
        } else if index == 2 {
            row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: gameBoardView.subviews[1], withConstant: -30)
        } else if index == 3 {
            row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: gameBoardView.subviews[2], withConstant: -30)
        } else if index == 4 {
            row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: gameBoardView.subviews[3], withConstant: -30)
        } else if index == 5 {
            row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: gameBoardView.subviews[4], withConstant: -30)
        }
    }
    
    func addSquare(rowIndex : Int, squareIndex : Int) -> UIView {
        let square = UIView ()
        square.tag = squareIndex

        allRows[rowIndex].addSubview(square)

        square.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var plus = Int(6.25) * Int(gridDimension)
        
        var squareWidth : CGFloat = gameBoardViewWidth / CGFloat(gridDimension) + CGFloat(plus)
        var squareHeight : CGFloat = gameBoardViewHeight / CGFloat(gridDimension) + CGFloat(plus)
        
        square.constrainToSize(CGSizeMake(squareWidth, squareHeight))

        allSquares += [square]
        
        addSquarePosition(square, squareIndex: squareIndex, rowIndex: rowIndex, margin: CGFloat(plus))
        
        return square
    }
    
    func addSquarePosition(square : UIView, squareIndex : Int, rowIndex : Int, margin : CGFloat) {
        
        if squareIndex == 0 {
            square.centerInContainerOnAxis(.CenterY)
            square.pinAttribute(.Left, toAttribute: .Left, ofItem: allRows[rowIndex], withConstant: 0)
        } else if squareIndex == 1 {
            square.centerInContainerOnAxis(.CenterY)
            square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[0], withConstant: -(margin + 6))
        } else if squareIndex == 2 {
            square.centerInContainerOnAxis(.CenterY)
            square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[1], withConstant: -(margin + 6))
        } else if squareIndex == 3 {
            square.centerInContainerOnAxis(.CenterY)
            square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[2], withConstant: -(margin + 6))
        } else if squareIndex == 4 {
            square.centerInContainerOnAxis(.CenterY)
            square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[3], withConstant: -(margin + 6))
        }
    }
    
    func addStripe(stripeIndex : Int, square : UIView) -> UIButton {
        let stripe = UIButton()
        
        stripe.selected = false
        square.clipsToBounds = false
        square.addSubview(stripe)
        
        stripe.setTranslatesAutoresizingMaskIntoConstraints(false)
        addStripePosition(stripe, square: square, stripeIndex: stripeIndex)
        
        stripe.setImage(UIImage(named: "\(position[stripe]!.rawValue)_stripeBackground"), forState: .Normal)

        return stripe
    }
    
    func addStripePosition(stripe : UIButton, square : UIView, stripeIndex : Int) {
        var stripeWidth : CGFloat = gameBoardViewWidth / CGFloat(gridDimension)
        var stripeHeight : CGFloat = gameBoardViewHeight / CGFloat(gridDimension)
        var margin = CGFloat(0) as CGFloat
        
        if stripeIndex == 0 {
            stripe.constrainToSize(CGSizeMake(stripeWidth - 12, 30))
            stripe.pinAttribute(.Left, toAttribute: .Left, ofItem: square, withConstant: 15)
            stripe.pinAttribute(.Top, toAttribute: .Top, ofItem: square)
            position[stripe] = .Top
        } else if stripeIndex == 1 {
            stripe.constrainToSize(CGSizeMake(30, stripeHeight - 12))
            stripe.pinAttribute(.Right, toAttribute: .Right, ofItem: square, withConstant: -5)
            stripe.pinAttribute(.Top, toAttribute: .Top, ofItem: square, withConstant: 15)
            position[stripe] = .Right
        } else if stripeIndex == 2 {
            stripe.constrainToSize(CGSizeMake(stripeWidth - 12, 30))
            stripe.pinAttribute(.Left, toAttribute: .Left, ofItem: square, withConstant: 15)
            stripe.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: square)
            position[stripe] = .Bottom
        } else if stripeIndex == 3 {
            stripe.constrainToSize(CGSizeMake(30, stripeHeight - 12))
            stripe.pinAttribute(.Left, toAttribute: .Left, ofItem: square)
            stripe.pinAttribute(.Top, toAttribute: .Top, ofItem: square, withConstant: 15)
            position[stripe] = .Left
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
            button.userInteractionEnabled = false
        }
    }
    
    func giveColorToScoredSquares() {
        var game: PFObject = gameObject[0] as PFObject
        
        for squareObject in game["allScoredSquares"] as NSArray {
            var square: UIView = allRows[squareObject["rowIndex"] as Int].subviews[squareObject["squareIndex"] as Int] as UIView
            
            if squareObject["userId"] as NSString == PFUser.currentUser().objectId {
                addSquareBackgroundImage(square, content: "fullSquareBlue")
            } else {
                addSquareBackgroundImage(square, content: "fullSquareRed")
            }
        }
    }
    
    func addSquareBackgroundImage(square : UIView, content : String ) {
        var image = UIImage(named: "\(content)")
        var imageV = UIImageView(image: image)
        imageV.setTranslatesAutoresizingMaskIntoConstraints(false)
        var width = gameBoardViewWidth / CGFloat(gridDimension)
        var height = gameBoardViewHeight / CGFloat(gridDimension)
        
        square.insertSubview(imageV, atIndex: 0)
        square.sendSubviewToBack(imageV)
        
        var x : CGFloat = CGFloat(Int(120) / Int(gridDimension))
        
        imageV.constrainToSize(CGSizeMake(width - x, height - x))
        
        imageV.pinAttribute(.Top, toAttribute: .Top, ofItem: square, withConstant: 25)
        imageV.pinAttribute(.Left, toAttribute: .Left, ofItem: square, withConstant: 25)
    }
    
    func selectCurrentStripe(stripe : UIButton, oldStripe : UIButton, doubleStripe: UIButton, oldDoubleStripe: UIButton, submitBtn : UIButton) -> UIButton {
        if stripe != oldStripe {
            var image = UIImage(named: "\(position[stripe]!.rawValue)_currentBlueStripe") as UIImage?
            stripe.setImage(image, forState: .Normal)
            animateStripe(stripe, delay: 0, startFloat: 0.4)
            stripe.selected = true
            
            doubleStripe.selected = true
            
            oldStripe.selected = false
            if oldStripe.superview != nil {
                oldStripe.setImage(UIImage(named: "\(position[oldStripe]!.rawValue)_stripeBackground") , forState: .Normal)
            }
            
            oldDoubleStripe.selected = false
            oldDoubleStripe.backgroundColor = UIColor.clearColor()
            
        } else if stripe == oldStripe && stripe.selected == false {
            var image = UIImage(named: "\(position[stripe]!.rawValue)_currentBlueStripe") as UIImage?
            stripe.setImage(image, forState: .Normal)
            animateStripe(stripe, delay: 0, startFloat: 0.4)
            stripe.selected = true
            
            doubleStripe.selected = true
            
        } else {
            stripe.setImage(UIImage(named: "\(position[oldStripe]!.rawValue)_stripeBackground"), forState: .Normal)
            stripe.selected = false
            
            doubleStripe.selected = false
            
            oldStripe.selected = false
            oldDoubleStripe.selected = false
        }
        
        if stripe.selected == false  {
            submitBtn.hidden = true
        } else {
            submitBtn.hidden = false
        }
        
        return stripe
    }
    
    func addSubmitBtn(submitBtn : UIButton) {        
        gameController.view.addSubview(submitBtn)
        
        submitBtn.setTranslatesAutoresizingMaskIntoConstraints(false)

        submitBtn.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: gameController.view, withConstant: -5)
        submitBtn.centerInContainerOnAxis(.CenterX)
        
        if (UIInterfaceOrientationIsPortrait(gameController.interfaceOrientation)) {
            submitBtn.setImage(UIImage(named: "playBtniPhone"), forState: .Normal)
            submitBtn.constrainToSize(CGSizeMake(screenWidth - 10, 50))
        } else {
            submitBtn.setImage(UIImage(named: "playBtniPad"), forState: .Normal)
            submitBtn.constrainToSize(CGSizeMake(screenWidth - 10, 60))
        }
        
        submitBtn.hidden = true
    }
    
    func stylingWhenSubmittingStripe(submitBtn : UIButton) {
        submitBtn.hidden = true
        loadingContainer = loadingView().showActivityIndicator(gameController.view)
        
        gameController.navigationController!.navigationBarHidden = true
    }
    
    func removeStylingWhenSubmit(stripeToSubmit : UIButton) {
        stripeToSubmit.userInteractionEnabled = false
        
        var image = UIImage(named: "\(position[stripeToSubmit]!.rawValue)_blueStripe") as UIImage?
        stripeToSubmit.setImage(image, forState: .Normal)
        
        loadingView().hideActivityIndicator(loadingContainer)
        gameController.navigationController!.navigationBarHidden = false
    }
    
    func selectDoubleStripe(stripe : UIButton) -> UIButton {
        var squareOfStripeTag = stripe.superview!.tag
        var rowOfStripe = stripe.superview!.superview!
        var doubleStripe = UIButton()
        
        if squareOfStripeTag > 0 {
            if position[stripe] == .Left {
                var doubleStripe: UIButton = rowOfStripe.subviews[squareOfStripeTag - 1].subviews[1] as UIButton
                doubleStripe.selected = true
                
                return doubleStripe
            }
        }
        
        if rowOfStripe.tag > 0 {
            if position[stripe] == .Top {
                var doubleStripe: UIButton = allRows[rowOfStripe.tag - 1].subviews[squareOfStripeTag].subviews[2] as UIButton
                doubleStripe.selected = true
                
                return doubleStripe
            }
        }
        
        return UIButton()
    }
    
    func updateUserPoints(pointsToAdd : Int) -> Int {
        userPoints += pointsToAdd

        userPointsView.text = "You: \(userPoints)"
        
        return userPoints
    }
    
    func colorSelectedStripes(rowIndex : Int, squareIdx : Int, stripe: UIButton, boardObject : Board, userBoard : Bool) {
        if boardObject.board[rowIndex][squareIdx].isStripeSelected(position[stripe]!) {
            if userBoard {
                var image = UIImage(named: "\(position[stripe]!.rawValue)_blueStripe") as UIImage?
                stripe.setImage(image, forState: .Normal)
            } else {
                var image = UIImage(named: "\(position[stripe]!.rawValue)_redStripe") as UIImage?
                stripe.setImage(image, forState: .Normal)
            }

            stripe.selected = true
            stripe.userInteractionEnabled = false
            
            selectDoubleStripe(stripe)
        }
    }
    
    func selectLastPlayedStripe() {
        var lastStripeObject = gameObject[0]["lastStripe"] as NSArray
        var lastStripe = UIButton()
        
        if lastStripeObject != [] {
            var rowIndex = lastStripeObject[0]["rowIndex"] as Int
            var squareIndex = lastStripeObject[0]["squareIndex"] as Int
            var stripeIndex = lastStripeObject[0]["stripeIndex"] as Int
            
            
            if allRows[rowIndex].subviews[squareIndex].subviews.count == 4 {
                lastStripe = allRows[rowIndex].subviews[squareIndex].subviews[stripeIndex] as UIButton
            } else if allRows[rowIndex].subviews[squareIndex].subviews.count == 5 {
                lastStripe = allRows[rowIndex].subviews[squareIndex].subviews[stripeIndex + 1] as UIButton
            }
            
            lastStripe.backgroundColor = UIColor(patternImage: UIImage(named:"\(position[lastStripe]!.rawValue)_stripeBackground")!)
            
            if lastStripeObject[0]["userId"] as NSString == PFUser.currentUser().objectId {
                lastStripe.setImage(UIImage(named: "\(position[lastStripe]!.rawValue)_currentBlueStripe"), forState: .Normal)
            } else {
                lastStripe.setImage(UIImage(named: "\(position[lastStripe]!.rawValue)_currentRedStripe"), forState: .Normal)
            }
            
            animateStripe(lastStripe, delay: 0.6, startFloat: 0.000001)
        }
    }
    
    func animateStripe(button : UIButton, delay : Double, startFloat : CGFloat) {
        if position[button] == .Top || position[button] == .Bottom {
            button.imageView!.transform = CGAffineTransformMakeScale(startFloat, 1.0)
            button.imageView!.layer.anchorPoint = CGPointMake(0, 0.5)
        } else {
            button.imageView!.transform = CGAffineTransformMakeScale(1.0, startFloat)
            button.imageView!.layer.anchorPoint = CGPointMake(0.5, 0)
        }
        
        UIView.animateWithDuration(0.1, delay: delay, options: UIViewAnimationOptions.CurveLinear, animations: {
            button.imageView!.transform = CGAffineTransformIdentity
            button.backgroundColor = UIColor.clearColor()
            }, completion: (nil)
        )
    }
    
    func animateSquare(bgImage : UIImageView, delay : Double) {
        bgImage.transform = CGAffineTransformMakeScale(1.0, 0.00001)
        bgImage.layer.anchorPoint = CGPointMake(0, 0)
        
        UIView.animateWithDuration(0.2, delay: delay, options: UIViewAnimationOptions.CurveLinear, animations: {
            bgImage.transform = CGAffineTransformIdentity
            }, completion: (nil)
        )
    }
    
    func viewsToRemove() {
        gameBoardView.removeFromSuperview()
    }
}