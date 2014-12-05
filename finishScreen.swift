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
    
    var container : UIViewController = UIViewController()
    var textView: UITextView = UITextView()
    var continuButton : UIButton = UIButton()
    
    func gameDidFinishWithCurrentUserWinner(uiControl : UIViewController, userTurn : Bool) -> UIButton {
        container.view.backgroundColor = UIColor.greenColor()
        textView.backgroundColor = UIColor.greenColor()
        textView.text = "Congratulations! You won."
        
        var winBtn = defaultContainerSetup(uiControl.view, userTurn: userTurn)

        return winBtn
    }
    
    func gameDidFinishWithOpponentWinner(uiControl : UIViewController, userTurn : Bool) -> UIButton {
        container.view.backgroundColor = UIColor.redColor()
        textView.backgroundColor = UIColor.redColor()
        textView.text = "Uh oh! You've lost this time. Try again!"
        
        var lostBtn = defaultContainerSetup(uiControl.view, userTurn: userTurn)
        
        return lostBtn
    }
    
    func gameDidFinishDraw(uiControl : UIViewController, userTurn : Bool) -> UIButton {
        var drawBtn = defaultContainerSetup(uiControl.view, userTurn: userTurn)

        container.view.backgroundColor = UIColor.orangeColor()
        textView.backgroundColor = UIColor.orangeColor()
        textView.text = "It's a draw. At least you didn't lose this game!"
        
        return drawBtn
    }
    
    func defaultContainerSetup(uiView: UIView, userTurn : Bool) -> UIButton {
        container.view.frame = uiView.frame
        container.view.center = uiView.center
        
        textView.frame = CGRectMake(0, 0, container.view.bounds.width, 100)
        textView.font = UIFont.systemFontOfSize(20)
        textView.center = uiView.center
        textView.textAlignment = .Center
        textView.userInteractionEnabled = false
        var btn = UIButton()
        
        uiView.addSubview(container.view)
        container.view.addSubview(textView)
        
        if userTurn {
            btn = addContinuButton(uiView)
        }
        
        return btn
    }
    
    func addContinuButton(uiView: UIView) -> UIButton {
        continuButton.setTitle("Continue", forState: .Normal)
        continuButton.backgroundColor = UIColor.blueColor()
        
        uiView.addSubview(continuButton)
        
        continuButton.setTranslatesAutoresizingMaskIntoConstraints(false)
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