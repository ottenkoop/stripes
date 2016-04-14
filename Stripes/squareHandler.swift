//
//  SquareHandler.swift
//  Stripes
//
//  Created by Koop Otten on 01/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

class squareHandler : PFObject {
    
    class func addSquareAndRelationToUser(gameId: String, squareIndex : Int, rowIndex : Int)  {
        var newSquare = PFObject(className:"Square")

        newSquare["belongsToUser"] = PFUser.currentUser()
        newSquare["rowIdx"] = rowIndex
        newSquare["squareIdx"] = squareIndex
        newSquare["belongsToGame"] = PFObject(withoutDataWithClassName:"Game", objectId:"\(gameId)")

        println(squareIndex)
        println(rowIndex)
    }
}