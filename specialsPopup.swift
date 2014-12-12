//
//  specialsPopup.swift
//  Stripes
//
//  Created by Koop Otten on 08/12/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class specialsPopup {
    var container: UIView = UIView()
    var special1Btn : UIButton = UIButton()
    var special2Btn : UIButton = UIButton()
    var cancelBtn : UIButton = UIButton()
    
    func openPopup(uiView: UIView) -> NSArray {
        addContainerView(uiView)
        
        var buttonArray : NSArray = []
        addSpecial1Btn()
        addSpecial2Btn()
        addCancelBtn()
        
        // first el always 1btn, etc..
        buttonArray = [special1Btn, special2Btn, cancelBtn]
        
        return buttonArray
    }
    
    func addContainerView(uiView : UIView) {
        container.setTranslatesAutoresizingMaskIntoConstraints(false)
        container.constrainToSize(CGSizeMake(uiView.bounds.width - 20, uiView.bounds.height - 100))
        
        container.layer.borderWidth = 1.0
        container.layer.borderColor = UIColor.colorWithRGBHex(0x979797, alpha: 1.0).CGColor
        container.backgroundColor = UIColor.whiteColor()
        container.layer.cornerRadius = 8
        
        uiView.addSubview(container)
        
        container.pinAttribute(.Top, toAttribute: .Top, ofItem: uiView, withConstant: 70)
        container.centerInContainerOnAxis(.CenterX)
        
        addTitleLabel()
    }
    
    func addTitleLabel() {
        var titleLabel = UILabel()
        
        titleLabel.text = "Specials"
        titleLabel.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
        titleLabel.font = UIFont(name: "SchoolBell", size: 28)
        
        container.addSubview(titleLabel)
        
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleLabel.pinAttribute(.Top, toAttribute: .Top, ofItem: container, withConstant: 5)
        titleLabel.centerInContainerOnAxis(.CenterX)
    }
    
    func addSpecial1Btn() {
        special1Btn.setTranslatesAutoresizingMaskIntoConstraints(false)
        special1Btn.setImage(UIImage(named: "special1Background"), forState: .Normal)
        
        container.addSubview(special1Btn)
        
        special1Btn.constrainToHeight(150)
        special1Btn.pinAttribute(.Top, toAttribute: .Top, ofItem: container, withConstant: 60)
        special1Btn.pinAttribute(.Left, toAttribute: .Left, ofItem: container, withConstant: 20)
        special1Btn.pinAttribute(.Right, toAttribute: .Right, ofItem: container, withConstant: -20)
    }
    
    func addSpecial2Btn() {
        special2Btn.setTranslatesAutoresizingMaskIntoConstraints(false)
//        special2Btn.setImage(UIImage(named: ""), forState: .Normal)
        
        special2Btn.layer.borderWidth = 1.0
        special2Btn.layer.borderColor = UIColor.colorWithRGBHex(0x979797, alpha: 1.0).CGColor
        special2Btn.layer.cornerRadius = 8
        
        container.addSubview(special2Btn)
        
        special2Btn.constrainToHeight(150)
        special2Btn.pinAttribute(.Top, toAttribute: .Bottom, ofItem: special1Btn, withConstant: 20)
        special2Btn.pinAttribute(.Left, toAttribute: .Left, ofItem: container, withConstant: 20)
        special2Btn.pinAttribute(.Right, toAttribute: .Right, ofItem: container, withConstant: -20)
    }
    
    func addCancelBtn() {
        cancelBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        cancelBtn.setImage(UIImage(named: "cancelBtniPhone"), forState: .Normal)
        
//        if (UIInterfaceOrientationIsPortrait() {
//            submitBtn.setImage(UIImage(named: "playBtniPhone"), forState: .Normal)
//            submitBtn.constrainToSize(CGSizeMake(screenWidth - 75, 50))
//        } else {
//            submitBtn.setImage(UIImage(named: "playBtniPad"), forState: .Normal)
//            submitBtn.constrainToSize(CGSizeMake(screenWidth - 75, 60))
//        }
        
        container.addSubview(cancelBtn)
        
        cancelBtn.constrainToHeight(50)
        cancelBtn.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: container, withConstant: -10)
        cancelBtn.pinAttribute(.Left, toAttribute: .Left, ofItem: container, withConstant: 10)
        cancelBtn.pinAttribute(.Right, toAttribute: .Right, ofItem: container, withConstant: -10)
    }
    
    func hidePopup(button : UIButton!) {
        button.superview!.removeFromSuperview()
    }
}