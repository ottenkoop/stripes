//
//  stripeHandler.swift
//  Tiles-swift
//
//  Created by Koop Otten on 27/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation


class stripeHandler: PFObject {
    
    class func createStripeObject(rowIndex : Int, squareIndex : Int, stripeIndex : Int) -> NSObject {
        var objectToReturn = [String: AnyObject]()
        
        objectToReturn["rowIndex"] = rowIndex
        objectToReturn["squareIndex"] = squareIndex
        objectToReturn["stripeIndex"] = stripeIndex
        objectToReturn["userId"] = PFUser.currentUser().objectId
        
        return objectToReturn
        
    }
}