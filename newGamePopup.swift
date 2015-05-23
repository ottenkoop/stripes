//
//  bannerView.swift
//  Stripes
//
//  Created by Koop Otten on 03/12/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class newGamePopup {
    var overViewControl : UIViewController = UIViewController()
    var container: UIView = UIView()
    var background: UIView = UIView()
    var buttonArea: UIView = UIView()
    
    var faceBookFriend : UIButton = UIButton()
    var userSearch : UIButton = UIButton()
    var randomOpp : UIButton = UIButton()
    var cancelBtn: UIButton = UIButton()
    
    func openPopup(overViewController : UIViewController) -> NSArray {
        overViewControl = overViewController
        
        addContainerView(overViewControl.view)
        
        var buttonArray : NSArray = []
        var buttonsToSpace : NSArray = []
        addCancelBtn()
        
        if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
            addFaceBookFriendsBtn()
            buttonsToSpace = [faceBookFriend, userSearch, randomOpp]
        } else {
            faceBookFriend.userInteractionEnabled = false
            buttonsToSpace = [userSearch, randomOpp]
        }
        
        addUserNameBtn()
        addRandomOppBtn()
        
        // first el always 1btn, etc..
        buttonArray = [faceBookFriend, userSearch, randomOpp, cancelBtn]
        
        buttonArea.spaceViews(buttonsToSpace as! [AnyObject], onAxis: .Vertical)
        
        return buttonArray
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

        container.pulseToSize(1.1, duration: 0.2, repeat: false)
        
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
        
        titleLabel.text = "New Battle"
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
    
    func addFaceBookFriendsBtn() {
        faceBookFriend.setTranslatesAutoresizingMaskIntoConstraints(false)
        faceBookFriend.setImage(UIImage(named: "faceBookFriends"), forState: .Normal)
        
        buttonArea.addSubview(faceBookFriend)
        
        faceBookFriend.constrainToSize(CGSizeMake(278, 50))
        faceBookFriend.centerInContainerOnAxis(.CenterX)
    }
    
    func addUserNameBtn() {
        userSearch.setTranslatesAutoresizingMaskIntoConstraints(false)
        userSearch.setImage(UIImage(named: "userSearchBtn"), forState: .Normal)
        
        buttonArea.addSubview(userSearch)
        
        userSearch.constrainToSize(CGSizeMake(278, 50))
        userSearch.centerInContainerOnAxis(.CenterX)
    }
    
    func addRandomOppBtn() {
        randomOpp.setTranslatesAutoresizingMaskIntoConstraints(false)
        randomOpp.setImage(UIImage(named: "randomSearchBtn"), forState: .Normal)
        
        buttonArea.addSubview(randomOpp)
        
        randomOpp.constrainToSize(CGSizeMake(278, 50))
        randomOpp.centerInContainerOnAxis(.CenterX)
    }
    
    func addCancelBtn() {
        cancelBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        cancelBtn.setImage(UIImage(named: "cancelBtniPhone"), forState: .Normal)
        
        container.addSubview(cancelBtn)
        
        cancelBtn.constrainToHeight(50)
        cancelBtn.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: container, withConstant: -10)
        cancelBtn.pinAttribute(.Left, toAttribute: .Left, ofItem: container, withConstant: 10)
        cancelBtn.pinAttribute(.Right, toAttribute: .Right, ofItem: container, withConstant: -10)
    }
    
    func removePopup(button : UIButton) {
        button.superview!.superview!.superview!.removeFromSuperview()
    }
    
    func cancelPopup(button : UIButton) {
        button.superview!.superview!.removeFromSuperview()
    }
}