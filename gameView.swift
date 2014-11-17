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
    
    let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    
    private var gameBoardViewHeight : CGFloat = 0
    private var gameBoardViewWidth : CGFloat = 0
    
    private var allRows : [UIView] = []
    private var allSquares : [UIView] = []
    
    var position = [UIButton: StripeType]()
    
    init (gameControl : UIViewController, dimension : Int, gameObj : [AnyObject]) {
        gameController = gameControl
        gameObject = gameObj
        gridDimension = dimension
    }

    func addGameBoard() {
        gameController.view.addSubview(gameBoardView)
        gameBoardView.setTranslatesAutoresizingMaskIntoConstraints(false)
        gameBoardView.backgroundColor = UIColor.redColor()
        
        if (UIInterfaceOrientationIsPortrait(gameController.interfaceOrientation)) {
            
            gameBoardViewHeight = screenHeight - 200
            gameBoardViewWidth = screenWidth - 10
            
            gameBoardView.centerInContainerOnAxis(.CenterX)
            gameBoardView.constrainToSize(CGSizeMake(gameBoardViewWidth, gameBoardViewHeight))
            gameBoardView.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: gameController.view, withConstant: -75)
            
        } else {
            gameBoardViewHeight = screenHeight - 150
            gameBoardViewWidth = (screenWidth / 2) + 100
            
            gameBoardView.centerInContainerOnAxis(.CenterY)
            gameBoardView.constrainToSize(CGSizeMake(gameBoardViewWidth, gameBoardViewHeight))
            gameBoardView.pinAttribute(.Left, toAttribute: .Left, ofItem: gameController.view, withConstant: 10)
        }
    }
    
    func addRow(rowindex : Int) {
        let row = UIView()
        row.tag = rowindex
        
        gameBoardView.addSubview(row)
        row.setTranslatesAutoresizingMaskIntoConstraints(false)
        row.backgroundColor = UIColor.whiteColor()
        
        var rowHeight : CGFloat =  gameBoardViewHeight / CGFloat(gridDimension)
        
        row.constrainToSize(CGSizeMake(gameBoardViewWidth, rowHeight))
        row.centerInContainerOnAxis(.CenterX)
        
        allRows += [row]

        addRowPosition(row, index: rowindex)
    }

    func addRowPosition(row : UIView, index : Int) {
        if index == 0 {
            row.pinAttribute(.Top, toAttribute: .Top, ofItem: gameBoardView)
        } else if index == 1 {
            row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: gameBoardView.subviews[0])
        } else if index == 2 {
            row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: gameBoardView.subviews[1])
        } else if index == 3 {
            row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: gameBoardView.subviews[2])
        } else if index == 4 {
            row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: gameBoardView.subviews[3])
        } else if index == 5 {
            row.pinAttribute(.Top, toAttribute: .Bottom, ofItem: gameBoardView.subviews[4])
        }
    }
    
    func addSquare(rowIndex : Int, squareIndex : Int) -> UIView {
        let square = UIView ()
        square.tag = squareIndex
        
        allRows[rowIndex].addSubview(square)
        
        square.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var squareWidth : CGFloat = gameBoardViewWidth / CGFloat(gridDimension)
        var squareHeight : CGFloat = gameBoardViewHeight / CGFloat(gridDimension)
        
        square.constrainToSize(CGSizeMake(squareWidth, squareHeight))

        allSquares += [square]
        
        addSquarePosition(square, squareIndex: squareIndex, rowIndex: rowIndex)
        
        return square
    }
    
    func addSquarePosition(square : UIView, squareIndex : Int, rowIndex : Int) {
        if squareIndex == 0 {
            square.centerInContainerOnAxis(.CenterY)
            square.pinAttribute(.Left, toAttribute: .Left, ofItem: allRows[rowIndex])
        } else if squareIndex == 1 {
            square.centerInContainerOnAxis(.CenterY)
            square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[0])
        } else if squareIndex == 2 {
            square.centerInContainerOnAxis(.CenterY)
            square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[1])
        } else if squareIndex == 3 {
            square.centerInContainerOnAxis(.CenterY)
            square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[2])
        } else if squareIndex == 4 {
            square.centerInContainerOnAxis(.CenterY)
            square.pinAttribute(.Left, toAttribute: .Right, ofItem: allSquares[3])
        }
    }
    
    func addStripe(stripeIndex : Int, square : UIView) -> UIButton {
        let stripe = UIButton ()
        
        stripe.selected = false
        stripe.layer.borderWidth = 1
        stripe.layer.borderColor = UIColor.blackColor().CGColor
        stripe.backgroundColor = UIColor.whiteColor()

        square.addSubview(stripe)
        
        stripe.setTranslatesAutoresizingMaskIntoConstraints(false)
        addStripePosition(stripe, square: square, stripeIndex: stripeIndex)
        
//        addStripeTag(stripeIndex, stripe: stripe)
        
        return stripe
    }
    
    func addStripePosition(stripe : UIButton, square : UIView, stripeIndex : Int) {
        var stripeWidth : CGFloat = gameBoardViewWidth / CGFloat(gridDimension)
        var stripeHeight : CGFloat = gameBoardViewHeight / CGFloat(gridDimension)

        if stripeIndex == 0 {
            stripe.constrainToSize(CGSizeMake(stripeWidth, 20))
            stripe.pinAttribute(.Left, toAttribute: .Left, ofItem: square)
            stripe.pinAttribute(.Top, toAttribute: .Top, ofItem: square)
            position[stripe] = .Top
        } else if stripeIndex == 1 {
            stripe.constrainToSize(CGSizeMake(20, stripeHeight))
            stripe.pinAttribute(.Right, toAttribute: .Right, ofItem: square)
            stripe.pinAttribute(.Top, toAttribute: .Top, ofItem: square)
            position[stripe] = .Right
        } else if stripeIndex == 2 {
            stripe.constrainToSize(CGSizeMake(stripeWidth, 20))
            stripe.pinAttribute(.Left, toAttribute: .Left, ofItem: square)
            stripe.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: square)
            position[stripe] = .Bottom
        } else if stripeIndex == 3 {
            stripe.constrainToSize(CGSizeMake(20, stripeHeight))
            stripe.pinAttribute(.Left, toAttribute: .Left, ofItem: square)
            stripe.pinAttribute(.Top, toAttribute: .Top, ofItem: square)
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
        }
    }
    
    func currentSelectedStripe(stripe : UIButton, oldStripe : UIButton, doubleStripe : UIButton) -> UIButton {
        if stripe != oldStripe {
            oldStripe.backgroundColor = UIColor.whiteColor()
            stripe.backgroundColor = UIColor.colorWithRGBHexWithAlpha(0x5AB103, alpha: 0.7)
            oldStripe.selected = false
            stripe.selected = true
            doubleStripe
        } else if stripe == oldStripe && stripe.selected == false {
            stripe.backgroundColor = UIColor.colorWithRGBHexWithAlpha(0x5AB103, alpha: 0.7)
            stripe.selected = true
        } else {
            stripe.backgroundColor = UIColor.whiteColor()
            stripe.selected = false
            oldStripe.selected = false
        }
        
        return stripe
    }
    
    func addSubmitBtn(submitBtn : UIButton) {
        submitBtn.setTitle("Play", forState: .Normal)
        submitBtn.backgroundColor = UIColor.colorWithRGBHex(0x5AB103)
        
        gameController.view.addSubview(submitBtn)
        submitBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        submitBtn.constrainToSize(CGSizeMake(screenWidth - 10, 50))
        submitBtn.centerInContainerOnAxis(.CenterX)
        submitBtn.pinAttribute(.Top, toAttribute: .Bottom, ofItem: gameBoardView, withConstant: 10)
        
        submitBtn.hidden = true
    }
    
    func stylingWhenSubmittingStripe(submitBtn : UIButton) {
        submitBtn.hidden = true
        loadingView().showActivityIndicator(gameController.view)
        
        gameController.navigationController!.navigationBarHidden = true
        
    }
    
    func selectDoubleStripe(stripe : UIButton) -> UIButton {
        var squareOfStripeTag = stripe.superview!.tag
        var rowOfStripe = stripe.superview!.superview!
        var doubleStripe = UIButton()
        
        if squareOfStripeTag > 0 {
            if position[stripe] == .Left {
                var doubleStripe: UIButton = rowOfStripe.subviews[squareOfStripeTag - 1].subviews[1] as UIButton
                doubleStripe.selected = true
                doubleStripe.backgroundColor = UIColor.yellowColor()
                
                return doubleStripe
            }
        }
        
        if rowOfStripe.tag > 0 {
            if position[stripe] == .Top {
                var doubleStripe: UIButton = allRows[rowOfStripe.tag - 1].subviews[squareOfStripeTag].subviews[2] as UIButton
                doubleStripe.selected = true
                doubleStripe.backgroundColor = UIColor.yellowColor()
                
                return doubleStripe
            }
        }
        
        return UIButton()
    }
    
    func colorSelectedStripes(rowIndex : Int, squareIdx : Int, stripe: UIButton, boardObject : Board, userBoard : Bool) {
        if boardObject.board[rowIndex][squareIdx].isSelected(position[stripe]!) {
            if userBoard {
                stripe.backgroundColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 0.8)
            } else {
                stripe.backgroundColor = UIColor.colorWithRGBHex(0xD32121, alpha: 0.8)
            }
            
            stripe.selected = true
            stripe.userInteractionEnabled = false
            
            selectDoubleStripe(stripe)
        }
    }
}