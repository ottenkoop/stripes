////
////  GameViewController.swift
////  Stripes
////
////  Created by Koop Otten on 06/11/14.
////  Copyright (c) 2014 KoDev. All rights reserved.
////
//
//import Foundation
//
//class gameViewBuilder {
//    var engineScreen : UIViewController = UIViewController()
////    private var gameViewObject : [AnyObject] = []
////    
////    private var allRowsArray : [UIView] = []
////    private var allSquaresArray : [UIView] = []
////    private var allStripesArray : [UIButton] = []
////    private var allOpenStripes : [UIButton] = []
////    private var openStripesCount : Int = 0
////    
////    private var userPoints : Int = 0
////    private var opponentPoints : Int = 0
//    
//    func buildView(engineController : UIViewController) {
//        engineScreen = engineController
//        
////        gameViewObject = game
////        userPoints = userpoints
////        opponentPoints = oppPoints
////        
////        allRowsArray = rows
////        openStripesCount = openStripes
////        allStripesArray = stripes
////        
////        loadPlayedStripes()
////        loadScoredSquares()
////        
////        checkIfGameIsFinished()
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUserPoints", name: "userScoredAPoint", object: nil)
//    }
//    
//    
//    func checkIfGameIsFinished(uiView : UIView) {
////        finishScreen().gameDidFinishWithCurrentUserWinner(uiView)
////        if openStripesCount == 0 {
////            println("game Finished")
////
////        }
//    }
////    
////    func updateUserPoints () {
////        userPoints += 1
////        openStripesCount -= 1
////        
////        checkIfGameIsFinished()
////    }
////    
////    func loadPlayedStripes () {
////        var game: PFObject = gameViewObject[0] as PFObject
////        var stripesArray = game["allStripes"] as NSArray
////        
////        allOpenStripes = allStripesArray
////        
////        for stripe in stripesArray {
////            if stripe as NSObject == stripesArray.lastObject! as NSObject {
////                setPlayedStripes(stripe, lastObject: true)
////            } else {
////                setPlayedStripes(stripe, lastObject: false)
////            }
////        }
////    }
////    
////    func loadScoredSquares () {
////        var game: PFObject = gameViewObject[0] as PFObject
////
////        for squareObject in game["allScoredSquares"] as NSArray {
////            
////            var square: UIView = allRowsArray[squareObject["rowIndex"] as Int].subviews[squareObject["squareIndex"] as Int] as UIView
////            
////            if squareObject["userId"] as NSString == PFUser.currentUser().objectId {
////                square.backgroundColor = UIColor.greenColor()
////            } else {
////                square.backgroundColor = UIColor.redColor()
////            }
////        }
////    }
////    
////    func setPlayedStripes (stripe : AnyObject, lastObject : Bool) {
////        var rowIndex : Int = stripe["rowIndex"] as Int
////        var squareIndex : Int = stripe["squareIndex"] as Int
////        var stripeIndex : Int = stripe["stripeIndex"] as Int
////        var stripeBelongsToUser : NSString = stripe["userId"] as NSString
////        
////        var playedStripe : UIButton = allRowsArray[rowIndex].subviews[squareIndex].subviews[stripeIndex] as UIButton
////        
////        if stripeBelongsToUser == PFUser.currentUser().objectId {
////            playedStripe.backgroundColor = UIColor.greenColor()
////        } else if lastObject {
////            playedStripe.backgroundColor = UIColor.yellowColor()
////        } else {
////            playedStripe.backgroundColor = UIColor.redColor()
////        }
////        
////        var doublePlayedStripe = duplicateOfSelectDoubleHiddenStripe(playedStripe)
////        
////        playedStripe.selected = true
////        playedStripe.userInteractionEnabled = false
////        
////        openStripesCount -= 1
////        allOpenStripes.remove(playedStripe)
////        allOpenStripes.remove(doublePlayedStripe)
////    }
////    
////    func duplicateOfSelectDoubleHiddenStripe(stripe: UIButton) -> UIButton {
////        var squareOfStripeTag = stripe.superview!.tag
////        var rowOfStripe = stripe.superview!.superview!
////        var doubleStripe = UIButton()
////        
////        if squareOfStripeTag > 0 {
////            if stripe.tag == 3 {
////                var doubleStripe: UIButton = rowOfStripe.subviews[squareOfStripeTag - 1].subviews[1] as UIButton
////                doubleStripe.backgroundColor = UIColor.greenColor()
////                doubleStripe.selected = true
////                
////                return doubleStripe
////            }
////        }
////        
////        if rowOfStripe.tag > 0 {
////            if stripe.tag == 0 {
////                var doubleStripe: UIButton = allRowsArray[rowOfStripe.tag - 1].subviews[squareOfStripeTag].subviews[2] as UIButton
////                doubleStripe.backgroundColor = UIColor.greenColor()
////                doubleStripe.selected = true
////                
////                return doubleStripe
////            }
////        }
////        
////        return UIButton()
////    }
//}