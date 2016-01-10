
//  scoreBoard.swift
//  Stripes
//
//  Created by Koop Otten on 27/12/15.
//  Copyright © 2015 KoDev. All rights reserved.
//

import Foundation
import UIKit

class scoreBoardView {
    var gameObject = Game.currentGame()
    let finalScoreView = UIView()
    let uNameLabel = UILabel()
    let uPointsLabel = UILabel()
    let oppNameLabel = UILabel()
    let oppPointsLabel = UILabel()
    var userIsPFUser : Bool = false

    
    func addScoreBoard(container : UIView) -> UIView {
        userIsPFUser = gameObject["user"] as! PFUser == PFUser.currentUser()! ? true : false
        
        let uPoints = userIsPFUser ? gameObject["userPoints"] : gameObject["opponentPoints"]
        let oppPoints = userIsPFUser ? gameObject["opponentPoints"] : gameObject["userPoints"]
        
        let oppName = userIsPFUser ? gameObject["user2FullName"] : gameObject["userFullName"]
        let uName = userIsPFUser ? gameObject["userFullName"] : gameObject["user2FullName"]
        
        let userFullName = (uName as! NSString).componentsSeparatedByString(" ") as NSArray
        let oppFullName = (oppName as! NSString).componentsSeparatedByString(" ") as NSArray
//        
//        print(userIsPFUser)
//        print(gameObject)
//        print(oppName)
//        print(uName)
//        print(userFullName)
//        print(oppFullName)
        
        uNameLabel.text = userFullName[0] as? String
        oppNameLabel.text = oppFullName[0] as? String
        uPointsLabel.text = String(uPoints) as String
        oppPointsLabel.text = String(oppPoints) as String
        
        uNameLabel.textAlignment = .Center
        oppNameLabel.textAlignment = .Center
        uPointsLabel.textAlignment = .Center
        oppPointsLabel.textAlignment = .Center
        
        finalScoreView.addSubview(uNameLabel)
        finalScoreView.addSubview(uPointsLabel)
        finalScoreView.addSubview(oppNameLabel)
        finalScoreView.addSubview(oppPointsLabel)
        
        container.addSubview(finalScoreView)
        
//        finalScoreView.backgroundColor = UIColor.yellowColor()
        
        finalScoreView.translatesAutoresizingMaskIntoConstraints = false
        finalScoreView.constrainToHeight(150)
        
        finalScoreView.pinAttribute(.Left, toAttribute: .Left, ofItem: container, withConstant: 10)
        finalScoreView.pinAttribute(.Right, toAttribute: .Right, ofItem: container, withConstant: -10)
        finalScoreView.pinAttribute(.Top, toAttribute: .Top, ofItem: container, withConstant: 150)
        
        setupTextLabel([uNameLabel, oppNameLabel])

        oppNameLabel.textColor = UIColor.colorWithRGBHex(0xFF0000, alpha: 1.0)
        oppNameLabel.font = UIFont(name: "HanziPen SC", size: 32)
        uNameLabel.font = UIFont(name: "HanziPen SC", size: 32)
        
        uPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        oppPointsLabel.translatesAutoresizingMaskIntoConstraints = false

        uPointsLabel.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
        oppPointsLabel.textColor = UIColor.colorWithRGBHex(0xFF0000, alpha: 1.0)
        
        let screen_width = UIScreen.mainScreen().bounds.size.width - 20
        
        oppNameLabel.constrainToWidth(screen_width / 2)
        uNameLabel.constrainToWidth(screen_width / 2)
        uPointsLabel.constrainToWidth(screen_width / 2)
        oppPointsLabel.constrainToWidth(screen_width / 2)

        uPointsLabel.font = UIFont(name: "HanziPen SC", size: 80)
        oppPointsLabel.font = UIFont(name: "HanziPen SC", size: 80)

        uNameLabel.pinAttribute(.Top, toAttribute: .Top, ofItem: finalScoreView, withConstant: 20)
        uNameLabel.pinAttribute(.Left, toAttribute: .Left, ofItem: finalScoreView, withConstant: 5)
        uPointsLabel.pinAttribute(.Top, toAttribute: .Bottom, ofItem: uNameLabel)
        uPointsLabel.pinAttribute(.Left, toAttribute: .Left, ofItem: uNameLabel)
        uPointsLabel.pinAttribute(.Right, toAttribute: .Right, ofItem: uNameLabel)
        
        oppNameLabel.pinAttribute(.Top, toAttribute: .Top, ofItem: finalScoreView, withConstant: 20)
        oppNameLabel.pinAttribute(.Right, toAttribute: .Right, ofItem: finalScoreView)
        oppPointsLabel.pinAttribute(.Top, toAttribute: .Bottom, ofItem: oppNameLabel)
        oppPointsLabel.pinAttribute(.Left, toAttribute: .Left, ofItem: oppNameLabel)
        oppPointsLabel.pinAttribute(.Right, toAttribute: .Right, ofItem: oppNameLabel)
        
        return finalScoreView
    }
    
    func setupTextLabel(labels : [UILabel]) {
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.constrainToHeight(40)
            label.textColor = UIColor.colorWithRGBHex(0x0079FF, alpha: 1.0)
            label.font = UIFont(name: "HanziPen SC", size: 24)
        }
    }

}