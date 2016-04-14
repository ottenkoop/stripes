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
    var restartText = UILabel()
    var continuButton : UIButton = UIButton()
    var titleLabel = UILabel()

    
    func openPopup(uiView: UIView, finishBtn : UIButton) -> [UIButton] {
        addContainerView(uiView)
        defaultContainerSetup()
        addRestartText()
        
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
        
        var buttonArray : [UIButton] = []
        continuButton = finishBtn
        addContinuButton()
        scoreBoardView().addScoreBoard(container)
        
        buttonArray = [continuButton]
        
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
        container.pulseToSize(1.1, duration: 0.2, repeat: false)
        
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
        textLabelView.text = "Awesome! You've won the Game."
    }
    
    func gameDidFinishWithOpponentWinner() {
        textLabelView.text = "Uh oh! You've lost this time. Try again!"
    }
    
    func gameDidFinishDraw() {
        textLabelView.text = "It's a draw. At least you didn't lose!"
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
    
    func addContinuButton() -> UIButton {
//        continuButton.setTitle("Continue", forState: .Normal)
        continuButton.translatesAutoresizingMaskIntoConstraints = false
        continuButton.setImage(UIImage(named: "yesBtn"), forState: .Normal)
        
        container.addSubview(continuButton)
        
//        continuButton.addTarget(self, action: "btnTouched:", forControlEvents: UIControlEvents.TouchDown)
        
        continuButton.constrainToHeight(50)
        continuButton.centerInContainerOnAxis(.CenterX)
        continuButton.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: container, withConstant: -10)
        
        return continuButton
    }
    
    func addRestartText() {
        restartText.text = "Play again?"
        restartText.font = UIFont(name: "HanziPen SC", size: 28)
        
        container.addSubview(restartText)
        

        restartText.translatesAutoresizingMaskIntoConstraints = false
        restartText.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: container, withConstant: -80)
        
        restartText.centerInContainerOnAxis(.CenterX)
    }
    
//    func addContainerInformationView() {
//        container.addSubview(centerInformationText)
//        container.bringSubviewToFront(centerInformationText)
//        
//        centerInformationText.translatesAutoresizingMaskIntoConstraints = false
//        centerInformationText.pinAttribute(.Left, toAttribute: .Left, ofItem: container)
//        centerInformationText.pinAttribute(.Right, toAttribute: .Right, ofItem: container)
//        centerInformationText.pinAttribute(.Top, toAttribute: .Top, ofItem: container, withConstant: 75)
//        centerInformationText.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: container, withConstant: -125)
//    }
    
    func btnTouched(sender:UIButton!) {
        print("jaaaa");
    }
    
}