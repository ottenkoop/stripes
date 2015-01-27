//
//  weekBattleFinished.swift
//  Stripes
//
//  Created by Koop Otten on 26/01/15.
//  Copyright (c) 2015 KoDev. All rights reserved.
//

import Foundation

class weekBattleFinished {
    var overViewControl : UIViewController = UIViewController()
    var container: UIView = UIView()
    var background: UIView = UIView()
    var buttonArea: UIView = UIView()
    
    var resetButton : UIButton = UIButton()
    var deleteButton : UIButton = UIButton()
    
    func openPopup(overViewController : UIViewController, uPoints : Int, oppPoints : Int) {
        overViewControl = overViewController
        
        addContainerView(overViewControl.view)
        
        println(uPoints)
        println(oppPoints)
        
        if uPoints > oppPoints {
            addWinNotification()
        } else if oppPoints > uPoints {
            println("lost...")
        } else {
            println("fucking draw")
        }
        
//        var buttonArray : NSArray = []
//        var buttonsToSpace : NSArray = []
        
//        addUserNameBtn()
//        addRandomOppBtn()
        
        // first el always 1btn, etc..
//        buttonArray = [resetButton, deleteButton]
        
//        buttonArea.spaceViews(buttonsToSpace, onAxis: .Horizontal)
//        
//        return buttonArray
    }
    
    func addContainerView(uiView : UIView) {
        background.frame = uiView.frame
        background.backgroundColor = UIColor.colorWithRGBHexWithAlpha(0x444444, alpha: 0.2)
        
        container.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        container.layer.borderWidth = 1.0
        container.layer.borderColor = UIColor.colorWithRGBHex(0x979797, alpha: 1.0).CGColor
        container.backgroundColor = UIColor.whiteColor()
        container.layer.cornerRadius = 8
        
        uiView.addSubview(background)
        
        background.addSubview(container)
        
        container.pulseToSize(1.1, duration: 0.4, repeat: false)
        
        if (UIInterfaceOrientationIsPortrait(overViewControl.interfaceOrientation)) {
            container.constrainToSize(CGSizeMake(uiView.bounds.width - 20, uiView.bounds.height - 100))
            container.centerInContainerOnAxis(.CenterX)
        } else {
            container.constrainToSize(CGSizeMake(500, uiView.bounds.height - 130))
            container.centerInContainerOnAxis(.CenterX)
        }
        
        container.pinAttribute(.Top, toAttribute: .Top, ofItem: uiView, withConstant: 70)
        
        addTitleLabel()
    }
    
    func addTitleLabel() {
        var titleLabel = UILabel()
        
        titleLabel.text = "Time's Up!"
        titleLabel.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
        titleLabel.font = UIFont(name: "HanziPen SC", size: 36)
        
        container.addSubview(titleLabel)
        container.addSubview(buttonArea)
        
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        buttonArea.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        titleLabel.pinAttribute(.Top, toAttribute: .Top, ofItem: container, withConstant: 5)
        titleLabel.centerInContainerOnAxis(.CenterX)
        
        buttonArea.pinAttribute(.Top, toAttribute: .Bottom, ofItem: titleLabel)
        buttonArea.pinAttribute(.Right, toAttribute: .Right, ofItem: container)
        buttonArea.pinAttribute(.Left, toAttribute: .Left, ofItem: container)
        buttonArea.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: container, withConstant: -60)
    }
    
    func addWinNotification() {
//        faceBookFriend.setTranslatesAutoresizingMaskIntoConstraints(false)
//        faceBookFriend.setImage(UIImage(named: "faceBookFriends"), forState: .Normal)
//        
//        buttonArea.addSubview(faceBookFriend)
//        
//        faceBookFriend.constrainToSize(CGSizeMake(278, 50))
//        faceBookFriend.centerInContainerOnAxis(.CenterX)
    }
//
//    func addUserNameBtn() {
//        userSearch.setTranslatesAutoresizingMaskIntoConstraints(false)
//        userSearch.setImage(UIImage(named: "userSearchBtn"), forState: .Normal)
//        
//        buttonArea.addSubview(userSearch)
//        
//        userSearch.constrainToSize(CGSizeMake(278, 50))
//        userSearch.centerInContainerOnAxis(.CenterX)
//    }
//    
//    func addRandomOppBtn() {
//        randomOpp.setTranslatesAutoresizingMaskIntoConstraints(false)
//        randomOpp.setImage(UIImage(named: "randomSearchBtn"), forState: .Normal)
//        
//        buttonArea.addSubview(randomOpp)
//        
//        randomOpp.constrainToSize(CGSizeMake(278, 50))
//        randomOpp.centerInContainerOnAxis(.CenterX)
//    }
//    
//    func addCancelBtn() {
//        cancelBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
//        cancelBtn.setImage(UIImage(named: "cancelBtniPhone"), forState: .Normal)
//        
//        container.addSubview(cancelBtn)
//        
//        cancelBtn.constrainToHeight(50)
//        cancelBtn.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: container, withConstant: -10)
//        cancelBtn.pinAttribute(.Left, toAttribute: .Left, ofItem: container, withConstant: 10)
//        cancelBtn.pinAttribute(.Right, toAttribute: .Right, ofItem: container, withConstant: -10)
//    }
    
    func removePopup(button : UIButton) {
        button.superview!.superview!.superview!.removeFromSuperview()
    }
    
    func cancelPopup(button : UIButton) {
        button.superview!.superview!.removeFromSuperview()
    }
}