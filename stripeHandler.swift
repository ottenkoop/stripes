//
//  stripeHandler.swift
//  Tiles-swift
//
//  Created by Koop Otten on 27/10/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation


class stripeHandler: PFObject {
    
    class func addNewStripe(opponent : String, rowIndex : Int, squareIndex : Int, stripeIndex : Int, gameId : String){
        var newStripe = PFObject(className:"Stripe")
        
        newStripe["user"] = PFUser.currentUser()
        newStripe["rowIdx"] = rowIndex
        newStripe["squareIdx"] = squareIndex
        newStripe["stripeIdx"] = stripeIndex
        newStripe["belongsToGame"] = PFObject(withoutDataWithClassName:"Game", objectId:"\(gameId)")
        
        newStripe.saveInBackgroundWithBlock ({
            (succeeded: Bool!, err: NSError!) -> Void in
            println(err)
        })
    }
}