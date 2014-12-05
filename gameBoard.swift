//
//  gameBoard.swift
//  Stripes
//
//  Created by Koop Otten on 13/11/14.
//  Copyright (c) 2014 KoDev. All rights reserved.
//

import Foundation

enum StripeType : UInt8 {
    case Top =         0b0001
    case Right =       0b0010
    case Bottom =      0b0100
    case Left =        0b1000
}

class Square {
    var content : UInt8 = 0

    func placeStripe (stripe: StripeType) {
        content = content | stripe.rawValue
    }

    func isStripeSelected (stripe: StripeType) -> Bool {
        return content & stripe.rawValue > 0
    }
    
    func isSquareSelected () -> Bool {
        return content == 15
    }
    
    func isSquareGettingSelected(stripe : StripeType) -> Bool {
        var newContent = content | stripe.rawValue
        
        return newContent == 15
    }
    
    func loadSquareFromBackend(stripe: UInt8) {
        content = content | stripe
    }
}

class Board {
    var board : [[Square]] = []
    
    init (dimension : Int) {
        for index in 0..<dimension {
            var row : [Square] = []
            
            for index2 in 0 ..< dimension {
                row.append (Square())
            }
            
            board.append(row)
        }
    }
    
    func placeStripe (x:Int, y:Int, stripe: StripeType) {
        board[x][y].placeStripe(stripe)

        // Magic
        
        // verstuur notificatie met veranderde square
        NSNotificationCenter.defaultCenter().postNotificationName("", object: nil)
    }
    
    func loadSquareFromBackend(boardArray : [[Int]]) {
        for (rowIndex, row) in enumerate(boardArray) {
            for (index, square) in enumerate(row) {
                board[rowIndex][index].loadSquareFromBackend(UInt8(square))
            }
        }
    }
    
    func isGameFinished(uBoard : Board, opBoard : Board, dimension : Int) -> Bool {
        let b = Board(dimension: dimension)
        b.loadSquareFromBackend(uBoard.toString(uBoard.board))
        b.loadSquareFromBackend(opBoard.toString(opBoard.board))
        
        var values : [Int] = []

        for row in b.board {
            for s in row {
                values += [Int(s.content)]
            }
        }

        if values.min() < 15 {
            return false
        } else {
            return true
        }
    }

    func toString (board : [[Square]]) -> [[Int]] {
        var newArray : [[Int]] = [[Int]]()
        
        for (index, b) in enumerate(board) {
            var row : [Int] = []
            
            for s in b {
                row.append (Int(s.content))
            }
            
            newArray.append(row)
        }
        
        return newArray
    }
}