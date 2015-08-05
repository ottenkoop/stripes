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
    var titleLabel = UILabel()
    var centerInformationText = UIView()
    var informationToSpace : [UIView] = []
    
    var yesButton : UIButton = UIButton()
    var resetBtn : UIButton = UIButton()
    let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
    var containerWidth : CGFloat = CGFloat()
    
    func openPopup(overViewController : UIViewController, uPoints : Int, oppPoints : Int, oppName : NSString) -> [UIButton] {
        overViewControl = overViewController
        
        addContainerView(overViewControl.view)
        
        overViewController.navigationController?.setNavigationBarHidden(true, animated: true)
        var textView = UIView()
        
        if uPoints > oppPoints {
            textView = addWinNotification()
        } else if oppPoints > uPoints {
            textView = addLostNotification()
        } else {
            textView = addDrawNotification()
        }
        
        var scoreView = addScoreBoard(oppName, oppPoints: oppPoints, uPoints: uPoints)
        addYesBtn()
        addResetBtn()
        addRestartText()
        
        informationToSpace += [textView, scoreView]
        centerInformationText.spaceViews(informationToSpace, onAxis: .Vertical)
        
        return [yesButton, resetBtn]
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
        background.bringSubviewToFront(container)
        
        container.pulseToSize(1.1, duration: 0.4, repeat: false)
        
        if (UIInterfaceOrientationIsPortrait(overViewControl.interfaceOrientation)) {
            containerWidth = uiView.bounds.width - 20
            container.constrainToSize(CGSizeMake(uiView.bounds.width - 20, screenHeight - 50))
            container.centerInContainerOnAxis(.CenterX)
        } else {
            container.constrainToSize(CGSizeMake(500, uiView.bounds.height - 130))
            container.centerInContainerOnAxis(.CenterX)
            containerWidth = 500
        }
        
        container.pinAttribute(.Top, toAttribute: .Top, ofItem: uiView, withConstant: 30)

        addContainerInformationView()
        
        addTitleLabel()
    }
    
    func addContainerInformationView() {
        container.addSubview(centerInformationText)
        container.bringSubviewToFront(centerInformationText)
        
        centerInformationText.setTranslatesAutoresizingMaskIntoConstraints(false)
        centerInformationText.pinAttribute(.Left, toAttribute: .Left, ofItem: container)
        centerInformationText.pinAttribute(.Right, toAttribute: .Right, ofItem: container)
        centerInformationText.pinAttribute(.Top, toAttribute: .Top, ofItem: container, withConstant: 75)
        centerInformationText.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: container, withConstant: -125)
    }
    
    func addTitleLabel() {
        titleLabel.text = "Time's Up!"
        titleLabel.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
        titleLabel.font = UIFont(name: "HanziPen SC", size: 36)
        
        container.addSubview(titleLabel)
        
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        titleLabel.pinAttribute(.Top, toAttribute: .Top, ofItem: container, withConstant: 10)
        titleLabel.centerInContainerOnAxis(.CenterX)
    }
    
    func addWinNotification() -> UIView {
        var textView = UIView()
        var awesomeTextLabel = UILabel()
        var wonTextLabel = UILabel()
        
        awesomeTextLabel.text = "Awesome!"
        wonTextLabel.text = "You've won this round."
        
        textView.addSubview(awesomeTextLabel)
        textView.addSubview(wonTextLabel)
        
        setupTextLabel([awesomeTextLabel, wonTextLabel])

        centerInformationText.addSubview(textView)
        
        textView.setTranslatesAutoresizingMaskIntoConstraints(false)
        textView.constrainToHeight(150)
//        textView.pinAttribute(.Top, toAttribute: .Bottom, ofItem: centerInformationText, withConstant: 10)
        textView.pinAttribute(.Left, toAttribute: .Left, ofItem: container)
        textView.pinAttribute(.Right, toAttribute: .Right, ofItem: container)
//        textView.centerInContainerOnAxis(.CenterX)
        
        awesomeTextLabel.pinAttribute(.Top, toAttribute: .Top, ofItem: textView)
        wonTextLabel.pinAttribute(.Top, toAttribute: .Bottom, ofItem: awesomeTextLabel, withConstant: 0)
        awesomeTextLabel.centerInContainerOnAxis(.CenterX)
        wonTextLabel.centerInContainerOnAxis(.CenterX)
        
        return textView
    }
    
    func addLostNotification() -> UIView {
        var textView = UIView()
        var UhOhTextLabel = UILabel()
        var lostTextLabel = UILabel()
        
        UhOhTextLabel.text = "Uh Oh!"
        lostTextLabel.text = "You've lost this round."

        textView.addSubview(UhOhTextLabel)
        textView.addSubview(lostTextLabel)
        
        setupTextLabel([UhOhTextLabel, lostTextLabel])
        UhOhTextLabel.textColor = UIColor.colorWithRGBHex(0xFF0000, alpha: 1.0)
        lostTextLabel.textColor = UIColor.colorWithRGBHex(0xFF0000, alpha: 1.0)
        
        centerInformationText.addSubview(textView)
        
        textView.setTranslatesAutoresizingMaskIntoConstraints(false)
        textView.constrainToHeight(150)
//        textView.pinAttribute(.Top, toAttribute: .Bottom, ofItem: titleLabel, withConstant: 10)
        textView.pinAttribute(.Left, toAttribute: .Left, ofItem: container)
        textView.pinAttribute(.Right, toAttribute: .Right, ofItem: container)
        textView.centerInContainerOnAxis(.CenterX)
        
        UhOhTextLabel.pinAttribute(.Top, toAttribute: .Top, ofItem: textView)
        lostTextLabel.pinAttribute(.Top, toAttribute: .Bottom, ofItem: UhOhTextLabel, withConstant: 0)
        UhOhTextLabel.centerInContainerOnAxis(.CenterX)
        lostTextLabel.centerInContainerOnAxis(.CenterX)
        
        return textView
    }
    
    func addDrawNotification() -> UIView {
        var textView = UIView()
        var drawTextLabel = UILabel()
        var textLabel = UILabel()
        
        drawTextLabel.text = "It's a draw."
        textLabel.text = "Well, at least you didn't lose."
        
        textView.addSubview(drawTextLabel)
        textView.addSubview(textLabel)
        
        setupTextLabel([drawTextLabel, textLabel])
        
        centerInformationText.addSubview(textView)
        
        textView.setTranslatesAutoresizingMaskIntoConstraints(false)
        textView.constrainToHeight(150)
//        textView.pinAttribute(.Top, toAttribute: .Bottom, ofItem: titleLabel, withConstant: 10)
        textView.pinAttribute(.Left, toAttribute: .Left, ofItem: container)
        textView.pinAttribute(.Right, toAttribute: .Right, ofItem: container)
//        textView.centerInContainerOnAxis(.CenterX)
        
        drawTextLabel.pinAttribute(.Top, toAttribute: .Top, ofItem: textView)
        textLabel.pinAttribute(.Top, toAttribute: .Bottom, ofItem: drawTextLabel, withConstant: 0)
        drawTextLabel.centerInContainerOnAxis(.CenterX)
        textLabel.centerInContainerOnAxis(.CenterX)
        
        return textView
    }
    
    func setupTextLabel(labels : [UILabel]) {
        for label in labels {
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            label.constrainToHeight(40)
            label.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
            label.font = UIFont(name: "HanziPen SC", size: 24)
        }
    }
    
    func addScoreBoard(oppName : NSString, oppPoints : Int, uPoints : Int) -> UIView {
        var finalScoreView = UIView()
        var uNameLabel = UILabel()
        var uPointsLabel = UILabel()
        var oppNameLabel = UILabel()
        var oppPointsLabel = UILabel()
        
        var userName = ""
        var userFullName = (PFUser.currentUser()["fullName"] as! NSString).componentsSeparatedByString(" ") as NSArray
        var lastUName = userFullName.lastObject as! String
        var lastULetter = lastUName[lastUName.startIndex]
        
        userName = "\(userFullName[0]) \(lastULetter)."
        
        var opponentName = ""
        var oppFullName = (oppName as NSString).componentsSeparatedByString(" ") as NSArray
        var lastName = oppFullName.lastObject as! String
        var lastLetter = lastName[lastName.startIndex]
        
        opponentName = "\(oppFullName[0]) \(lastLetter)."
        
        uNameLabel.text = userName
        oppNameLabel.text = opponentName
        uPointsLabel.text = String(uPoints) as String
        oppPointsLabel.text = String(oppPoints) as String
        
        uNameLabel.textAlignment = .Center
        oppNameLabel.textAlignment = .Center
        uPointsLabel.textAlignment = .Center
        oppPointsLabel.textAlignment = .Center

        centerInformationText.addSubview(finalScoreView)
        
        finalScoreView.addSubview(uNameLabel)
        finalScoreView.addSubview(uPointsLabel)
        finalScoreView.addSubview(oppNameLabel)
        finalScoreView.addSubview(oppPointsLabel)
        
        finalScoreView.setTranslatesAutoresizingMaskIntoConstraints(false)
        finalScoreView.constrainToHeight(150)

        finalScoreView.pinAttribute(.Left, toAttribute: .Left, ofItem: container, withConstant: 20)
        finalScoreView.pinAttribute(.Right, toAttribute: .Right, ofItem: container, withConstant: -20)
        
        setupTextLabel([uNameLabel, oppNameLabel])
        oppNameLabel.textColor = UIColor.colorWithRGBHex(0xFF0000, alpha: 1.0)
        oppNameLabel.font = UIFont(name: "HanziPen SC", size: 32)
        uNameLabel.font = UIFont(name: "HanziPen SC", size: 32)
        
        uPointsLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        oppPointsLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        uPointsLabel.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
        oppPointsLabel.textColor = UIColor.colorWithRGBHex(0xFF0000, alpha: 1.0)
        
        oppNameLabel.constrainToWidth(containerWidth / 2)
        uNameLabel.constrainToWidth(containerWidth / 2)
        uPointsLabel.constrainToWidth(containerWidth / 2)
        oppPointsLabel.constrainToWidth(containerWidth / 2)
        
        uPointsLabel.font = UIFont(name: "HanziPen SC", size: 80)
        oppPointsLabel.font = UIFont(name: "HanziPen SC", size: 80)
        
        oppNameLabel.pinAttribute(.Top, toAttribute: .Top, ofItem: finalScoreView, withConstant: 20)
        oppNameLabel.pinAttribute(.Left, toAttribute: .Left, ofItem: container, withConstant: 5)
        uNameLabel.pinAttribute(.Top, toAttribute: .Top, ofItem: finalScoreView, withConstant: 20)
        uNameLabel.pinAttribute(.Left, toAttribute: .Right, ofItem: oppNameLabel, withConstant: -5)
        
        oppPointsLabel.pinAttribute(.Top, toAttribute: .Bottom, ofItem: oppNameLabel)
        oppPointsLabel.pinAttribute(.Left, toAttribute: .Left, ofItem: oppNameLabel)
        
        uPointsLabel.pinAttribute(.Top, toAttribute: .Bottom, ofItem: uNameLabel)
        uPointsLabel.pinAttribute(.Left, toAttribute: .Left, ofItem: uNameLabel)
        
        return finalScoreView
    }

    func addYesBtn() -> UIButton {
        yesButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        yesButton.setImage(UIImage(named: "yesBtn"), forState: .Normal)
        
        container.addSubview(yesButton)
        
        yesButton.constrainToHeight(50)
        yesButton.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: container, withConstant: -10)
        yesButton.pinAttribute(.Left, toAttribute: .Left, ofItem: container, withConstant: 15)
        
        return yesButton
    }
    
    func addResetBtn() -> UIButton {
        resetBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        resetBtn.setImage(UIImage(named: "noBtn"), forState: .Normal)
        
        container.addSubview(resetBtn)
        
        resetBtn.constrainToHeight(50)
        resetBtn.pinAttribute(.Bottom, toAttribute: .Bottom, ofItem: container, withConstant: -10)
        resetBtn.pinAttribute(.Right, toAttribute: .Right, ofItem: container, withConstant: -15)
        
        return resetBtn
    }
    
    func addRestartText() {
        var restartText = UILabel()
        
        restartText.text = "Play again?"
        container.addSubview(restartText)
        
        restartText.font = UIFont(name: "HanziPen SC", size: 28)
        restartText.setTranslatesAutoresizingMaskIntoConstraints(false)
        restartText.pinAttribute(.Bottom, toAttribute: .Top, ofItem: yesButton, withConstant: -10)
        
        restartText.centerInContainerOnAxis(.CenterX)
    }
    
    func removePopup(button : UIButton) {
        button.superview!.superview!.superview!.removeFromSuperview()
    }
    
    func cancelPopup(button : UIButton) {
        button.superview!.superview!.removeFromSuperview()
    }
}