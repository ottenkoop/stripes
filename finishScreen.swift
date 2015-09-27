//
//  finishScreen.swift
//  Stripes
//
//  Created by Koop Otten on 10/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation
import UIKit

class finishScreen {
    
    var vController : UIViewController = UIViewController()
    var container : UIView = UIView()
    var textLabelView = UILabel()
    var continuButton : UIButton = UIButton()
    var titleLabel = UILabel()

    
    func openPopup(uiView: UIView, finishBtn : UIButton) -> NSArray {
        addContainerView(uiView)
        
        switch finishBtn.tag {
        case 1:
            gameDidFinishWithCurrentUserWinner()
        case 2:
            gameDidFinishWithOpponentWinner()
        case 3:
            gameDidFinishDraw()
        default:
            "what?"
        }
        
        let buttonArray : NSArray = []
//        addSpecial1Btn()
//        addSpecial2Btn()
//        addCancelBtn()
        
//         first el always 1btn, etc..
//        buttonArray = [special1Btn, special2Btn, cancelBtn]
        
        return buttonArray
    }
    
    func addContainerView(uiView : UIView) {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.constrainToSize(CGSizeMake(uiView.bounds.width - 20, uiView.bounds.height - 100))
        
        container.layer.borderWidth = 1.0
        container.layer.borderColor = UIColor.colorWithRGBHex(0x979797, alpha: 1.0).CGColor
        container.backgroundColor = UIColor.whiteColor()
        container.layer.cornerRadius = 8
        
        uiView.addSubview(container)
        container.pulseToSize(1.1, duration: 0.2, `repeat`: false)
        
        container.pinAttribute(.Top, toAttribute: .Top, ofItem: uiView, withConstant: 70)
        container.centerInContainerOnAxis(.CenterX)
        
        addTitleLabel()
    }
    
    func addTitleLabel() {
        titleLabel.text = "Game Finished!"
        titleLabel.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
        titleLabel.font = UIFont(name: "HanziPen SC", size: 36)
        
        container.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.pinAttribute(.Top, toAttribute: .Top, ofItem: container, withConstant: 5)
        titleLabel.centerInContainerOnAxis(.CenterX)
    }
    
    
    func gameDidFinishWithCurrentUserWinner() {
        textLabelView.text = "Awesome! You've won this round."
        var winBtn = defaultContainerSetup()

    }
    
    func gameDidFinishWithOpponentWinner() {
//        container.view.backgroundColor = UIColor.redColor()
//        textView.backgroundColor = UIColor.redColor()
//        textView.text = "Uh oh! You've lost this time. Try again!"
        
//        var lostBtn = defaultContainerSetup(uiControl.view, userTurn: userTurn)
//        
//        return lostBtn
    }
    
    func gameDidFinishDraw() {
//        var drawBtn = defaultContainerSetup(uiControl.view, userTurn: userTurn)

//        container.view.backgroundColor = UIColor.orangeColor()
//        textView.backgroundColor = UIColor.orangeColor()
//        textView.text = "It's a draw. At least you didn't lose this game!"
        
//        return drawBtn
    }
    
    func defaultContainerSetup() -> UIButton {
        textLabelView.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
        textLabelView.font = UIFont(name: "HanziPen SC", size: 20)

        container.addSubview(textLabelView)
        
        textLabelView.translatesAutoresizingMaskIntoConstraints = false
        textLabelView.pinAttribute(.Top, toAttribute: .Top, ofItem: container, withConstant: 100)
        textLabelView.centerInContainerOnAxis(.CenterX)
        
        let btn = UIButton()
        
        return btn
    }
    
    func addContinuButton(uiView: UIView) -> UIButton {
        continuButton.setTitle("Continue", forState: .Normal)
        continuButton.backgroundColor = UIColor.blueColor()
        
        uiView.addSubview(continuButton)
        
        continuButton.translatesAutoresizingMaskIntoConstraints = false
        continuButton.constrainToSize(CGSizeMake(uiView.bounds.width - 10, 50))
        continuButton.centerInContainerOnAxis(.CenterX)
        continuButton.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: uiView, withConstant: -10)
        
        return continuButton
    }
    
    /*
    Define UIColor from hex value
    
    @param rgbValue - hex color value
    @param alpha - transparency level
    */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}