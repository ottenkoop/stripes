//
//  LoginView.swift
//  Stripes
//
//  Created by Koop Otten on 15/12/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation
import UIKit

class loginPopupView {
    var container: UIView = UIView()
    var cancelBtn: UIButton = UIButton()
    var fullName : UITextField = UITextField()
    var userName : UITextField = UITextField()
    var passWord : UITextField = UITextField()
    
    func openRegisterLogin(loginView : UIView) {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.constrainToSize(CGSizeMake(loginView.bounds.width - 20, loginView.bounds.height - 100))
        
        container.layer.borderWidth = 1.0
        container.layer.borderColor = UIColor.colorWithRGBHex(0x979797, alpha: 1.0).CGColor
        container.backgroundColor = UIColor.whiteColor()
        container.layer.cornerRadius = 8
        
        loginView.addSubview(container)
        
        container.pinAttribute(.Top, toAttribute: .Top, ofItem: loginView, withConstant: 70)
        container.centerInContainerOnAxis(.CenterX)
        
        addCancelBtn()
        addTextFields()
    }
    
    func addCancelBtn() {
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.setImage(UIImage(named: "cancelBtniPhone"), forState: .Normal)
        
        container.addSubview(cancelBtn)
        
        cancelBtn.constrainToHeight(50)
        cancelBtn.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: container, withConstant: -10)
        cancelBtn.pinAttribute(.Left, toAttribute: .Left, ofItem: container, withConstant: 10)
        cancelBtn.pinAttribute(.Right, toAttribute: .Right, ofItem: container, withConstant: -10)
    }
    
    func addTextFields() {
        fullName.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(fullName)

        fullName.placeholder = "Full name"
        fullName.font = UIFont(name: "HanziPen SC", size: 18)
        fullName.textAlignment = .Center
        fullName.constrainToSize(CGSizeMake(200, 50))
        fullName.centerInContainerOnAxis(.CenterX)
        fullName.pinAttribute(.Top, toAttribute: .Top, ofItem: container, withConstant: 100)
        
        userName.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(userName)
        
        userName.placeholder = "Username"
        userName.font = UIFont(name: "HanziPen SC", size: 18)
        userName.textAlignment = .Center
        userName.constrainToSize(CGSizeMake(200, 50))
        userName.centerInContainerOnAxis(.CenterX)
        userName.pinAttribute(.Top, toAttribute: .Bottom, ofItem: fullName, withConstant: 10)
    }
}