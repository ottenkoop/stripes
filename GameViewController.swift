//
//  GameViewController.swift
//  Stripes
//
//  Created by Koop Otten on 06/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class GameViewController: GameEngineController {
    private var gameViewObject : [AnyObject] = []
    private var userPoints : Int = 0
    private var user2Points : Int = 0
    
    private var allRowsArray : [UIView] = []
    private var allStripesArray : [UIButton] = []
    private var allOpenStripes : [UIButton] = []
    
    func buildView(game : [PFObject], rows : [UIView], stripes : [UIButton]) {
        gameViewObject = game
        
        allRowsArray = rows
        allStripesArray = stripes
        
        loadPlayedStripes()
        loadScoredSquares()
    }
    
    override func setUserPoints() {
    }
    
    func loadPlayedStripes () {
        var game: PFObject = gameViewObject[0] as PFObject
        
        allOpenStripes = allStripesArray
        
        for stripe in game["allStripes"] as NSArray {
            setPlayedStripes(stripe)
        }
    }
    
    func loadScoredSquares () {
        var game: PFObject = gameViewObject[0] as PFObject

        for squareObject in game["allScoredSquares"] as NSArray {
            
            var square: UIView = allRowsArray[squareObject["rowIndex"] as Int].subviews[squareObject["squareIndex"] as Int] as UIView
            if squareObject["userId"] as NSString == PFUser.currentUser().objectId {
                square.backgroundColor = UIColor.greenColor()
            } else {
                square.backgroundColor = UIColor.redColor()
            }
        }
    }
    
    func setPlayedStripes (stripe : AnyObject) {
        var rowIndex : Int = stripe["rowIndex"] as Int
        var squareIndex : Int = stripe["squareIndex"] as Int
        var stripeIndex : Int = stripe["stripeIndex"] as Int
        var stripeBelongsToUser : NSString = stripe["userId"] as NSString
        
        var playedStripe : UIButton = allRowsArray[rowIndex].subviews[squareIndex].subviews[stripeIndex] as UIButton
        
        if stripeBelongsToUser == PFUser.currentUser().objectId {
            playedStripe.backgroundColor = UIColor.greenColor()
        } else {
            playedStripe.backgroundColor = UIColor.redColor()
        }
        
        duplicateOfSelectDoubleHiddenStripe(playedStripe)
        
        playedStripe.selected = true
        playedStripe.userInteractionEnabled = false
        
        allOpenStripes.remove(playedStripe)
    }
    
    func duplicateOfSelectDoubleHiddenStripe(stripe: UIButton) -> UIButton {
        var squareOfStripeTag = stripe.superview!.tag
        var rowOfStripe = stripe.superview!.superview!
        var doubleStripe = UIButton()
        
        if squareOfStripeTag > 0 {
            if stripe.tag == 3 {
                var doubleStripe: UIButton = rowOfStripe.subviews[squareOfStripeTag - 1].subviews[1] as UIButton
                doubleStripe.backgroundColor = UIColor.greenColor()
                doubleStripe.selected = true
                
                return doubleStripe
            }
        }
        
        if rowOfStripe.tag > 0 {
            if stripe.tag == 0 {
                var doubleStripe: UIButton = allRowsArray[rowOfStripe.tag - 1].subviews[squareOfStripeTag].subviews[2] as UIButton
                doubleStripe.backgroundColor = UIColor.greenColor()
                doubleStripe.selected = true
                
                return doubleStripe
            }
        }
        
        return UIButton()
    }
}