//
//  stripeHandler.swift
//  Tiles-swift
//
//  Created by Koop Otten on 27/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation


class stripeHandler: PFObject {
    
    class func addNewStripe(rowIndex : Int, squareIndex : Int, stripeIndex : Int, game : PFObject){

        var stripeObject = createStripeObject(rowIndex, squareIndex: squareIndex, stripeIndex: stripeIndex)
        var newArrayToSubmit : [AnyObject] = []
        
        for alreadyPlayedStripe in game["allStripes"] as NSArray {
            newArrayToSubmit += [alreadyPlayedStripe]
        }
        
        newArrayToSubmit += [stripeObject]
        
        game["allStripes"] = newArrayToSubmit
        
        game.saveEventually()
    }
    
    class func createStripeObject(rowIndex : Int, squareIndex : Int, stripeIndex : Int) -> NSObject {
        var objectToReturn = [String: AnyObject]()
        
        objectToReturn["rowIndex"] = rowIndex
        objectToReturn["squareIndex"] = squareIndex
        objectToReturn["stripeIndex"] = stripeIndex
        objectToReturn["userId"] = PFUser.currentUser().objectId
        
        return objectToReturn
        
    }
}